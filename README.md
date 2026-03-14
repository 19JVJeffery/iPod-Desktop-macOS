<div align="center">

# 🎵 iPod Desktop — macOS

A native macOS music player that recreates the iconic iPod Classic experience.  
Built entirely in Swift and SwiftUI — no cross-platform framework required.

</div>

---

## ✨ Features

| | Feature |
|---|---|
| 🎡 | Click wheel with rotation gesture and five tap zones |
| 🗃️ | Full local music library — MP3, WAV, FLAC, M4A, AAC, AIFF, OGG, Opus |
| 🧑‍🎤 | Browse by Songs, Albums, Artists, Genres |
| 🎞️ | Cover Flow view with 3-D artwork rotation |
| 💿 | Now Playing screen with artwork, progress bar and transport controls |
| 🔀 | Shuffle and Repeat (All / One) modes |
| 📃 | User-created Playlists |
| 🔍 | In-app Search |
| 🎨 | 12 device colour themes (Silver, Black, Red, Blue, …) |
| 🌓 | Light and Dark screen themes |
| 🔋 | Live macOS battery indicator in the status bar |
| ⭐ | Track star-rating |
| 🔉 | Volume control via click wheel rotation on Now Playing |
| ⌨️ | Full keyboard shortcuts via the Playback and Library menus |
| 📦 | No external dependencies — pure Swift / AVFoundation |

---

## 🛠 Requirements

- **macOS 14 Sonoma** or later
- **Xcode 15** or later

---

## 🚀 Getting Started

```bash
git clone https://github.com/19JVJeffery/iPod-Desktop-macOS.git
cd iPod-Desktop-macOS/iPodDesktop
open iPodDesktop.xcodeproj
```

Press **⌘R** in Xcode to build and run.  
On first launch the app will ask you to choose your Music folder.

---

## 📁 Project Layout

```
iPodDesktop/
├── iPodDesktop.xcodeproj/      ← Xcode project
└── iPodDesktop/
    ├── iPodDesktopApp.swift    ← App entry point & window setup
    ├── Models/
    │   ├── Track.swift         ← Audio file data model
    │   ├── Playlist.swift      ← User playlist model
    │   └── iPodColorScheme.swift  ← All 12 device colour themes
    ├── ViewModels/
    │   ├── AppState.swift      ← Navigation stack & settings
    │   ├── PlayerEngine.swift  ← AVFoundation playback engine
    │   └── LibraryManager.swift  ← File scanner & metadata reader
    └── Views/
        ├── ContentView.swift
        ├── DeviceBodyView.swift  ← iPod frame, layout & click-wheel wiring
        ├── ClickWheelView.swift  ← Rotation + tap gesture handling
        ├── iPodScreenView.swift  ← Routes the navigation stack to screens
        ├── StatusBarView.swift   ← iPod status bar + battery indicator
        ├── Shared/
        │   ├── ListRowView.swift
        │   └── iPodListScreen.swift
        └── Screens/
            ├── MainMenuView.swift
            ├── MusicMenuView.swift
            ├── BrowseViews.swift   ← Songs, Albums, Artists, Genres
            ├── PlaylistViews.swift
            ├── NowPlayingView.swift
            ├── SettingsView.swift
            ├── SearchView.swift
            └── CoverFlowView.swift
```

---

## ⌨️ Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Play / Pause | Space |
| Next Track | ⌘→ |
| Previous Track | ⌘← |
| Volume Up | ⌘↑ |
| Volume Down | ⌘↓ |
| Choose Music Folder | ⌘O |
| Rescan Library | ⌘R |

---

## 📜 License

[MIT](LICENSE)
