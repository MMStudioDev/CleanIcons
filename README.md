# CleanIcons

**CleanIcons** is a lightweight batch utility for Windows 10 and Windows 11 designed to remove or restore desktop shortcut arrows and administrator shield overlays on icons, giving your desktop a cleaner, more minimal look.

---

## 🚀 Features

* **Shortcut Arrow Removal:** Hides the small arrow overlay on shortcut icons (Shell Icon `29`).
* **Admin Shield Removal:** Hides the UAC administrator shield overlay on shortcuts running as administrator (Shell Icon `77`).
* **Automatic Icon Generation:** If a `blank.ico` file is missing, the script generates a transparent multi-size icon automatically via PowerShell.
* **Icon Cache Renewal:** Automatically restarts `explorer.exe` and purges the Windows icon cache to ensure changes take effect immediately.
* **Easy Restoration:** Easily revert changes back to Windows defaults at any time.
* **Self-Elevating:** Automatically requests Administrator privileges if launched normally.

---

## 📥 Installation & Usage

1. **Download the Release:**
   * Navigate to the **Releases** section on the right side of this repository page (or under the Releases tab).
   * Download the latest `.zip` file release.

2. **Extract the Files:**
   * Extract the contents of the `.zip` file to a folder of your choice on your computer.

3. **Run the Script:**
   * Right-click `CleanIcons.bat` and select **Run as administrator** (or double-click to let it request elevated privileges).
   * Choose an option from the menu to apply or restore overlay settings.

---

## 🛠️ How It Works

Windows manages system icon overlays using registry keys under:
`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons`

* **Shortcut Arrow:** Handled by string value `29`
* **Admin Shield:** Handled by string value `77`

When an overlay is hidden, the script sets the corresponding registry key to point to a fully transparent `.ico` file located in `%windir%\blank.ico`. Upon restoring defaults, the registry keys are removed and the icon cache is cleared.

---

## ⚠️ Requirements

* **OS:** Windows 10 or Windows 11
* **Permissions:** Administrator rights (required to modify `HKLM` registry entries)