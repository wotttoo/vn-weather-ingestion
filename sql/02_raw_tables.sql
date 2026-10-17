-- Các bảng của lớp raw. Mỗi lần chạy pipeline đều ghi thêm bản ghi mới,
-- vì vậy các bảng này KHÔNG có ràng buộc chống trùng nội dung.
 
-- ---------------------------------------------------------------------
-- raw.weather_daily: mỗi dòng là MỘT phản hồi của Open-Meteo API
-- (một địa điểm, một khoảng ngày).
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS raw.weather_daily (
    _raw_id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    _batch_id           TEXT            NOT NULL,
    _ingested_at        TIMESTAMPTZ     NOT NULL DEFAULT now(),
    _source             TEXT            NOT NULL,
    _request_params     JSONB,           
    _payload_hash       TEXT,            
    payload             JSONB           NOT NULL         
);

CREATE INDEX IF NOT EXISTS idx_raw_weather_daily_batch
    ON raw.weather_daily (_batch_id);

COMMENT ON TABLE raw.weather_daily IS
    'Phản hồi nguyên bản từ Open-Meteo Historical Weather API, mỗi dòng một lần gọi.';
COMMENT ON COLUMN raw.weather_daily._raw_id IS
    'Khóa định danh bản ghi raw; staging tham chiếu ngược qua cột này.';
COMMENT ON COLUMN raw.weather_daily._batch_id IS
    'Mã lần chạy pipeline; dùng để nhóm, xóa hoặc nạp lại theo lần chạy và đối chiếu với log.';
COMMENT ON COLUMN raw.weather_daily._ingested_at IS
    'Thời điểm bản ghi được ghi vào lớp raw.';
COMMENT ON COLUMN raw.weather_daily._source IS
    'Tên nguồn và endpoint, ví dụ open-meteo/archive.';
COMMENT ON COLUMN raw.weather_daily._request_params IS
    'Tham số của yêu cầu: location_id, tọa độ gửi lên, khoảng ngày, danh sách biến.';
COMMENT ON COLUMN raw.weather_daily._payload_hash IS
    'Giá trị băm của khối "daily" (không băm cả phản hồi vì generationtime_ms thay đổi mỗi lần gọi).';
COMMENT ON COLUMN raw.weather_daily.payload IS
    'Phản hồi JSON nguyên bản, chưa ép kiểu, chưa lọc.';

-- ---------------------------------------------------------------------
-- raw.locations: mỗi dòng là MỘT dòng của file CSV danh mục địa điểm.
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS raw.locations (
    _raw_id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    _batch_id       TEXT            NOT NULL,
    _ingested_at    TIMESTAMPTZ     NOT NULL DEFAULT now(),
    _source         TEXT            NOT NULL,
    payload         JSONB           NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_raw_locations_batch
    ON raw.locations (_batch_id);

COMMENT ON TABLE raw.locations IS
    'Các dòng nguyên bản của file CSV danh mục địa điểm, chưa ép kiểu.';
COMMENT ON COLUMN raw.locations._source IS
    'Tên file CSV nguồn.';
COMMENT ON COLUMN raw.locations.payload IS
    'Nội dung một dòng CSV dạng khóa - giá trị; mọi giá trị đều là chuỗi.';