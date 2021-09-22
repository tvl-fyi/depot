{ depot, pkgs, ... }:

let
  inherit (pkgs) graphviz runCommandNoCC writeText;

  tvlGraph = runCommandNoCC "tvl.svg" {
    nativeBuildInputs = with pkgs; [ fontconfig freetype cairo jetbrains-mono ];
  } ''
    ${graphviz}/bin/neato -Tsvg ${./tvl.dot} > $out
  '';

  homepage = depot.web.tvl.template {
    title = "The Virus Lounge";
    content = ''
      The Virus Lounge
      ================

      -------

      ![The Virus Lounge](/static/virus_lounge.webp)

      Welcome to **The Virus Lounge**. We're a random group of
      people who feel undersocialised in these trying times, and
      we've decided that there isn't enough spontaneous socialising
      on the internet.

      <hr>

      ## Where did all these people come from?

      It's pretty straightforward. Feel free to click on people, too.

      <div class="tvl-graph-container">
        <!--
          cheddar leaves HTML inside of HTML alone,
          so wrapping the SVG prevents it from messing it up
        -->
        ${builtins.readFile tvlGraph}
      </div>
    '';
    extraHead = ''
      <style>
        .tvl-graph-container {
          max-width: inherit;
        }

        .tvl-graph-container svg {
          max-width: inherit;
          height: auto;
        }
      </style>
    '';
  };
in runCommandNoCC "website" {} ''
  mkdir $out
  cp ${homepage} $out/index.html
  cp -r ${depot.web.static} $out/static
''
