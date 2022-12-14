# Python package for controlling the Broadlink RM Pro Infrared
# controller.
#
# https://github.com/mjg59/python-broadlink
{ pkgs, lib, ... }:

let
  inherit (pkgs) fetchFromGitHub;
  inherit (pkgs.python3Packages) buildPythonPackage cryptography;
in
buildPythonPackage (lib.fix (self: {
  pname = "python-broadlink";
  version = "0.13.2";
  src = ./.;
  propagatedBuildInputs = [ cryptography ];
}))
