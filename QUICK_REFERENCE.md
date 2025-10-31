# Quick Reference - Museum App Implementation

## ✅ Đã hoàn thành

### Models
- **Museum** model với đầy đủ thông tin (id, name, description, address, phone, email, hours, location, tags)
- **Artifact** model đã cập nhật:
  - `code` - Mã QR
  - `museumId` - Thuộc bảo tàng nào
  - `area` - Khu vực trưng bày
  - `displayPosition` - Vị trí cụ thể

### APIs (Museum Service)
```dart
// Museums
getAllMuseums()                    // Danh sách bảo tàng
getMuseumById(museumId)           // Chi tiết bảo tàng
getMockMuseums()                  // Mock data

// Artifacts  
getArtifactByCode(code)           // ⭐ Lấy hiện vật bằng QR code
getArtifactById(id)               // Lấy theo ID
getArtifactsByMuseumId(museumId)  // Hiện vật của bảo tàng
getAllArtifacts()                 // Tất cả hiện vật
searchArtifacts(query)            // Tìm kiếm
```

### Screens
1. **MuseumsListScreen** - Danh sách bảo tàng
2. **MuseumDetailScreen** - Chi tiết bảo tàng + hiện vật
3. **ArtifactDetailScreen** - Chi tiết hiện vật (đã update hiển thị area/position)
4. **QRScannerScreen** - Quét QR (đã update dùng getArtifactByCode)

### Navigation
Bottom Nav có 5 tabs:
1. Trang chủ
2. **Bảo tàng** ← MỚI
3. Hiện vật
4. Quét QR
5. Tìm kiếm

## 🔥 Luồng chính: QR Code Scanning

```
Visitor → Quét QR → Extract code → getArtifactByCode(code) → Show Detail
                                    (với area & displayPosition)
```

**QR Format hỗ trợ:**
- `AR001`
- `MUSEUM:AR001`  
- `https://museum.com/artifact/AR001`

## 📦 Mock Data

**3 Museums:**
- MUS001: Bảo Tàng Lịch Sử Quốc Gia
- MUS002: Bảo Tàng Mỹ Thuật Việt Nam
- MUS003: Bảo Tàng Dân Tộc Học

**3 Artifacts:**
- AR001: Bình gốm Hàn (MUS001, Khu A - Tầng 1, Tủ kính 3)
- AR002: Kiếm đồng cổ (MUS001, Khu B - Tầng 2, Bàn 5)
- AR003: Tượng Phật gỗ (MUS002, Khu C - Tầng 1, Bệ đá 2)

## 🚀 Run App

```bash
flutter pub get
flutter run
```

## 🔄 Khi có API thật

### Update baseUrl:
```dart
// lib/services/museum_service.dart
static const String baseUrl = 'https://your-api.com';
```

### Replace Mock → Real API:
```dart
// Thay:
getMockMuseums() → getAllMuseums()
getMockArtifactByCode(code) → getArtifactByCode(code)
getMockArtifactsByMuseumId(id) → getArtifactsByMuseumId(id)
```

## 📝 Backend cần implement

```
GET  /museums                     
GET  /museums/{id}                
GET  /museums/{id}/artifacts      
GET  /artifacts                   
GET  /artifacts/{id}              
GET  /artifacts/code/{code}       ⭐ QUAN TRỌNG cho QR scan
GET  /artifacts/search?q={query}  
```

## ✨ Features

✅ Visitor không cần login
✅ Xem bảo tàng và hiện vật
✅ Quét QR để xem chi tiết
✅ Hiển thị vị trí trưng bày (area + displayPosition)
✅ Tìm kiếm hiện vật
✅ UI đẹp với cached images
✅ Pull to refresh
✅ Bottom navigation

## 📱 Test QR Scanning

Tạo QR code với nội dung:
- "AR001" hoặc
- "MUSEUM:AR002" hoặc  
- "https://museum.com/artifact/AR003"

Sau đó quét bằng app để test!

## ⚠️ Note

- IDE có thể báo error "MuseumDetailScreen isn't defined" - đây là false positive
- Code đã compile OK (verified với `flutter analyze` và `flutter build`)
- APK debug đã build thành công ✅

