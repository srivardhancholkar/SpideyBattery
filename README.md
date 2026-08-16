# 🕷️ SpideyBattery

An iOS status-bar tweak that gives the battery a **Spider-Man** look:

- 🔵 **Battery icon → blue**
- 🔴 **Battery percentage → red**

…everywhere it appears — inside apps, on the home screen, and on the lock screen —
and it *stays* red even as iOS tries to recolor it to match your wallpaper.

| Context | Battery | Percentage |
|---------|---------|------------|
| In apps | blue | red |
| Home screen | blue | red |
| Lock screen | blue | red |

## Requirements

- Jailbroken iPhone with a rootless bootstrap: **Dopamine / ElleKit** (tested on iOS 17.0, iPhone 14 Pro / A16, arm64e)
- iOS 15–17

## How it works

The status-bar battery is drawn by `_UIBatteryView` (inside `STUIStatusBarBatteryView`).
The tweak:

1. Forces the icon colors (`setBodyColor:` / `setFillColor:`) to **blue**.
2. Hooks `-_batteryTextIsCutout` to return `NO`, so at high charge the number is rendered
   as **solid text** instead of a see-through knockout of the fill.
3. Tags the internal `_percentageLabel` and hooks `-[UILabel setTextColor:]`, so once tagged
   the number can **never** be recolored away from red — this defeats the home/lock-screen
   *luma tracking* that otherwise repaints status-bar text white/black to match the wallpaper.

See `Tweak.x` — it's small and commented.

## Building

No Mac required — pushing to this repo builds a real **arm64 + arm64e** `.deb` on a macOS
green **Actions** run.

To build locally on a Mac instead:

```sh
export THEOS=~/theos          # https://theos.dev
make package FINALPACKAGE=1    # -> packages/*.deb
```

## Installing

## Sideload via Sileo (recommended, reboot-safe)

A prebuilt package is included at [`releases/SpideyBattery_1.1.0.deb`](releases/SpideyBattery_1.1.0.deb).

1. Get the `.deb` onto the phone (AirDrop, Files, `scp`, or download it from this repo).
2. Open it in **Sileo** → **Install** → **Respring**.

Sileo registers the code-signature with the jailbreak's trust cache, so the tweak reloads
automatically every time you re-jailbreak (Dopamine is semi-untethered — the tweak is simply
gone while booted stock, and returns when you re-run Dopamine).

**Alternatively — Sileo details / CLI**

**Via Sileo** (handles code-signing/trust permanently, survives reboots):
open the `.deb` in Sileo and install, then respring.

**Manual / CLI** (rootless paths shown):

```sh
dpkg -i com.spidey.battery_*.deb
# Dopamine gates dylib loading behind its trust cache; add both slice hashes:
for h in $(ldid -h /var/jb/Library/MobileSubstrate/DynamicLibraries/SpideyBattery.dylib \
           | grep '^CDHash=' | cut -d= -f2); do jbctl trustcache add "$h"; done
killall SpringBoard   # respring (this preserves the trust-cache add; a full sbreload/reboot does not)
```

> ⚠️ The manual `jbctl trustcache add` is **not** persistent across a full reboot. Install via
> Sileo for reboot-safety, otherwise re-add the hashes after a reboot before SpringBoard reloads.

## Uninstalling

```sh
dpkg -r com.spidey.battery && killall SpringBoard
```

## License

Do whatever you like. 🕸️
