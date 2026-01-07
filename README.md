<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2015+-blue?style=for-the-badge&logo=apple" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-5.9-orange?style=for-the-badge&logo=swift" alt="Swift">
  <img src="https://img.shields.io/badge/Architecture-MVVM-purple?style=for-the-badge" alt="Architecture">
  <img src="https://img.shields.io/badge/UI-UIKit-green?style=for-the-badge" alt="UI">
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="License">
</p>

<h1 align="center">StarLaunch</h1>

<p align="center">
  <strong>Uzayın derinliklerine açılan pencereniz. Gelecek uzay görevlerini keşfedin, fırlatma detaylarını inceleyin ve uzay ajansları hakkında bilgi edinin.</strong>
</p>

<p align="center">
  <em>Your window to the depths of space. Discover future space missions, explore launch details, and learn about space agencies.</em>
</p>

---

## Hakkında / About

**StarLaunch**, uzay meraklıları için tasarlanmış modern bir iOS uygulamasıdır. [The Space Devs API](https://thespacedevs.com/llapi)'nin gücünü kullanarak, kullanıcılara yaklaşan roket fırlatmaları hakkında zengin ve güncel bilgiler sunar.

Proje, modern iOS geliştirme pratiklerini sergilemek amacıyla **tamamen programatik** olarak (Storyboard veya XIB dosyaları olmadan) ve Swift'in en son özellikleri kullanılarak geliştirilmiştir.

---

## Ekran Görüntüleri / Screenshots

<table align="center">
<tr>
<td align="center">
<img src="https://github.com/user-attachments/assets/ff771398-6c90-413a-bbf9-1da694ad4668" width="250" alt="Splash Screen">
<br><em>Splash Screen</em>
</td>
<td align="center">
<img src="https://github.com/user-attachments/assets/47c9630f-3b5e-4403-8a63-fddba7d3c6dc" width="250" alt="Dashboard">
<br><em>Dashboard</em>
</td>
<td align="center">
<img src="https://github.com/user-attachments/assets/f5055fcf-442a-4955-93c2-83aa9c36dc26" width="250" alt="Launch List">
<br><em>Launch List</em>
</td>
</tr>
<tr>
<td align="center" colspan="3">
<img src="https://github.com/user-attachments/assets/eec58964-6d7e-43d3-b5d4-899f06dafdfd" width="250" alt="Launch Detail">
<br><em>Launch Detail</em>
</td>
</tr>
</table>

---

## Özellikler / Features

| Özellik | Açıklama |
|---------|----------|
| **Etkileşimli Açılış Ekranı** | Daktilo animasyonu ile keyifli karşılama deneyimi |
| **Zengin Dashboard** | Starship programı, fırlatma istatistikleri, ajans logoları |
| **Yaklaşan Fırlatmalar** | Sonsuz kaydırma ile pagination desteği |
| **Akıcı Animasyonlar** | Spring animasyonları ile pürüzsüz geçişler |
| **Detaylı Bilgi Kartları** | Roket, rampa, görev, mürettebat detayları |
| **Favoriler Sistemi** | Fırlatmaları kaydedin ve takip edin |
| **Arama ve Filtreleme** | Tarih, isim, sağlayıcıya göre sıralama |
| **Offline Modu** | İnternet olmadan önbellek verilerine erişim |
| **Çoklu Dil Desteği** | Türkçe ve İngilizce tam lokalizasyon |
| **Bildirimler** | Fırlatma hatırlatıcıları |
| **Haptic Feedback** | Dokunsal geri bildirim |
| **Ana Ekran Widget'ları** | Small, Medium, Large widget'lar ile fırlatma takibi |
| **Kilit Ekranı Widget'ları** | Kilidi açmadan geri sayımı görün |
| **Takvim Entegrasyonu** | Fırlatmaları takviminize ekleyin (EventKit) |
| **Fırlatma Karşılaştırma** | 3 fırlatmayı yan yana karşılaştırın |

---

## Teknik Mimari / Technical Architecture

### Teknoloji Yığını / Tech Stack

```
┌─────────────────────────────────────────────────────────────────┐
│                         StarLaunch                               │
├─────────────────────────────────────────────────────────────────┤
│  UI Layer          │  UIKit (100% Programmatic)                 │
│  Architecture      │  MVVM + Coordinator Pattern                │
│  Reactive          │  Combine Framework                         │
│  Async             │  Swift Concurrency (async/await)           │
│  Networking        │  URLSession + Custom NetworkService        │
│  Caching           │  NSCache (Memory) + FileManager (Disk)     │
│  Persistence       │  UserDefaults + JSON Encoding              │
│  Localization      │  NSLocalizedString + Runtime Switching     │
│  Testing           │  XCTest + Mock Objects                     │
│  Minimum iOS       │  iOS 15.0+                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Mimari Diyagram / Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                           App Layer                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │ AppDelegate  │  │SceneDelegate │  │   MainCoordinator    │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
├──────────────────────────────────────────────────────────────────┤
│                        Feature Modules                            │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐    │
│  │ Dashboard  │ │ LaunchList │ │  Favorites │ │  Settings  │    │
│  │ ┌────────┐ │ │ ┌────────┐ │ │ ┌────────┐ │ │ ┌────────┐ │    │
│  │ │  View  │ │ │ │  View  │ │ │ │  View  │ │ │ │  View  │ │    │
│  │ └────────┘ │ │ └────────┘ │ │ └────────┘ │ │ └────────┘ │    │
│  │ ┌────────┐ │ │ ┌────────┐ │ │ ┌────────┐ │ │            │    │
│  │ │ViewModel│ │ │ViewModel│ │ │ ViewModel│ │ │            │    │
│  │ └────────┘ │ │ └────────┘ │ │ └────────┘ │ │            │    │
│  │ ┌────────┐ │ │ ┌────────┐ │ │            │ │            │    │
│  │ │ Models │ │ │ │ Models │ │ │            │ │            │    │
│  │ └────────┘ │ │ └────────┘ │ │            │ │            │    │
│  └────────────┘ └────────────┘ └────────────┘ └────────────┘    │
├──────────────────────────────────────────────────────────────────┤
│                          Core Layer                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │NetworkService│  │ CacheManager │  │OfflineDataManager    │   │
│  │  - fetch()   │  │  - cache()   │  │  - save/load()       │   │
│  │  - retry()   │  │  - cached()  │  │                      │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │ ImageLoader  │  │FavoritesManager│ │LocalizationManager  │   │
│  │  - async     │  │  - toggle()  │  │  - setLanguage()    │   │
│  │  - cache     │  │  - persist   │  │  - localized()      │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │NetworkMonitor│  │AnalyticsService│ │NotificationManager  │   │
│  │  - NWPath    │  │  - track()   │  │  - schedule()       │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘
```

---

## Proje Yapısı / Project Structure

```
StarLaunch/
├── App/
│   ├── AppDelegate.swift              # App lifecycle
│   └── SceneDelegate.swift            # Scene management, DI setup
│
├── Features/
│   ├── Core/
│   │   ├── Analytics/
│   │   │   └── AnalyticsService.swift # Event tracking
│   │   ├── Caching/
│   │   │   ├── CacheManager.swift     # Memory + Disk cache
│   │   │   └── OfflineDataManager.swift
│   │   ├── DependencyInjection/
│   │   │   ├── DependencyContainer.swift
│   │   │   └── ViewModelFactory.swift
│   │   ├── Extensions/
│   │   │   └── UIColor+Hex.swift
│   │   ├── ImageLoader/
│   │   │   └── ImageLoader.swift      # Async image loading
│   │   ├── Localization/
│   │   │   └── LocalizationManager.swift
│   │   ├── Navigation/
│   │   │   ├── MainCoordinator.swift
│   │   │   └── MainTabBarController.swift
│   │   ├── Networking/
│   │   │   ├── APIConstants.swift     # Endpoint definitions
│   │   │   ├── NetworkError.swift     # Error types
│   │   │   ├── NetworkMonitor.swift   # Connectivity
│   │   │   ├── NetworkService.swift   # API client
│   │   │   └── RetryPolicy.swift      # Retry logic
│   │   ├── Notifications/
│   │   │   └── NotificationManager.swift
│   │   ├── Translation/
│   │   │   └── TranslationService.swift
│   │   ├── UI/
│   │   │   ├── EmptyStateView.swift
│   │   │   ├── ErrorView.swift
│   │   │   ├── HapticManager.swift
│   │   │   ├── SkeletonView.swift
│   │   │   └── UIComponents.swift
│   │   └── SplashViewController.swift
│   │
│   ├── Dashboard/
│   │   ├── Models/
│   │   │   ├── Agency.swift
│   │   │   ├── Spacecraft.swift
│   │   │   └── StarshipProgram.swift
│   │   ├── ViewModels/
│   │   │   └── DashboardViewModel.swift
│   │   └── Views/
│   │       ├── AgencyLogoCell.swift
│   │       ├── DashboardViewController.swift
│   │       └── StatCardView.swift
│   │
│   ├── LaunchList/
│   │   ├── Models/
│   │   │   └── LaunchItem.swift
│   │   ├── ViewModels/
│   │   │   └── LaunchListViewModel.swift
│   │   └── Views/
│   │       ├── LaunchCell.swift
│   │       └── LaunchListViewController.swift
│   │
│   ├── LaunchDetail/
│   │   ├── Models/
│   │   │   └── LaunchDetail.swift
│   │   ├── ViewModels/
│   │   │   └── LaunchDetailViewModel.swift
│   │   └── Views/
│   │       ├── CountdownView.swift
│   │       ├── CrewMemberCell.swift
│   │       ├── LaunchDetailViewController.swift
│   │       └── SectionHeaderView.swift
│   │
│   ├── Favorites/
│   │   ├── FavoritesManager.swift
│   │   └── FavoritesViewController.swift
│   │
│   ├── Search/
│   │   ├── SearchManager.swift
│   │   └── SearchViewController.swift
│   │
│   ├── Settings/
│   │   ├── LegalViewController.swift
│   │   └── SettingsViewController.swift
│   │
│   └── Onboarding/
│       ├── OnboardingManager.swift
│       └── OnboardingViewController.swift
│
├── Profile/Thema/
│   └── Colors.swift                   # Color palette
│
├── Resources/
│   ├── en.lproj/Localizable.strings   # English strings
│   └── tr.lproj/Localizable.strings   # Turkish strings
│
├── Info.plist                         # App configuration
│
└── StarLaunchTests/
    ├── LaunchListViewModelTests.swift
    ├── NetworkServiceTests.swift
    └── Mocks/
        └── MockNetworkService.swift
```

---

## Kurulum / Installation

### Gereksinimler / Requirements

| Gereksinim | Versiyon |
|------------|----------|
| macOS | Ventura 13.0+ |
| Xcode | 15.0+ |
| Swift | 5.9+ |
| iOS Deployment Target | 15.0+ |

### Adımlar / Steps

1. **Depoyu klonlayın / Clone the repository:**
   ```bash
   git clone https://github.com/CanSagnak1/StarLaunch.git
   cd StarLaunch
   ```

2. **Projeyi Xcode ile açın / Open with Xcode:**
   ```bash
   open StarLaunch.xcodeproj
   ```

3. **Simülatör seçin ve çalıştırın / Select simulator and run:**
   - Xcode'da bir iOS simülatörü seçin (örn: iPhone 15 Pro)
   - `Cmd + R` ile projeyi derleyip çalıştırın

---

## API Referansı / API Reference

Uygulama [The Space Devs Launch Library 2 API](https://ll.thespacedevs.com/2.2.0/docs/) kullanmaktadır.

### Kullanılan Endpointler / Used Endpoints

| Endpoint | Açıklama |
|----------|----------|
| `/launch/upcoming/` | Yaklaşan fırlatmalar |
| `/launch/{id}/` | Fırlatma detayları |
| `/config/launcher/` | Roket bilgileri |
| `/agencies/` | Uzay ajansları |
| `/dashboard/starship/` | Starship programı |

---

## Test / Testing

### Unit Testleri Çalıştırma / Running Unit Tests

```bash
# Xcode üzerinden
Cmd + U

# veya komut satırından
xcodebuild test -scheme StarLaunch -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### Test Kapsamı / Test Coverage

- `LaunchListViewModelTests` - ViewModel iş mantığı
- `NetworkServiceTests` - Ağ katmanı
- Mock nesneler ile izole testler

---

## Katkıda Bulunma / Contributing

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'e push yapın (`git push origin feature/amazing-feature`)
5. Pull Request açın

---

## Lisans / License

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

## İletişim / Contact

**Celal Can Sağnak**

- Email: [dddfrcgyuc123@gmail.com](mailto:dddfrcgyuc123@gmail.com)
- GitHub: [@CanSagnak1](https://github.com/CanSagnak1)

---

<p align="center">
  <strong>Made with passion for space exploration</strong>
</p>
