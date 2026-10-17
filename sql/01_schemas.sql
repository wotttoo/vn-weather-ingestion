-- Tạo hai schema tương ứng hai lớp dữ liệu của pipeline.
-- IF NOT EXISTS: chạy lại file nhiều lần cũng không báo lỗi.

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;

COMMENT ON SCHEMA raw IS
    'Lớp raw: dữ liệu nguyên bản từ nguồn kèm metadata, chỉ ghi thêm (append-only).';
COMMENT ON SCHEMA staging IS
    'Lớp staging: dữ liệu đã ép kiểu, chuẩn hóa, có khóa chính, không trùng lặp.';