{pkgs, ...}: let
  filter_ls = path: ext: (
    builtins.map (name: path + "/${name}") (
      builtins.filter (name: builtins.match ".*\\.${ext}" name != null) (
        builtins.attrNames (builtins.readDir path)
      )
    )
  );

  concat_ls = path: ext: (
    builtins.concatStringsSep "\n" (
      builtins.map (filename: builtins.readFile filename) (
        filter_ls path ext
      )
    )
  );

  attrs_to_env_vars = attrs: (
    pkgs.lib.strings.concatLines (
      map
      (
        key: let
          val = attrs."${key}";
          strVal = builtins.toString val;
        in ''export ${key}="${strVal}"''
      )
      (builtins.attrNames attrs)
    )
  );

  colorToHexWithOpacity = color: opacity: "0x${opacity}${color}";
  colorToHex = color: (colorToHexWithOpacity color "ff");
in {
  inherit attrs_to_env_vars;
  inherit colorToHex;
  inherit colorToHexWithOpacity;
  inherit concat_ls;
  inherit filter_ls;
}
