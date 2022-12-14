{ depot, ... }:

let
  inherit (depot.fun) clbot;
  inherit (depot.third_party) gopkgs;
in
depot.nix.buildGo.package {
  name = "code.tvl.fyi/fun/clbot/gerrit";
  srcs = [
    ./watcher.go
  ];
  deps = [
    clbot.gerrit.gerritevents
    clbot.backoffutil
    gopkgs."github.com".golang.glog.gopkg
    gopkgs."golang.org".x.crypto.ssh.gopkg
  ];
}
