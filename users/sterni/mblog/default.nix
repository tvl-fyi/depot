{ depot, pkgs, ... }:

depot.nix.buildLisp.program {
  name = "mnote-html";

  srcs = [
    ./packages.lisp
    ./maildir.lisp
    ./transformer.lisp
    ./note.lisp
    ./cli.lisp
  ];

  deps = [
    {
      sbcl = depot.nix.buildLisp.bundled "uiop";
      default = depot.nix.buildLisp.bundled "asdf";
    }
    depot.third_party.lisp.alexandria
    depot.third_party.lisp.babel
    depot.third_party.lisp.closure-html
    depot.third_party.lisp.cl-date-time-parser
    depot.third_party.lisp.cl-who
    depot.third_party.lisp.mime4cl
  ];

  main = "mblog:main";

  # due to sclf
  brokenOn = [
    "ccl"
    "ecl"
  ];
}
