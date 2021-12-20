{ depot, pkgs, ... }:

let
  src = pkgs.fetchgit {
    url = "https://github.com/nightfly19/cl-arrows.git";
    rev = "cbb46b69a7de40f1161c9caaf6cef93b3af9994f";
    hash = "sha256:0la2vr10510vmx29w9p3sj1qi1sych0crcpy4kdgxzn8m7kqlli0";
  };
in depot.nix.buildLisp.library {
  name = "cl-arrows";
  deps = [];
  srcs = [
    "${src}/packages.lisp"
    "${src}/arrows.lisp"
  ];
}