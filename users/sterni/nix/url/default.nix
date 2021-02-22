{ depot, lib, ... }:

let

  inherit (depot.users.sterni.nix)
    char
    int
    string
    ;

  reserved = c: builtins.elem c [
    "!" "#" "$" "&" "'" "(" ")"
    "*" "+" "," "/" ":" ";" "="
    "?" "@" "[" "]"
  ];

  unreserved = c: char.asciiAlphaNum c
    || builtins.elem c [ "-" "_" "." "~" ];

  percentEncode = c:
    if unreserved c
    then c
    else "%" + (string.fit {
      width = 2;
      char = "0";
      side = "left";
    } (int.toHex (char.ord c)));

  encode = { leaveReserved ? false }: s:
    let
      chars = lib.stringToCharacters s;
      tr = c:
        if leaveReserved && reserved c
        then c
        else percentEncode c;
    in lib.concatStrings (builtins.map tr chars);

in {
  inherit
    encode
    ;
}
