{ depot, pkgs, ... }:

{ # content of the <title> tag
  title
  # main part of the page, usually wrapped with <main>
, content
  # optional extra html to inject into <head>
, extraHead ? null
  # optional extra html to inject into <footer>
, extraFooter ? null
  # URL at which static assets are located
, staticUrl ? "https://static.tvl.fyi/${depot.web.static.drvHash}"
}@args:

let
  inherit (pkgs) runCommandNoCC lib;
  inherit (depot.tools) cheddar;
in

runCommandNoCC "index.html" {
  headerPart = ''
    <!DOCTYPE html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <meta name="description" content="The Virus Lounge">
      <link rel="stylesheet" type="text/css" href="${staticUrl}/tvl.css" media="all">
      <link rel="icon" type="image/webp" href="${staticUrl}/favicon.webp">
      <title>${title}</title>
  '' + lib.optionalString (args ? extraHead) extraHead + ''
    </head>
    <body class="light">
  '';

  inherit content;

  footerPart = ''
    <hr>
    <footer>
      <p class="footer">
        <a class="uncoloured-link" href="https://at.tvl.fyi/?q=%2F%2FREADME.md">code</a>
        |
        <a class="uncoloured-link" href="https://cl.tvl.fyi/">reviews</a>
        |
        <a class="uncoloured-link" href="https://tvl.fyi/builds">ci</a>
        |
        <a class="uncoloured-link" href="https://b.tvl.fyi/">bugs</a>
        |
        <a class="uncoloured-link" href="https://todo.tvl.fyi/">todos</a>
        |
        <a class="uncoloured-link" href="https://atward.tvl.fyi/">search</a>
        '' + lib.optionalString (args ? extraFooter) extraFooter + ''
      </p>
      <p class="lod">ಠ_ಠ</p>
    </footer>
  </body>
  '';

  passAsFile = [ "headerPart" "content" "footerPart" ];
} ''
  ${cheddar}/bin/cheddar --about-filter content.md < $contentPath > rendered.html
  cat $headerPartPath rendered.html $footerPartPath > $out
''
