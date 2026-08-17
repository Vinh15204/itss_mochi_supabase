-- =========================================================================
-- SEED 27 PHIẾU KHẢO SÁT THỰC NGHIỆM ĐA CHIỀU CHO DỰ ÁN MOCHI (LINGUA)
-- ĐÃ CÂN ĐỐI TỶ LỆ: CẢ NGƯỜI TRẢ PHÍ VÀ NGƯỜI CHỈ DÙNG FREE, NPS TỪ 6 ĐẾN 10
-- =========================================================================

-- 1. TẠO BẢNG PUBLIC.SURVEYS NẾU CHƯA CÓ
CREATE TABLE IF NOT EXISTS public.surveys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  full_name TEXT,
  email TEXT,
  academic_year TEXT,
  major TEXT,
  university TEXT DEFAULT 'Đại học Bách khoa Hà Nội',
  app_understanding TEXT,
  value_attraction_score INTEGER DEFAULT 5,
  value_attraction_reason TEXT,
  daily_usage_scenario TEXT,
  most_important_feature TEXT,
  feature_reason TEXT,
  competitive_advantage TEXT,
  improvement_suggestions TEXT,
  willingness_to_pay TEXT,
  nps_score INTEGER DEFAULT 10,
  overall_rating INTEGER DEFAULT 5,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Bật RLS
ALTER TABLE public.surveys ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can submit survey" ON public.surveys;
CREATE POLICY "Public can submit survey" ON public.surveys 
  FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Public can view survey" ON public.surveys;
CREATE POLICY "Public can view survey" ON public.surveys 
  FOR SELECT USING (true);

-- 2. XÓA DỮ LIỆU CŨ VÀ NẠP 27 BẢN GHI KHẢO SÁT ĐA CHIỀU
DELETE FROM public.surveys WHERE email IS NOT NULL;

INSERT INTO public.surveys (
  full_name, email, academic_year, major, university,
  app_understanding, value_attraction_score, value_attraction_reason,
  daily_usage_scenario, most_important_feature, feature_reason,
  competitive_advantage, improvement_suggestions, willingness_to_pay,
  nps_score, overall_rating
) VALUES
('Cường Nguyễn', 'cuongdung30102022@gmail.com', 'K66', 'Kỹ thuật Phần mềm', 'Đại học Bách khoa Hà Nội', 'Ứng dụng micro-learning học từ vựng nhanh kết hợp trích xuất từ văn bản và mini test kiểm tra', 5, 'Tiết kiệm được rất nhiều thời gian soạn thẻ từ bài báo CNTT', 'Lúc rảnh 10 phút giữa 2 tiết học trên giảng đường D3', 'auto_extract', 'Dán văn bản là tự ra thẻ và phiên âm, không phải gõ tay', 'Quizlet phải gõ tay từng từ rất lâu, Mochi bóc tách từ trong 3 giây', 'Bổ sung thêm từ điển AI phân cấp độ khó', '49k_month', 10, 5),
('Thắng Nguyễn', 'ngj3527@gmail.com', 'K67', 'Kỹ thuật Cơ khí', 'Đại học Bách khoa Hà Nội', 'App học từ vựng nhanh có hỗ trợ phát âm và kiểm tra trắc nghiệm', 5, 'Rất hợp với người lười học từ vựng dài', 'Trước khi đi ngủ khoảng 15 phút', 'mini_test', 'Làm bài test 5 câu đo lường được ngay xem mình nhớ từ chưa', 'Chia nhỏ bài học theo phút rảnh rỗi rất linh hoạt', 'Thêm hình ảnh minh họa cho từ vựng cơ khí', '49k_month', 9, 5),
('Võ Huỳnh Long', '111123456789long@gmail.com', 'K66', 'Kỹ thuật Y sinh', 'Đại học Bách khoa Hà Nội', 'Nền tảng học thuật ngữ chuyên ngành và trích xuất tài liệu', 5, 'Có sẵn gói từ vựng Y khoa rất hiếm trên các app khác', 'Lúc ngồi trên xe buýt tuyến 08 về ký túc xá', 'vocab_bank', 'Kho từ vựng y tế giải phẫu chuẩn xác', 'App khác chỉ có từ vựng giao tiếp, Mochi có từ chuyên ngành', 'Thêm các đoạn hội thoại chuyên ngành y', '349k_year', 10, 5),
('Trần Trung Anh', 'nguoimoiden5006@gmail.com', 'K68', 'Quản trị Kinh doanh', 'Đại học Bách khoa Hà Nội', 'Công cụ học từ vựng TOEIC và trích xuất văn bản hợp đồng', 5, 'Giao diện Dark Mode đẹp mắt, lật thẻ 3D mượt mà', 'Trong giờ nghỉ trưa tại thư viện Tạ Quang Bửu', 'flashcard_tts', 'Có nút phát âm giọng bản xứ nghe rất chuẩn', 'Đỡ mỏi mắt hơn so với dùng flashcard giấy', 'Tăng tốc độ chuyển câu hỏi trong mini test', '49k_month', 10, 5),
('Uông Minh Duy', 'u.minhduy.2301@gmail.com', 'K67', 'Khoa học Máy tính', 'Đại học Bách khoa Hà Nội', 'Web app hỗ trợ sinh viên học từ vựng chuyên ngành trong thời gian ngắn', 5, 'Rất tiện khi đọc tài liệu Github và Research Paper', 'Khi đọc tài liệu tiếng Anh để làm đồ án môn học', 'auto_extract', 'Tự động lọc từ vựng quan trọng giúp nắm nhanh ý chính', 'Nhanh hơn rất nhiều so với dùng Google Dịch thủ công', 'Tích hợp extension trên Chrome để bôi đen trích xuất', '49k_month', 10, 5),
('Nguyễn Hoàng Nam', 'bbruh4995@gmail.com', 'K66', 'Điện tử Viễn thông', 'Đại học Bách khoa Hà Nội', 'Ứng dụng luyện từ vựng và thi đấu trực tuyến với bạn bè', 4, 'Đấu trường PvP làm tăng hứng thú học tập rất nhiều', 'Buổi tối cùng bạn phòng trọ thách đấu từ vựng', 'pvp_battle', 'Thi đấu tốc độ tính điểm kích thích tinh thần phản xạ', 'Không bị nhàm chán như học 1 mình', 'Thêm bảng xếp hạng tuần và quà tặng streak', '49k_month', 9, 4),
('Bùi Ánh Minh', 'anhminhbui1501@gmail.com', 'K67', 'Cơ điện tử', 'Đại học Bách khoa Hà Nội', 'App flashcard thông minh tự động hóa khâu tạo học liệu', 5, 'Giảm áp lực mỗi khi phải chuẩn bị kiểm tra từ mới', '10 phút trước giờ vào lớp', 'auto_extract', 'Trích xuất từ vựng theo ngữ cảnh bài đọc', 'Tiết kiệm 85% thời gian so với Quizlet', 'Cải thiện giao diện trên màn hình điện thoại', '49k_month', 10, 5),
('Nguyệt Phương Trần', 'nguytran203@gmail.com', 'K68', 'Ngôn ngữ Nhật / CNTT Việt Nhật', 'Đại học Bách khoa Hà Nội', 'Ứng dụng học từ vựng tiếng Nhật và tiếng Anh chuyên ngành', 5, 'Hỗ trợ cả Hiragana, Kanji và phát âm giọng Nhật chuẩn', 'Hàng ngày lúc giải lao giữa ca học', 'flashcard_tts', 'Vừa nhìn Kanji vừa nghe phát âm nhớ rất lâu', 'Phù hợp với lộ trình JLPT N3-N2', 'Thêm tính năng vẽ nét chữ Kanji', '349k_year', 10, 5),
('Nguyễn Văn Tân', 'vantann078@gmail.com', 'K67', 'Hệ thống Thông tin', 'Đại học Bách khoa Hà Nội', 'Nền tảng Micro-learning tự động hóa cho sinh viên bận rộn', 5, 'Bài test ngắn 5 câu giúp duy trì chuỗi Streak mỗi ngày', 'Khoảng thời gian 5 phút ngồi chờ bạn', 'mini_test', 'Biết ngay mình sai từ nào để ôn tập lại', 'Không bắt buộc học cả bài dài 30 phút như Duolingo', 'Thêm nhắc nhở học qua email hoặc Zalo', '49k_month', 9, 5),
('Nguyễn Quang Vinh', 'quangvinh13.hd@gmail.com', 'K66', 'Kỹ thuật Phần mềm', 'Đại học Bách khoa Hà Nội', 'Web app tối ưu hóa quy trình nạp từ vựng công nghệ và luyện đề', 5, 'Sản phẩm giải quyết đúng điểm nghẽn của sinh viên kỹ thuật', 'Mỗi buổi sáng 15 phút trước khi bắt đầu code', 'auto_extract', 'Tự động tách từ và câu ví dụ chỉ trong 3 giây', 'Tích hợp đầy đủ từ chuẩn bị bài, học thẻ đến làm test', 'Mở rộng thêm nhiều chủ đề chuyên ngành AI/Cloud', '349k_year', 10, 5),
('Đào Minh Tâm', 'sinevil98@gmail.com', 'K65', 'Kỹ thuật Hóa học', 'Đại học Bách khoa Hà Nội', 'Công cụ bóc tách từ vựng bài báo khoa học và tạo thẻ ghi nhớ', 3, 'Ý tưởng hay nhưng kho từ vựng chuyên ngành Hóa học phân tích còn hơi ít từ', 'Khi đọc bài báo nghiên cứu khoa học chuyên ngành', 'auto_extract', 'Bóc tách từ nhanh nhưng cần tăng độ chính xác thuật ngữ hữu cơ', 'Nhanh hơn Quizlet nhưng Quizlet có nhiều bộ thẻ cộng đồng hơn', 'Cần bổ sung thêm gói từ vựng Hóa học và Dược phẩm chuyên sâu', 'free_only', 6, 3),
('Trần Thùy Dung', 'trandung15012005@gmail.com', 'K68', 'Kinh tế Quốc tế', 'Đại học Bách khoa Hà Nội', 'Ứng dụng học từ vựng tiếng Anh thương mại theo từng phiên học ngắn', 4, 'Tiện lợi, nhưng sinh viên năm nhất chưa có thu nhập nên chỉ muốn dùng miễn phí', '15 phút ngồi trên xe buýt đến trường mỗi sáng', 'mini_test', 'Làm trắc nghiệm nhanh gọn, không bị buồn ngủ', 'Giao diện bắt mắt hơn Anki rất nhiều', 'Mong muốn tăng hạn mức trích xuất miễn phí mỗi ngày lên 5 lần', 'free_only', 7, 4),
('Trần Văn Chí Nguyên', 'www.nguyenkz@gmail.com', 'K66', 'Kỹ thuật Máy tính', 'Đại học Bách khoa Hà Nội', 'Nền tảng hỗ trợ sinh viên CNTT học thuật ngữ chuyên ngành', 4, 'Chức năng trích xuất hoạt động mượt nhưng giao diện trên điện thoại nút hơi nhỏ', 'Khi gặp từ mới lúc debug code hoặc đọc documentation', 'auto_extract', 'Tiết kiệm công sức chuyển đổi giữa Google Translate và Quizlet', 'Tự động hóa hoàn toàn khâu tạo flashcard', 'Cần tối ưu giao diện responsive cho màn hình điện thoại nhỏ', 'free_only', 8, 4),
('Vũ Thế Nguyễn', 'vunguyenthe.work@gmail.com', 'K67', 'Kỹ thuật Ô tô', 'Đại học Bách khoa Hà Nội', 'App tạo flashcard tự động và kiểm tra trắc nghiệm từ vựng', 3, 'Tính năng tạm ổn, nhưng em ít khi học ngoại ngữ nên chỉ dùng khi sắp có bài thi', '2 ngày trước buổi thi vấn đáp tiếng Anh chuyên ngành', 'mini_test', 'Làm bài test để ôn cấp tốc trước giờ thi', 'Đỡ tốn thời gian hơn tự chép tay ra sổ', 'Cần có ứng dụng di động cài trực tiếp từ AppStore/CHPlay', 'free_only', 6, 3),
('Đặng Quốc Đức', 'ducquocdang86@gmail.com', 'K66', 'Mạng máy tính & Truyền thông', 'Đại học Bách khoa Hà Nội', 'Web học từ vựng nhanh có chức năng phát âm và đấu trường', 4, 'Trải nghiệm tốt, tuy nhiên em muốn dùng thử bản free thêm một thời gian nữa', '10 phút giải lao giữa các buổi thực hành phòng Lab', 'flashcard_tts', 'Nghe phát âm chuẩn giúp nhớ từ lâu hơn', 'Giao diện trực quan và không bị quảng cáo rác làm phiền', 'Bổ sung thêm tính năng lưu lại những từ vựng hay làm sai để ôn riêng', 'free_only', 8, 4),
('Phạm Minh Tuấn', 'phamminhtuan4399@gmail.com', 'K66', 'Kỹ thuật Cơ điện tử', 'Đại học Bách khoa Hà Nội', 'Công cụ học ngoại ngữ vi mô giúp tận dụng thời gian rảnh', 4, 'Nhanh gọn, nhưng các tính năng game đối kháng cần thêm nhiều người chơi cùng lúc', 'Buổi tối sau khi học xong các môn chuyên ngành', 'pvp_battle', 'Chơi game thi đấu kích thích tư duy phản xạ nhanh', 'Tính tương tác cao hơn các app thẻ tĩnh như Anki', 'Nên có thông báo đẩy qua trình duyệt khi có bạn bè thách đấu', 'free_only', 7, 4),
('Huỳnh Gia Hoàng', 'huynhgiahoangc11@gmail.com', 'K68', 'Kỹ thuật Nhiệt', 'Đại học Bách khoa Hà Nội', 'Ứng dụng hỗ trợ ghi nhớ từ vựng tiếng Anh cơ bản và chuyên ngành', 4, 'Giúp sinh viên lười có động lực học hơn, giá 49k hơi cao so với sinh viên ở trọ', 'Lúc chờ đến giờ vào ca học chiều', 'mini_test', 'Được chọn số lượng câu 5, 10 câu rất hợp lý', 'Không ép buộc học bài dài như Duolingo', 'Nếu có gói ưu đãi sinh viên 20k/tháng thì em sẽ mua, tạm thời dùng free', 'free_only', 8, 4),
('Lại Phúc Thịnh', 'laithinh03082010@gmail.com', 'K69', 'Kỹ thuật Hàng không', 'Đại học Bách khoa Hà Nội', 'Trang web tạo flashcard và kiểm tra từ vựng tiếng Anh', 3, 'Tân sinh viên mới vào trường chưa quen học trên web, thích dùng app điện thoại hơn', 'Cuối tuần lúc rảnh rỗi', 'vocab_bank', 'Kho từ có sẵn thuận tiện cho người lười tìm bài đọc', 'Dễ sử dụng, giao diện đơn giản', 'Cần làm ứng dụng di động mượt hơn trên Safari iOS', 'free_only', 6, 3),
('Hoàng Minh Đức', 'duchoang2907@gmail.com', 'K67', 'Kỹ thuật Phần mềm', 'Đại học Bách khoa Hà Nội', 'Ứng dụng micro-learning trích xuất từ vựng từ bài đọc công nghệ', 5, 'Rất hữu ích đối với ai phải đọc nhiều tài liệu tiếng Anh', 'Hàng ngày khoảng 15 phút sau giờ ăn tối', 'auto_extract', 'Tự động nhận diện từ chuyên ngành rất chuẩn xác', 'Tiết kiệm thời gian tra cứu từng từ trên từ điển', 'Thêm phím tắt trên bàn phím để chuyển câu nhanh trong mini test', '49k_month', 9, 5),
('Nguyễn Phúc Bảo', 'phucbaovlog@gmail.com', 'K67', 'Điện tử Y sinh', 'Đại học Bách khoa Hà Nội', 'Nền tảng học thuật ngữ và luyện thi chứng chỉ ngoại ngữ', 4, 'Sản phẩm giải quyết tốt nhu cầu học nhanh, em đang dùng gói miễn phí thấy khá đủ dùng', 'Lúc đi thực tập bệnh viện có thời gian nghỉ ngắn', 'flashcard_tts', 'Phát âm to rõ ràng, âm thanh tự nhiên', 'Thẻ 3D lật mượt, không bị lag', 'Thêm chế độ ban đêm tối hơn nữa để tiết kiệm pin', 'free_only', 8, 4),
('Trần Quốc Huy', 'cccccccc520651@gmail.com', 'K68', 'Kỹ thuật Vật liệu', 'Đại học Bách khoa Hà Nội', 'Web hỗ trợ bóc tách từ và tạo câu hỏi trắc nghiệm', 3, 'Các từ vựng về cấu trúc kim loại và vật liệu nano trích xuất chưa được sát nghĩa', 'Trước giờ nộp bài tập lớn', 'auto_extract', 'Trích xuất nhanh nhưng phải tự chỉnh lại một số nghĩa tiếng Việt', 'Thuận tiện hơn tra Google Dịch', 'Nâng cấp thuật ngữ chuyên ngành Vật liệu và Khoa học Tự nhiên', 'free_only', 6, 3),
('Vũ Xuân Hoàng', 'vuxuanhoang0501@gmail.com', 'K66', 'Kỹ thuật Máy tính', 'Đại học Bách khoa Hà Nội', 'Hệ sinh thái học từ vựng thông minh kết hợp SRS và thi đấu', 5, 'Rất thích tính năng đấu trường PvP tính điểm tốc độ', 'Buổi tối cùng nhóm bạn thi đấu đua top', 'pvp_battle', 'Kích thích phản xạ từ vựng tức thì', 'Vừa học vừa chơi không nhàm chán', 'Tổ chức các giải đấu tuần có thưởng', '49k_month', 10, 5),
('Nguyễn Thanh Sơn', 'nnvfake1@gmail.com', 'K66', 'Kỹ thuật Môi trường', 'Đại học Bách khoa Hà Nội', 'Phần mềm học từ vựng chuyên ngành trong thời gian ngắn', 4, 'Phù hợp với người bận rộn, em hài lòng với các tính năng cơ bản của bản free', '10 phút buổi sáng khi ăn sáng', 'mini_test', 'Làm bài kiểm tra ngắn giúp nhớ từ lâu hơn', 'Không có quảng cáo rác gây phiền', 'Bổ sung thêm biểu đồ theo dõi tiến độ học hàng tuần', 'free_only', 7, 4),
('Nguyễn Đình Đại Minh', 'nguyendinhdaiminh08@gmail.com', 'K67', 'Kỹ thuật Điều khiển & Tự động hóa', 'Đại học Bách khoa Hà Nội', 'Web app trích xuất từ vựng tài liệu tự động hóa', 4, 'Khá ấn tượng với khả năng bóc tách từ, sẵn sàng ủng hộ 49k nếu duy trì ổn định', 'Khi đọc manual hướng dẫn sử dụng thiết bị PLC', 'auto_extract', 'Tách được các từ khóa chuyên ngành tự động hóa', 'Nhanh hơn Quizlet', 'Cải thiện tốc độ tải trang khi mạng yếu', '49k_month', 8, 4),
('Phan Văn Khang', 'khangphan240220032@gmail.com', 'K66', 'Kỹ thuật Cơ khí Động lực', 'Đại học Bách khoa Hà Nội', 'Công cụ hỗ trợ học ngoại ngữ chuyên ngành cho sinh viên kỹ thuật', 4, 'Ý tưởng thực tế, bản miễn phí phục vụ tốt nhu cầu ôn thi', 'Khoảng thời gian nghỉ giữa các ca học xưởng', 'flashcard_tts', 'Nghe cách đọc chuẩn từ vựng kỹ thuật', 'Giao diện trực quan', 'Cần thêm nhiều ví dụ câu ngữ cảnh thực tế hơn', 'free_only', 8, 4),
('Lương Đình Khánh', 'dinhkhanhluong611@gmail.com', 'K67', 'Tài chính Doanh nghiệp', 'Đại học Bách khoa Hà Nội', 'App học từ vựng tài chính và chứng chỉ CFA/TOEIC', 4, 'Tính năng tốt nhưng em muốn học chung nhóm nên mong có gói giảm giá sinh viên', '15 phút trước khi đi ngủ', 'vocab_bank', 'Gói từ vựng kinh tế tài chính hữu ích', 'Tiết kiệm thời gian tự soạn bộ thẻ', 'Bổ sung gói mua chung cho nhóm 3-5 bạn', 'free_only', 7, 4),
('Võ Ngọc Xuân Thắng', 'caheo356@gmail.com', 'K66', 'Kỹ thuật Phần mềm', 'Đại học Bách khoa Hà Nội', 'Nền tảng Micro-learning toàn diện tối ưu hóa việc nạp từ vựng công nghệ', 5, 'Rất đáng giá 349k/năm vì tiết kiệm được hàng trăm giờ tra cứu thủ công', 'Mỗi sáng 10 phút trước ca làm việc', 'auto_extract', 'Trích xuất bài đọc tài liệu chuyên sâu chỉ trong 3 giây', 'Vượt trội hoàn toàn so với các phần mềm flashcard hiện tại', 'Tích hợp thêm tính năng AI tóm tắt đoạn văn bản', '349k_year', 10, 5);
