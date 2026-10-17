-- Các bảng của lớp staging: đã ép kiểu, có khóa chính, không trùng lặp.
-- Không đặt khóa ngoại giữa hai bảng: staging.locations được ghi đè
-- toàn bộ mỗi lần chạy, khóa ngoại sẽ chặn bước xóa. Mỗi bảng staging chỉ phụ thuộc vào một bảng raw.
 
-- ---------------------------------------------------------------------
-- staging.locations: danh mục địa điểm, mỗi địa điểm một dòng.
-- Cách ghi: ghi đè toàn bộ (bảng nhỏ).
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS staging.locations (
    location_id TEXT            PRIMARY KEY,
    name        TEXT            NOT NULL,
    latitude    NUMERIC(8, 5)   NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude  NUMERIC(8, 5)   NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    _batch_id   TEXT            NOT NULL
);

COMMENT ON TABLE staging.locations IS
    'Danh mục địa điểm đã chuẩn hóa; ghi đè toàn bộ mỗi lần chạy.';
COMMENT ON COLUMN staging.locations.location_id IS
    'Mã địa điểm, ví dụ HN.';

-- ---------------------------------------------------------------------
-- staging.weather_daily: thời tiết theo ngày, mỗi (địa điểm, ngày) một dòng.
-- Cách ghi: upsert theo khóa chính (INSERT ... ON CONFLICT).
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS staging.weather_daily(
    location_id TEXT            NOT NULL,
    date        DATE            NOT NULL,
    temp_min    NUMERIC(4, 1),
    temp_max    NUMERIC(4, 1),
    temp_mean   NUMERIC(4, 1),
    precip_mm   NUMERIC(6, 2)   CHECK (precip_mm >= 0),
    _raw_id     BIGINT          NOT NULL,
    _batch_id   TEXT            NOT NULL,
    _updated_at TIMESTAMPTZ     NOT NULL DEFAULT now(),

    -- Khóa chính: mỗi địa điểm chỉ có một dòng cho mỗi ngày.
    -- Đây là nền tảng của upsert và của việc chống trùng.
    CONSTRAINT pk_weather_daily PRIMARY KEY (location_id, date),

    -- Chốt chặn chất lượng: nhiệt độ thấp nhất không vượt nhiệt độ cao nhất
    CONSTRAINT chk_temp_range CHECK (temp_min <= temp_max)
);

COMMENT ON TABLE staging.weather_daily IS
    'Thời tiết theo ngày đã chuẩn hóa; khóa (location_id, date); ghi bằng upsert.';
COMMENT ON COLUMN staging.weather_daily.temp_max IS 'Nhiệt độ cao nhất trong ngày (°C).';
COMMENT ON COLUMN staging.weather_daily.temp_min IS 'Nhiệt độ thấp nhất trong ngày (°C).';
COMMENT ON COLUMN staging.weather_daily.temp_mean IS 'Nhiệt độ trung bình trong ngày (°C).';
COMMENT ON COLUMN staging.weather_daily.precip_mm IS 'Tổng lượng mưa trong ngày (mm).';
COMMENT ON COLUMN staging.weather_daily._raw_id IS
    'Bản ghi raw đã sinh ra dòng này, dùng để truy vết.';
COMMENT ON COLUMN staging.weather_daily._updated_at IS
    'Thời điểm dòng được ghi hoặc cập nhật gần nhất.';