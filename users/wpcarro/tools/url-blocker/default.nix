{ pkgs, ... }:

let
  ghc = pkgs.haskellPackages.ghcWithPackages (hpkgs: [
    hpkgs.time
    hpkgs.aeson
    hpkgs.either
  ]);

  # This is the systemd service unit
  service = pkgs.stdenv.mkDerivation {
    name = "url-blocker";
    src = builtins.path { path = ./.; name = "url-blocker"; };
    buildPhase = ''
      ${ghc}/bin/ghc Main.hs
    '';
    installPhase = ''
      mv ./Main $out
    '';
  };

  # This is the systemd timer unit.
  # Run once every minute.
  # Give root privilege.
  systemdUnit = {
    systemd = {
      timers.simple-timer = {
        wantedBy = [ "timers.target" ];
        partOf = [ ];
      };
    };
  };
in
null
