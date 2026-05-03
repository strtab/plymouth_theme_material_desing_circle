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
          plymouthTheme =
            pkgs.runCommand "plymouth-theme-material-design-circle" { nativeBuildInputs = [ pkgs.ffmpeg ]; }
              ''
                THEME_NAME="material_design_circle"
                THEME_DIR="$out/share/plymouth/themes/$THEME_NAME"
                mkdir -p $THEME_DIR/images
                cp ${self}/theme.plymouth $THEME_DIR/$THEME_NAME.plymouth
                cp ${self}/theme.script   $THEME_DIR/$THEME_NAME.script
                cp ${cfg.logo.path}       $THEME_DIR/images/logo.png
                sed -i 's/^reduction.*/reduction = ${cfg.logo.scale}/' "$THEME_DIR/$THEME_NAME.script"
                for i in ${self}/images/*.png; do
                  ffmpeg -i "$i" \
                    -vf "colorchannelmixer=rr=${toString cfg.circle.red}/255:gg=${toString cfg.circle.green}/255:bb=${toString cfg.circle.blue}/255" \
                    "$THEME_DIR/images/$(basename "$i")"
                done
                ${lib.optionalString cfg.circle.wavy ''
                  for i in ${self}/wave/*.png; do
                    ffmpeg -i "$i" \
                      -vf "colorchannelmixer=rr=${toString cfg.circle.red}/255:gg=${toString cfg.circle.green}/255:bb=${toString cfg.circle.blue}/255" \
                      "$THEME_DIR/images/$(basename "$i")"
                  done
                ''}
              '';
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

          config = lib.mkIf cfg.enable {
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
          };
        };
    };
}
