<div align="center">

# Bài giữa kỳ Linux ngày 29/06

**Lời giải đề giữa kỳ của Sơn**

| Họ và tên | Mã sinh viên |
| --- | --- |
| Đỗ Văn Sơn | 2300412 |

</div>

## Cấu trúc thư mục

```text
.
├── README.md
├── assets/
│   ├── code-de-son.png
│   └── diagram-de-son.png
├── diagrams/
│   └── de_son_flow.puml
├── scripts/
│   └── de_son.sh
└── tests/
    └── run_tests.sh
```

## Sơ đồ xử lý

![Sơ đồ xử lý Đề của Sơn](assets/diagram-de-son.png)

## Nội dung bài giữa kỳ

Script `scripts/de_son.sh` thực hiện lần lượt 10 câu của đề:

| Câu | Chức năng |
| --- | --- |
| 1 | Tạo thư mục `/root/baitap`. |
| 2 | Đọc `/etc/passwd`, đếm người dùng hệ thống có `UID < 1000`, kiểm tra người dùng có `UID=100`. |
| 3 | Lọc người dùng có `UID=100`, `GID=100` và ghi vào `/root/baitap/dsuser`. |
| 4 | Đọc `/etc/group`, đếm nhóm hệ thống có `GID < 1000`. |
| 5 | Tạo các nhóm `hocvien`, `admin`, `user`. |
| 6 | Tạo các tài khoản `hv1`, `hv2`, `hv3`, `user1`, `user2` và đặt mật khẩu `123456`. |
| 7 | Hủy tài khoản `hv3`. |
| 8 | Cấp quyền `640` cho tập tin `dsuser`. |
| 9 | Đặt `umask 027`, tạo tập tin và thư mục để so sánh quyền mặc định. |
| 10 | Đăng nhập bằng `user1` và thử đọc tập tin `dsuser`. |

## Ảnh chụp mã nguồn

![Ảnh chụp mã nguồn Đề của Sơn](assets/code-de-son.png)

## Cách chạy

```bash
chmod +x scripts/de_son.sh
sudo bash scripts/de_son.sh
```

## Kiểm thử

```bash
bash tests/run_tests.sh
```

Kiểm thử kiểm tra cú pháp Bash và sự tồn tại của các tệp chính trong bài.
