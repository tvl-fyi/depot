# My Emacs distribution, which is supporting the following platforms:
# - Linux
# - Darwin
#
# USAGE:
#   $ mg build //users/wpcarro/emacs:osx
{ depot, pkgs, lib, ... }:

# TODO(wpcarro): See if it's possible to expose emacsclient on PATH, so that I
# don't need to depend on wpcarros-emacs and emacs in my NixOS configurations.
let
  inherit (depot.third_party.nixpkgs) emacsPackagesFor emacs28;
  inherit (depot.users) wpcarro;
  inherit (lib) mapAttrsToList;
  inherit (lib.strings) concatStringsSep makeBinPath;
  inherit (pkgs) runCommand writeShellScriptBin;

  emacsBinPath = makeBinPath (
    wpcarro.common.shell-utils ++
    # Rust dependencies
    (with pkgs; [
      cargo
      rust-analyzer
      rustc
      rustfmt
    ]) ++
    # Misc dependencies
    (with pkgs; [
      ispell
      nix
      pass
      rust-analyzer
      rustc
      rustfmt
    ] ++
    (if pkgs.stdenv.isLinux then [
      scrot
      xorg.xset
    ] else [ ]))
  );

  emacsWithPackages = (emacsPackagesFor emacs28).emacsWithPackages;

  wpcarrosEmacs = emacsWithPackages (epkgs:
    (with wpcarro.emacs.pkgs; [
      al
      bookmark
      cycle
      list
      macros
      maybe
      set
      string
      struct
      symbol
      theme
      tuple
      vterm-mgt
      zle
    ]) ++

    (with epkgs.tvlPackages; [
      tvl
    ]) ++

    (with epkgs.elpaPackages; [
      exwm
    ]) ++

    (with epkgs.melpaPackages; [
      alert
      all-the-icons
      all-the-icons-ivy
      avy
      base16-theme
      cider
      clojure-mode
      company
      counsel
      counsel-projectile
      csharp-mode
      dap-mode
      dash
      deadgrep
      deferred
      diminish
      direnv
      dockerfile-mode
      doom-themes
      eglot
      elisp-slime-nav
      elixir-mode
      elm-mode
      emojify
      engine-mode
      evil
      evil-collection
      evil-commentary
      evil-surround
      f
      fish-mode
      flycheck
      flymake-shellcheck
      general
      go-mode
      haskell-mode
      helpful
      ivy
      ivy-clipmenu
      ivy-pass
      ivy-prescient
      key-chord
      lispyville
      lsp-ui
      magit
      magit-popup
      markdown-mode
      nix-mode
      notmuch
      org-bullets
      package-lint
      paradox
      parsec
      password-store
      pcre2el
      prettier-js
      projectile
      py-yapf
      racket-mode
      rainbow-delimiters
      reason-mode
      refine
      request
      restclient
      rjsx-mode
      rust-mode
      sly
      suggest
      telephone-line
      terraform-mode
      tide
      ts
      tuareg
      use-package
      vterm
      web-mode
      which-key
      yaml-mode
      yasnippet
    ]));

  loadPath = concatStringsSep ":" [
    ./.emacs.d/wpc
    # TODO(wpcarro): Explain why the trailing ":" is needed.
    "${wpcarrosEmacs.deps}/share/emacs/site-lisp:"
  ];

  # Transform an attrset into "export k=v" statements.
  makeEnvVars = env: concatStringsSep "\n"
    (mapAttrsToList (k: v: "export ${k}=\"${v}\"") env);

  withEmacsPath = { emacsBin, env ? { }, load ? [ ] }:
    writeShellScriptBin "wpcarros-emacs" ''
      export XMODIFIERS=emacs
      export PATH="${emacsBinPath}:$PATH"
      export EMACSLOADPATH="${loadPath}"
      ${makeEnvVars env}
      exec ${emacsBin} \
        --debug-init \
        --no-init-file \
        --no-site-file \
        --no-site-lisp \
        --load ${./.emacs.d/init.el} \
        ${concatStringsSep "\n  " (map (el: "--load ${el} \\") load)}
        "$@"
    '';
in
depot.nix.readTree.drvTargets {
  # TODO(wpcarro): Support this with base.overrideAttrs or something similar.
  nixos = { load ? [ ] }: withEmacsPath {
    inherit load;
    emacsBin = "${wpcarrosEmacs}/bin/emacs";
  };

  osx = writeShellScriptBin "wpcarros-emacs" ''
    export PATH="${emacsBinPath}:$PATH"
    export EMACSLOADPATH="${loadPath}"
    exec ${wpcarrosEmacs}/bin/emacs \
      --debug-init \
      --no-init-file \
      --no-site-file \
      --no-site-lisp \
      --load ${./.emacs.d/init.el} \
      "$@"
  '';

  # Script that asserts my Emacs can initialize without warnings or errors.
  check = runCommand "check-emacs" { } ''
    # Even though Buildkite defines this, I'd still like still be able to test
    # this locally without depending on my ability to remember to set CI=true.
    export CI=true
    export PATH="${emacsBinPath}:$PATH"
    export EMACSLOADPATH="${loadPath}"
    ${wpcarrosEmacs}/bin/emacs \
      --no-site-file \
      --no-site-lisp \
      --no-init-file \
      --script ${./ci.el} \
      ${./.emacs.d/init.el} && \
    touch $out
  '';
}
