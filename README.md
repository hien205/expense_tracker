# Receipt OCR & Expense Tracker

Ứng dụng di động được phát triển bằng Flutter nhằm hỗ trợ người dùng quản lý chi tiêu cá nhân thông qua việc quét hóa đơn, trích xuất thông tin và theo dõi các khoản thu chi.

## 1. Giới thiệu

Receipt OCR & Expense Tracker là mini-project ứng dụng công nghệ nhận dạng ký tự quang học (OCR) để hỗ trợ nhập dữ liệu hóa đơn nhanh chóng, kết hợp với cơ sở dữ liệu cục bộ để lưu trữ và quản lý chi tiêu.

## 2. Công nghệ sử dụng

- **Flutter & Dart:** Xây dựng ứng dụng di động.
- **Google ML Kit Text Recognition:** Nhận dạng văn bản từ ảnh hóa đơn, nếu đã được tích hợp trong phiên bản hiện tại.
- **SQLite / sqflite:** Lưu trữ dữ liệu chi tiêu trên thiết bị.
- **image_picker:** Chọn ảnh hoặc chụp ảnh hóa đơn.
- **Gemini API:** Hỗ trợ phân tích chi tiêu bằng AI, nếu đã cấu hình API.
- **SharedPreferences:** Lưu một số thiết lập và trạng thái ứng dụng.

> Lưu ý: Danh sách công nghệ trên cần được đối chiếu với `pubspec.yaml` và mã nguồn thực tế trước khi nộp.

## 3. Chức năng chính

- Quản lý và xem các khoản chi tiêu.
- Chọn hoặc chụp ảnh hóa đơn để nhận dạng văn bản.
- Trích xuất thông tin hóa đơn như cửa hàng, ngày và tổng tiền khi dữ liệu phù hợp.
- Lưu trữ dữ liệu chi tiêu cục bộ.
- Hiển thị thống kê chi tiêu.
- Hỗ trợ phân tích chi tiêu bằng AI nếu đã cấu hình dịch vụ.

Một số chức năng có thể yêu cầu cấu hình bổ sung hoặc kiểm thử trước khi sử dụng.

## 4. Yêu cầu môi trường

- Flutter SDK tương thích với dự án.
- Dart SDK đi kèm Flutter.
- Android Studio hoặc VS Code.
- Android Emulator hoặc thiết bị Android thật.
- Kết nối Internet đối với những chức năng cần API trực tuyến.

## 5. Hướng dẫn cài đặt

### Bước 1: Clone repository

```bash
git clone https://github.com/hien205/expense_tracker.git
cd expense_tracker
```

### Bước 2: Cài đặt thư viện

```bash
flutter pub get
```

### Bước 3: Kiểm tra cấu hình

Nếu dự án sử dụng API key, hãy cấu hình khóa theo cách phù hợp với mã nguồn. Không đưa API key thật vào repository công khai.

### Bước 4: Chạy ứng dụng

Kết nối thiết bị Android hoặc khởi động Android Emulator, sau đó chạy:

```bash
flutter run
```

### Bước 5: Kiểm tra mã nguồn

```bash
flutter analyze
flutter test
```

Các lệnh trên giúp kiểm tra lỗi phân tích tĩnh và chạy các bài kiểm thử đã được viết trong dự án.

## 6. Cấu trúc thư mục

```text
expense_tracker/
├── android/                 # Cấu hình nền tảng Android
├── ios/                     # Cấu hình nền tảng iOS
├── lib/                     # Mã nguồn Dart của ứng dụng
├── test/                    # Các bài kiểm thử
├── web/                     # Cấu hình nền tảng Web
├── windows/                 # Cấu hình nền tảng Windows
├── linux/                   # Cấu hình nền tảng Linux
├── macos/                   # Cấu hình nền tảng macOS
├── pubspec.yaml              # Khai báo dependencies
├── pubspec.lock              # Phiên bản dependencies đã khóa
├── analysis_options.yaml     # Quy tắc phân tích mã nguồn
└── README.md                 # Tài liệu hướng dẫn dự án
```

## 7. Dữ liệu và bảo mật

- Dữ liệu SQLite có thể được lưu trên thiết bị cục bộ.
- Không commit API key, mật khẩu hoặc thông tin cá nhân lên GitHub.
- Không đưa dữ liệu hóa đơn thật hoặc cơ sở dữ liệu cá nhân vào repository công khai.
- Khi sử dụng API bên ngoài, cần cấu hình khóa truy cập an toàn.

## 8. Hướng phát triển

- Cải thiện độ chính xác khi trích xuất thông tin hóa đơn.
- Hoàn thiện biểu đồ thống kê chi tiêu.
- Nâng cao khả năng phân tích và đề xuất tiết kiệm bằng AI.
- Bổ sung kiểm thử và cải thiện trải nghiệm người dùng.

## 9. Repository

GitHub: https://github.com/hien205/expense_tracker

## 10. Tác giả

Ngô Võ Phương Hiền

Mini-Project: Receipt OCR & Expense Tracker
