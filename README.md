# ADBloat
ADBloat ("a debloat") is simple PowerShell wrapper around Android Debug Bridge, created to make the process of debloating your phone easier. By using this tool, you can remove many pre-installed apps on your phone, that can't be uninstalled the normal way (by using the Settings).

Once the bloatware apps are uninstalled, it may help you saving your battery life or protecting your data from them.

## Features
- List installed packages
- Install package (revert uninstall)
- Uninstall package

Planned: option to remove apps in bulk, pre-defined lists of bloatware apps for different phone vendors, DeGoogle list. 

## Usage (steps)
1. Read the notices on the bottom of this README file.
2. Download Android Debug Bridge files from [here](https://dl.google.com/android/repository/platform-tools-latest-windows.zip).
3. Download ADBloat script and put it in the same folder as ADB.
4. Enter "Programmer Settings" on your phone and enable the "USB Debugging" option.
5. Run the script (preferably by opening PowerShell and typing ".\ADBloat.ps1" in the console).
6. Follow the instructions contained in the script.

The script automatically creates log file when you install or uninstall an package to help you when you need to revert the changes.

If you don't see the "Programmer Settings" option on your phone, you may need to go into *Settings > About phone* and just clicking the "Build number" field few times in a row.

---
#### Notice 1: please make sure that you don't uninstall apps (packages) related to the system as it may soft-brick your phone, although most critical apps can't be removed. I am not responsible for that, so backup your data if needed.

#### Notice 2: the apps aren't really removed from your phone, only uninstalled from the user scope. They may still work in the background if they work with system privileges. All uninstalled apps will get restored if you reset your phone using the *Stock recovery* or *Factory reset* option.
