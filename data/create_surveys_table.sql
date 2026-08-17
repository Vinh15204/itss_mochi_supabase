-- =========================================================================
-- TẠO BẢNG KHẢO SÁT TRẢI NGHIỆM NGƯỜI DÙNG (CH2021 ĐỔI MỚI SÁNG TẠO & KHỞI NGHIỆP)
-- =========================================================================

CREATE TABLE IF NOT EXISTS public.surveys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  full_name TEXT,
  email TEXT,
  academic_year TEXT,                                  -- K65, K66, K67, K68, K69...
  major TEXT,                                          -- Chuyên ngành
  university TEXT DEFAULT 'Đại học Bách khoa Hà Nội',  -- Trường ĐH
  app_understanding TEXT,                              -- Nhận thức về ứng dụng
  value_attraction_score INTEGER DEFAULT 5,            -- Mức độ hấp dẫn (1-5)
  value_attraction_reason TEXT,                        -- Lý do hấp dẫn
  daily_usage_scenario TEXT,                           -- Tình huống sử dụng thực tế
  most_important_feature TEXT,                         -- Tính năng quan trọng nhất
  feature_reason TEXT,                                 -- Lý do chọn tính năng
  competitive_advantage TEXT,                          -- Điểm vượt trội so với đối thủ
  improvement_suggestions TEXT,                        -- Đề xuất cải tiến
  willingness_to_pay TEXT,                             -- Khảo sát giá (49k/tháng, 349k/năm...)
  nps_score INTEGER DEFAULT 10,                        -- Điểm giới thiệu NPS (1-10)
  overall_rating INTEGER DEFAULT 5,                    -- Đánh giá chung (1-5 sao)
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Bật Row Level Security (RLS)
ALTER TABLE public.surveys ENABLE ROW LEVEL SECURITY;

-- Cho phép mọi người dùng (kể cả khách vãng lai và người đã đăng nhập) gửi khảo sát
DROP POLICY IF EXISTS "Public can submit survey" ON public.surveys;
CREATE POLICY "Public can submit survey" ON public.surveys
FOR INSERT WITH CHECK (true);

-- Cho phép xem kết quả khảo sát
DROP POLICY IF EXISTS "Public can view survey" ON public.surveys;
CREATE POLICY "Public can view survey" ON public.surveys
FOR SELECT USING (true);
