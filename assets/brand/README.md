# Jevons the Oracle

Single, outlined Baskerville **O**, optically centered with generous negative space.

- Citron: `#E4ED87`
- Olive: `#34452B`
- Dark icon background: `#172013`

## Deliverables

- `oracle-logo.svg` / `oracle-logo.png`: flat master, 1024 × 1024.
- `oracle-o.svg`: transparent vector monogram, outlined (no font required).
- `oracle-liquid-glass-light.png` / `oracle-liquid-glass-dark.png`: actual Apple Icon Composer renderer previews.
- `../../ios/JEV/OracleIcon.icon`: layered native app icon; the background and glass O remain separate. Light appearance uses an olive background and citron O; dark appearance retains its dark background and citron O. Xcode compiles the icon, including compatibility renditions.
- `../../ios/JEV/BrandAssets.xcassets`: scalable PDF monogram for future branding use. The entrance shows only the text wordmark, without the large O.

Regenerate flat/vector artwork from the repository root:

```sh
swift -module-cache-path /tmp/jevons-brand-module-cache ios/Tools/prepare-oracle-brand.swift "$PWD"
```

Render a native preview (use absolute paths for input and output):

```sh
"/Applications/Xcode-26.0.app/Contents/Applications/Icon Composer.app/Contents/Executables/ictool" \
  "$PWD/ios/JEV/OracleIcon.icon" --export-preview iOS Light 1024 1024 1 \
  "$PWD/assets/brand/oracle-liquid-glass-light.png"
```

## Integration

The display name is **Jevons the Oracle**. The existing `JEV` scheme/module and `com.jev.oracle` bundle identifier are retained to preserve build/test integration and device data.

`OracleBrand.swift` contains the palette, entrance wordmark, native iOS 26 glass button treatment (olive background, citron label) and menu/control material. Older iOS versions use standard prominent buttons/material. Reduce Transparency uses opaque navigation surfaces. The conversation composer's existing native glass implementation is retained.

Brand changes are intentionally separate from artwork, scene/depth rendering, language generation and connection code, which other agents are editing concurrently. `project.yml` and the Xcode project both reference the brand assets; the project was patched without regenerating it.

Apple references: [Icon Composer](https://developer.apple.com/documentation/xcode/creating-your-app-icon-using-icon-composer), [SwiftUI Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/323/).
