Material design circle plymouth theme for NixOS.

Based on

- [gevera/plymouth-themes](https://github.com/gevera/plymouth_themes)
- [material design m3 progress indicators](https://m3.material.io/components/progress-indicators/specs)

## Installation

```nix
# flake.nix
inputs.plymouth-circle.url = "github:strtab/plymouth-circle";
```

```nix
# configuraion.nix
imports = [ inputs.plymouth-circle.nixosModules.default ];

boot.plymouthCircle = {
  enable = true;
  # logo = ./my-logo.png;
  circle = {
    red   = 98;
    green = 114;
    blue  = 164;
    wavy  = true;
  };
};
```

## Options

---

### `boot.plymouthCircle.enable`

Enable the theme. Default: `false`.

---

### `boot.plymouthCircle.logo.path`

Path to a `.png` file used as the center logo.
Default: `images/logo.png` from the flake.

---

### `boot.plymouthCircle.logo.scale`

Scale size the center logo.
Default: `images/logo.png` from the flake.

---

### `boot.plymouthCircle.circle.red` / `.green` / `.blue`

RGB color of the animated circle. Each channel is an integer from `0` to `255`.
Default: `10` for all channels.

---

### `boot.plymouthCircle.circle.wavy`

Use wavy-style circle frames (`wave/`) instead of the default ones (`normal/`).
Default: `false`.

---

### Installation on regular linux

```sh
git clone --depth 1 https://github.com/strtab/plymouth_material_design_circle-theme.git /tmp/plymouth_material_design_circle
mkdir -p /usr/share/plymouth/themes/material_design_circle/
cp -vr /tmp/plymouth_material_design_circle/ /usr/share/plymouth/themes/material_design_circle/
update-alternatives --config default.plymouth
update-initramfs -u
reboot
```
