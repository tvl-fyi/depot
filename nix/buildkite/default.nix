# Logic for generating Buildkite pipelines from Nix build targets read
# by //nix/readTree.
#
# It outputs a "YAML" (actually JSON) file which is evaluated and
# submitted to Buildkite at the start of each build.
#
# The structure of the file that is being created is documented here:
#   https://buildkite.com/docs/pipelines/defining-steps
{ pkgs, ... }:

let
  inherit (builtins)
    attrValues
    concatMap
    concatStringsSep
    filter
    foldl'
    length
    mapAttrs
    toJSON;

  inherit (pkgs) lib runCommandNoCC writeText;
in rec {
  # Creates a Nix expression that yields the target at the specified
  # location in the repository.
  #
  # This makes a distinction between normal targets (which physically
  # exist in the repository) and subtargets (which are "virtual"
  # targets exposed by a physical one) to make it clear in the build
  # output which is which.
  mkBuildExpr = target:
    let
      descend = expr: attr: "builtins.getAttr \"${attr}\" (${expr})";
      targetExpr = foldl' descend "import ./. {}" target.__readTree;
      subtargetExpr = descend targetExpr target.__subtarget;
    in if target ? __subtarget then subtargetExpr else targetExpr;

  # Create a pipeline label from the target's tree location.
  mkLabel = target:
    let label = concatStringsSep "/" target.__readTree;
    in if target ? __subtarget
      then "${label}:${target.__subtarget}"
      else label;

  # Skip build steps if their out path has already been built.
  skip = headBranch: target: let
    shouldSkip = with builtins;
      # Only skip in real Buildkite builds
      (getEnv "BUILDKITE_BUILD_ID" != "") &&
      # Always build everything for the canon branch.
      (getEnv "BUILDKITE_BRANCH" != headBranch) &&
      # Discard string context to avoid realising the store path during
      # pipeline construction.
      (pathExists (unsafeDiscardStringContext target.outPath));
    in if shouldSkip then "Target was already built." else false;

  # Create a pipeline step from a single target.
  mkStep = headBranch: skipIfBuilt: target: {
    label = ":nix: ${mkLabel target}";
    skip = if skipIfBuilt then skip headBranch target else false;

    command = let
      drvPath = builtins.unsafeDiscardStringContext target.drvPath;
    in concatStringsSep " " [
      # First try to realise the drvPath of the target so we don't evaluate twice.
      # Nix has no concept of depending on a derivation file without depending on
      # at least one of its `outPath`s, so we need to discard the string context
      # if we don't want to build everything during pipeline construction.
      "nix-store --realise '${drvPath}'"
      # Since we don't gcroot the derivation files, they may be deleted by the
      # garbage collector. In that case we can reevaluate and build the attribute
      # using nix-build.
      "|| (test ! -f '${drvPath}' && nix-build -E '${mkBuildExpr target}' --show-trace)"
    ];

    # Add a dependency on the initial static pipeline step which
    # always runs. This allows build steps uploaded in batches to
    # start running before all batches have been uploaded.
    depends_on = ":init:";
  };

  # Helper function to inelegantly divide a list into chunks of at
  # most n elements.
  #
  # This works by assigning each element a chunk ID based on its
  # index, and then grouping all elements by their chunk ID.
  chunksOf = n: list: let
    chunkId = idx: toString (idx / n + 1);
    assigned = lib.imap1 (idx: value: { inherit value ; chunk = chunkId idx; }) list;
    unchunk = mapAttrs (_: elements: map (e: e.value) elements);
  in unchunk (lib.groupBy (e: e.chunk) assigned);

  # Define a build pipeline chunk as a JSON file, using the pipeline
  # format documented on
  # https://buildkite.com/docs/pipelines/defining-steps.
  makePipelineChunk = chunkId: chunk: rec {
    filename = "chunk-${chunkId}.json";
    path = writeText filename (toJSON {
      steps = chunk;
    });
  };

  # Split the pipeline into chunks of at most 256 steps at once, which
  # are uploaded sequentially. This is because of a limitation in the
  # Buildkite backend which struggles to process more than a specific
  # number of chunks at once.
  pipelineChunks = steps:
    attrValues (mapAttrs makePipelineChunk (chunksOf 256 steps));

  # Create a pipeline structure for the given targets.
  mkPipeline = {
    # HEAD branch of the repository on which release steps, GC
    # anchoring and other "mainline only" steps should run.
    headBranch,

    # List of derivations as read by readTree (in most cases just the
    # output of readTree.gather) that should be built in Buildkite.
    #
    # These are scheduled as the first build steps and run as fast as
    # possible, in order, without any concurrency restrictions.
    drvTargets,

    # Should build steps be skipped (on non-HEAD builds) if the output
    # path has already been built?
    skipIfBuilt ? false,

    # A list of plain Buildkite step structures to run alongside the
    # build for all drvTargets, but before proceeding with any
    # post-build actions such as status reporting.
    #
    # Can be used for things like code formatting checks.
    additionalSteps ? [],

    # A list of plain Buildkite step structures to run after all
    # previous steps succeeded.
    #
    # Can be used for status reporting steps and the like.
    postBuildSteps ? []
  }: let
    mkStep' = mkStep headBranch skipIfBuilt;
    steps =
      # Add build steps for each derivation target.
      (map mkStep' drvTargets)

      # Add additional steps (if set).
      ++ additionalSteps

      # Wait for all previous checks to complete
      ++ [({
        wait = null;
        continue_on_failure = true;
      })]

      # Run post-build steps for status reporting and co.
      ++ postBuildSteps;
    chunks = pipelineChunks steps;
  in runCommandNoCC "buildkite-pipeline" {} ''
    mkdir $out
    echo "Generated ${toString (length chunks)} pipeline chunks"
    ${
      lib.concatMapStringsSep "\n"
        (chunk: "cp ${chunk.path} $out/${chunk.filename}") chunks
    }
  '';
}