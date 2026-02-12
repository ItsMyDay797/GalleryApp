# Gallery App

iOS gallery application that displays photos from the [Unsplash API](https://unsplash.com/documentation), with favorites and a detail view with swipe navigation.

**Contact:** [GitHub profile](https://github.com/ItsMyDay797)

---

## Introduction

The app fetches curated photos from Unsplash, shows them in a scrollable grid, and lets users open a full-screen detail view, add photos to favorites, and swipe between images. Favorites are stored locally and persist between launches.

---

## Features

- **Gallery screen** — Grid of thumbnails with pagination (30 photos per page). Tap a cell to open the detail screen.
- **Detail screen** — Full-size image, description, and author. Swipe left/right to move between photos from the gallery. Favorite button in the navigation bar.
- **Favorites** — Heart icon on thumbnails and in the detail view. Tapping toggles favorite state; IDs are saved in `UserDefaults`.
- **Smooth scrolling** — In-memory image cache for thumbnails; new pages are appended without full reload so already loaded images stay visible.

---

## Assumptions & Extras

- Favorites are stored by photo ID only (no full photo object). The list of favorite IDs is kept in `UserDefaults`.
- Swipe navigation in the detail view is limited to photos already loaded in the gallery (no extra API calls when swiping).
- No separate “Favorites only” screen; favorites are indicated on the main gallery and in the detail view only.
- File headers and a minimal `.gitignore` are included for a clean project layout.

---

## Technical Overview

| Area | Choice |
|------|--------|
| **Language** | Swift |
| **Minimum iOS** | 15.0 |
| **UI** | UIKit |
| **Networking** | URLSession only; no third-party HTTP libraries |
| **Architecture** | MVVM-style: separate layers for networking, repository, view model, and presentation |

**Structure:**

- **Models** — Domain model `Photo` and DTOs for Unsplash API with mapping to domain.
- **Networking** — `UnsplashAPIClient` (List Photos endpoint, Client-ID auth), error handling with `LocalizedError`.
- **Repository** — `PhotoRepository` for pagination (first page / next page).
- **Persistence** — `FavoritesStore` protocol and implementation using `UserDefaults`.
- **Presentation** — `ViewController` (gallery + collection view), `GalleryViewModel`, `GalleryCollectionViewCell`, `PhotoDetailViewController`, `PhotoDetailPageViewController` (UIPageViewController for swipe).

**Patterns:** Protocol-oriented dependencies, completion-handler async, no external pods.

---

## Configuration

The app needs an Unsplash **Access Key** (Client-ID).

1. Register an application at [Unsplash Developers](https://unsplash.com/developers) and get your Access Key.
2. Open `GalleryAppV3/Info.plist` in Xcode.
3. Set the value of `UNSPLASH_ACCESS_KEY` to your key.


---

## Build & Run

1. Open `GalleryAppV3.xcodeproj` in Xcode.
2. Select a simulator or device (iOS 15.0+).
3. Run (⌘R).

---

## Screenshots / Demo

<img width="1206" height="2622" alt="simulator_screenshot_D62A339B-614E-4F8B-912F-8857712B1036" src="https://github.com/user-attachments/assets/a5b2e3c0-a893-40b1-903e-0e7cbd9be584" />
<img width="1206" height="2622" alt="simulator_screenshot_110A5A63-259F-4C49-AEEE-B7C20C612E25" src="https://github.com/user-attachments/assets/886fa767-9f60-463f-914a-f73754bc5c0b" />


