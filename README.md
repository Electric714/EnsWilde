# EnsWilde (Mobile)

**EnsWilde** is a tool utilizing `itunesstored` & `bookassetd` exploits, designed for iPhone and iPad running the latest **iOS Version 26.2b1**.  

It operates as a standalone on-device application, functioning independently like modern apps. It leverages the `sparserestore` exploit to write data to files situated outside of the intended restore location.  

---

## Features  

* **Disable call recording notification sound:** Turns off the audible alert when call recording starts.  
* **Change Apple Wallet background image:** Customize the background appearance of Wallet passes/cards.  
* **Edit MobileGestalt file (advanced):** Modify MobileGestalt configuration values (for advanced users).  
* **Change Passcode background:** Customize the numeric keypad appearance using the `.passthm` interface.  
* **On-device patching (no PC required):** Operates as a standalone app after the initial setup.  
* **More features coming soon:** Development is ongoing to introduce additional capabilities.  

---

## Usage Guides  

### Apple Wallet Background Guide  
Step-by-step guide for changing Apple Wallet pass/card backgrounds using EnsWilde:  
🔗 [https://gist.github.com/YangJiiii/06daf0c2d0fa11002757e501622353ea](https://gist.github.com/YangJiiii/06daf0c2d0fa11002757e501622353ea)  

### Passcode Background Guide  
Detailed instructions for customizing the passcode keypad background using `.passthm`:  
🔗 [https://gist.github.com/YangJiiii/67c6323cf4b7fd8487fcd6e2c8fb4233](https://gist.github.com/YangJiiii/67c6323cf4b7fd8487fcd6e2c8fb4233)  

---

## Getting Your `.mobiledevicepairing` File (Impactor)  
EnsWilde uses **Impactor** to automatically handle pairing.  
🔗 [https://github.com/khcrysalis/Impactor](https://github.com/khcrysalis/Impactor)  

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
* **@SideStore team**: [idevice and C bindings from StikDebug](https://github.com/sidestore)  
* **@JJTech0130**: [SparseRestore and backup exploit](https://github.com/JJTech0130)  
* **@hanakim3945**: [bl_sbx exploit files and writeup](https://github.com/hanakim3945)  
* **@Lakr233**: [BBackupp](https://github.com/Lakr233/BBackupp)  
* **@libimobiledevice**: [Underlying communication libraries](https://github.com/libimobiledevice/libimobiledevice)  
* **@PoomSmart**: MobileGestalt dump  
* **@paragonarsi**: Apple Wallet Get  
* **@iTechExpert21**: Hide Dynamic Island  

---

## About  
EnsWilde is a tool utilizing `itunesstored` & `bookassetd` exploits, designed for iPhone and iPad running the latest iOS Version 26.2b1.  

### Resources  
[Readme](#readme-ov-file)  

### License  
[AGPL-3.0 license](#AGPL-3.0-1-ov-file)

---

## Project Nature & Technical Notes (Hobby Project Clarification)

**This is a personal hobby and research project only.** It is **not** intended for the App Store, commercial distribution, or public release in any form that would require Apple's review process. Sideloading via tools like Impactor or TrollStore is the expected (and only) distribution method for advanced users who understand the risks.

The use of **private APIs** (e.g., direct interaction with `itunesstored`, `bookassetd`, MobileGestalt editing, and low-level exploit code in `PatchEngine`, `SparseRestore`, `PrivateAPI.m`, etc.) is **absolutely necessary** to deliver the core on-device patching capabilities without a tethered computer. These are not optional or replaceable with public APIs for the advanced customizations this tool provides. The project embraces this for its intended audience of tinkerers and researchers.

**Code Quality Note:** As recommended, the previous runtime method swizzling hack for `UIDocumentPickerViewController` (used to force `asCopy: true`) has been fully replaced with a clean `FixedDocumentPickerViewController` subclass (see `Sources/FixedDocumentPickerViewController.swift`). This eliminates potential instability from `method_exchangeImplementations` while preserving the exact behavior. No swizzling remains in the codebase. The app primarily leverages SwiftUI's `.fileImporter` for user-facing file selection, making the subclass available for any future UIKit integrations or internal needs.

All private API and exploit usage is intentional, well-understood, and core to the project's purpose. No plans to remove or abstract them for "App Store compatibility" because there are none.

**Use responsibly. Backup your device before experimenting. This is for educational and personal customization purposes on compatible iOS betas.**

Thank you for understanding the project's scope and goals.