CREATE DATABASE HeThongBanHangTrucTuyen;
GO
USE HeThongBanHangTrucTuyen;
GO


CREATE TABLE TaiKhoan (
    taiKhoanID INT IDENTITY(1,1) PRIMARY KEY,
    tenDangNhap NVARCHAR(50) NOT NULL UNIQUE,
    matKhau NVARCHAR(255) NOT NULL,
    vaiTro NVARCHAR(20) CHECK (vaiTro IN (N'KhachHang', N'NhanVien', N'Admin')) NOT NULL,
    ngayTao DATETIME DEFAULT GETDATE()
);

CREATE TABLE KhachHang (
    khachHangID INT IDENTITY(1,1) PRIMARY KEY,
    hoTen NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) UNIQUE,
    soDienThoai NVARCHAR(20),
    diaChi NVARCHAR(255),
    taiKhoanID INT REFERENCES TaiKhoan(taiKhoanID) ON DELETE CASCADE
);

CREATE TABLE NhanVien (
    nhanVienID INT IDENTITY(1,1) PRIMARY KEY,
    hoTen NVARCHAR(100),
    chucVu NVARCHAR(50),
    luong DECIMAL(12,2),
    taiKhoanID INT REFERENCES TaiKhoan(taiKhoanID) ON DELETE CASCADE
);

CREATE TABLE SanPham (
    sanPhamID INT IDENTITY(1,1) PRIMARY KEY,
    tenSanPham NVARCHAR(100) NOT NULL,
    moTa NVARCHAR(255),
    donGia DECIMAL(10,2) NOT NULL,
    soLuongTon INT DEFAULT 0,
    hinhAnh NVARCHAR(255),
    danhMuc NVARCHAR(100)
);

CREATE TABLE DonHang (
    donHangID INT IDENTITY(1,1) PRIMARY KEY,
    khachHangID INT REFERENCES KhachHang(khachHangID),
    ngayDatHang DATETIME DEFAULT GETDATE(),
    tongTien DECIMAL(12,2),
    trangThai NVARCHAR(50) CHECK (trangThai IN (N'Chờ xử lý', N'Đã giao', N'Đã hủy')) DEFAULT N'Chờ xử lý'
);

CREATE TABLE ChiTietDonHang (
    chiTietID INT IDENTITY(1,1) PRIMARY KEY,
    donHangID INT REFERENCES DonHang(donHangID) ON DELETE CASCADE,
    sanPhamID INT REFERENCES SanPham(sanPhamID),
    soLuong INT NOT NULL,
    donGia DECIMAL(10,2) NOT NULL
);

CREATE TABLE ThanhToan (
    thanhToanID INT IDENTITY(1,1) PRIMARY KEY,
    donHangID INT REFERENCES DonHang(donHangID),
    phuongThuc NVARCHAR(50),
    ngayThanhToan DATETIME DEFAULT GETDATE(),
    trangThai NVARCHAR(50) CHECK (trangThai IN (N'Thành công', N'Thất bại', N'Chờ xử lý'))
);

-- Bảng danh mục chi tiết
CREATE TABLE DanhMuc (
    danhMucID INT IDENTITY(1,1) PRIMARY KEY,
    tenDanhMuc NVARCHAR(100) NOT NULL, -- Áo sơ mi, Quần jean, Phụ kiện...
    moTa NVARCHAR(255),
    danhMucCha INT REFERENCES DanhMuc(danhMucID)
);

-- Bảng chi tiết sản phẩm (size, màu)
CREATE TABLE ChiTietSanPham (
    chiTietSPID INT IDENTITY(1,1) PRIMARY KEY,
    sanPhamID INT REFERENCES SanPham(sanPhamID),
    size NVARCHAR(10), -- S, M, L, XL, XXL
    mauSac NVARCHAR(50), -- Đen, Trắng, Xanh...
    soLuongTon INT DEFAULT 0
);

-- Bảng đánh giá sản phẩm
CREATE TABLE DanhGia (
    danhGiaID INT IDENTITY(1,1) PRIMARY KEY,
    sanPhamID INT REFERENCES SanPham(sanPhamID),
    khachHangID INT REFERENCES KhachHang(khachHangID),
    soSao INT CHECK (soSao BETWEEN 1 AND 5),
    binhLuan NVARCHAR(500),
    ngayDanhGia DATETIME DEFAULT GETDATE()
);

-- Bảng giỏ hàng
CREATE TABLE GioHang (
    gioHangID INT IDENTITY(1,1) PRIMARY KEY,
    khachHangID INT REFERENCES KhachHang(khachHangID),
    sanPhamID INT REFERENCES SanPham(sanPhamID),
    chiTietSPID INT REFERENCES ChiTietSanPham(chiTietSPID),
    soLuong INT NOT NULL,
    ngayThem DATETIME DEFAULT GETDATE()
);

-- Bảng khuyến mãi/voucher
CREATE TABLE KhuyenMai (
    khuyenMaiID INT IDENTITY(1,1) PRIMARY KEY,
    maCode NVARCHAR(20) UNIQUE,
    phanTramGiam DECIMAL(5,2),
    giaTriGiamToiDa DECIMAL(10,2),
    ngayBatDau DATETIME,
    ngayKetThuc DATETIME,
    soLuotDung INT DEFAULT 0
);
-- DỮ LIỆU MẪU

INSERT INTO TaiKhoan (tenDangNhap, matKhau, vaiTro) VALUES
(N'khach1', N'123456', N'KhachHang'),
(N'admin1', N'admin@123', N'Admin'),
(N'nhanvien1', N'passnv', N'NhanVien');

INSERT INTO KhachHang (hoTen, email, soDienThoai, diaChi, taiKhoanID) VALUES
(N'Nguyễn Văn A', N'a@gmail.com', N'0901234567', N'Hà Nội', 1);

INSERT INTO NhanVien (hoTen, chucVu, luong, taiKhoanID) VALUES
(N'Trần Thị B', N'Bán hàng', 8000000, 3);

INSERT INTO SanPham (tenSanPham, moTa, donGia, soLuongTon, hinhAnh, danhMuc) VALUES
(N'Cà phê sữa', N'Cà phê sữa đá đậm vị', 25000, 100, N'cafe-sua.jpg', N'Đồ uống'),
(N'Trà đào', N'Trà đào cam sả tươi mát', 30000, 50, N'tra-dao.jpg', N'Đồ uống');

INSERT INTO DonHang (khachHangID, tongTien, trangThai) VALUES
(1, 55000, N'Chờ xử lý');

INSERT INTO ChiTietDonHang (donHangID, sanPhamID, soLuong, donGia) VALUES
(1, 1, 1, 25000),
(1, 2, 1, 30000);

INSERT INTO ThanhToan (donHangID, phuongThuc, trangThai) VALUES
(1, N'Thanh toán khi nhận hàng', N'Chờ xử lý');
GO


-- VIEW: Thông tin đơn hàng chi tiết
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
GO

-- STORED PROCEDURE: Tạo đơn hàng mới
CREATE PROCEDURE sp_TaoDonHang
    @khachHangID INT,
    @tongTien DECIMAL(12,2)
AS
BEGIN
    INSERT INTO DonHang (khachHangID, tongTien, trangThai)
    VALUES (@khachHangID, @tongTien, N'Chờ xử lý');

    SELECT SCOPE_IDENTITY() AS maDonHangMoi;
END;
GO

-- STORED PROCEDURE: Cập nhật trạng thái đơn hàng

CREATE PROCEDURE sp_CapNhatTrangThaiDonHang
    @donHangID INT,
    @trangThai NVARCHAR(50)
AS
BEGIN
    UPDATE DonHang
    SET trangThai = @trangThai
    WHERE donHangID = @donHangID;
END;
GO
SELECT * FROM TaiKhoan;
