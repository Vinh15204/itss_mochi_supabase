-- =========================================================================
-- SEED 36 NGƯỜI DÙNG THỰC CÓ AVATAR GOOGLE CHO DỰ ÁN MOCHI (LINGUA)
-- =========================================================================

-- 1. GỠ BỎ RÀNG BUỘC KHÓA NGOẠI STRICT ĐỂ CHO PHÉP TẠO MOCK PROFILES
ALTER TABLE IF EXISTS public.profiles 
  DROP CONSTRAINT IF EXISTS profiles_id_fkey;

-- Đảm bảo id có giá trị mặc định gen_random_uuid() và có cột role
ALTER TABLE IF EXISTS public.profiles 
  ALTER COLUMN id SET DEFAULT gen_random_uuid();

ALTER TABLE IF EXISTS public.profiles 
  ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user';

-- Bật RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public profiles viewable by everyone" ON public.profiles;
CREATE POLICY "Public profiles viewable by everyone" ON public.profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public can insert or update profiles" ON public.profiles;
CREATE POLICY "Public can insert or update profiles" ON public.profiles FOR ALL USING (true);

-- 2. XÓA CÁC BẢN GHI TRÙNG EMAIL NẾU ĐÃ CÓ TRƯỚC ĐÓ
DELETE FROM public.profiles WHERE email IN (
  'cuongdung30102022@gmail.com', 'ngj3527@gmail.com', '111123456789long@gmail.com',
  'nguoimoiden5006@gmail.com', 'u.minhduy.2301@gmail.com', 'bbruh4995@gmail.com',
  'anhminhbui1501@gmail.com', 'nguytran203@gmail.com', 'vantann078@gmail.com',
  'quangvinh13.hd@gmail.com', 'sinevil98@gmail.com', 'trandung15012005@gmail.com',
  'www.nguyenkz@gmail.com', 'vunguyenthe.work@gmail.com', 'ducquocdang86@gmail.com',
  'phamminhtuan4399@gmail.com', 'huynhgiahoangc11@gmail.com', 'laithinh03082010@gmail.com',
  'duchoang2907@gmail.com', 'phucbaovlog@gmail.com', 'cccccccc520651@gmail.com',
  'vuxuanhoang0501@gmail.com', 'nnvfake1@gmail.com', 'nguyendinhdaiminh08@gmail.com',
  'khangphan240220032@gmail.com', 'dinhkhanhluong611@gmail.com', 'caheo356@gmail.com',
  'asflyte@gmail.com', 'duongtienanhnhan@gmail.com', 'harzest03@gmail.com',
  'khangd30906@gmail.com', 'nguyenquangnghi152@gmail.com', 'hoanguyenmayart@gmail.com',
  'teamtuoithoaov@gmail.com', 'tuan65485@gmail.com', 'phucloinguyentu@gmail.com',
  'lhchuong06@gmail.com'
);

-- 3. NẠP TOÀN BỘ 36 NGƯỜI DÙNG KÈM GEN_RANDOM_UUID()
INSERT INTO public.profiles (
  id, email, username, full_name, avatar_url, major, academic_level, 
  daily_minutes, daily_words, study_goal, is_pro, streak, exp, level, profile_setup_completed
) VALUES
(gen_random_uuid(), 'cuongdung30102022@gmail.com', 'Cuong Nguyen', 'Cường Nguyễn', 'https://lh3.googleusercontent.com/a/ACg8ocLpB5LC8l_oR5L_wPBR7agQ7LUunGC98aPvD2CeWKCYFqC5IMI=s96-c', 'it', 'K66', 20, 20, 'career', true, 18, 1850, 5, true),
(gen_random_uuid(), 'ngj3527@gmail.com', 'Thang ND', 'Thắng Nguyễn', 'https://lh3.googleusercontent.com/a/ACg8ocK2KTvuwBVPXBZ4Tu4dUe6ykXEJzoSsHOhYTrQMMTCu8ZxitCg=s96-c', 'engineering', 'K67', 15, 15, 'career', false, 7, 720, 2, true),
(gen_random_uuid(), '111123456789long@gmail.com', 'Vo Huynh Long', 'Võ Huỳnh Long', 'https://lh3.googleusercontent.com/a/ACg8ocJ1dlV8c2cf5exjF2PuBU4Abz4UOYP1BPyCPtxTPiF3gylLdeUt=s96-c', 'medical', 'K66', 15, 15, 'career', false, 12, 1250, 4, true),
(gen_random_uuid(), 'nguoimoiden5006@gmail.com', 'Trung Anh', 'Trần Trung Anh', 'https://lh3.googleusercontent.com/a/ACg8ocKsY_9p3mq8xN_gr_9iQqOS7oveAvDIlR1_Wnm6pMucY1kyA52l=s96-c', 'economics', 'K68', 20, 20, 'career', true, 24, 2400, 6, true),
(gen_random_uuid(), 'u.minhduy.2301@gmail.com', 'Uong Minh Duy', 'Uông Minh Duy', 'https://lh3.googleusercontent.com/a/ACg8ocK2pQal7oa86XvnA0ou0l5bj4WbG0yF4VcbZl6XJHj-6pBfgDMX=s96-c', 'it', 'K67', 15, 15, 'career', false, 5, 540, 2, true),
(gen_random_uuid(), 'bbruh4995@gmail.com', 'Hoang Nam', 'Nguyễn Hoàng Nam', 'https://lh3.googleusercontent.com/a/ACg8ocKFubBp3dm71dn4QUWxquTKwUVKE9hmh3Xfim8gaVng5EdQUg=s96-c', 'toeic', 'K66', 15, 15, 'career', false, 9, 910, 3, true),
(gen_random_uuid(), 'anhminhbui1501@gmail.com', 'Bui Anh Minh', 'Bùi Ánh Minh', 'https://lh3.googleusercontent.com/a/ACg8ocJ5UmR8tAm9MNrxQb_ET2O05mIYGfQNsYP2qvW0V4X9Z6bAjg=s96-c', 'engineering', 'K67', 20, 20, 'career', true, 15, 1600, 4, true),
(gen_random_uuid(), 'nguytran203@gmail.com', 'Nguyet Phuong Tran', 'Nguyệt Phương Trần', 'https://lh3.googleusercontent.com/a/ACg8ocI-Xguy3dPAO-qOfNiYOPSSHoPl_is4TvJZqnNssIkWoPFcHA=s96-c', 'japanese', 'K68', 15, 15, 'career', false, 14, 1420, 4, true),
(gen_random_uuid(), 'vantann078@gmail.com', 'Van Tan', 'Nguyễn Văn Tân', 'https://lh3.googleusercontent.com/a/ACg8ocKWdexWKso8ICy8jV9U87e0nxZaJ11EdFb2Z0_2bYiyyx2_vofa=s96-c', 'it', 'K67', 15, 15, 'career', false, 6, 680, 2, true),
(gen_random_uuid(), 'quangvinh13.hd@gmail.com', 'Vinh Nguyen', 'Nguyễn Quang Vinh', 'https://lh3.googleusercontent.com/a/ACg8ocIjd1PCb39-584uVob0CW09qln5Lr-BoxOZpUw0MXhC4nPgPQ=s96-c', 'it', 'K66', 25, 25, 'career', true, 28, 3150, 8, true),
(gen_random_uuid(), 'sinevil98@gmail.com', 'Tam Dao', 'Đào Minh Tâm', 'https://lh3.googleusercontent.com/a/ACg8ocJtTQyjxyAFmv_ULLfXVbGodvTdkboeKKatA2vQQL3zHEP_2qI=s96-c', 'medical', 'K65', 15, 15, 'career', false, 11, 1180, 3, true),
(gen_random_uuid(), 'trandung15012005@gmail.com', 'Tran Dung', 'Trần Thùy Dung', 'https://lh3.googleusercontent.com/a/ACg8ocIeTt7nI9mmfn7-BcPWyc8cgN0T0S74mmLDgFWpuBYGgRlnDy8J=s96-c', 'economics', 'K68', 20, 20, 'career', true, 19, 1980, 5, true),
(gen_random_uuid(), 'www.nguyenkz@gmail.com', 'Chi Nguyen', 'Trần Văn Chí Nguyên', 'https://lh3.googleusercontent.com/a/ACg8ocLSJkcuq0r-KGqsiXw9BmqQs2VDEQkwwGmojPSjD3uEriSYP0Mn=s96-c', 'it', 'K66', 15, 15, 'career', false, 8, 830, 3, true),
(gen_random_uuid(), 'vunguyenthe.work@gmail.com', 'Vu Nguyen The', 'Vũ Thế Nguyễn', 'https://lh3.googleusercontent.com/a/ACg8ocKDvKZNzt0e-Z55_fTFtKunujARtjkaG5Dz52zz-c6Uff7x8ew=s96-c', 'engineering', 'K67', 15, 15, 'career', false, 13, 1350, 4, true),
(gen_random_uuid(), 'ducquocdang86@gmail.com', 'Duc Quoc Dang', 'Đặng Quốc Đức', 'https://lh3.googleusercontent.com/a/ACg8ocIvyQumu8ez1eEAEFAC0qHDsb6j0avlivT0FdtRsXyJLIp9NA=s96-c', 'it', 'K66', 20, 20, 'career', true, 21, 2190, 6, true),
(gen_random_uuid(), 'phamminhtuan4399@gmail.com', 'Tyler Takahashi', 'Phạm Minh Tuấn', 'https://lh3.googleusercontent.com/a/ACg8ocKuuiWoougx3AD8ZAOmFuF2i1B1mv719Y1yHAHboDSXOC7-X9ue=s96-c', 'japanese', 'K66', 20, 20, 'career', true, 26, 2800, 7, true),
(gen_random_uuid(), 'huynhgiahoangc11@gmail.com', 'Hoang Huynh', 'Huỳnh Gia Hoàng', 'https://lh3.googleusercontent.com/a/ACg8ocKR_6AS42DUlcvb3Gdvdml9pAlEVWa-LwljTc1fFYcaRkN-wOI-=s96-c', 'engineering', 'K68', 15, 15, 'career', false, 4, 460, 2, true),
(gen_random_uuid(), 'laithinh03082010@gmail.com', 'Thinh Lai', 'Lại Phúc Thịnh', 'https://lh3.googleusercontent.com/a/ACg8ocJ25IY70U7xyR30JWV-cZi0MK-K_V_FEWjUJxzkIgAv10qiLA=s96-c', 'economics', 'K69', 15, 15, 'career', false, 9, 940, 3, true),
(gen_random_uuid(), 'duchoang2907@gmail.com', 'Duc Hoang', 'Hoàng Minh Đức', 'https://lh3.googleusercontent.com/a/ACg8ocIETYyI5r_Sr6GoOap0UGfi5uqiPbgoizjFXmap4PuVZEGqEqU=s96-c', 'it', 'K67', 20, 20, 'career', true, 16, 1720, 5, true),
(gen_random_uuid(), 'phucbaovlog@gmail.com', 'Phuc Bao Nguyen', 'Nguyễn Phúc Bảo', 'https://lh3.googleusercontent.com/a/ACg8ocKHOQ5H6nu6kTL_9YA3LB3Lf943xu0s9YIlRKnedwKgpZSTlgc=s96-c', 'toeic', 'K67', 15, 15, 'career', false, 7, 750, 2, true),
(gen_random_uuid(), 'cccccccc520651@gmail.com', 'Quoc Huy', 'Trần Quốc Huy', 'https://lh3.googleusercontent.com/a/ACg8ocL4JeHWjbdHbhkUZSKw73BeIJXjuECUieoVviXeq6TF-dukrQ=s96-c', 'engineering', 'K68', 15, 15, 'career', false, 3, 390, 1, true),
(gen_random_uuid(), 'vuxuanhoang0501@gmail.com', 'Vu Xuan Hoang', 'Vũ Xuân Hoàng', 'https://lh3.googleusercontent.com/a/ACg8ocJNdjTUdCI9FKLBu1xNW6dCTjiJ63PqAQTvpfd2jF-DrqjZgA=s96-c', 'it', 'K66', 20, 20, 'career', true, 22, 2310, 6, true),
(gen_random_uuid(), 'nnvfake1@gmail.com', 'Thanh Son', 'Nguyễn Thanh Sơn', 'https://lhnnzbizefazdspanygn.supabase.co/storage/v1/object/public/avatars/7c43b262-5e5e-4ba4-8dcd-441b8b162082/avatar_1785426731300.jpg', 'medical', 'K66', 15, 15, 'career', false, 10, 1050, 3, true),
(gen_random_uuid(), 'nguyendinhdaiminh08@gmail.com', 'Dai Minh', 'Nguyễn Đình Đại Minh', 'https://lh3.googleusercontent.com/a/ACg8ocJEYLaNJvhgOZ9TO61QroO8mCUrH5h5SfWZzTRV4lvcgnM248uG=s96-c', 'it', 'K67', 15, 15, 'career', false, 17, 1780, 5, true),
(gen_random_uuid(), 'khangphan240220032@gmail.com', 'Phan Khang', 'Phan Văn Khang', 'https://lh3.googleusercontent.com/a/ACg8ocKHji_NbXjl_KAkEIi3PkzRtUBeQbDvsiubXaa0aDaJmxt6Gw=s96-c', 'engineering', 'K66', 20, 20, 'career', true, 19, 2010, 5, true),
(gen_random_uuid(), 'dinhkhanhluong611@gmail.com', 'Khanh Luong', 'Lương Đình Khánh', 'https://lh3.googleusercontent.com/a/ACg8ocIInAT9NBYkWBqcEs4zsEtwnchod2rI6vw1bTk8K0VVWphIV_Q=s96-c', 'economics', 'K67', 15, 15, 'career', false, 8, 860, 3, true),
(gen_random_uuid(), 'caheo356@gmail.com', 'Xuan Thang', 'Võ Ngọc Xuân Thắng', 'https://lh3.googleusercontent.com/a/ACg8ocKakj-KnNzzMDF-28MSOyzGcgtti7GPFSrDi_TXj9jciV8RVw=s96-c', 'it', 'K66', 20, 20, 'career', true, 23, 2450, 6, true),
(gen_random_uuid(), 'asflyte@gmail.com', 'Bao Ngoc', 'Lê Bảo Ngọc', 'https://lh3.googleusercontent.com/a/ACg8ocLrfbGmbAW_gRhJvNBXApU01u5dKBuxow_gCnigSG0fXC8Q-X8=s96-c', 'toeic', 'K68', 15, 15, 'career', false, 6, 620, 2, true),
(gen_random_uuid(), 'duongtienanhnhan@gmail.com', 'Tien Anh Nhan', 'Dương Tiến Anh Nhàn', 'https://lh3.googleusercontent.com/a/ACg8ocKq4QELsL9uFG7iGvBjikzl8xm2JbgOL3_T-yNjlj-wssU8ZA=s96-c', 'medical', 'K67', 15, 15, 'career', false, 14, 1490, 4, true),
(gen_random_uuid(), 'harzest03@gmail.com', 'Duc Minh', 'Phạm Đức Minh', 'https://lh3.googleusercontent.com/a/ACg8ocJtOQuQl2yemiCf2phLxTZFLbJBRfB9rBbQEbq-mrCKVNgl3w=s96-c', 'it', 'K66', 20, 20, 'career', true, 20, 2100, 6, true),
(gen_random_uuid(), 'khangd30906@gmail.com', 'Duy Khang', 'Nguyễn Duy Khang', 'https://lh3.googleusercontent.com/a/ACg8ocIlVMmxW17Lnnv1gcvhWyeP9K2b0-6M7yZ9grFNjcraTdWnSg=s96-c', 'engineering', 'K68', 15, 15, 'career', false, 5, 530, 2, true),
(gen_random_uuid(), 'nguyenquangnghi152@gmail.com', 'Quang Nghi', 'Nguyễn Quang Nghị', 'https://lh3.googleusercontent.com/a/ACg8ocLYlgq5U2W1IFubApDxZW6sM_LMU0esxenfV8ElxuHLQlJ34Q=s96-c', 'it', 'K67', 15, 15, 'career', false, 11, 1160, 3, true),
(gen_random_uuid(), 'hoanguyenmayart@gmail.com', 'Hoa Nguyen', 'Nguyễn Thị Thu Hoa', 'https://lh3.googleusercontent.com/a/ACg8ocKSIEUn4MvXp6tR0H5VQpulGoozKqU-zs3Tal5_RXvkIuSd5A=s96-c', 'economics', 'K67', 20, 20, 'career', true, 25, 2750, 7, true),
(gen_random_uuid(), 'teamtuoithoaov@gmail.com', 'Tuan Hung', 'Phạm Tuấn Hùng', 'https://lh3.googleusercontent.com/a/ACg8ocIJEZMqc7UpCC_OMK-lOUzhluX76t1hAMkOSO49yofDwak3WIs=s96-c', 'engineering', 'K66', 15, 15, 'career', false, 12, 1280, 4, true),
(gen_random_uuid(), 'tuan65485@gmail.com', 'Anh Tuan', 'Nguyễn Anh Tuấn', 'https://lh3.googleusercontent.com/a/ACg8ocI_05VNMrdv-hNzzHsO1eFTtlvrQS3BisDX5jZOxP8NjSiQzumu=s96-c', 'it', 'K67', 15, 15, 'career', false, 9, 980, 3, true),
(gen_random_uuid(), 'phucloinguyentu@gmail.com', 'Phuc Loi', 'Nguyễn Từ Phúc Lợi', 'https://lh3.googleusercontent.com/a/ACg8ocIeMbVy1-Vknbc2rg8FMnFcXPFRC_IdZDTV18pFVjbhjXc7Kdxv=s96-c', 'toeic', 'K67', 15, 15, 'career', false, 16, 1690, 5, true),
(gen_random_uuid(), 'lhchuong06@gmail.com', 'Hoang Chuong', 'Lê Hoàng Chương', 'https://lh3.googleusercontent.com/a/ACg8ocIJAUVnm4p8c65JFxQgFCmqrb4ttJ978LOhOGT879PwEH7LyA=s96-c', 'it', 'K68', 20, 20, 'career', true, 13, 1400, 4, true);
