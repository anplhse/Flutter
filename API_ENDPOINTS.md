# API Endpoints Documentation

## Base URL
```
https://museum-system-api-160202770359.asia-southeast1.run.app/api/v1
```

## Authentication
Tất cả các API dưới `/visitors` yêu cầu Bearer Token trong header:
```
Authorization: Bearer {token}
```

---

## 🔐 Authentication APIs

### 1. Đăng ký Visitor
**Endpoint:** `POST /visitors/register`

**Request Body:**
```json
{
  "username": "haian",
  "password": "123456"
}
```

**Response:**
```json
{
  "code": 200,
  "statusCode": "Success",
  "message": "Register successfully",
  "data": {
    "id": "de8530f6-4891-4994-8511-53026254dcc7",
    "username": "haian",
    "status": "Active",
    "createdAt": "2025-11-03T12:01:55.2839121Z",
    "updatedAt": "2025-11-03T12:01:55.2839122Z"
  }
}
```

### 2. Đăng nhập Visitor
**Endpoint:** `POST /visitors/login`

**Request Body:**
```json
{
  "username": "haian",
  "password": "123456"
}
```

**Response:**
```json
{
  "code": 200,
  "statusCode": "Success",
  "message": "Login successfully",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "visitor": {
      "id": "de8530f6-4891-4994-8511-53026254dcc7",
      "username": "haian",
      "status": "Active"
    }
  }
}
```

### 3. Lấy Profile Visitor
**Endpoint:** `GET /visitors/me`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "code": 200,
  "statusCode": "Success",
  "message": "Take profile sucessfully",
  "data": {
    "id": "de8530f6-4891-4994-8511-53026254dcc7",
    "username": "haian",
    "status": "Active",
    "createdAt": "2025-11-03T12:01:55.2839121",
    "updatedAt": "2025-11-03T12:01:55.2839122"
  }
}
```

---

## 🏛️ Museum APIs

### 4. Lấy danh sách Bảo tàng
**Endpoint:** `GET /visitors/museums`

**Query Parameters:**
- `pageIndex` (int, default: 1)
- `pageSize` (int, default: 10)
- `name` (string, optional) - Tìm kiếm theo tên

**Example:**
```
GET /visitors/museums?pageIndex=1&pageSize=10
GET /visitors/museums?pageIndex=1&pageSize=10&name=FPT
```

**Response:**
```json
{
  "code": 200,
  "statusCode": "Success",
  "message": "Take museums successfully",
  "data": {
    "items": [
      {
        "id": "11c9d49a-b49d-4cf0-bbe9-fdaf46df5b4a",
        "name": "Bảo tàng FPT",
        "location": "PBT",
        "description": "Nơi tinh hoa tan chảy ok",
        "status": "Active"
      }
    ],
    "totalItems": 2,
    "pageIndex": 1,
    "totalPages": 1,
    "pageSize": 10
  }
}
```

### 5. Lấy chi tiết Bảo tàng
**Endpoint:** `GET /visitors/museums/{museumId}`

**Example:**
```
GET /visitors/museums/11c9d49a-b49d-4cf0-bbe9-fdaf46df5b4a
```

**Response:**
```json
{
  "code": 200,
  "statusCode": "Success",
  "message": "Take museum successfully",
  "data": {
    "id": "11c9d49a-b49d-4cf0-bbe9-fdaf46df5b4a",
    "name": "Bảo tàng FPT",
    "location": "PBT",
    "description": "Nơi tinh hoa tan chảy ok",
    "status": "Active"
  }
}
```

---

## 🏺 Artifact APIs

### 6. Lấy danh sách Hiện vật của Bảo tàng
**Endpoint:** `GET /visitors/museums/{museumId}/artifacts`

**Query Parameters:**
- `pageIndex` (int, default: 1)
- `pageSize` (int, default: 10)

**Example:**
```
GET /visitors/museums/11c9d49a-b49d-4cf0-bbe9-fdaf46df5b4a/artifacts?pageIndex=1&pageSize=10
```

**Response:**
```json
{
  "code": 200,
  "statusCode": "Success",
  "message": "Take artifacts successfully",
  "data": {
    "items": [
      {
        "id": "beb1f5df-00e9-408b-aedc-4b8c4770f46a",
        "artifactCode": "BAO-ART-0003-20251103060746",
        "name": "Bình vạc bằng đồng",
        "periodTime": "Trần–Hồ",
        "description": "Bình vạc cổ với họa tiết...",
        "isOriginal": true,
        "weight": 20,
        "height": 35,
        "width": 16,
        "length": 45,
        "status": "OnDisplay",
        "displayPositionName": "C1",
        "areaName": "Khu vực trưng bày đồ đồng cổ",
        "mediaItems": null
      }
    ],
    "totalItems": 5,
    "pageIndex": 1,
    "totalPages": 1,
    "pageSize": 10
  }
}
```

### 7. Lấy chi tiết Hiện vật
**Endpoint:** `GET /visitors/artifacts/{artifactId}`

**Example:**
```
GET /visitors/artifacts/beb1f5df-00e9-408b-aedc-4b8c4770f46a
```

**Response:**
```json
{
  "code": 200,
  "statusCode": "Success",
  "message": "Take artifact successfully",
  "data": {
    "id": "beb1f5df-00e9-408b-aedc-4b8c4770f46a",
    "artifactCode": "BAO-ART-0003-20251103060746",
    "name": "Bình vạc bằng đồng",
    "periodTime": "Trần–Hồ",
    "description": "Bình vạc cổ với họa tiết hoa văn lá sen...",
    "isOriginal": true,
    "weight": 20,
    "height": 35,
    "width": 16,
    "length": 45,
    "status": "OnDisplay",
    "displayPositionName": "C1",
    "areaName": "Khu vực trưng bày đồ đồng cổ",
    "mediaItems": [
      {
        "id": "7c1dc0d4-effc-4cc8-a90c-7585a63a98db",
        "mediaType": "Image",
        "filePath": "https://storage.googleapis.com/museum-artifact-storage/...",
        "fileFormat": "jpeg",
        "status": "Active"
      }
    ]
  }
}
```

### 8. Tìm kiếm Hiện vật
**Endpoint:** `GET /visitors/artifacts`

**Query Parameters:**
- `pageIndex` (int, default: 1)
- `pageSize` (int, default: 10)
- `artifactCode` (string, optional) - Tìm theo mã QR
- `name` (string, optional) - Tìm theo tên
- `includeDeleted` (bool, default: false)

**Example:**
```
GET /visitors/artifacts?pageIndex=1&pageSize=10
GET /visitors/artifacts?artifactCode=BAO-ART-0003-20251103060746&pageSize=1
GET /visitors/artifacts?name=Bình vạc
```

**Response:** Giống như API #6

---

## 💬 Chat AI APIs

### 9. Gửi tin nhắn đến AI Chat Bot
**Endpoint:** `POST /chat/generate`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "prompt": "1+1"
}
```

**Response:**
```
1+1 = 2
```

**Note:** API này trả về plain text response, không phải JSON.

**Example prompts:**
- "Tìm bảo tàng gần tôi"
- "Giới thiệu về hiện vật nổi bật"
- "Giờ mở cửa của bảo tàng"
- "1+1"

---

## 🎯 QR Code Scanning Flow

### Khi quét QR Code:

1. **QR Code format:** `ARTIFACT:{artifactCode}`
   - Ví dụ: `ARTIFACT:BAO-ART-0003-20251103060746`

2. **App xử lý:**
   - Extract `artifactCode` từ QR
   - Gọi API: `GET /visitors/artifacts?artifactCode={code}&pageSize=1`
   - Lấy `artifactId` từ kết quả
   - Gọi API: `GET /visitors/artifacts/{artifactId}` để lấy chi tiết đầy đủ
   - Hiển thị màn hình chi tiết hiện vật

---

## 📝 Status Values

### Museum Status:
- `Active` - Hoạt động
- `Inactive` - Ngừng hoạt động

### Artifact Status:
- `OnDisplay` - Đang trưng bày
- `InStorage` - Trong kho
- `UnderMaintenance` - Đang bảo trì
- `Deleted` - Đã xóa

### Visitor Status:
- `Active` - Hoạt động
- `Inactive` - Ngừng hoạt động
- `Banned` - Bị cấm

---

## 🔧 Error Handling

Tất cả API trả về format:
```json
{
  "code": 400/401/404/500,
  "statusCode": "Error",
  "message": "Error message here",
  "data": null
}
```

**Common Error Codes:**
- `400` - Bad Request
- `401` - Unauthorized (token không hợp lệ hoặc hết hạn)
- `404` - Not Found
- `500` - Internal Server Error

