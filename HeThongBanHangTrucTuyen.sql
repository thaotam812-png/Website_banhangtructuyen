CREATE DATABASE HeThongBanHangTrucTuyen CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE HeThongBanHangTrucTuyen;

CREATE TABLE TaiKhoan (
    taiKhoanID INT AUTO_INCREMENT PRIMARY KEY,
    tenDangNhap VARCHAR(50) NOT NULL UNIQUE,
    matKhau VARCHAR(255) NOT NULL,
    vaiTro VARCHAR(20) NOT NULL,
    ngayTao DATETIME DEFAULT NOW(),
    CHECK (vaiTro IN ('KhachHang', 'NhanVien', 'Admin'))
);

CREATE TABLE KhachHang (
    khachHangID INT AUTO_INCREMENT PRIMARY KEY,
    hoTen VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    soDienThoai VARCHAR(20),
    diaChi VARCHAR(255),
    taiKhoanID INT,
    FOREIGN KEY (taiKhoanID) REFERENCES TaiKhoan(taiKhoanID) ON DELETE CASCADE
);

CREATE TABLE NhanVien (
    nhanVienID INT AUTO_INCREMENT PRIMARY KEY,
    hoTen VARCHAR(100),
    chucVu VARCHAR(50),
    luong DECIMAL(12,2),
    taiKhoanID INT,
    FOREIGN KEY (taiKhoanID) REFERENCES TaiKhoan(taiKhoanID) ON DELETE CASCADE
);

CREATE TABLE SanPham (
    sanPhamID INT AUTO_INCREMENT PRIMARY KEY,
    tenSanPham VARCHAR(100) NOT NULL,
    moTa VARCHAR(255),
    donGia DECIMAL(10,2) NOT NULL,
    soLuongTon INT DEFAULT 0,
    hinhAnh VARCHAR(255),
    danhMuc VARCHAR(100)
);

CREATE TABLE DonHang (
    donHangID INT AUTO_INCREMENT PRIMARY KEY,
    khachHangID INT,
    ngayDatHang DATETIME DEFAULT NOW(),
    tongTien DECIMAL(12,2),
    trangThai VARCHAR(50) DEFAULT 'Chờ xử lý',
    CHECK (trangThai IN ('Chờ xử lý', 'Đã giao', 'Đã hủy')),
    FOREIGN KEY (khachHangID) REFERENCES KhachHang(khachHangID)
);

CREATE TABLE ChiTietDonHang (
    chiTietID INT AUTO_INCREMENT PRIMARY KEY,
    donHangID INT,
    sanPhamID INT,
    soLuong INT NOT NULL,
    donGia DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (donHangID) REFERENCES DonHang(donHangID) ON DELETE CASCADE,
    FOREIGN KEY (sanPhamID) REFERENCES SanPham(sanPhamID)
);

CREATE TABLE ThanhToan (
    thanhToanID INT AUTO_INCREMENT PRIMARY KEY,
    donHangID INT,
    phuongThuc VARCHAR(50),
    ngayThanhToan DATETIME DEFAULT NOW(),
    trangThai VARCHAR(50),
    CHECK (trangThai IN ('Thành công', 'Thất bại', 'Chờ xử lý')),
    FOREIGN KEY (donHangID) REFERENCES DonHang(donHangID)
);

CREATE TABLE DanhMuc (
    danhMucID INT AUTO_INCREMENT PRIMARY KEY,
    tenDanhMuc VARCHAR(100) NOT NULL,
    moTa VARCHAR(255),
    danhMucCha INT,
    FOREIGN KEY (danhMucCha) REFERENCES DanhMuc(danhMucID)
);

CREATE TABLE ChiTietSanPham (
    chiTietSPID INT AUTO_INCREMENT PRIMARY KEY,
    sanPhamID INT,
    size VARCHAR(10),
    mauSac VARCHAR(50),
    soLuongTon INT DEFAULT 0,
    FOREIGN KEY (sanPhamID) REFERENCES SanPham(sanPhamID)
);

CREATE TABLE DanhGia (
    danhGiaID INT AUTO_INCREMENT PRIMARY KEY,
    sanPhamID INT,
    khachHangID INT,
    soSao INT,
    binhLuan VARCHAR(500),
    ngayDanhGia DATETIME DEFAULT NOW(),
    CHECK (soSao BETWEEN 1 AND 5),
    FOREIGN KEY (sanPhamID) REFERENCES SanPham(sanPhamID),
    FOREIGN KEY (khachHangID) REFERENCES KhachHang(khachHangID)
);

CREATE TABLE GioHang (
    gioHangID INT AUTO_INCREMENT PRIMARY KEY,
    khachHangID INT,
    sanPhamID INT,
    chiTietSPID INT,
    soLuong INT NOT NULL,
    ngayThem DATETIME DEFAULT NOW(),
    FOREIGN KEY (khachHangID) REFERENCES KhachHang(khachHangID),
    FOREIGN KEY (sanPhamID) REFERENCES SanPham(sanPhamID),
    FOREIGN KEY (chiTietSPID) REFERENCES ChiTietSanPham(chiTietSPID)
);

CREATE TABLE KhuyenMai (
    khuyenMaiID INT AUTO_INCREMENT PRIMARY KEY,
    maCode VARCHAR(20) UNIQUE,
    phanTramGiam DECIMAL(5,2),
    giaTriGiamToiDa DECIMAL(10,2),
    ngayBatDau DATETIME,
    ngayKetThuc DATETIME,
    soLuotDung INT DEFAULT 0
);

INSERT INTO TaiKhoan (tenDangNhap, matKhau, vaiTro) VALUES
('khach1', '123456', 'KhachHang'),
('admin1', 'admin@123', 'Admin'),
('nhanvien1', 'passnv', 'NhanVien');

INSERT INTO KhachHang (hoTen, email, soDienThoai, diaChi, taiKhoanID) VALUES
('Nguyễn Văn A', 'a@gmail.com', '0901234567', 'Hà Nội', 1);

INSERT INTO NhanVien (hoTen, chucVu, luong, taiKhoanID) VALUES
('Trần Thị B', 'Bán hàng', 8000000, 3);

INSERT INTO SanPham (tenSanPham, moTa, donGia, soLuongTon, hinhAnh, danhMuc) VALUES
('Cà phê sữa', 'Cà phê sữa đá đậm vị', 25000, 100, 'cafe-sua.jpg', 'Đồ uống'),
('Trà đào', 'Trà đào cam sả tươi mát', 30000, 50, 'tra-dao.jpg', 'Đồ uống');

INSERT INTO DonHang (khachHangID, tongTien, trangThai) VALUES
(1, 55000, 'Chờ xử lý');

INSERT INTO ChiTietDonHang (donHangID, sanPhamID, soLuong, donGia) VALUES
(1, 1, 1, 25000),
(1, 2, 1, 30000);

INSERT INTO ThanhToan (donHangID, phuongThuc, trangThai) VALUES
(1, 'Thanh toán khi nhận hàng', 'Chờ xử lý');

CREATE VIEW view_DonHangChiTiet AS
SELECT 
    dh.donHangID,
    kh.hoTen AS tenKhachHang,
    sp.tenSanPham,
    ctdh.soLuong,
    ctdh.donGia,
    (ctdh.soLuong * ctdh.donGia) AS thanhTien,
    dh.ngayDatHang,
    dh.trangThai
FROM DonHang dh
JOIN KhachHang kh ON dh.khachHangID = kh.khachHangID
JOIN ChiTietDonHang ctdh ON dh.donHangID = ctdh.donHangID
JOIN SanPham sp ON ctdh.sanPhamID = sp.sanPhamID;

DELIMITER //

CREATE PROCEDURE sp_TaoDonHang (
    IN khachHangID INT,
    IN tongTien DECIMAL(12,2)
)
BEGIN
    INSERT INTO DonHang (khachHangID, tongTien, trangThai)
    VALUES (khachHangID, tongTien, 'Chờ xử lý');

    SELECT LAST_INSERT_ID() AS maDonHangMoi;
END;
//

CREATE PROCEDURE sp_CapNhatTrangThaiDonHang (
    IN donHangID INT,
    IN trangThai VARCHAR(50)
)
BEGIN
    UPDATE DonHang
    SET trangThai = trangThai
    WHERE donHangID = donHangID;
END;
//

DELIMITER ;

SELECT * FROM TaiKhoan;
