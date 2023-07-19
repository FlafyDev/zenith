{
  version,
  src,
  #
  wlroots,
  fetchpatch,
  lib,
  hwdata,
  libliftoff,
  libdisplay-info,
  enableXWayland ? true,
}: (wlroots.overrideAttrs
    (old: {
      inherit version src;
      pname =
        old.pname
        + "-hyprland";
      patches =
        (old.patches or [])
        ++ (lib.optionals enableXWayland [
          # adapted from https://gitlab.freedesktop.org/lilydjwg/wlroots/-/commit/6c5ffcd1fee9e44780a6a8792f74ecfbe24a1ca7
          (fetchpatch {
            url = "https://gitlab.freedesktop.org/wlroots/wlroots/-/commit/18595000f3a21502fd60bf213122859cc348f9af.diff";
            sha256 = "sha256-jvfkAMh3gzkfuoRhB4E9T5X1Hu62wgUjj4tZkJm0mrI=";
            revert = true;
          })
        ]);
      buildInputs = old.buildInputs ++ [hwdata libliftoff libdisplay-info];

      NIX_CFLAGS_COMPILE = toString [
        "-Wno-error=maybe-uninitialized"
      ];
    }))
  .override {
    # xwayland = xwayland.overrideAttrs (old: {
    #   patches =
    #     (old.patches or [])
    #     ++ (lib.optionals hidpiXWayland [
    #       # ./xwayland-vsync.patch
    #       # ./xwayland-hidpi.patch
    #     ]);
    # });
  }
