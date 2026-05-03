{
  outputs =
    { self }:
    {
      nixosModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.boot.plymouthCircle;
        in
        {
          options.boot.plymouthCircle = {
            enable = lib.mkEnableOption "material design circle plymouth theme";

            circle = {
              wavy = lib.mkEnableOption "wavy style for circle";

              red = {
                type = lib.types.ints.between 0 255;
                default = 10;
                description = "Red channel (0-255)";
              };
              green = lib.mkOption {
                type = lib.types.ints.between 0 255;
                default = 10;
                description = "Green channel (0-255)";
              };
              blue = lib.mkOption {
                type = lib.types.ints.between 0 255;
                default = 10;
                description = "Blue channel (0-255)";
              };
            };

            logo = {
              scale = lib.mkOption {
                type = lib.types.str;
                default = "0.3";
                description = "Logo scale";
              };
              path = lib.mkOption {
                type = lib.types.path;
                default = "${self}/images/logo.png";
                defaultText = lib.literalExpression ''"''${self}/images/logo.png"'';
                description = "Path to a logo .png for the theme";
              };
            };
          };

          config = lib.mkIf cfg.enable (
            let
              plymouthTheme =
                pkgs.runCommand "plymouth-theme-material-design-circle"
                  {
                    nativeBuildInputs = [ pkgs.ffmpeg ];
                    inherit (cfg.circle) red green blue;
                    wavy = lib.boolToString cfg.circle.wavy;
                    logo = cfg.logo.path;
                    scale = cfg.logo.scale;
                  }
                  ''
                    THEME_NAME="material_design_circle"
                    THEME_DIR="$out/share/plymouth/themes/$THEME_NAME"
                    mkdir -p $THEME_DIR/images
                    cp ${self}/theme.plymouth $THEME_DIR/$THEME_NAME.plymouth
                    cp ${self}/theme.script   $THEME_DIR/$THEME_NAME.script
                    cp "$logo"                $THEME_DIR/images/logo.png
                    sed -i "s/^reduction.*/reduction = $scale/" "$THEME_DIR/$THEME_NAME.script"
                    for i in ${self}/images/*.png; do
                      ffmpeg -i "$i" \
                        -vf "colorchannelmixer=rr=$red/255:gg=$green/255:bb=$blue/255" \
                        "$THEME_DIR/images/$(basename "$i")"
                    done
                    ${lib.optionalString cfg.circle.wavy ''
                      for i in ${self}/wave/*.png; do
                        ffmpeg -i "$i" \
                          -vf "colorchannelmixer=rr=$red/255:gg=$green/255:bb=$blue/255" \
                          "$THEME_DIR/images/$(basename "$i")"
                      done
                    ''}
                  '';
            in
            {
              boot = {
                consoleLogLevel = lib.mkDefault 0;
                initrd = {
                  verbose = lib.mkDefault false;
                  systemd.enable = lib.mkDefault true;
                };
                plymouth = {
                  enable = lib.mkDefault true;
                  theme = "material_design_circle";
                  themePackages = [ plymouthTheme ];
                };
                kernelParams = [
                  "quiet"
                  "splash"
                  "udev.log_level=3"
                  "rd.udev.log_level=3"
                  "systemd.show_status=false"
                  "vt.global_cursor_default=0"
                ];
              };
            }
          );
        };
    };
}
