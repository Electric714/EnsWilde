<div align="center">
  <img src="https://github.com/YangJiiii/EnsWilde/blob/be10a7d93b70df3b40057f869e6cc82de92bc2f0/MyApp_Dark_1024.png?raw=true" width="120" alt="EnsWilde Logo" />
</div>

# EnsWilde (Mobile)

**EnsWilde** is a tool utilizing `itunesstored` & `bookassetd` exploits, designed for iPhone and iPad running the latest **iOS Version 26.2b1**.

It operates as a standalone on-device application, functioning independently like modern apps. It leverages the `sparserestore` exploit to write data to files situated outside of the intended restore location.

> [!WARNING]
> **DISCLAIMER:**
> I am **not responsible** if your device enters a bootloop. Use this software with caution.
> **Please back up your data before using!**

---

## Features
* **Disable call recording notification sound:** Turns off the audible alert when call recording starts.
* **Change Apple Wallet background image:** Customize the background appearance of Wallet passes/cards.
* **Edit MobileGestalt file (advanced):** Modify MobileGestalt configuration values (for advanced users).
* **Change Passcode background:** Customize the numeric keypad appearance using the `.passthm` interface.
* **On-device patching (no PC required):** Operates as a standalone app after the initial setup.
* **More features coming soon:** Development is ongoing to introduce additional capabilities.

---

## Plugin System (New!)

EnsWilde is evolving into a **plugin-based patching system** to make it easy to add, share, and maintain tweaks without hardcoding everything in Swift.

### Goals
- Turn **every patch** (including new Control Center, Dynamic Island, Status Bar & CC Enhancements, Privacy & Telemetry Blockers) into **loadable JSON** + optional Swift modules.
- Simple patches (MobileGestalt/plist keys & values) defined purely in JSON.
- Complex patches keep custom SwiftUI (e.g. image pickers) via optional conforming modules.
- `PatchLoader` scans `Patches/` on launch and auto-registers toggles in the main UI.
- Community contributions via `Patches/Community/`.

### Implementation Steps Completed
1. ✅ Created `Patches/` folder + `Patches/Community/` subfolder
2. ✅ Defined clean JSON schema in `Patches/patch-template.json` (with fields: title, description, iOS version requirement, patches array for MobileGestalt/plist keys & values, UI toggle type, category, etc.)
3. ✅ Added core files:
   - `Sources/PatchEngine/PatchLoader.swift` (scans Patches/ on launch and auto-registers toggles)
   - `Sources/PatchEngine/PatchModule.swift` (protocol + JSON default impl)
4. ⏳ Refactor 1–2 existing patches (e.g. Wallet background or a simple MobileGestalt one) into JSON proof-of-concept (next)
5. ⏳ Update main UI (ContentView/MainViewWithNavigation) to dynamically load plugins from PatchLoader
6. ✅ Pushed everything + updated README with this guide
7. ⏳ Merge back to develop after testing

### JSON Schema Highlights
See `Patches/patch-template.json` for the full schema and example. Key fields:
- `id`, `title`, `description`
- `iOSVersionMin`, `category` (UI, ControlCenter, DynamicIsland, Privacy, etc.)
- `uiToggleType`: switch | slider | picker
- `patches[]`: array of {targetType, targetPath, key, value, operation}
- `customModule` (optional string for advanced Swift impl)

### How to Add Your Own Plugin

**For simple patches (most new features like CC toggles, telemetry blockers):**

1. Create `Patches/YourPatchID.json` (or in Community/)
2. Fill using the template. Example for a Control Center enhancement:
```json
{
  "id": "cc-hide-some-module",
  "title": "Hide Control Center Module X",
  "description": "Removes a specific module from Control Center via plist/MobileGestalt patch.",
  "iOSVersionMin": "26.2",
  "category": "ControlCenter",
  "uiToggleType": "switch",
  "defaultEnabled": false,
  "requiresRespring": true,
  "patches": [
    {
      "targetType": "Plist",
      "targetPath": "/var/mobile/Library/Preferences/com.apple.springboard.plist",
      "key": "YourCCKeyHere",
      "value": false,
      "operation": "set"
    }
  ]
}
```

**For complex patches (e.g. full Wallet background with custom UI):**
- Use JSON for the data part + set `"customModule": "AppleWalletModule"`
- Implement `Sources/PatchModules/YourModule.swift` conforming to `PatchModule`
- Provide custom `makeCustomView` and `apply()` logic

**Contributing**
- PR against `develop`
- Test on iOS 26.2b1 device with pairing + VPN
- Update `version.json` build number if releasing

This architecture will make adding the requested features (Dynamic Island customizer, Status Bar & CC Enhancements, Feature Flags expansion, Privacy & Telemetry Blockers, AFC File Explorer, etc.) much cleaner and community-friendly.

---

## Usage Guides

### Apple Wallet Background Guide
Step-by-step guide for changing Apple Wallet pass/card backgrounds using EnsWilde:

🔗 https://gist.github.com/YangJiiii/06daf0c2d0fa11002757e501622353ea

---

### Passcode Background Guide
Detailed instructions on customizing the passcode keypad background using `.passthm`:

🔗 https://gist.github.com/YangJiiii/67c6323cf4b7fd8487fcd6e2c8fb4233

---

## Getting Your .mobiledevicepairing File (Impactor)

EnsWilde uses **Impactor** to automatically handle pairing.

🔗 https://github.com/khcrysalis/Impactor

### Steps
1. Download and open **Impactor** on your computer.
2. Connect your iPhone or iPad via USB.
3. In Impactor, select **EnsWilde**.
4. Click **Import**.
5. Impactor will automatically generate and inject the required pairing data.

No manual export or file transfer is required.

---

## Setting Up VPN
1. Download **LocaldevVPN** from the iOS App Store.
2. Enable the VPN inside the app.
3. Launch **EnsWilde**.

---

## Credits

Special thanks to the following for their contributions and support:

* **Carrot1211**: [For cheering me on and supporting me during development](https://x.com/Hihihehe1221)
* **@khanhduytran0**: [SparseBox](https://github.com/khanhduytran0/SparseBox)
* **@Little_34306**: [Original concept for "Disable Call Recording"](https://github.com/34306)
* **@SideStore team**: [`idevice` and C bindings from StikDebug](https://github.com/sidestore)
* **@JJTech0130**: [`SparseRestore` and backup exploit](https://github.com/JJTech0130)
* **@hanakim3945**: [`bl_sbx` exploit files and writeup](https://github.com/hanakim3945)
* **@Lakr233**: [BBackupp](https://github.com/Lakr233/BBackupp)
* **@libimobiledevice**: [Underlying communication libraries](https://github.com/libimobiledevice/libimobiledevice)
* **@PoomSmart**: MobileGestalt dump
* **@paragonarsi**: Apple Wallet Get
* **@iTechExpert21**: Hide Dynamic Island
