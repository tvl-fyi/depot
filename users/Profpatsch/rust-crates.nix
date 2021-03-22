{ depot, pkgs, ... }:
rec {
  cfg-if = pkgs.buildRustCrate {
    pname = "cfg-if";
    crateName = "cfg-if";
    version = "1.0.0";
    sha256 = "1fzidq152hnxhg4lj6r2gv4jpnn8yivp27z6q6xy7w6v0dp6bai9";
  };

  cc = pkgs.buildRustCrate {
    pname = "cc";
    crateName = "cc";
    version = "1.0.66";
    sha256 = "12q71z6ck8wlqrwgi25x3lrryyks9djymswn9b1c6qq0i01jpc1p";
  };

  ascii = pkgs.buildRustCrate {
    pname = "ascii";
    crateName = "ascii";
    version = "1.0.0";
    sha256 = "0gam8xsn981wfa40srsniivffjsfz1pg0xnigmczk9k7azb1ks1m";
  };

  regex-syntax = pkgs.buildRustCrate {
    pname = "regex-syntax";
    crateName = "regex-syntax";
    version = "0.6.22";
    sha256 = "0r00n2dgyixacl1sczqp18gxf0xh7x272hcdp62412lypba2gqyg";
  };

  regex = pkgs.buildRustCrate {
    pname = "regex";
    crateName = "regex";
    version = "1.4.3";
    features = [ "std" ];
    dependencies = [ regex-syntax ];
    sha256 = "0w0b4bh0ng20lf5y8raaxmxj46ikjqpgwy1iggzpby9lhv9vydkp";
  };

  libloading = pkgs.buildRustCrate {
    pname = "libloading";
    crateName = "libloading";
    version = "0.6.7";
    dependencies = [ cfg-if ];
    sha256 = "111d8zsizswnxiqn43vcgnc2ym9spsx1i6pcfp35ca3yw2ixq95j";
  };

  tree-sitter = pkgs.buildRustCrate {
    pname = "tree_sitter";
    crateName = "tree-sitter";
    # buildRustCrate isn’t really smart enough to detect the subdir
    libPath = "binding_rust/lib.rs";
    # and the build.rs is also not where buildRustCrate would find it
    build = "binding_rust/build.rs";
    version = "0.17.1";
    dependencies = [ regex ];
    buildDependencies = [ cc ];
    sha256 = "0jwwbvs4icpra7m1ycvnyri5h3sbw4qrfvgnnvnk72h4w93qhzhr";
  };

  libc = pkgs.buildRustCrate {
    pname = "libc";
    crateName = "libc";
    version = "0.2.82";
    sha256 = "02zgn6c0xwh331hky417lbr29kmvrw3ylxs8822syyhjfjqszvsx";
  };

  bitflags = pkgs.buildRustCrate {
    pname = "bitflags";
    crateName = "bitflags";
    version = "1.2.1";
    sha256 = "0b77awhpn7yaqjjibm69ginfn996azx5vkzfjj39g3wbsqs7mkxg";
  };

  inotify-sys = pkgs.buildRustCrate {
    pname = "inotify-sys";
    crateName = "inotify-sys";
    version = "0.1.5";
    dependencies = [ libc ];
    sha256 = "1yiy577xxhi0j90nbg9nkd8cqwc1xix62rz55jjngvxa5jl5613v";
  };

  inotify = pkgs.buildRustCrate {
    pname = "inotify";
    crateName = "inotify";
    version = "0.9.2";
    edition = "2018";
    dependencies = [ bitflags libc inotify-sys ];
    sha256 = "0fcknyvknglwwk1pdzdlb4m0ry2dym1yx8r5prf2v00pxnjk0hv2";
  };

  httparse = pkgs.buildRustCrate {
    pname = "httparse";
    version = "1.3.4";
    crateName = "httparse";
    sha256 = "0dggj4s0cq69bn63q9nqzzay5acmwl33nrbhjjsh5xys8sk2x4jw";
  };

  version-check = pkgs.buildRustCrate {
    pname = "version-check";
    version = "0.9.2";
    crateName = "version-check";
    sha256 = "1vwvc1mzwv8ana9jv8z933p2xzgj1533qwwl5zr8mi89azyhq21v";
  };

  memchr = pkgs.buildRustCrate {
    pname = "memchr";
    version = "2.3.3";
    crateName = "memchr";
    sha256 = "1ivxvlswglk6wd46gadkbbsknr94gwryk6y21v64ja7x4icrpihw";
  };
  nom = pkgs.buildRustCrate {
    pname = "nom";
    version = "5.1.1";
    crateName = "nom";
    sha256 = "1gb4r6mjwd645jqh02nhn60i7qkw8cgy3xq1r4clnmvz3cmkv1l0";
    dependencies = [ memchr ];
    buildDependencies = [ version-check ];
    features = [ "std" "alloc" ];
  };

  base64 = pkgs.buildRustCrate {
    pname = "base64";
    version = "0.13.0";
    crateName = "base64";
    edition = "2018";
    sha256 = "0i0jk5sgq37kc4c90d1g7dp7zvphbg0dbqc1ajnn0vffjxblgamg";
    features = [ "alloc" "std" ];
  };

  bufstream = pkgs.buildRustCrate {
    pname = "bufstream";
    version = "0.1.4";
    crateName = "bufstream";
    sha256 = "10rqm7jly5jjx7wcc19q6q4m2zsrw3l2v3m1054wnbwvdh42xxf1";
  };

  autocfg = pkgs.buildRustCrate {
    pname = "autocfg";
    version = "1.0.1";
    crateName = "autocfg";
    sha256 = "1lsjz23jdcchcqbsmlzd4iksg3hc8bdvy677jy0938i2gp24frw1";
  };

  num-traits = pkgs.buildRustCrate {
    pname = "num-traits";
    version = "0.2.14";
    crateName = "num-traits";
    buildDependencies = [ autocfg ];
    sha256 = "09ac9dcp6cr57vjzyiy213y7312jqcy84mkamp99zr40qd1gwnyk";
  };

  num-integer = pkgs.buildRustCrate {
    pname = "num-integer";
    version = "0.1.44";
    crateName = "num-integer";
    dependencies = [ num-traits ];
    buildDependencies = [ autocfg ];
    sha256 = "1gdbnfgnivp90h644wmqj4a20yfmdga2xxxacx53pjbcazvfvajc";
  };

  chrono = pkgs.buildRustCrate {
    pname = "chrono";
    version = "0.4.19";
    crateName = "chrono";
    dependencies = [ num-traits num-integer ];
    features = [ "alloc" "std" ];
    sha256 = "0cjf5dnfbk99607vz6n5r6bhwykcypq5psihvk845sxrhnzadsar";
  };

  imap-proto = pkgs.buildRustCrate {
    pname = "imap-proto";
    version = "0.10.2";
    crateName = "imap-proto";
    dependencies = [ nom ];
    sha256 = "1bf5r4d0z7c8wxrvr7kjy26500wr7cd4sxz49ix3b3yzc6ayyqv1";
  };

  lazy_static = pkgs.buildRustCrate {
    pname = "lazy_static";
    version = "1.4.0";
    crateName = "lazy_static";
    sha256 = "13h6sdghdcy7vcqsm2gasfw3qg7ssa0fl3sw7lq6pdkbk52wbyfr";
  };

  imap = pkgs.buildRustCrate {
    pname = "imap";
    version = "2.4.0";
    crateName = "imap";
    edition = "2018";
    dependencies = [
      base64
      bufstream
      chrono
      imap-proto
      lazy_static
      nom
      regex
    ];
    sha256 = "1nj6x45qnid98nv637623rrh7imcxk0kad89ry8j5dkkgccvjyc0";
  };

  epoll = pkgs.buildRustCrate {
    pname = "epoll";
    version = "4.3.1";
    crateName = "epoll";
    dependencies = [ bitflags libc ];
    sha256 = "0dgmgdmrfbjkpxn1w3xmmwsm2a623a9qdwn90s8yl78n4a36kbh9";
  };

}
