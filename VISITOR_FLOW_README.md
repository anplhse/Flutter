# Visitor Flow Implementation - Museum App

## Tổng quan
App hỗ trợ visitor (không cần đăng nhập) có thể:
- Xem danh sách bảo tàng
- Xem chi tiết bảo tàng và các hiện vật của bảo tàng đó
- Xem danh sách tất cả hiện vật
- Quét mã QR trên hiện vật để xem thông tin chi tiết
- Tìm kiếm hiện vật

## Cấu trúc Models

### 1. Museum Model (`lib/models/museum.dart`)
```dart
- id: String
- name: String
- description: String
- address: String
- imageUrl: String
- phone: String
- email: String
- openingHours: String
- latitude: double
- longitude: double
- tags: List<String>
- createdAt: DateTime
```

### 2. Artifact Model (Updated - `lib/models/artifact.dart`)
```dart
- id: String
- code: String              // Mã hiện vật dùng cho QR code
- name: String
- description: String
- imageUrl: String
- period: String
- origin: String
- material: String
- category: String
- discoveryDate: DateTime
- location: String
- tags: List<String>
- museumId: String          // ID của bảo tàng
- area: String?             // Khu vực trưng bày (vd: "Khu A - Tầng 1")
- displayPosition: String?  // Vị trí cụ thể (vd: "Tủ kính số 3")
```

## API Endpoints (MuseumService)

### Museum APIs
- `getAllMuseums()` - Lấy danh sách tất cả bảo tàng
- `getMuseumById(museumId)` - Lấy chi tiết một bảo tàng
- `getMockMuseums()` - Mock data cho demo

### Artifact APIs
- `getArtifactByCode(code)` - **Lấy hiện vật theo mã QR code** ⭐
- `getArtifactById(artifactId)` - Lấy hiện vật theo ID
- `getArtifactsByMuseumId(museumId)` - Lấy tất cả hiện vật của một bảo tàng
- `getAllArtifacts()` - Lấy tất cả hiện vật
- `searchArtifacts(query)` - Tìm kiếm hiện vật

## Luồng QR Code Scanning

1. **Visitor quét QR code** trên biển hiệu bên cạnh hiện vật
2. QR code chứa artifact **code** (ví dụ: "AR001", "MUSEUM:AR002", v.v.)
3. `QRScannerService.scanQRCode()` mở camera và quét mã
4. `QRScannerService.extractArtifactId()` trích xuất code từ QR
5. Gọi API `MuseumService.getArtifactByCode(code)` để lấy thông tin
6. Hiển thị `ArtifactDetailScreen` với đầy đủ thông tin:
   - Thông tin cơ bản (tên, mô tả, hình ảnh)
   - Thời kỳ, xuất xứ, chất liệu, danh mục
   - **Khu vực trưng bày** (area)
   - **Vị trí cụ thể** (displayPosition)
   - Ngày phát hiện
   - Tags

## Màn hình (Screens)

### 1. HomeScreen (`lib/screens/home_screen.dart`)
- Màn hình chính với các chức năng:
  - Quét mã QR
  - Duyệt hiện vật
  - Tìm kiếm

### 2. MuseumsListScreen (`lib/screens/museums_list_screen.dart`)
- Danh sách tất cả bảo tàng
- Hiển thị thông tin: tên, mô tả, địa chỉ, giờ mở cửa
- Click vào để xem chi tiết

### 3. MuseumDetailScreen (`lib/screens/museum_detail_screen.dart`)
- Chi tiết bảo tàng
- Thông tin liên hệ đầy đủ
- **Danh sách hiện vật của bảo tàng**
- Click vào hiện vật để xem chi tiết

### 4. ArtifactsListScreen (`lib/screens/artifacts_list_screen.dart`)
- Danh sách tất cả hiện vật
- Lọc theo category
- Click để xem chi tiết

### 5. ArtifactDetailScreen (`lib/screens/artifact_detail_screen.dart`)
- Chi tiết hiện vật với đầy đủ thông tin
- **Hiển thị area và displayPosition** để visitor biết vị trí chính xác

### 6. QRScannerScreen (`lib/screens/qr_scanner_screen.dart`)
- Quét QR code
- Sử dụng `getArtifactByCode()` để lấy thông tin

### 7. SearchScreen (`lib/screens/search_screen.dart`)
- Tìm kiếm hiện vật theo keyword

## Bottom Navigation

1. **Trang chủ** - HomeScreen
2. **Bảo tàng** - MuseumsListScreen ⭐ (Mới thêm)
3. **Hiện vật** - ArtifactsListScreen
4. **Quét QR** - QRScannerScreen
5. **Tìm kiếm** - SearchScreen

## Mock Data

### Museums (3 bảo tàng mẫu)
- MUS001: Bảo Tàng Lịch Sử Quốc Gia
- MUS002: Bảo Tàng Mỹ Thuật Việt Nam
- MUS003: Bảo Tàng Dân Tộc Học

### Artifacts (3 hiện vật mẫu)
- AR001: Bình gốm Hàn (MUS001, Khu A - Tầng 1, Tủ kính số 3)
- AR002: Kiếm đồng cổ (MUS001, Khu B - Tầng 2, Bàn trưng bày số 5)
- AR003: Tượng Phật gỗ (MUS002, Khu C - Tầng 1, Bệ đá số 2)

## Cách sử dụng khi có API thật

### Trong `qr_scanner_screen.dart`:
```dart
// Thay thế dòng này:
final artifact = await MuseumService.getMockArtifactByCode(artifactCode);

// Bằng dòng này:
final artifact = await MuseumService.getArtifactByCode(artifactCode);
```

### Trong các screens khác:
- Thay `getMockMuseums()` → `getAllMuseums()`
- Thay `getMockArtifact()` → `getArtifactById()`
- Thay `getMockArtifactsByMuseumId()` → `getArtifactsByMuseumId()`

## Tính năng đã implement

✅ Model Museum với đầy đủ thông tin
✅ Model Artifact với code, museumId, area, displayPosition
✅ API getArtifactByCode() cho QR scanning
✅ API getArtifactsByMuseumId() cho museum detail
✅ Screen danh sách bảo tàng
✅ Screen chi tiết bảo tàng với danh sách hiện vật
✅ QR Scanner sử dụng artifact code
✅ Hiển thị area và displayPosition trong artifact detail
✅ Bottom navigation với tab Bảo tàng
✅ Mock data đầy đủ cho demo

## Lưu ý
- Visitor không cần đăng nhập, tất cả dữ liệu đều public
- QR code format: "AR001", "MUSEUM:AR002", hoặc URL có "/artifact/AR003"
- Area và displayPosition giúp visitor tìm hiện vật dễ dàng trong bảo tàng

