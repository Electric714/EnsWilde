---

## Plugin System (New in this branch!)

EnsWilde is evolving into a **plugin-based patching system** to make it easy to add, share, and maintain tweaks without hardcoding everything in Swift.

### Goals
- Every patch (including new Control Center, Dynamic Island, Status Bar, Privacy/Telemetry blockers) defined as **loadable JSON** for simple cases (MobileGestalt keys, plist edits, file writes).
- **Optional Swift modules** for complex patches that need custom UI (e.g. image pickers for Wallet background) or advanced apply logic.
- Community can contribute via `Patches/Community/*.json` (future sideloading support).
- Dynamic UI: toggles auto-appear in the main tweaks list.
- Centralized `PatchLoader` + `PatchModule` protocol.

### Current Status (feature/patch-plugin-system branch)
- ✅ `Patches/patch-template.json` with full JSON schema + example
- ✅ `Sources/PatchEngine/PatchModule.swift` (protocol + JSONPatchModule default impl)
- ✅ `Sources/PatchEngine/PatchLoader.swift` (scans bundle on launch, auto-registers)
- ⏳ Refactor existing patches (Wallet, DisableSound, etc.) to JSON + optional modules (in progress)
- ⏳ Dynamic UI in ContentView/MainView
- ⏳ Integration with ToolRunner / Apply system

### How to Add Your Own Plugin (for contributors)

#### 1. Simple Data-Driven Patch (Recommended for most tweaks)

Create a new `.json` file in `Patches/` (core) or `Patches/Community/` (community).

Example: `Patches/hide-dynamic-island.json`

```json
{
  "id": "hide-dynamic-island",
  "title": "Hide Dynamic Island",
  "description": "Hides the Dynamic Island pill (builds on @iTechExpert21 work).",
  "iOSVersionMin": "26.2",
  "category": "DynamicIsland",
  "uiToggleType": "switch",
  "defaultEnabled": false,
  "requiresRespring": true,
  "patches": [
    {
      "targetType": "MobileGestalt",
      "key": "YourRealMobileGestaltKeyForDynamicIsland",
      "value": false,
      "operation": "set"
    }
  ]
}
```

Use the schema in `patch-template.json` for validation (many editors support it).

#### 2. Complex Patch with Custom Swift Module

1. Add the JSON as above, with `"customModule": "YourPatchModule"`
2. Create `Sources/PatchModules/YourPatchModule.swift` (or inside Tools/ for now) that conforms to `PatchModule`
3. Implement `apply()` with your custom logic (e.g. image import + sparserestore)
4. In `PatchLoader.loadAllPatches()` or onAppear, call `PatchLoader.shared.register(YourPatchModule())`
5. Override `makeCustomView(binding:)` to return your SwiftUI view (e.g. image picker + preview)

See `AppleWallet` folder as reference for complex patch patterns.

#### 3. Submitting
- Open PR to `develop` from your fork/branch
- Include before/after screenshots, iOS version tested, and the JSON + any Swift
- Update this README and add to `version.json` if needed

This system will eventually replace the hardcoded toggles in `ToolStore.swift` and `ContentView.swift`, making EnsWilde much more extensible while keeping the powerful sparserestore + bookassetd engine.

> **Note for Control Center patches**: New CC tweaks (from `feature/control-center-tweaks`) will be migrated to this JSON format as part of this effort.

---

## Credits

... (rest of original README continues as before)