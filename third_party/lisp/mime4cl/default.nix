# Copyright (C) 2021 by the TVL Authors
# SPDX-License-Identifier: LGPL-2.1-or-later
{ depot, pkgs, ... }:

depot.nix.buildLisp.library {
  name = "mime4cl";

  deps = [
    depot.third_party.lisp.babel
    depot.third_party.lisp.npg
    depot.third_party.lisp.trivial-gray-streams
  ];

  srcs = [
    ./ex-sclf.lisp
    ./package.lisp
    ./endec.lisp
    ./streams.lisp
    ./mime.lisp
    ./address.lisp
  ];

  tests = {
    name = "mime4cl-tests";

    srcs = [
      ./test/rt.lisp
      ./test/package.lisp
      (pkgs.writeText "nix-samples.lisp" ''
        (in-package :mime4cl-tests)

        ;; missing from the tarball completely
        (defvar *samples-directory* (pathname "/this/does/not/exist"))
        ;; override auto discovery which doesn't work in store
        (defvar *sample1-file* (pathname "${./test/sample1.msg}"))
      '')
      ./test/temp-file.lisp
      ./test/endec.lisp
      ./test/address.lisp
      ./test/mime.lisp
    ];

    expression = "(rtest:do-tests)";
  };

  # limited by sclf
  brokenOn = [
    "ccl"
    "ecl"
  ];
}
