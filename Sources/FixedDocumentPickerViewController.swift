import UIKit
import UniformTypeIdentifiers

/// Proper subclass replacement for the previous UIDocumentPickerViewController method swizzling hack.
/// Forces `asCopy: true` to maintain the intended behavior without runtime modification of system classes.
/// This is a cleaner, more maintainable approach suitable for a hobby project.
/// 
/// Usage: Replace any direct `UIDocumentPickerViewController(...)` instantiation with `FixedDocumentPickerViewController(...)`.
/// Note: Current app uses SwiftUI `.fileImporter` which may internally use the base class, but this subclass is available for any UIKit code or future needs.
/// Private APIs remain in use elsewhere as they are essential for the exploit-based features.
class FixedDocumentPickerViewController: UIDocumentPickerViewController {
    override init(forOpeningContentTypes contentTypes: [UTType], asCopy: Bool) {
        super.init(forOpeningContentTypes: contentTypes, asCopy: true)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}