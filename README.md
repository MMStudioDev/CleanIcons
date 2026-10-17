# CleanIcons

**One-click script to hide the shortcut arrow and the administrator shield on icons in Windows 10 and 11.**

Windows draws small overlays on top of your icons: an arrow on every shortcut, and a blue-and-yellow shield on anything that needs administrator rights. CleanIcons hides either one, or both, and can bring them back whenever you want.

## Features

- Hides the **shortcut arrow** and the **administrator shield**, separately or together
- Works on **Windows 10 and Windows 11**, and detects which one you have
- Shows the current state of each overlay
- Restores the Windows defaults with one choice
- Asks for administrator rights by itself, so you can just double-click it
- Restarts Explorer and clears the icon cache so changes show right away
- One plain `.bat` file you can read and check, with nothing to install

## Usage

1. Download `CleanIcons.bat` (or clone this repository).
2. Double-click it and approve the administrator prompt.
3. Pick an option from the menu:

| Option | Action |
| --- | --- |
| `1` | Remove shortcut arrows |
| `2` | Remove administrator shield |
| `3` | Remove both |
| `4` | Restore shortcut arrows |
| `5` | Restore administrator shield |
| `6` | Restore both |
| `7` | Exit |

Explorer restarts after every change, so your taskbar and desktop will flicker and any open File Explorer windows will close. Save your work in them first.

The menu shows one of three states for each overlay:

| State | Meaning |
| --- | --- |
| `VISIBLE` | Windows default, nothing changed |
| `HIDDEN` | Hidden by CleanIcons |
| `CUSTOM` | Changed by some other tool; choosing Restore removes that change |

## How it works

CleanIcons writes a fully transparent icon to `C:\ProgramData\CleanIcons\blank.ico` and points the Windows overlays at it, using values under:

```
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons
```

| Value name | Overlay |
| --- | --- |
| `29` | Shortcut arrow |
| `77` | Administrator shield |

It uses its own blank icon rather than one from a system file, because the position of built-in icons changes between Windows builds.

**Restore** deletes the matching registry value, so Windows goes back to its default overlay. The `CleanIcons` folder is removed once neither overlay uses it. Nothing else on your system is touched.

If you used an earlier version of this script (`OverlayOff`, `BareIcons` or `DeArrow`), CleanIcons moves you over to the new icon folder the first time it runs.

## Requirements

- Windows 10 or Windows 11
- Administrator rights (the change is made under `HKEY_LOCAL_MACHINE`)

## Troubleshooting

- **An overlay is still visible.** Restart your PC. Some builds only reload overlays at sign-in.
- **It came back after a Windows update.** Feature updates can reset icon settings. Run CleanIcons again.
- **No administrator prompt appears.** Right-click `CleanIcons.bat` and choose **Run as administrator**.
- **Administrator Protection is turned on.** On Windows 11 24H2 and 25H2 this optional setting runs administrator programs under a hidden account, so the icon cache may not be cleared. The change itself still applies; restart your PC to see it.
- **Something went wrong.** Run the script again as administrator. If it still fails, choose a Restore option to return to the defaults.

## Notes

- Hiding the administrator shield only removes the **icon**. Programs that need administrator rights still ask for them, and Windows still shows the permission prompt.
- The shield also appears on some installers and setup files, and those are cleaned up too.
- The script edits the registry. Reading through it before running is always a good idea.
