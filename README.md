# StarLaunch

<p align="center">
  <strong>Uzayın derinliklerine açılan pencereniz. Gelecek uzay görevlerini keşfedin, fırlatma detaylarını inceleyin ve uzay ajansları hakkında bilgi edinin.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS-blue.svg" alt="Platform">
  <img src="https://img.shields.io/badge/Language-Swift_5-orange.svg" alt="Language">
  <img src="https://img.shields.io/badge/Architecture-MVVM-purple.svg" alt="Architecture">
  <img src="https://img.shields.io/badge/UI-UIKit_(Programmatic)-green.svg" alt="UI">
</p>

---

## Hakkında

**StarLaunch**, uzay meraklıları için tasarlanmış modern bir iOS uygulamasıdır. [The Space Devs API](https://thespacedevs.com/llapi)'sinin gücünü kullanarak, kullanıcılara yaklaşan roket fırlatmaları hakkında zengin ve güncel bilgiler sunar. Uygulama, şık ve akıcı bir kullanıcı arayüzü ile karmaşık verileri anlaşılır ve estetik bir şekilde sergiler.

Proje, modern iOS geliştirme pratiklerini sergilemek amacıyla tamamen programatik olarak (Storyboard veya XIB dosyaları olmadan) ve Swift'in en son özellikleri kullanılarak geliştirilmiştir.

---

## Özellikler

- **Etkileşimli Açılış Ekranı:** Uygulama başlarken veriler arka planda yüklenirken, kullanıcıyı sonsuz döngüde bir daktilo animasyonu karşılar. Bu, bekleme süresini keyifli bir deneyime dönüştürür.
- **Zengin Dashboard:** Ana ekran, Starship programı hakkında öne çıkan bilgiler, toplam fırlatma sayısı, başarı oranı gibi önemli istatistikler ve önde gelen uzay ajanslarının logolarını içeren dinamik bir yapıya sahiptir.
- **Yaklaşan Fırlatmalar:** Gelecekteki tüm fırlatmaları listeleyen ve kullanıcı aşağı kaydırdıkça otomatik olarak daha fazla veri yükleyen (sonsuz kaydırma/pagination) bir liste ekranı.
- **Akıcı Animasyonlar:** Liste ekranındaki her bir hücre, ekrana pürüzsüz ve yaylanma efektli bir animasyonla gelir. Sayfalama sırasında yeni veriler eklenirken animasyon akıcılığı bozulmaz.
- **Detaylı Fırlatma Bilgileri:** Her fırlatma için; roket, fırlatma rampası, görev tanımı, fırlatma durumu ve eğer varsa mürettebat bilgileri gibi kapsamlı detayların sunulduğu bir detay ekranı.
- **Modern ve Şık Arayüz:** `UIVisualEffectView` (Blur) ve özel renk paleti kullanılarak oluşturulmuş, uzay temasına uygun, estetik ve modern bir kullanıcı arayüzü.
- **Verimli Resim Yükleme:** Ağdan yüklenen tüm resimler `NSCache` kullanılarak önbelleğe alınır, bu da performansı artırır ve gereksiz ağ isteklerini önler.

---

##  Ekran Görüntüleri
<table align="center" style="border: none;">
<tr>
<td align="center">

<img src="https://github.com/user-attachments/assets/ff771398-6c90-413a-bbf9-1da694ad4668" width="300" alt="Splash Ekranı">
</td>
<td align="center">

<img src="https://github.com/user-attachments/assets/47c9630f-3b5e-4403-8a63-fddba7d3c6dc" width="300" alt="Dashboard Ekranı">
</td>
</tr>
<tr>
<td align="center">

<img src="https://github.com/user-attachments/assets/f5055fcf-442a-4955-93c2-83aa9c36dc26" width="300" alt="Fırlatma Listesi">
</td>
<td align="center">

<img src="https://github.com/user-attachments/assets/eec58964-6d7e-43d3-b5d4-899f06dafdfd" width="300" alt="Fırlatma Detayları">
</td>
</tr>
</table>

---

## Teknoloji ve Mimari

Bu proje, ölçeklenebilir, sürdürülebilir ve yüksek performanslı bir uygulama oluşturmak için modern iOS geliştirme teknikleri üzerine inşa edilmiştir.

### Ana Teknolojiler

- **Dil:** **Swift 5**
- **UI:** **UIKit (Programmatic)** - Tüm arayüz kodla oluşturulmuştur, Storyboard kullanılmamıştır. Bu yaklaşım, versiyon kontrol sistemlerinde daha temiz bir birleştirme süreci ve yeniden kullanılabilir bileşenler oluşturmada esneklik sağlar.
- **Mimari Desen:** **MVVM (Model-View-ViewModel)** - Sorumlulukların net bir şekilde ayrılması (separation of concerns) için kullanılmıştır.
  - **Model:** API'den gelen verileri temsil eden `Codable` yapılar. (`Launch`, `Starship`, `Agency` vb.)
  - **View:** `UIViewController` ve `UIView` alt sınıfları. Kullanıcı etkileşimlerini alır ve ViewModel'den gelen verileri görüntüler.
  - **ViewModel:** View için veri ve durum yönetimi yapar. Ağ isteklerini tetikler ve Model'i View'ın anlayacağı bir formata dönüştürür.
- **Asenkron İşlemler:** **Swift Concurrency (`async/await`)** - Ağ istekleri ve veri işleme gibi asenkron operasyonlar için modern, okunabilir ve güvenli bir yapı sunar. `TaskGroup` ile birden fazla ağ isteği paralel olarak yönetilir.
- **Reaktif Programlama:** **Combine Framework** - ViewModel ve View arasındaki veri akışını yönetmek için kullanılır. `@Published` property wrapper'ı ile ViewModel'deki değişiklikler View tarafından kolayca gözlemlenir.

### Ağ (Networking)

- **`NetworkService`:** `async/await` tabanlı, yeniden kullanılabilir bir ağ katmanı oluşturulmuştur. Bu singleton sınıf, tüm API isteklerini yönetir, gelen JSON verilerini `Codable` modellere dönüştürür ve hataları yönetir.
- **`APIConstants`:** Tüm API endpoint'leri merkezi bir yerde toplanarak kodun daha temiz ve yönetilebilir olması sağlanmıştır.

### Resim Yükleme

- **`ImageLoader`:** Asenkron olarak resim indiren ve `NSCache` ile önbelleğe alan özel bir sınıf. Bu sayede, aynı resimler tekrar tekrar indirilmez ve uygulama performansı artırılır.

---

## Başlarken

Bu projeyi yerel makinenizde çalıştırmak için aşağıdaki adımları izleyin.

### Gereksinimler

- macOS
- Xcode 13 veya üstü
- Swift 5.5 veya üstü

### Kurulum

1.  **Depoyu klonlayın:**
    ```sh
    git clone https://github.com/CanSagnak1/TGY-HOMEWORK/new/main/Ödevler/SpaceX/StarLaunch.git
    ```
2.  **Projeyi açın:**
    Klonladığınız dizine gidin ve `StarLaunch.xcodeproj` dosyasını Xcode ile açın.

3.  **Çalıştırın:**
    Bir simülatör (örneğin, iPhone 14 Pro) seçin ve `Cmd + R` tuşlarına basarak projeyi derleyip çalıştırın.

---

## İletişim

Celal Can Sağnak - [Gmail](mailto:dddfrcgyuc123@gmail.com)
