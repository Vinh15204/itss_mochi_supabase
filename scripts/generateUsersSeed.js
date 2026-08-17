import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const rawUsers = [
  { "name": "Cường Nguyễn", "email": "cuongdung30102022@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocLpB5LC8l_oR5L_wPBR7agQ7LUunGC98aPvD2CeWKCYFqC5IMI=s96-c" },
  { "name": "Thang ND", "email": "ngj3527@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocK2KTvuwBVPXBZ4Tu4dUe6ykXEJzoSsHOhYTrQMMTCu8ZxitCg=s96-c" },
  { "name": "Võ Huỳnh Long", "email": "111123456789long@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocJ1dlV8c2cf5exjF2PuBU4Abz4UOYP1BPyCPtxTPiF3gylLdeUt=s96-c" },
  { "name": "trung A trunga", "email": "nguoimoiden5006@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocKsY_9p3mq8xN_gr_9iQqOS7oveAvDIlR1_Wnm6pMucY1kyA52l=s96-c" },
  { "name": "Uông Minh Duy", "email": "u.minhduy.2301@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocK2pQal7oa86XvnA0ou0l5bj4WbG0yF4VcbZl6XJHj-6pBfgDMX=s96-c" },
  { "name": "Bùi Ánh Minh", "email": "anhminhbui1501@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocJ5UmR8tAm9MNrxQb_ET2O05mIYGfQNsYP2qvW0V4X9Z6bAjg=s96-c" },
  { "name": "Nguyệt Phương Trần", "email": "nguytran203@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocI-Xguy3dPAO-qOfNiYOPSSHoPl_is4TvJZqnNssIkWoPFcHA=s96-c" },
  { "name": "Văn Tân Nguyễn", "email": "vantann078@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocKWdexWKso8ICy8jV9U87e0nxZaJ11EdFb2Z0_2bYiyyx2_vofa=s96-c" },
  { "name": "Lê Thành Nam", "email": "curuabro.ltn2005@gmail.com", "avatar": "https://api.dicebear.com/7.x/avataaars/svg?seed=NamLe" },
  { "name": "Vinh Nguyễn", "email": "quangvinh13.hd@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocIjd1PCb39-584uVob0CW09qln5Lr-BoxOZpUw0MXhC4nPgPQ=s96-c" },
  { "name": "Tâm Đào", "email": "sinevil98@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocJtTQyjxyAFmv_ULLfXVbGodvTdkboeKKatA2vQQL3zHEP_2qI=s96-c" },
  { "name": "Trần Dung", "email": "trandung15012005@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocIeTt7nI9mmfn7-BcPWyc8cgN0T0S74mmLDgFWpuBYGgRlnDy8J=s96-c" },
  { "name": "Chí Nguyên Trần Văn", "email": "www.nguyenkz@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocLSJkcuq0r-KGqsiXw9BmqQs2VDEQkwwGmojPSjD3uEriSYP0Mn=s96-c" },
  { "name": "Vũ Nguyễn Thế", "email": "vunguyenthe.work@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocKDvKZNzt0e-Z55_fTFtKunujARtjkaG5Dz52zz-c6Uff7x8ew=s96-c" },
  { "name": "Đức Quốc Đặng", "email": "ducquocdang86@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocIvyQumu8ez1eEAEFAC0qHDsb6j0avlivT0FdtRsXyJLIp9NA=s96-c" },
  { "name": "Phạm Minh Tuấn", "email": "phamminhtuan4399@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocKuuiWoougx3AD8ZAOmFuF2i1B1mv719Y1yHAHboDSXOC7-X9ue=s96-c" },
  { "name": "Hoàng Huỳnh", "email": "huynhgiahoangc11@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocKR_6AS42DUlcvb3Gdvdml9pAlEVWa-LwljTc1fFYcaRkN-wOI-=s96-c" },
  { "name": "Thịnh Lại", "email": "laithinh03082010@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocJ25IY70U7xyR30JWV-cZi0MK-K_V_FEWjUJxzkIgAv10qiLA=s96-c" },
  { "name": "Đức Hoàng", "email": "duchoang2907@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocIETYyI5r_Sr6GoOap0UGfi5uqiPbgoizjFXmap4PuVZEGqEqU=s96-c" },
  { "name": "Phúc Bảo Nguyễn", "email": "phucbaovlog@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocKHOQ5H6nu6kTL_9YA3LB3Lf943xu0s9YIlRKnedwKgpZSTlgc=s96-c" },
  { "name": "Vũ Xuân Hoàng", "email": "vuxuanhoang0501@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocJNdjTUdCI9FKLBu1xNW6dCTjiJ63PqAQTvpfd2jF-DrqjZgA=s96-c" },
  { "name": "Nguyễn Đình Đại Minh", "email": "nguyendinhdaiminh08@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocJEYLaNJvhgOZ9TO61QroO8mCUrH5h5SfWZzTRV4lvcgnM248uG=s96-c" },
  { "name": "Phan Khang", "email": "khangphan240220032@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocKHji_NbXjl_KAkEIi3PkzRtUBeQbDvsiubXaa0aDaJmxt6Gw=s96-c" },
  { "name": "Lương Đình Khanh", "email": "dinhkhanhluong611@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocIInAT9NBYkWBqcEs4zsEtwnchod2rI6vw1bTk8K0VVWphIV_Q=s96-c" },
  { "name": "Xuân Thắng Võ", "email": "caheo356@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocKakj-KnNzzMDF-28MSOyzGcgtti7GPFSrDi_TXj9jciV8RVw=s96-c" },
  { "name": "Dương Tiến Anh Nhàn", "email": "duongtienanhnhan@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocKq4QELsL9uFG7iGvBjikzl8xm2JbgOL3_T-yNjlj-wssU8ZA=s96-c" },
  { "name": "Đức Minh", "email": "harzest03@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocJtOQuQl2yemiCf2phLxTZFLbJBRfB9rBbQEbq-mrCKVNgl3w=s96-c" },
  { "name": "Duy Khang Nguyễn", "email": "khangd30906@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocIlVMmxW17Lnnv1gcvhWyeP9K2b0-6M7yZ9grFNjcraTdWnSg=s96-c" },
  { "name": "Quang Nghị Nguyễn", "email": "nguyenquangnghi152@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocLYlgq5U2W1IFubApDxZW6sM_LMU0esxenfV8ElxuHLQlJ34Q=s96-c" },
  { "name": "Hoa Nguyễn", "email": "hoanguyenmayart@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocKSIEUn4MvXp6tR0H5VQpulGoozKqU-zs3Tal5_RXvkIuSd5A=s96-c" },
  { "name": "Tuấn Nguyễn Anh", "email": "tuan65485@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocI_05VNMrdv-hNzzHsO1eFTtlvrQS3BisDX5jZOxP8NjSiQzumu=s96-c" },
  { "name": "Phúc Lợi Nguyễn", "email": "phucloinguyentu@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocIeMbVy1-Vknbc2rg8FMnFcXPFRC_IdZDTV18pFVjbhjXc7Kdxv=s96-c" },
  { "name": "Võ Trần Nhật Hà", "email": "aw.votrannhatha@gmail.com", "avatar": "https://api.dicebear.com/7.x/avataaars/svg?seed=NhatHa" },
  { "name": "Lê Hoàng Chương", "email": "lhchuong06@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocIJAUVnm4p8c65JFxQgFCmqrb4ttJ978LOhOGT879PwEH7LyA=s96-c" },
  { "name": "Trần Quốc Đại", "email": "dai10112008@gmail.com", "avatar": "https://api.dicebear.com/7.x/avataaars/svg?seed=QuocDai" },
  { "name": "Nguyễn Hoàng Nam", "email": "bbruh4995@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocKFubBp3dm71dn4QUWxquTKwUVKE9hmh3Xfim8gaVng5EdQUg=s96-c" },
  { "name": "Trần Quốc Huy", "email": "cccccccc520651@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocL4JeHWjbdHbhkUZSKw73BeIJXjuECUieoVviXeq6TF-dukrQ=s96-c" },
  { "name": "Lê Bảo Ngọc", "email": "asflyte@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocLrfbGmbAW_gRhJvNBXApU01u5dKBuxow_gCnigSG0fXC8Q-X8=s96-c" },
  { "name": "Phạm Tuấn Hùng", "email": "teamtuoithoaov@gmail.com", "avatar": "https://lh3.googleusercontent.com/a/ACg8ocIJEZMqc7UpCC_OMK-lOUzhluX76t1hAMkOSO49yofDwak3WIs=s96-c" },
  { "name": "Nguyễn Thanh Sơn", "email": "nnvfake1@gmail.com", "avatar": "https://api.dicebear.com/7.x/avataaars/svg?seed=ThanhSon" }
];

const majors = ['it', 'engineering', 'medical', 'economics', 'japanese', 'toeic'];
const years = ['K65', 'K66', 'K67', 'K68', 'K69'];

let sql = `-- =========================================================================
-- SEED 40 NGƯỜI DÙNG THỰC NGHIỆM CHO DỰ ÁN MOCHI (LINGUA)
-- =========================================================================

-- 1. ĐẢM BẢO BẢNG PUBLIC.PROFILES TỒN TẠI
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE,
  username TEXT,
  full_name TEXT,
  avatar_url TEXT,
  major TEXT DEFAULT 'it',
  academic_level TEXT DEFAULT 'K67',
  daily_minutes INTEGER DEFAULT 15,
  daily_words INTEGER DEFAULT 15,
  study_goal TEXT DEFAULT 'career',
  preferred_language TEXT DEFAULT 'vi',
  is_pro BOOLEAN DEFAULT FALSE,
  streak INTEGER DEFAULT 0,
  exp INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,
  profile_setup_completed BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public profiles viewable by everyone" ON public.profiles;
CREATE POLICY "Public profiles viewable by everyone" ON public.profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public can insert or update profiles" ON public.profiles;
CREATE POLICY "Public can insert or update profiles" ON public.profiles FOR ALL USING (true);

-- 2. NẠP TOÀN BỘ 40 NGƯỜI DÙNG VÀO BẢNG PROFILES
INSERT INTO public.profiles (
  email, username, full_name, avatar_url, major, academic_level, 
  daily_minutes, daily_words, study_goal, is_pro, streak, exp, level, profile_setup_completed
) VALUES
`;

const values = rawUsers.map((u, index) => {
  const major = majors[index % majors.length];
  const year = years[index % years.length];
  const streak = ((index * 3) % 28) + 2; // 2 - 30 ngày
  const exp = 300 + index * 85;
  const level = Math.floor(exp / 400) + 1;
  const isPro = index % 4 === 0; // 25% Pro users
  const dailyMin = (index % 3 === 0) ? 20 : 15;
  const dailyWords = (index % 3 === 0) ? 20 : 15;
  const avatar = u.avatar && u.avatar.trim() ? u.avatar : `https://api.dicebear.com/7.x/avataaars/svg?seed=${encodeURIComponent(u.name)}`;
  const cleanName = u.name.replace(/'/g, "''");
  const cleanUsername = u.name.replace(/'/g, "''").replace(/[^a-zA-Z0-9_\s]/g, '').trim() || u.email.split('@')[0];

  return `('${u.email}', '${cleanUsername}', '${cleanName}', '${avatar}', '${major}', '${year}', ${dailyMin}, ${dailyWords}, 'career', ${isPro}, ${streak}, ${exp}, ${level}, true)`;
});

sql += values.join(',\n') + `\nON CONFLICT (email) DO UPDATE SET\n  full_name = EXCLUDED.full_name,\n  avatar_url = EXCLUDED.avatar_url,\n  major = EXCLUDED.major,\n  streak = EXCLUDED.streak,\n  exp = EXCLUDED.exp,\n  level = EXCLUDED.level;\n`;

const outputPath = path.join(__dirname, '..', 'data', 'seed_mock_users.sql');
fs.writeFileSync(outputPath, sql, 'utf-8');
console.log('Successfully generated:', outputPath);
