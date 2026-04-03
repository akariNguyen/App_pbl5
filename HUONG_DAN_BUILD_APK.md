# Hướng dẫn build APK – Orchid Classifier

## Những thay đổi đã được thực hiện

- Tên app: `Orchid Classifier` (thay vì `flutter_application`)
- Application ID: `com.huynhthai.orchidclassifier`
- Version: `1.0.0+1`
- Đã xóa `android:usesCleartextTraffic="true"` (không cần vì dùng HTTPS qua Cloudflare)
- Server URL: `https://orchid.huynhthai.xyz` (giữ nguyên)
- Permissions: INTERNET, CAMERA, READ_MEDIA_IMAGES (đầy đủ)

---

## Yêu cầu trên máy tính của bạn

- Flutter SDK đã cài (chạy `flutter --version` để kiểm tra)
- Android SDK / Android Studio đã cài
- Java 17 trở lên

---

## Bước 1: Mở terminal trong thư mục project

```bash
cd đường/dẫn/đến/flutter_application
```

## Bước 2: Lấy dependencies

```bash
flutter pub get
```

## Bước 3: Build APK release

```bash
flutter build apk --release
```

> APK sẽ được tạo tại:
> `build/app/outputs/flutter-apk/app-release.apk`

---

## Cài APK lên điện thoại

### Cách 1: Chuyển file trực tiếp
1. Copy file `app-release.apk` vào điện thoại qua USB/Bluetooth/Drive
2. Trên điện thoại: **Cài đặt → Bảo mật → Cho phép cài từ nguồn không xác định**
3. Mở file APK và cài đặt

### Cách 2: Dùng ADB (nếu có Developer Options)
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## Lưu ý quan trọng

- App cần có **kết nối internet** để gửi ảnh lên server Raspberry Pi 5
- Server phải đang chạy và Cloudflare tunnel phải active
- Nếu điện thoại báo lỗi khi cài, hãy bật "Install unknown apps" trong Settings

---

## Build APK nhỏ hơn (tùy chọn)

Nếu muốn tạo APK riêng cho từng kiến trúc chip (nhỏ hơn ~50%):
```bash
flutter build apk --split-per-abi --release
```
Sẽ tạo ra 3 file:
- `app-armeabi-v7a-release.apk` (điện thoại cũ 32-bit)
- `app-arm64-v8a-release.apk` (điện thoại mới 64-bit — **dùng cái này**)
- `app-x86_64-release.apk` (emulator)
