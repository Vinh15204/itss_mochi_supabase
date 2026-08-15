-- =========================================================================
-- LINGUA: CẤP QUYỀN RLS & NẠP 1.050 TỪ VỰNG CHUYÊN NGÀNH (70 BÀI HỌC)
-- =========================================================================

-- 1. CẤP QUYỀN TRUY CẬP (ROW-LEVEL SECURITY) CHO BỘ TỪ GỐC
-- Đảm bảo người dùng VÀ khách vãng lai đều đọc được bộ thẻ hệ thống (user_id IS NULL)
ALTER TABLE IF EXISTS decks ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS cards ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can view system and own decks" ON decks;
CREATE POLICY "Public can view system and own decks" ON decks
FOR SELECT USING (user_id IS NULL OR auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own decks" ON decks;
CREATE POLICY "Users can insert own decks" ON decks
FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own decks" ON decks;
CREATE POLICY "Users can update own decks" ON decks
FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own decks" ON decks;
CREATE POLICY "Users can delete own decks" ON decks
FOR DELETE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Public can view cards" ON cards;
CREATE POLICY "Public can view cards" ON cards
FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can manage cards in own decks" ON cards;
CREATE POLICY "Users can manage cards in own decks" ON cards
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM decks
    WHERE decks.id = cards.deck_id
    AND (decks.user_id = auth.uid() OR decks.user_id IS NULL)
  )
);

-- 2. NẠP TOÀN BỘ 70 BÀI HỌC CHUYÊN NGÀNH VÀO CƠ SỞ DỮ LIỆU
DO $$
DECLARE
  v_deck_id UUID;
BEGIN

  -- Xóa sạch các bộ thẻ hệ thống cũ (nếu có) để tránh bị trùng lặp
  DELETE FROM decks WHERE user_id IS NULL;

  -- =========================================================
  -- KHỐI: IT_SOFTWARE.JSON (10 bài học)
  -- =========================================================

  -- Bài 1: IT - Bài 1: Web & Frontend
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('IT - Bài 1: Web & Frontend', 'Thuật ngữ lập trình giao diện web và tương tác người dùng.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'responsive', '/rɪˈspɒn.sɪv/', 'tương thích', 'The website is fully responsive. (Trang web hoàn toàn tương thích mọi thiết bị.)', false, NOW()),
  (v_deck_id, 'render', '/ˈren.dər/', 'hiển thị', 'React will render the component. (React sẽ hiển thị component.)', false, NOW()),
  (v_deck_id, 'state', '/steɪt/', 'trạng thái', 'Manage the global state with Redux. (Quản lý trạng thái toàn cục bằng Redux.)', false, NOW()),
  (v_deck_id, 'props', '/prɒps/', 'thuộc tính truyền vào', 'Pass data as props to the child. (Truyền dữ liệu dạng props vào component con.)', false, NOW()),
  (v_deck_id, 'lifecycle', '/ˈlaɪfˌsaɪ.kəl/', 'vòng đời', 'Component lifecycle methods handle updates. (Các hàm vòng đời xử lý cập nhật component.)', false, NOW()),
  (v_deck_id, 'hydrate', '/ˈhaɪ.dreɪt/', 'gắn kết dữ liệu', 'The app will hydrate HTML on the client. (Ứng dụng sẽ gắn kết dữ liệu HTML trên trình duyệt.)', false, NOW()),
  (v_deck_id, 'bundle', '/ˈbʌn.dəl/', 'gói mã nguồn', 'Vite optimizes the production bundle. (Vite tối ưu hóa gói mã nguồn thành phẩm.)', false, NOW()),
  (v_deck_id, 'lazy loading', '/ˈleɪ.zi ˈləʊ.dɪŋ/', 'tải khi cần', 'Lazy loading images saves bandwidth. (Tải ảnh khi cần giúp tiết kiệm băng thông.)', false, NOW()),
  (v_deck_id, 'debounce', '/dɪˈbaʊns/', 'hoãn thực thi', 'Debounce the search input event. (Hoãn thực thi sự kiện ô tìm kiếm.)', false, NOW()),
  (v_deck_id, 'throttle', '/ˈθrɒt.əl/', 'giới hạn tần suất', 'Throttle the scroll event listener. (Giới hạn tần suất hàm lắng nghe sự kiện cuộn.)', false, NOW()),
  (v_deck_id, 'payload', '/ˈpeɪ.ləʊd/', 'dữ liệu gửi đi', 'The request payload contains user info. (Dữ liệu gửi đi chứa thông tin người dùng.)', false, NOW()),
  (v_deck_id, 'middleware', '/ˈmɪd.əl.weər/', 'phần mềm trung gian', 'Use auth middleware to protect routes. (Dùng middleware xác thực để bảo vệ route.)', false, NOW()),
  (v_deck_id, 'asynchronous', '/eɪˈsɪŋ.krə.nəs/', 'bất đồng bộ', 'Async functions handle background tasks. (Hàm bất đồng bộ xử lý tác vụ ngầm.)', false, NOW()),
  (v_deck_id, 'caching', '/ˈkæʃ.ɪŋ/', 'lưu bộ nhớ đệm', 'Browser caching speeds up reload. (Lưu bộ nhớ đệm trình duyệt tăng tốc độ tải lại.)', false, NOW()),
  (v_deck_id, 'accessibility', '/əkˌses.əˈbɪl.ə.ti/', 'khả năng tiếp cận', 'Improve web accessibility for everyone. (Nâng cao khả năng tiếp cận web cho mọi người.)', false, NOW());

  -- Bài 2: IT - Bài 2: Backend & Database
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('IT - Bài 2: Backend & Database', 'Thuật ngữ máy chủ, cơ sở dữ liệu và hệ thống phân tán.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'scalability', '/ˌskeɪ.ləˈbɪl.ə.ti/', 'khả năng mở rộng', 'Cloud improves server scalability. (Điện toán đám mây nâng cao khả năng mở rộng máy chủ.)', false, NOW()),
  (v_deck_id, 'latency', '/ˈleɪ.tən.si/', 'độ trễ', 'CDN reduces network latency. (CDN giúp giảm độ trễ mạng.)', false, NOW()),
  (v_deck_id, 'throughput', '/ˈθruː.pʊt/', 'thông lượng', 'The server handles high throughput. (Máy chủ xử lý thông lượng cao.)', false, NOW()),
  (v_deck_id, 'schema', '/ˈskiː.mə/', 'lược đồ cấu trúc', 'Update the database schema. (Cập nhật lược đồ cơ sở dữ liệu.)', false, NOW()),
  (v_deck_id, 'indexing', '/ˈɪn.dek.sɪŋ/', 'đánh chỉ mục', 'Indexing speeds up search queries. (Đánh chỉ mục giúp tăng tốc truy vấn.)', false, NOW()),
  (v_deck_id, 'transaction', '/trænˈzæk.ʃən/', 'giao dịch dữ liệu', 'A transaction ensures data integrity. (Giao dịch dữ liệu đảm bảo tính toàn vẹn.)', false, NOW()),
  (v_deck_id, 'concurrency', '/kənˈkʌr.ən.si/', 'tính đồng thời', 'Handle high concurrency safely. (Xử lý tính đồng thời cao một cách an toàn.)', false, NOW()),
  (v_deck_id, 'deadlock', '/ˈded.lɒk/', 'khóa chết', 'Avoid database deadlock issues. (Tránh các sự cố khóa chết cơ sở dữ liệu.)', false, NOW()),
  (v_deck_id, 'load balancer', '/ˈləʊd ˌbæl.ən.sər/', 'bộ cân bằng tải', 'The load balancer distributes traffic. (Bộ cân bằng tải phân phối lưu lượng truy cập.)', false, NOW()),
  (v_deck_id, 'redundancy', '/rɪˈdʌn.dən.si/', 'sự dự phòng', 'Server redundancy prevents downtime. (Dự phòng máy chủ giúp tránh gián đoạn.)', false, NOW()),
  (v_deck_id, 'idempotent', '/ˌaɪ.dəmˈpəʊ.tənt/', 'lũy đẳng', 'GET requests are idempotent. (Yêu cầu GET có tính lũy đẳng.)', false, NOW()),
  (v_deck_id, 'sharding', '/ˈʃɑː.dɪŋ/', 'phân mảnh dữ liệu', 'Database sharding scales storage. (Phân mảnh dữ liệu giúp mở rộng lưu trữ.)', false, NOW()),
  (v_deck_id, 'replication', '/ˌrep.lɪˈkeɪ.ʃən/', 'sao chép nhân bản', 'Data replication prevents data loss. (Nhân bản dữ liệu giúp tránh mất mát.)', false, NOW()),
  (v_deck_id, 'bottleneck', '/ˈbɒt.əl.nek/', 'điểm nghẽn', 'Find the performance bottleneck. (Tìm điểm nghẽn hiệu năng.)', false, NOW()),
  (v_deck_id, 'deprecated', '/ˈdep.rə.keɪ.tɪd/', 'lỗi thời / sắp bỏ', 'This method is deprecated. (Phương thức này đã lỗi thời.)', false, NOW());

  -- Bài 3: IT - Bài 3: Trí Tuệ Nhân Tạo & Máy Học
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('IT - Bài 3: Trí Tuệ Nhân Tạo & Máy Học', 'Thuật ngữ AI, học máy, học sâu và mô hình ngôn ngữ lớn.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'algorithm', '/ˈæl.ɡə.rɪ.ðəm/', 'thuật toán', 'The search algorithm is fast. (Thuật toán tìm kiếm rất nhanh.)', false, NOW()),
  (v_deck_id, 'dataset', '/ˈdeɪ.tə.set/', 'tập dữ liệu', 'Train the model on a large dataset. (Huấn luyện mô hình trên một tập dữ liệu lớn.)', false, NOW()),
  (v_deck_id, 'neural network', '/ˈnjʊə.rəl ˈnet.wɜːk/', 'mạng nơ-ron', 'Deep neural networks recognize images. (Mạng nơ-ron sâu nhận diện hình ảnh.)', false, NOW()),
  (v_deck_id, 'overfitting', '/ˌəʊ.vəˈfɪt.ɪŋ/', 'học vẹt / quá khớp', 'Regularization prevents overfitting. (Chuẩn hóa giúp ngăn chặn hiện tượng quá khớp.)', false, NOW()),
  (v_deck_id, 'inference', '/ˈɪn.fər.əns/', 'suy luận mô hình', 'Model inference latency is low. (Độ trễ suy luận của mô hình rất thấp.)', false, NOW()),
  (v_deck_id, 'hyperparameter', '/ˌhaɪ.pə.pəˈræm.ɪ.tər/', 'siêu tham số', 'Tune the model hyperparameters. (Tinh chỉnh các siêu tham số mô hình.)', false, NOW()),
  (v_deck_id, 'fine-tuning', '/ˈfaɪn ˌtjuː.nɪŋ/', 'tinh chỉnh mô hình', 'Fine-tuning improves domain accuracy. (Tinh chỉnh mô hình giúp tăng độ chính xác theo chuyên môn.)', false, NOW()),
  (v_deck_id, 'embedding', '/ɪmˈbed.ɪŋ/', 'vector hóa văn bản', 'Vector embeddings represent word meanings. (Vector hóa giúp biểu diễn ý nghĩa của từ.)', false, NOW()),
  (v_deck_id, 'prompt', '/prɒmpt/', 'câu lệnh gợi ý', 'Write a clear prompt for the AI. (Viết một câu lệnh gợi ý rõ ràng cho AI.)', false, NOW()),
  (v_deck_id, 'classification', '/ˌklæs.ɪ.fɪˈkeɪ.ʃən/', 'phân loại', 'Image classification model. (Mô hình phân loại hình ảnh.)', false, NOW()),
  (v_deck_id, 'regression', '/rɪˈɡreʃ.ən/', 'hồi quy', 'Linear regression predicts price trends. (Hồi quy tuyến tính dự đoán xu hướng giá.)', false, NOW()),
  (v_deck_id, 'unsupervised', '/ˌʌnˈsuː.pə.vaɪzd/', 'không giám sát', 'Clustering is unsupervised learning. (Phân cụm là học không giám sát.)', false, NOW()),
  (v_deck_id, 'reinforcement', '/ˌriː.ɪnˈfɔːs.mənt/', 'học tăng cường', 'Robots learn via reinforcement learning. (Robot học thông qua học tăng cường.)', false, NOW()),
  (v_deck_id, 'benchmark', '/ˈbentʃ.mɑːk/', 'bài kiểm tra chuẩn', 'The model topped the benchmark tests. (Mô hình dẫn đầu các bài kiểm tra chuẩn.)', false, NOW()),
  (v_deck_id, 'tokenization', '/ˌtəʊ.kən.aɪˈzeɪ.ʃən/', 'tách từ / chia token', 'Text tokenization precedes analysis. (Tách token văn bản diễn ra trước khi phân tích.)', false, NOW());

  -- Bài 4: IT - Bài 4: An Toàn Thông Tin & Bảo Mật
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('IT - Bài 4: An Toàn Thông Tin & Bảo Mật', 'Thuật ngữ an ninh mạng, mã hóa, lỗ hổng và xác thực bảo mật.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'encryption', '/ɪnˈkrɪp.ʃən/', 'mã hóa dữ liệu', 'End-to-end encryption protects messages. (Mã hóa đầu cuối bảo vệ tin nhắn.)', false, NOW()),
  (v_deck_id, 'decryption', '/diːˈkrɪp.ʃən/', 'giải mã dữ liệu', 'Decrypt the file with a private key. (Giải mã tệp bằng khóa riêng tư.)', false, NOW()),
  (v_deck_id, 'vulnerability', '/ˌvʌl.nər.əˈbɪl.ə.ti/', 'lỗ hổng bảo mật', 'Patch the critical security vulnerability. (Vá lỗ hổng bảo mật nghiêm trọng.)', false, NOW()),
  (v_deck_id, 'exploit', '/ˈek.splɔɪt/', 'khai thác lỗ hổng', 'Hackers tried to exploit the bug. (Tin tặc đã cố gắng khai thác lỗi phần mềm.)', false, NOW()),
  (v_deck_id, 'phishing', '/ˈfɪʃ.ɪŋ/', 'lừa đảo giả mạo', 'Never click suspicious phishing links. (Không bao giờ nhấp vào liên kết lừa đảo đáng ngờ.)', false, NOW()),
  (v_deck_id, 'firewall', '/ˈfaɪə.wɔːl/', 'tường lửa', 'The firewall blocks unauthorized traffic. (Tường lửa chặn lưu lượng không được phép.)', false, NOW()),
  (v_deck_id, 'malware', '/ˈmæl.weər/', 'phần mềm độc hại', 'Scan the server for hidden malware. (Quét máy chủ để tìm phần mềm độc hại ẩn.)', false, NOW()),
  (v_deck_id, 'ransomware', '/ˈræn.səm.weər/', 'mã độc tống tiền', 'Ransomware locked company files. (Mã độc tống tiền đã khóa các tệp của công ty.)', false, NOW()),
  (v_deck_id, 'authorization', '/ˌɔː.θər.aɪˈzeɪ.ʃən/', 'phân quyền truy cập', 'Check user authorization for this role. (Kiểm tra quyền hạn người dùng cho vai trò này.)', false, NOW()),
  (v_deck_id, 'authentication', '/ɔːˌθen.tɪˈkeɪ.ʃən/', 'xác thực danh tính', 'Two-factor authentication adds security. (Xác thực hai yếu tố tăng cường bảo mật.)', false, NOW()),
  (v_deck_id, 'breach', '/briːtʃ/', 'rò rỉ / xâm phạm', 'Investigate the recent data breach. (Điều tra vụ rò rỉ dữ liệu gần đây.)', false, NOW()),
  (v_deck_id, 'penetration testing', '/ˌpen.ɪˈtreɪ.ʃən ˈtes.tɪŋ/', 'kiểm thử xâm nhập', 'Conduct annual penetration testing. (Tiến hành kiểm thử xâm nhập hàng năm.)', false, NOW()),
  (v_deck_id, 'hash', '/hæʃ/', 'băm mật khẩu', 'Always hash passwords before storing. (Luôn băm mật khẩu trước khi lưu trữ.)', false, NOW()),
  (v_deck_id, 'credential', '/krɪˈden.ʃəl/', 'thông tin đăng nhập', 'Keep your login credentials secret. (Giữ bí mật thông tin đăng nhập của bạn.)', false, NOW()),
  (v_deck_id, 'backdoor', '/ˈbæk.dɔːr/', 'cổng sau bí mật', 'Attackers installed a backdoor. (Kẻ tấn công đã cài đặt một cổng sau bí mật.)', false, NOW());

  -- Bài 5: IT - Bài 5: DevOps & Hạ Tầng Đám Mây
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('IT - Bài 5: DevOps & Hạ Tầng Đám Mây', 'Thuật ngữ CI/CD, container, triển khai và tự động hóa hệ thống.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'deployment', '/dɪˈplɔɪ.mənt/', 'triển khai ứng dụng', 'Automated deployment to production. (Triển khai tự động lên môi trường thật.)', false, NOW()),
  (v_deck_id, 'container', '/kənˈteɪ.nər/', 'bộ chứa đóng gói', 'Docker packages code in a container. (Docker đóng gói mã nguồn trong bộ chứa.)', false, NOW()),
  (v_deck_id, 'pipeline', '/ˈpaɪp.laɪn/', 'quy trình tự động (CI/CD)', 'The CI/CD pipeline runs unit tests. (Quy trình CI/CD tự động chạy kiểm thử đơn vị.)', false, NOW()),
  (v_deck_id, 'orchestration', '/ˌɔː.kɪˈstreɪ.ʃən/', 'điều phối hệ thống', 'Kubernetes handles container orchestration. (Kubernetes xử lý điều phối các container.)', false, NOW()),
  (v_deck_id, 'rollback', '/ˈrəʊl.bæk/', 'quay lui phiên bản', 'Rollback to the previous stable release. (Quay lui về phiên bản ổn định trước đó.)', false, NOW()),
  (v_deck_id, 'monitoring', '/ˈmɒn.ɪ.tər.ɪŋ/', 'giám sát hệ thống', 'Server monitoring alerts on high CPU. (Hệ thống giám sát cảnh báo khi CPU quá tải.)', false, NOW()),
  (v_deck_id, 'provisioning', '/prəˈvɪʒ.ən.ɪŋ/', 'cấp phát tài nguyên', 'Automate cloud server provisioning. (Tự động hóa việc cấp phát máy chủ đám mây.)', false, NOW()),
  (v_deck_id, 'cluster', '/ˈklʌs.tər/', 'cụm máy chủ', 'Deploy the app across a multi-node cluster. (Triển khai ứng dụng trên cụm nhiều máy chủ.)', false, NOW()),
  (v_deck_id, 'telemetry', '/təˈlem.ə.tri/', 'dữ liệu đo từ xa', 'Collect telemetry data for debugging. (Thu thập dữ liệu đo từ xa để gỡ lỗi.)', false, NOW()),
  (v_deck_id, 'uptime', '/ˈʌp.taɪm/', 'thời gian hoạt động', 'Guarantee 99.9 percent server uptime. (Cam kết máy chủ hoạt động 99.9% thời gian.)', false, NOW()),
  (v_deck_id, 'downtime', '/ˈdaʊn.taɪm/', 'thời gian ngừng hoạt động', 'Scheduled downtime for maintenance. (Thời gian ngừng hoạt động định kỳ để bảo trì.)', false, NOW()),
  (v_deck_id, 'repository', '/rɪˈpɒz.ɪ.tər.i/', 'kho lưu trữ mã', 'Clone the Git code repository. (Sao chép kho lưu trữ mã nguồn Git.)', false, NOW()),
  (v_deck_id, 'virtualization', '/ˌvɜː.tʃu.ə.laɪˈzeɪ.ʃən/', 'ảo hóa phần cứng', 'Hardware virtualization saves power. (Ảo hóa phần cứng giúp tiết kiệm điện năng.)', false, NOW()),
  (v_deck_id, 'daemon', '/ˈdiː.mən/', 'tiến trình chạy ngầm', 'Background daemon processes logs. (Tiến trình chạy ngầm xử lý các tệp nhật ký.)', false, NOW()),
  (v_deck_id, 'artifact', '/ˈɑː.tɪ.fækt/', 'sản phẩm sau khi build', 'Store the build artifacts safely. (Lưu trữ các sản phẩm sau khi build an toàn.)', false, NOW());

  -- Bài 6: IT - Bài 6: Cấu Trúc Dữ Liệu & Thuật Toán
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('IT - Bài 6: Cấu Trúc Dữ Liệu & Thuật Toán', 'Thuật ngữ cấu trúc dữ liệu, độ phức tạp và thuật toán cơ bản.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'array', '/əˈreɪ/', 'mảng dữ liệu', 'Access elements in an array. (Truy cập các phần tử trong một mảng.)', false, NOW()),
  (v_deck_id, 'queue', '/kjuː/', 'hàng đợi (FIFO)', 'Queue processes tasks in order. (Hàng đợi xử lý tác vụ theo thứ tự đến trước.)', false, NOW()),
  (v_deck_id, 'stack', '/stæk/', 'ngăn xếp (LIFO)', 'Stack follows last-in first-out. (Ngăn xếp tuân theo nguyên tắc vào sau ra trước.)', false, NOW()),
  (v_deck_id, 'recursion', '/rɪˈkɜː.ʃən/', 'đệ quy', 'Calculate factorial using recursion. (Tính giai thừa bằng phương pháp đệ quy.)', false, NOW()),
  (v_deck_id, 'iteration', '/ˌɪt.ərˈeɪ.ʃən/', 'vòng lặp / lặp lại', 'Each loop iteration checks a condition. (Mỗi lần lặp đều kiểm tra điều kiện.)', false, NOW()),
  (v_deck_id, 'complexity', '/kəmˈplek.sə.ti/', 'độ phức tạp', 'Time complexity is O(log n). (Độ phức tạp thời gian là O(log n).)', false, NOW()),
  (v_deck_id, 'pointer', '/ˈpɔɪn.tər/', 'con trỏ bộ nhớ', 'The pointer points to memory address. (Con trỏ trỏ đến địa chỉ bộ nhớ.)', false, NOW()),
  (v_deck_id, 'traversal', '/trəˈvɜː.səl/', 'duyệt qua dữ liệu', 'Perform a binary tree traversal. (Thực hiện duyệt qua cây nhị phân.)', false, NOW()),
  (v_deck_id, 'hash table', '/ˈhæʃ ˌteɪ.bəl/', 'bảng băm', 'Hash table provides O(1) lookup. (Bảng băm cho phép tra cứu với tốc độ O(1).)', false, NOW()),
  (v_deck_id, 'binary search', '/ˈbaɪ.nər.i ˈsɜːtʃ/', 'tìm kiếm nhị phân', 'Binary search requires a sorted list. (Tìm kiếm nhị phân yêu cầu danh sách đã sắp xếp.)', false, NOW()),
  (v_deck_id, 'sorting', '/ˈsɔː.tɪŋ/', 'sắp xếp dữ liệu', 'Quicksort is an efficient sorting method. (Quicksort là phương pháp sắp xếp rất hiệu quả.)', false, NOW()),
  (v_deck_id, 'graph', '/ɡrɑːf/', 'đồ thị', 'Represent relationships using a graph. (Biểu diễn các mối quan hệ bằng đồ thị.)', false, NOW()),
  (v_deck_id, 'node', '/nəʊd/', 'nút dữ liệu', 'Each node contains value and pointer. (Mỗi nút chứa giá trị và con trỏ.)', false, NOW()),
  (v_deck_id, 'matrix', '/ˈmeɪ.trɪks/', 'ma trận 2 chiều', 'Multiply two matrices together. (Nhân hai ma trận với nhau.)', false, NOW()),
  (v_deck_id, 'dynamic programming', '/daɪˈnæm.ɪk ˈprəʊ.ɡræm.ɪŋ/', 'quy hoạch động', 'Solve subproblems with dynamic programming. (Giải bài toán con bằng quy hoạch động.)', false, NOW());

  -- Bài 7: IT - Bài 7: Kiến Trúc & Thiết Kế Phần Mềm
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('IT - Bài 7: Kiến Trúc & Thiết Kế Phần Mềm', 'Thuật ngữ hướng đối tượng (OOP), mẫu thiết kế và kiến trúc hệ thống.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'inheritance', '/ɪnˈher.ɪ.təns/', 'tính kế thừa', 'Subclass gets methods via inheritance. (Lớp con nhận các phương thức qua tính kế thừa.)', false, NOW()),
  (v_deck_id, 'encapsulation', '/ɪnˌkæp.sjəˈleɪ.ʃən/', 'tính đóng gói', 'Encapsulation hides internal data. (Tính đóng gói giúp che giấu dữ liệu nội bộ.)', false, NOW()),
  (v_deck_id, 'polymorphism', '/ˌpɒl.iˈmɔː.fɪ.zəm/', 'tính đa hình', 'Polymorphism allows method overriding. (Tính đa hình cho phép ghi đè phương thức.)', false, NOW()),
  (v_deck_id, 'abstraction', '/æbˈstræk.ʃən/', 'tính trừu tượng', 'Interfaces provide clean abstraction. (Giao diện interface cung cấp tính trừu tượng rõ ràng.)', false, NOW()),
  (v_deck_id, 'singleton', '/ˈsɪŋ.ɡəl.tən/', 'mẫu khởi tạo duy nhất', 'Use singleton pattern for database connection. (Dùng mẫu singleton cho kết nối cơ sở dữ liệu.)', false, NOW()),
  (v_deck_id, 'dependency injection', '/dɪˈpen.dən.si ɪnˈdʒek.ʃən/', 'tiêm phụ thuộc (DI)', 'Dependency injection decouples classes. (Tiêm phụ thuộc giúp giảm liên kết giữa các lớp.)', false, NOW()),
  (v_deck_id, 'refactoring', '/ˌriːˈfæk.tər.ɪŋ/', 'tái cấu trúc mã', 'Refactoring improves code readability. (Tái cấu trúc giúp mã nguồn dễ đọc hơn.)', false, NOW()),
  (v_deck_id, 'monolith', '/ˈmɒn.ə.lɪθ/', 'kiến trúc nguyên khối', 'Migrating away from a legacy monolith. (Chuyển dịch dần khỏi hệ thống nguyên khối cũ.)', false, NOW()),
  (v_deck_id, 'microservices', '/ˈmaɪ.krəʊˌsɜː.vɪ.sɪz/', 'kiến trúc dịch vụ nhỏ', 'Microservices communicate via REST or gRPC. (Các dịch vụ nhỏ giao tiếp qua REST hoặc gRPC.)', false, NOW()),
  (v_deck_id, 'event-driven', '/ɪˈvent ˌdrɪv.ən/', 'hướng sự kiện', 'Event-driven systems use message brokers. (Hệ thống hướng sự kiện sử dụng bộ chuyển tiếp thông điệp.)', false, NOW()),
  (v_deck_id, 'coupling', '/ˈkʌp.lɪŋ/', 'độ phụ thuộc giữa các module', 'Aim for loose coupling in architecture. (Hướng đến độ phụ thuộc lỏng lẻo trong kiến trúc.)', false, NOW()),
  (v_deck_id, 'cohesion', '/kəʊˈhiː.ʒən/', 'tính gắn kết nội bộ', 'High cohesion makes modules reusable. (Tính gắn kết cao giúp module tái sử dụng tốt.)', false, NOW()),
  (v_deck_id, 'interface', '/ˈɪn.tə.feɪs/', 'giao diện lập trình', 'Implement the payment interface. (Triển khai giao diện lập trình thanh toán.)', false, NOW()),
  (v_deck_id, 'boilerplate', '/ˈbɔɪ.lə.pleɪt/', 'mã mẫu lặp lại', 'Lombok reduces Java boilerplate code. (Lombok giúp giảm mã mẫu lặp lại trong Java.)', false, NOW()),
  (v_deck_id, 'anti-pattern', '/ˈæn.ti ˌpæt.ən/', 'mẫu thiết kế sai lầm', 'God object is a famous anti-pattern. (Đối tượng vạn năng là mẫu thiết kế sai lầm điển hình.)', false, NOW());

  -- Bài 8: IT - Bài 8: Kiểm Thử & Đảm Bảo Chất Lượng
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('IT - Bài 8: Kiểm Thử & Đảm Bảo Chất Lượng', 'Thuật ngữ kiểm thử phần mềm, tự động hóa và đảm bảo chất lượng (QA).', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'unit test', '/ˈjuː.nɪt ˌtest/', 'kiểm thử đơn vị', 'Write unit tests for every function. (Viết kiểm thử đơn vị cho từng hàm.)', false, NOW()),
  (v_deck_id, 'integration test', '/ˌɪn.tɪˈɡreɪ.ʃən ˌtest/', 'kiểm thử tích hợp', 'Integration tests verify API communication. (Kiểm thử tích hợp xác minh giao tiếp API.)', false, NOW()),
  (v_deck_id, 'regression test', '/rɪˈɡreʃ.ən ˌtest/', 'kiểm thử hồi quy', 'Run regression tests before releasing. (Chạy kiểm thử hồi quy trước khi phát hành.)', false, NOW()),
  (v_deck_id, 'mock', '/mɒk/', 'giả lập dữ liệu / hàm', 'Mock the payment gateway in tests. (Giả lập cổng thanh toán trong bài kiểm thử.)', false, NOW()),
  (v_deck_id, 'assertion', '/əˈsɜː.ʃən/', 'khẳng định kết quả kiểm thử', 'The test assertion passed successfully. (Khẳng định kiểm thử đã vượt qua thành công.)', false, NOW()),
  (v_deck_id, 'coverage', '/ˈkʌv.ər.ɪdʒ/', 'độ bao phủ kiểm thử', 'Aim for 80 percent code coverage. (Mục tiêu đạt 80% độ bao phủ mã kiểm thử.)', false, NOW()),
  (v_deck_id, 'smoke test', '/ˈsməʊk ˌtest/', 'kiểm thử nhanh ban đầu', 'Smoke tests ensure basic features work. (Kiểm thử nhanh đảm bảo các tính năng cơ bản chạy được.)', false, NOW()),
  (v_deck_id, 'stress test', '/ˈstres ˌtest/', 'kiểm thử chịu tải tối đa', 'Stress test server under heavy load. (Kiểm thử máy chủ dưới mức tải cực lớn.)', false, NOW()),
  (v_deck_id, 'bug', '/bʌɡ/', 'lỗi phần mềm', 'Fix the critical payment bug. (Sửa lỗi thanh toán nghiêm trọng.)', false, NOW()),
  (v_deck_id, 'debugger', '/diːˈbʌɡ.ər/', 'trình gỡ lỗi', 'Set breakpoints in the debugger. (Đặt điểm dừng trong trình gỡ lỗi.)', false, NOW()),
  (v_deck_id, 'edge case', '/ˈedʒ ˌkeɪs/', 'trường hợp biên / ngoại lệ', 'Always test edge cases like zero input. (Luôn kiểm tra các trường hợp biên như đầu vào bằng 0.)', false, NOW()),
  (v_deck_id, 'flaky', '/ˈfleɪ.ki/', 'chập chờn (kết quả không ổn định)', 'Fix flaky tests that fail randomly. (Sửa các bài kiểm thử chập chờn hay lỗi ngẫu nhiên.)', false, NOW()),
  (v_deck_id, 'stub', '/stʌb/', 'hàm giả trả kết quả cố định', 'Use a stub for external service calls. (Dùng hàm giả cho các lệnh gọi dịch vụ bên ngoài.)', false, NOW()),
  (v_deck_id, 'acceptance criteria', '/əkˈsep.təns kraɪˌtɪə.ri.ə/', 'tiêu chí nghiệm thu', 'Meet all user story acceptance criteria. (Đáp ứng đủ tiêu chí nghiệm thu yêu cầu người dùng.)', false, NOW()),
  (v_deck_id, 'sanity test', '/ˈsæn.ə.ti ˌtest/', 'kiểm thử hợp lý sau khi sửa', 'Run a quick sanity test after bug fix. (Chạy kiểm thử hợp lý nhanh sau khi sửa lỗi.)', false, NOW());

  -- Bài 9: IT - Bài 9: Lập Trình Ứng Dụng Di Động
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('IT - Bài 9: Lập Trình Ứng Dụng Di Động', 'Thuật ngữ phát triển ứng dụng di động iOS, Android và đa nền tảng.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'cross-platform', '/ˌkrɒsˈplæt.fɔːm/', 'đa nền tảng', 'Flutter enables cross-platform mobile apps. (Flutter cho phép làm ứng dụng di động đa nền tảng.)', false, NOW()),
  (v_deck_id, 'native', '/ˈneɪ.tɪv/', 'thuần bản địa (iOS/Android)', 'Native apps have high performance. (Ứng dụng thuần bản địa có hiệu năng rất cao.)', false, NOW()),
  (v_deck_id, 'emulator', '/ˈem.jə.leɪ.tər/', 'trình giả lập thiết bị', 'Test the app on an Android emulator. (Kiểm tra ứng dụng trên trình giả lập Android.)', false, NOW()),
  (v_deck_id, 'notification', '/ˌnəʊ.tɪ.fɪˈkeɪ.ʃən/', 'thông báo đẩy', 'Send push notifications to users. (Gửi thông báo đẩy đến người dùng.)', false, NOW()),
  (v_deck_id, 'deep linking', '/ˈdiːp ˌlɪŋ.kɪŋ/', 'liên kết trực tiếp vào màn hình app', 'Deep linking opens specific product pages. (Liên kết sâu mở trực tiếp trang sản phẩm cụ thể.)', false, NOW()),
  (v_deck_id, 'offline mode', '/ˈɒf.laɪn məʊd/', 'chế độ ngoại tuyến', 'Support offline mode using local storage. (Hỗ trợ chế độ ngoại tuyến bằng bộ nhớ cục bộ.)', false, NOW()),
  (v_deck_id, 'sync', '/sɪŋk/', 'đồng bộ hóa dữ liệu', 'Sync local notes with cloud database. (Đồng bộ hóa ghi chú trên máy với dữ liệu đám mây.)', false, NOW()),
  (v_deck_id, 'biometric', '/ˌbaɪ.əʊˈmet.rɪk/', 'sinh trắc học (vân tay/mặt)', 'Login using biometric fingerprint scan. (Đăng nhập bằng quét vân tay sinh trắc học.)', false, NOW()),
  (v_deck_id, 'webview', '/ˈweb.vjuː/', 'khung nhúng web trong app', 'Display terms of service inside a webview. (Hiển thị điều khoản dịch vụ trong khung nhúng web.)', false, NOW()),
  (v_deck_id, 'widget', '/ˈwɪdʒ.ɪt/', 'tiện ích giao diện', 'Add a weather widget to home screen. (Thêm tiện ích thời tiết vào màn hình chính.)', false, NOW()),
  (v_deck_id, 'gesture', '/ˈdʒes.tʃər/', 'cử chỉ chạm vuốt', 'Swipe gesture dismisses the modal. (Cử chỉ vuốt giúp đóng cửa sổ bật lên.)', false, NOW()),
  (v_deck_id, 'manifest', '/ˈmæn.ɪ.fest/', 'tệp khai báo cấu hình app', 'Declare app permissions in the manifest. (Khai báo quyền ứng dụng trong tệp manifest.)', false, NOW()),
  (v_deck_id, 'orientation', '/ˌɔː.ri.enˈteɪ.ʃən/', 'hướng xoay màn hình', 'Lock app orientation to portrait. (Khóa hướng màn hình ứng dụng theo chiều dọc.)', false, NOW()),
  (v_deck_id, 'sandbox', '/ˈsænd.bɒks/', 'môi trường cách ly an toàn', 'Mobile apps run in a secure sandbox. (Ứng dụng di động chạy trong môi trường cách ly an toàn.)', false, NOW()),
  (v_deck_id, 'analytics', '/ˌæn.əlˈɪt.ɪks/', 'dữ liệu phân tích hành vi', 'Track user retention with app analytics. (Theo dõi tỷ lệ giữ chân người dùng qua phân tích app.)', false, NOW());

  -- Bài 10: IT - Bài 10: Dữ Liệu Lớn & Phân Tích
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('IT - Bài 10: Dữ Liệu Lớn & Phân Tích', 'Thuật ngữ Big Data, xử lý dòng dữ liệu và kho dữ liệu phân tích.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'data warehouse', '/ˈdeɪ.tə ˌweə.haʊs/', 'kho dữ liệu tập trung', 'Store historical records in a data warehouse. (Lưu trữ lịch sử dữ liệu trong kho tập trung.)', false, NOW()),
  (v_deck_id, 'data lake', '/ˈdeɪ.tə leɪk/', 'hồ dữ liệu thô', 'Ingest unstructured files into the data lake. (Nạp các tệp chưa cấu trúc vào hồ dữ liệu.)', false, NOW()),
  (v_deck_id, 'streaming', '/ˈstriː.mɪŋ/', 'xử lý dữ liệu dòng liên tục', 'Apache Kafka handles real-time data streaming. (Apache Kafka xử lý dữ liệu dòng theo thời gian thực.)', false, NOW()),
  (v_deck_id, 'batch', '/bætʃ/', 'xử lý theo lô định kỳ', 'Run batch jobs every midnight. (Chạy tác vụ xử lý theo lô vào mỗi nửa đêm.)', false, NOW()),
  (v_deck_id, 'ETL', '/ˌiː.tiːˈel/', 'trích xuất, chuyển đổi và nạp', 'Build an automated ETL pipeline. (Xây dựng quy trình ETL tự động hóa.)', false, NOW()),
  (v_deck_id, 'partitioning', '/pɑːˈtɪʃ.ən.ɪŋ/', 'chia vùng dữ liệu', 'Table partitioning improves query speed. (Chia vùng bảng giúp tăng tốc độ truy vấn.)', false, NOW()),
  (v_deck_id, 'aggregation', '/ˌæɡ.rɪˈɡeɪ.ʃən/', 'tổng hợp dữ liệu', 'Calculate monthly sales aggregation. (Tính toán tổng hợp doanh số bán hàng hàng tháng.)', false, NOW()),
  (v_deck_id, 'analytics', '/ˌæn.əlˈɪt.ɪks/', 'phân tích dữ liệu', 'Predictive analytics forecasts future sales. (Phân tích dự đoán giúp dự báo doanh số tương lai.)', false, NOW()),
  (v_deck_id, 'metadata', '/ˈmet.əˌdeɪ.tə/', 'dữ liệu mô tả thông tin', 'File metadata includes creation date. (Dữ liệu mô tả tệp bao gồm ngày tạo.)', false, NOW()),
  (v_deck_id, 'dashboard', '/ˈdæʃ.bɔːd/', 'bảng điều khiển trực quan', 'View business metrics on the dashboard. (Xem các chỉ số kinh doanh trên bảng điều khiển.)', false, NOW()),
  (v_deck_id, 'schema-on-read', '/ˈskiː.mə ɒn riːd/', 'định dạng khi đọc dữ liệu', 'NoSQL often uses schema-on-read. (NoSQL thường áp dụng định dạng khi đọc dữ liệu.)', false, NOW()),
  (v_deck_id, 'ingestion', '/ɪnˈdʒes.tʃən/', 'thu nhận dữ liệu đầu vào', 'Fast data ingestion from IoT sensors. (Thu nhận dữ liệu nhanh từ các cảm biến IoT.)', false, NOW()),
  (v_deck_id, 'anonymization', '/əˌnɒn.ɪ.maɪˈzeɪ.ʃən/', 'ẩn danh hóa dữ liệu', 'Data anonymization protects user privacy. (Ẩn danh hóa dữ liệu giúp bảo vệ quyền riêng tư.)', false, NOW()),
  (v_deck_id, 'scalability', '/ˌskeɪ.ləˈbɪl.ə.ti/', 'khả năng mở rộng', 'Hadoop offers horizontal scalability. (Hadoop cung cấp khả năng mở rộng theo chiều ngang.)', false, NOW()),
  (v_deck_id, 'insight', '/ˈɪn.saɪt/', 'thấu hiểu sâu sắc', 'Gain actionable business insights. (Đạt được những hiểu biết sâu sắc để ra quyết định.)', false, NOW());

  -- =========================================================
  -- KHỐI: MEDICAL.JSON (10 bài học)
  -- =========================================================

  -- Bài 11: Y Khoa - Bài 1: Chẩn Đoán & Bệnh Học
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Y Khoa - Bài 1: Chẩn Đoán & Bệnh Học', 'Thuật ngữ y khoa thiết yếu về triệu chứng lâm sàng và chẩn đoán.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'diagnosis', '/ˌdaɪ.əɡˈnəʊ.sɪs/', 'chẩn đoán', 'Accurate diagnosis is crucial. (Chẩn đoán chính xác là điều tối quan trọng.)', false, NOW()),
  (v_deck_id, 'prognosis', '/prɒɡˈnəʊ.sɪs/', 'tiên lượng', 'The doctor gave a good prognosis. (Bác sĩ đưa ra tiên lượng tốt.)', false, NOW()),
  (v_deck_id, 'acute', '/əˈkjuːt/', 'cấp tính', 'He has acute pain in the abdomen. (Anh ấy bị đau bụng cấp tính.)', false, NOW()),
  (v_deck_id, 'chronic', '/ˈkrɒn.ɪk/', 'mãn tính', 'Asthma is a chronic illness. (Hen suyễn là bệnh mãn tính.)', false, NOW()),
  (v_deck_id, 'symptom', '/ˈsɪmp.təm/', 'triệu chứng', 'Fever is a common symptom. (Sốt là một triệu chứng phổ biến.)', false, NOW()),
  (v_deck_id, 'inflammation', '/ˌɪn.fləˈmeɪ.ʃən/', 'sưng viêm', 'Ice reduces inflammation. (Đá lạnh giúp giảm sưng viêm.)', false, NOW()),
  (v_deck_id, 'benign', '/bɪˈnaɪn/', 'lành tính', 'The tumor is benign. (Khối u là lành tính.)', false, NOW()),
  (v_deck_id, 'malignant', '/məˈlɪɡ.nənt/', 'ác tính', 'Early detection of malignant cells. (Phát hiện sớm các tế bào ác tính.)', false, NOW()),
  (v_deck_id, 'metastasis', '/məˈtæs.tə.sɪs/', 'di căn', 'Preventing cancer metastasis. (Ngăn chặn ung thư di căn.)', false, NOW()),
  (v_deck_id, 'biopsy', '/ˈbaɪ.ɒp.si/', 'sinh thiết', 'They performed a skin biopsy. (Họ đã thực hiện sinh thiết da.)', false, NOW()),
  (v_deck_id, 'lesion', '/ˈliː.ʒən/', 'vết thương tổn', 'Examine the skin lesion. (Khám xét vết thương tổn trên da.)', false, NOW()),
  (v_deck_id, 'relapse', '/rɪˈlæps/', 'tái phát', 'Take medicine to avoid relapse. (Uống thuốc để tránh tái phát.)', false, NOW()),
  (v_deck_id, 'remission', '/rɪˈmɪʃ.ən/', 'thuyên giảm', 'The disease is in remission. (Bệnh đang trong giai đoạn thuyên giảm.)', false, NOW()),
  (v_deck_id, 'etiology', '/ˌiː.tiˈɒl.ə.dʒi/', 'nguyên nhân bệnh', 'The etiology is still unknown. (Nguyên nhân bệnh vẫn chưa rõ.)', false, NOW()),
  (v_deck_id, 'pathology', '/pəˈθɒl.ə.dʒi/', 'bệnh học', 'Review the pathology report. (Xem lại báo cáo bệnh học.)', false, NOW());

  -- Bài 12: Y Khoa - Bài 2: Điều Trị & Dược Phẩm
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Y Khoa - Bài 2: Điều Trị & Dược Phẩm', 'Thuật ngữ về dược lý học, đơn thuốc và điều trị lâm sàng.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'prescription', '/prɪˈskrɪp.ʃən/', 'đơn thuốc', 'Get medicine with a prescription. (Mua thuốc theo đơn thuốc.)', false, NOW()),
  (v_deck_id, 'dosage', '/ˈdəʊ.sɪdʒ/', 'liều lượng', 'Follow the correct dosage. (Tuân theo đúng liều lượng.)', false, NOW()),
  (v_deck_id, 'adverse effect', '/ˈæd.vɜːs ɪˈfekt/', 'tác dụng phụ', 'Check for any adverse effect. (Kiểm tra xem có tác dụng phụ nào không.)', false, NOW()),
  (v_deck_id, 'contraindication', '/ˌkɒn.trəˌɪn.dɪˈkeɪ.ʃən/', 'chống chỉ định', 'Pregnancy is a contraindication. (Mang thai là trường hợp chống chỉ định.)', false, NOW()),
  (v_deck_id, 'efficacy', '/ˈef.ɪ.kə.si/', 'hiệu lực thuốc', 'The vaccine has high efficacy. (Vắc-xin có hiệu lực cao.)', false, NOW()),
  (v_deck_id, 'intravenous', '/ˌɪn.trəˈviː.nəs/', 'tiêm tĩnh mạch', 'Administer intravenous fluids. (Truyền dịch qua đường tĩnh mạch.)', false, NOW()),
  (v_deck_id, 'anesthesia', '/ˌæn.əsˈθiː.zi.ə/', 'gây mê', 'Surgery requires anesthesia. (Phẫu thuật cần phải gây mê.)', false, NOW()),
  (v_deck_id, 'triage', '/ˈtriː.ɑːʒ/', 'phân loại cấp cứu', 'Emergency triage saves lives. (Phân loại cấp cứu giúp cứu người.)', false, NOW()),
  (v_deck_id, 'resuscitation', '/rɪˌsʌs.ɪˈteɪ.ʃən/', 'hồi sức cấp cứu', 'Start resuscitation immediately. (Bắt đầu hồi sức cấp cứu ngay.)', false, NOW()),
  (v_deck_id, 'immunity', '/ɪˈmjuː.nə.ti/', 'miễn dịch', 'Build natural immunity. (Xây dựng miễn dịch tự nhiên.)', false, NOW()),
  (v_deck_id, 'placebo', '/pləˈsiː.bəʊ/', 'giả dược', 'The patient took a placebo. (Bệnh nhân đã uống viên giả dược.)', false, NOW()),
  (v_deck_id, 'palliative care', '/ˈpæl.jə.tɪv keər/', 'chăm sóc giảm nhẹ', 'Palliative care eases pain. (Chăm sóc giảm nhẹ giúp xoa dịu nỗi đau.)', false, NOW()),
  (v_deck_id, 'intubation', '/ˌɪn.tjuːˈbeɪ.ʃən/', 'đặt ống thở', 'Emergency intubation was needed. (Cần phải đặt ống thở khẩn cấp.)', false, NOW()),
  (v_deck_id, 'sterilization', '/ˌster.ɪ.laɪˈzeɪ.ʃən/', 'tiệt trùng', 'Tool sterilization is mandatory. (Tiệt trùng dụng cụ là bắt buộc.)', false, NOW()),
  (v_deck_id, 'therapy', '/ˈθer.ə.pi/', 'trị liệu', 'Physical therapy helps recovery. (Vật lý trị liệu giúp hồi phục.)', false, NOW());

  -- Bài 13: Y Khoa - Bài 3: Tim Mạch & Tuần Hoàn
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Y Khoa - Bài 3: Tim Mạch & Tuần Hoàn', 'Thuật ngữ hệ tim mạch, mạch máu và huyết áp.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'hypertension', '/ˌhaɪ.pəˈten.ʃən/', 'cao huyết áp', 'Control severe hypertension. (Kiểm soát chứng cao huyết áp nặng.)', false, NOW()),
  (v_deck_id, 'hypotension', '/ˌhaɪ.pəʊˈten.ʃən/', 'huyết áp thấp', 'Dizziness caused by hypotension. (Chóng mặt do huyết áp thấp.)', false, NOW()),
  (v_deck_id, 'myocardial infarction', '/ˌmaɪ.əʊˈkɑː.di.əl ɪnˈfɑːk.ʃən/', 'nhồi máu cơ tim', 'Survive a myocardial infarction. (Sống sót sau cơn nhồi máu cơ tim.)', false, NOW()),
  (v_deck_id, 'arrhythmia', '/əˈrɪð.mi.ə/', 'loạn nhịp tim', 'ECG detects heart arrhythmia. (Điện tâm đồ phát hiện loạn nhịp tim.)', false, NOW()),
  (v_deck_id, 'artery', '/ˈɑː.tər.i/', 'động mạch', 'Arteries carry oxygenated blood. (Động mạch vận chuyển máu giàu oxy.)', false, NOW()),
  (v_deck_id, 'vein', '/veɪn/', 'tĩnh mạch', 'Blood flows back through veins. (Máu chảy ngược về qua các tĩnh mạch.)', false, NOW()),
  (v_deck_id, 'capillary', '/kəˈpɪl.ər.i/', 'mao mạch', 'Gas exchange in lung capillaries. (Trao đổi khí trong các mao mạch phổi.)', false, NOW()),
  (v_deck_id, 'atherosclerosis', '/ˌæθ.ə.rəʊ.skləˈrəʊ.sɪs/', 'xơ vữa động mạch', 'Cholesterol causes atherosclerosis. (Cholesterol gây ra xơ vữa động mạch.)', false, NOW()),
  (v_deck_id, 'thrombosis', '/θrɒmˈbəʊ.sɪs/', 'huyết khối (cục máu đông)', 'Deep vein thrombosis risk. (Nguy cơ huyết khối tĩnh mạch sâu.)', false, NOW()),
  (v_deck_id, 'embolism', '/ˈem.bəl.ɪ.zəm/', 'thuyên tắc mạch', 'Pulmonary embolism is dangerous. (Thuyên tắc phổi là bệnh lý nguy hiểm.)', false, NOW()),
  (v_deck_id, 'stroke', '/strəʊk/', 'đột quỵ não', 'Quick action saves stroke victims. (Xử trí nhanh cứu sống nạn nhân đột quỵ.)', false, NOW()),
  (v_deck_id, 'aneurysm', '/ˈæn.jə.rɪ.zəm/', 'phình động mạch', 'Surgical repair of brain aneurysm. (Phẫu thuật khắc phục phình động mạch não.)', false, NOW()),
  (v_deck_id, 'pacemaker', '/ˈpeɪsˌmeɪ.kər/', 'máy tạo nhịp tim', 'Implant a permanent pacemaker. (Cấy ghép máy tạo nhịp tim vĩnh viễn.)', false, NOW()),
  (v_deck_id, 'stent', '/stent/', 'ống nong mạch vành', 'Insert a stent into the blocked artery. (Đặt ống nong vào động mạch bị tắc.)', false, NOW()),
  (v_deck_id, 'systolic', '/sɪsˈtɒl.ɪk/', 'huyết áp tâm thu', 'Measure systolic blood pressure. (Đo chỉ số huyết áp tâm thu.)', false, NOW());

  -- Bài 14: Y Khoa - Bài 4: Hô Hấp & Phổi
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Y Khoa - Bài 4: Hô Hấp & Phổi', 'Thuật ngữ hệ hô hấp, phế quản và bệnh phổi.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'pneumonia', '/njuːˈməʊ.ni.ə/', 'viêm phổi', 'Bacterial pneumonia requires antibiotics. (Viêm phổi do vi khuẩn cần uống kháng sinh.)', false, NOW()),
  (v_deck_id, 'bronchitis', '/brɒŋˈkaɪ.tɪs/', 'viêm phế quản', 'Chronic bronchitis causes coughing. (Viêm phế quản mãn tính gây ra các cơn ho.)', false, NOW()),
  (v_deck_id, 'asthma', '/ˈæs.mə/', 'hen suyễn', 'Use an inhaler during asthma attacks. (Dùng ống hít trong các cơn hen suyễn.)', false, NOW()),
  (v_deck_id, 'inhaler', '/ɪnˈheɪ.lər/', 'ống hít hen', 'Carry a rescue inhaler. (Mang theo ống hít cấp cứu.)', false, NOW()),
  (v_deck_id, 'hypoxia', '/haɪˈpɒk.si.ə/', 'thiếu oxy mô', 'Brain hypoxia causes cell damage. (Thiếu oxy não gây tổn thương tế bào.)', false, NOW()),
  (v_deck_id, 'dyspnea', '/dɪspˈniː.ə/', 'khó thở', 'Severe dyspnea on exertion. (Khó thở nghiêm trọng khi gắng sức.)', false, NOW()),
  (v_deck_id, 'alveoli', '/æl.viˈəʊ.laɪ/', 'phế nang phổi', 'Oxygen diffuses across alveoli. (Oxy khuếch tán qua các phế nang.)', false, NOW()),
  (v_deck_id, 'trachea', '/trəˈkiː.ə/', 'khí quản', 'Clear the blocked trachea. (Làm thông khí quản bị tắc nghẽn.)', false, NOW()),
  (v_deck_id, 'sputum', '/ˈspjuː.təm/', 'đờm dãi', 'Send sputum sample for lab testing. (Gửi mẫu đờm đi xét nghiệm phòng thí nghiệm.)', false, NOW()),
  (v_deck_id, 'ventilator', '/ˈven.tɪ.leɪ.tər/', 'máy thở oxy', 'Connect critical patient to a ventilator. (Nối bệnh nhân nguy kịch với máy thở.)', false, NOW()),
  (v_deck_id, 'fibrosis', '/faɪˈbrəʊ.sɪs/', 'xơ hóa mô', 'Pulmonary fibrosis scars lung tissue. (Xơ phổi tạo sẹo ở mô phổi.)', false, NOW()),
  (v_deck_id, 'cyanosis', '/ˌsaɪ.əˈnəʊ.sɪs/', 'tím tái do thiếu oxy', 'Bluish skin indicates cyanosis. (Da xanh xao tím tái là dấu hiệu thiếu oxy.)', false, NOW()),
  (v_deck_id, 'spirometry', '/spaɪˈrɒm.ə.tri/', 'đo chức năng hô hấp', 'Spirometry tests lung capacity. (Đo chức năng hô hấp kiểm tra dung tích phổi.)', false, NOW()),
  (v_deck_id, 'emphysema', '/ˌem.fɪˈsiː.mə/', 'khí phế thũng', 'Smoking often causes emphysema. (Hút thuốc lá thường gây ra khí phế thũng.)', false, NOW()),
  (v_deck_id, 'tuberculosis', '/tjuːˌbɜː.kjəˈləʊ.sɪs/', 'bệnh lao phổi', 'Treat tuberculosis with medication. (Điều trị bệnh lao phổi bằng thuốc đặc trị.)', false, NOW());

  -- Bài 15: Y Khoa - Bài 5: Tiêu Hóa & Gan Mật
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Y Khoa - Bài 5: Tiêu Hóa & Gan Mật', 'Thuật ngữ đường tiêu hóa, dạ dày, gan mật và đại tràng.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'gastritis', '/ɡæsˈtraɪ.tɪs/', 'viêm dạ dày', 'Stress aggravates acute gastritis. (Căng thẳng làm nặng thêm viêm dạ dày cấp.)', false, NOW()),
  (v_deck_id, 'ulcer', '/ˈʌl.sər/', 'vết loét', 'Stomach ulcer causes burning pain. (Loét dạ dày gây đau rát cồn cào.)', false, NOW()),
  (v_deck_id, 'endoscopy', '/enˈdɒs.kə.pi/', 'nội soi tiêu hóa', 'Upper endoscopy finds stomach lesions. (Nội soi đường tiêu hóa trên phát hiện tổn thương.)', false, NOW()),
  (v_deck_id, 'hepatitis', '/ˌhep.əˈtaɪ.tɪs/', 'viêm gan', 'Get vaccinated against hepatitis B. (Tiêm vắc-xin phòng ngừa viêm gan B.)', false, NOW()),
  (v_deck_id, 'cirrhosis', '/sɪˈrəʊ.sɪs/', 'xơ gan', 'Liver cirrhosis impairs protein synthesis. (Xơ gan làm suy giảm tổng hợp protein.)', false, NOW()),
  (v_deck_id, 'jaundice', '/ˈdʒɔːn.dɪs/', 'vàng da / vàng mắt', 'Jaundice is a sign of liver failure. (Vàng da là dấu hiệu của suy giảm chức năng gan.)', false, NOW()),
  (v_deck_id, 'peristalsis', '/ˌper.ɪˈstæl.sɪs/', 'nhu động ruột', 'Normal gut peristalsis moves food. (Nhu động ruột bình thường đẩy thức ăn đi.)', false, NOW()),
  (v_deck_id, 'pancreatitis', '/ˌpæŋ.kri.əˈtaɪ.tɪs/', 'viêm tụy', 'Acute pancreatitis causes severe pain. (Viêm tụy cấp gây đau đớn dữ dội.)', false, NOW()),
  (v_deck_id, 'colonoscopy', '/ˌkɒl.əˈnɒs.kə.pi/', 'nội soi đại tràng', 'Screening colonoscopy detects polyps. (Nội soi đại tràng tầm soát phát hiện polyp.)', false, NOW()),
  (v_deck_id, 'polyp', '/ˈpɒl.ɪp/', 'khối u nhỏ (polyp)', 'Remove the colon polyp safely. (Cắt bỏ polyp đại tràng một cách an toàn.)', false, NOW()),
  (v_deck_id, 'nausea', '/ˈnɔː.zi.ə/', 'buồn nôn', 'Feel severe nausea after medication. (Cảm thấy buồn nôn dữ dội sau khi uống thuốc.)', false, NOW()),
  (v_deck_id, 'metabolism', '/məˈtæb.əl.ɪ.zəm/', 'chuyển hóa chất', 'Liver regulates body metabolism. (Gan điều hòa quá trình chuyển hóa của cơ thể.)', false, NOW()),
  (v_deck_id, 'enzyme', '/ˈen.zaɪm/', 'men tiêu hóa', 'Digestive enzymes break down fat. (Các men tiêu hóa giúp phân giải chất béo.)', false, NOW()),
  (v_deck_id, 'laxative', '/ˈlæk.sə.tɪv/', 'thuốc nhuận tràng', 'Take a mild laxative for relief. (Uống thuốc nhuận tràng nhẹ để dễ chịu hơn.)', false, NOW()),
  (v_deck_id, 'esophagus', '/ɪˈsɒf.ə.ɡəs/', 'thực quản', 'Acid reflux damages the esophagus. (Trào ngược axit làm tổn thương thực quản.)', false, NOW());

  -- Bài 16: Y Khoa - Bài 6: Thần Kinh & Não Bộ
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Y Khoa - Bài 6: Thần Kinh & Não Bộ', 'Thuật ngữ hệ thần kinh trung ương, não bộ và phản xạ.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'neuron', '/ˈnjʊə.rɒn/', 'tế bào thần kinh', 'Neurons transmit electrical signals. (Tế bào thần kinh truyền tín hiệu điện.)', false, NOW()),
  (v_deck_id, 'synapse', '/ˈsaɪ.næps/', 'khớp nối thần kinh', 'Neurotransmitters cross the synapse. (Chất dẫn truyền thần kinh đi qua khớp nối.)', false, NOW()),
  (v_deck_id, 'neurotransmitter', '/ˌnjʊə.rəʊ.trænzˈmɪt.ər/', 'chất dẫn truyền thần kinh', 'Dopamine is an important neurotransmitter. (Dopamine là chất dẫn truyền thần kinh quan trọng.)', false, NOW()),
  (v_deck_id, 'concussion', '/kənˈkʌʃ.ən/', 'chấn động não', 'Athlete suffered a mild concussion. (Vận động viên bị chấn động não nhẹ.)', false, NOW()),
  (v_deck_id, 'coma', '/ˈkəʊ.mə/', 'hôn mê sâu', 'Patient remains in a deep coma. (Bệnh nhân vẫn đang trong trạng thái hôn mê sâu.)', false, NOW()),
  (v_deck_id, 'seizure', '/ˈsiː.ʒər/', 'cơn co giật / động kinh', 'Medication controls epileptic seizures. (Thuốc giúp kiểm soát các cơn co giật động kinh.)', false, NOW()),
  (v_deck_id, 'dementia', '/dɪˈmen.ʃə/', 'sa sút trí tuệ', 'Alzheimer is the leading cause of dementia. (Alzheimer là nguyên nhân hàng đầu gây sa sút trí tuệ.)', false, NOW()),
  (v_deck_id, 'paralysis', '/pəˈræl.ə.sɪs/', 'liệt / bại liệt', 'Spinal injury caused lower body paralysis. (Tổn thương tủy sống gây liệt nửa thân dưới.)', false, NOW()),
  (v_deck_id, 'reflex', '/ˈriː.fleks/', 'phản xạ thần kinh', 'Check knee jerk reflex response. (Kiểm tra phản xạ giật đầu gối.)', false, NOW()),
  (v_deck_id, 'meningitis', '/ˌmen.ɪnˈdʒaɪ.tɪs/', 'viêm màng não', 'Bacterial meningitis requires prompt care. (Viêm màng não do vi khuẩn cần chữa trị khẩn cấp.)', false, NOW()),
  (v_deck_id, 'migraine', '/ˈmiː.ɡreɪn/', 'đau nửa đầu', 'Dark room relieves migraine headache. (Phòng tối giúp xoa dịu cơn đau nửa đầu.)', false, NOW()),
  (v_deck_id, 'vertigo', '/ˈvɜː.tɪ.ɡəʊ/', 'chóng mặt hoa mắt', 'Inner ear infection causes vertigo. (Nhiễm trùng tai trong gây ra chứng chóng mặt.)', false, NOW()),
  (v_deck_id, 'cranial', '/ˈkreɪ.ni.əl/', 'thuộc về hộp sọ', 'Examine twelve cranial nerves. (Khám xét 12 đôi dây thần kinh sọ não.)', false, NOW()),
  (v_deck_id, 'sedative', '/ˈsed.ə.tɪv/', 'thuốc an thần', 'Doctor prescribed a mild sedative. (Bác sĩ kê một liều thuốc an thần nhẹ.)', false, NOW()),
  (v_deck_id, 'amnesia', '/æmˈniː.zi.ə/', 'chứng mất trí nhớ', 'Head trauma caused temporary amnesia. (Chấn thương đầu gây mất trí nhớ tạm thời.)', false, NOW());

  -- Bài 17: Y Khoa - Bài 7: Cơ Xương Khớp & Chấn Thương
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Y Khoa - Bài 7: Cơ Xương Khớp & Chấn Thương', 'Thuật ngữ chỉnh hình, gãy xương, dây chằng và khớp.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'fracture', '/ˈfræk.tʃər/', 'gãy xương', 'X-ray confirmed an arm bone fracture. (Chụp X-quang xác nhận bị gãy xương tay.)', false, NOW()),
  (v_deck_id, 'dislocation', '/ˌdɪs.ləˈkeɪ.ʃən/', 'trật khớp', 'Shoulder dislocation reset by doctor. (Bác sĩ đã nắn lại khớp vai bị trật.)', false, NOW()),
  (v_deck_id, 'sprain', '/spreɪn/', 'bong gân', 'Ankle sprain needs ice and rest. (Bong gân mắt cá chân cần chườm đá và nghỉ ngơi.)', false, NOW()),
  (v_deck_id, 'ligament', '/ˈlɪɡ.ə.mənt/', 'dây chằng', 'Torn cruciate ligament in the knee. (Rách dây chằng chéo ở đầu gối.)', false, NOW()),
  (v_deck_id, 'tendon', '/ˈten.dən/', 'gân cơ', 'Achilles tendon connects calf to heel. (Gân gót nối bắp chân với gót chân.)', false, NOW()),
  (v_deck_id, 'cartilage', '/ˈkɑː.təl.ɪdʒ/', 'sụn khớp', 'Articular cartilage cushions joint bones. (Sụn khớp giúp đệm cho các đầu xương.)', false, NOW()),
  (v_deck_id, 'arthritis', '/ɑːˈθraɪ.tɪs/', 'viêm khớp', 'Rheumatoid arthritis causes joint swelling. (Viêm khớp dạng thấp gây sưng đau các khớp.)', false, NOW()),
  (v_deck_id, 'osteoporosis', '/ˌɒs.ti.əʊ.pəˈrəʊ.sɪs/', 'loãng xương', 'Calcium prevents bone osteoporosis. (Canxi giúp ngăn ngừa bệnh loãng xương.)', false, NOW()),
  (v_deck_id, 'cast', '/kɑːst/', 'bó bột cố định', 'Wear an arm plaster cast for six weeks. (Đeo bó bột cố định tay trong sáu tuần.)', false, NOW()),
  (v_deck_id, 'splint', '/splɪnt/', 'nẹp cố định', 'Apply a finger splint to stabilize. (Đeo nẹp ngón tay để cố định vị trí.)', false, NOW()),
  (v_deck_id, 'prosthesis', '/prɒsˈθiː.sɪs/', 'chi giả / bộ phận nhân tạo', 'Custom leg prosthesis fits comfortably. (Chân giả thiết kế riêng vừa vặn thoải mái.)', false, NOW()),
  (v_deck_id, 'rehabilitation', '/ˌriː.həˌbɪl.ɪˈteɪ.ʃən/', 'phục hồi chức năng', 'Post-surgery physical rehabilitation. (Phục hồi chức năng thể chất sau phẫu thuật.)', false, NOW()),
  (v_deck_id, 'vertebra', '/ˈvɜː.tɪ.brə/', 'đốt sống', 'Lumbar vertebra supports body weight. (Đốt sống thắt lưng chịu trọng lượng cơ thể.)', false, NOW()),
  (v_deck_id, 'spine', '/spaɪn/', 'cột sống', 'Maintain a healthy straight spine. (Giữ cho cột sống luôn thẳng và khỏe mạnh.)', false, NOW()),
  (v_deck_id, 'amputation', '/ˌæm.pjəˈteɪ.ʃən/', 'phẫu thuật cắt cụt', 'Severe infection necessitated limb amputation. (Nhiễm trùng nặng buộc phải phẫu thuật cắt cụt chi.)', false, NOW());

  -- Bài 18: Y Khoa - Bài 8: Nhi Khoa & Sản Phụ Khoa
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Y Khoa - Bài 8: Nhi Khoa & Sản Phụ Khoa', 'Thuật ngữ thai sản, sinh nở, chăm sóc trẻ sơ sinh và phụ khoa.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'gestation', '/dʒesˈteɪ.ʃən/', 'thai kỳ', 'Normal human gestation is 40 weeks. (Thai kỳ bình thường ở người kéo dài 40 tuần.)', false, NOW()),
  (v_deck_id, 'fetus', '/ˈfiː.təs/', 'thai nhi', 'Ultrasound checks fetus heartbeat. (Siêu âm kiểm tra nhịp tim của thai nhi.)', false, NOW()),
  (v_deck_id, 'ultrasound', '/ˈʌl.trə.saʊnd/', 'siêu âm', 'Routine prenatal ultrasound scan. (Quét siêu âm thai định kỳ trước sinh.)', false, NOW()),
  (v_deck_id, 'trimester', '/traɪˈmes.tər/', 'tam cá nguyệt (3 tháng thai)', 'First trimester morning sickness. (Ốm nghén trong tam cá nguyệt thứ nhất.)', false, NOW()),
  (v_deck_id, 'cesarean', '/sɪˈzeə.ri.ən/', 'mổ đẻ / sinh mổ', 'Emergency cesarean section delivery. (Ca phẫu thuật mổ đẻ cấp cứu.)', false, NOW()),
  (v_deck_id, 'premature', '/ˌprem.əˈtʃʊər/', 'sinh non', 'Premature infant in an incubator. (Trẻ sơ sinh non tháng nằm trong lồng ấp.)', false, NOW()),
  (v_deck_id, 'incubator', '/ˈɪŋ.kjə.beɪ.tər/', 'lồng ấp trẻ sơ sinh', 'Warm incubator keeps baby safe. (Lồng ấp ấm áp giữ an toàn cho em bé.)', false, NOW()),
  (v_deck_id, 'lactation', '/lækˈteɪ.ʃən/', 'tiết sữa mẹ', 'Support maternal lactation after birth. (Hỗ trợ tiết sữa mẹ sau khi sinh con.)', false, NOW()),
  (v_deck_id, 'pediatric', '/ˌpiː.diˈæt.rɪk/', 'thuộc về nhi khoa', 'Visit the pediatric clinic. (Đến khám tại phòng khám nhi khoa.)', false, NOW()),
  (v_deck_id, 'immunization', '/ˌɪm.jə.naɪˈzeɪ.ʃən/', 'tiêm chủng mở rộng', 'Childhood immunization schedule. (Lịch tiêm chủng mở rộng cho trẻ em.)', false, NOW()),
  (v_deck_id, 'congenital', '/kənˈdʒen.ɪ.təl/', 'bẩm sinh', 'Correct congenital heart defect. (Phẫu thuật sửa dị tật tim bẩm sinh.)', false, NOW()),
  (v_deck_id, 'placenta', '/pləˈsen.tə/', 'nhau thai', 'Placenta delivers nutrients to fetus. (Nhau thai cung cấp dưỡng chất cho thai nhi.)', false, NOW()),
  (v_deck_id, 'contractions', '/kənˈtræk.ʃənz/', 'cơn co thắt chuyển dạ', 'Labor contractions became more frequent. (Các cơn co thắt chuyển dạ xuất hiện dồn dập hơn.)', false, NOW()),
  (v_deck_id, 'obstetrics', '/əbˈstet.rɪks/', 'sản khoa', 'Specialized in gynecology and obstetrics. (Chuyên về phụ khoa và sản khoa.)', false, NOW()),
  (v_deck_id, 'postpartum', '/ˌpəʊstˈpɑː.təm/', 'hậu sản / sau sinh', 'Screening for postpartum depression. (Sàng lọc trầm cảm hậu sản sau sinh.)', false, NOW());

  -- Bài 19: Y Khoa - Bài 9: Nhãn Khoa & Tai Mũi Họng
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Y Khoa - Bài 9: Nhãn Khoa & Tai Mũi Họng', 'Thuật ngữ khám mắt, thị lực, thính giác và đường hô hấp trên.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'cornea', '/ˈkɔː.ni.ə/', 'giác mạc', 'Laser surgery reshapes the cornea. (Phẫu thuật laser định hình lại giác mạc.)', false, NOW()),
  (v_deck_id, 'retina', '/ˈret.ɪ.nə/', 'võng mạc', 'Retina detaches requiring surgery. (Bong võng mạc cần phải phẫu thuật can thiệp.)', false, NOW()),
  (v_deck_id, 'cataract', '/ˈkæt.ə.rækt/', 'đục thủy tinh thể', 'Cataract surgery restores vision clarity. (Mổ đục thủy tinh thể phục hồi thị lực sáng rõ.)', false, NOW()),
  (v_deck_id, 'glaucoma', '/ɡlɔːˈkəʊ.mə/', 'tăng nhãn áp', 'Eye drops lower glaucoma pressure. (Thuốc nhỏ mắt giúp hạ áp lực tăng nhãn áp.)', false, NOW()),
  (v_deck_id, 'myopia', '/maɪˈəʊ.pi.ə/', 'cận thị', 'Wear corrective glasses for myopia. (Đeo kính thuốc điều chỉnh tật cận thị.)', false, NOW()),
  (v_deck_id, 'hyperopia', '/ˌhaɪ.pərˈəʊ.pi.ə/', 'viễn thị', 'Hyperopia makes near objects blurry. (Viễn thị làm các vật ở gần bị mờ đi.)', false, NOW()),
  (v_deck_id, 'pupil', '/ˈpjuː.pəl/', 'đồng tử / con ngươi', 'Pupils dilate in dark light. (Đồng tử giãn nở trong điều kiện ánh sáng tối.)', false, NOW()),
  (v_deck_id, 'audiology', '/ˌɔː.diˈɒl.ə.dʒi/', 'thính học', 'Perform an audiology hearing test. (Tiến hành bài kiểm tra thính học đo sức nghe.)', false, NOW()),
  (v_deck_id, 'eardrum', '/ˈɪə.drʌm/', 'màng nhĩ', 'Ruptured eardrum heals over time. (Màng nhĩ bị thủng sẽ tự lành theo thời gian.)', false, NOW()),
  (v_deck_id, 'tinnitus', '/ˈtɪn.ɪ.təs/', 'ù tai', 'Persistent ringing tinnitus in ears. (Tiếng kêu vo vo ù tai dai dẳng trong tai.)', false, NOW()),
  (v_deck_id, 'sinusitis', '/ˌsaɪ.nəˈsaɪ.tɪs/', 'viêm xoang', 'Nasal spray treats acute sinusitis. (Thuốc xịt mũi điều trị viêm xoang cấp.)', false, NOW()),
  (v_deck_id, 'tonsillitis', '/ˌtɒn.sɪˈlaɪ.tɪs/', 'viêm amiđan', 'Swollen throat from tonsillitis. (Cổ họng sưng tấy do viêm amiđan.)', false, NOW()),
  (v_deck_id, 'larynx', '/ˈlær.ɪŋks/', 'thanh quản', 'Vocal cords located in the larynx. (Dây thanh quản nằm bên trong thanh quản.)', false, NOW()),
  (v_deck_id, 'pharynx', '/ˈfær.ɪŋks/', 'hầu họng', 'Food passes through the pharynx. (Thức ăn đi qua hầu họng xuống thực quản.)', false, NOW()),
  (v_deck_id, 'ophthalmology', '/ˌɒf.θælˈmɒl.ə.dʒi/', 'nhãn khoa', 'Consult an ophthalmology specialist. (Tham khảo ý kiến chuyên gia nhãn khoa.)', false, NOW());

  -- Bài 20: Y Khoa - Bài 10: Cấp Cứu & Hồi Sức Tích Cực
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Y Khoa - Bài 10: Cấp Cứu & Hồi Sức Tích Cực', 'Thuật ngữ phòng cấp cứu (ER), chăm sóc tích cực (ICU) và dấu hiệu sinh tồn.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'vital signs', '/ˈvaɪ.təl saɪnz/', 'dấu hiệu sinh tồn', 'Monitor patient vital signs hourly. (Theo dõi dấu hiệu sinh tồn bệnh nhân mỗi giờ.)', false, NOW()),
  (v_deck_id, 'defibrillator', '/diːˈfɪb.rɪ.leɪ.tər/', 'máy khử rung tim', 'Apply electric shock with defibrillator. (Sốc điện bằng máy khử rung tim cấp cứu.)', false, NOW()),
  (v_deck_id, 'hemorrhage', '/ˈhem.ər.ɪdʒ/', 'xuất huyết ồ ạt', 'Apply pressure to stop hemorrhage. (Ấn ép chặt để cầm máu xuất huyết ồ ạt.)', false, NOW()),
  (v_deck_id, 'tourniquet', '/ˈtʊə.nɪ.keɪ/', 'garo thắt cầm máu', 'Apply a tourniquet on the bleeding arm. (Thắt dây garo trên cánh tay đang chảy máu.)', false, NOW()),
  (v_deck_id, 'trauma', '/ˈtrɔː.mə/', 'chấn thương nghiêm trọng', 'Admit to the level-one trauma center. (Nhập vào trung tâm cấp cứu chấn thương cấp 1.)', false, NOW()),
  (v_deck_id, 'sepsis', '/ˈsep.sɪs/', 'nhiễm trùng huyết', 'Severe sepsis requires urgent IV antibiotics. (Nhiễm trùng huyết nặng cần kháng sinh tĩnh mạch khẩn.)', false, NOW()),
  (v_deck_id, 'anaphylaxis', '/ˌæn.ə.fɪˈlæk.sɪs/', 'sốc phản vệ', 'Inject epinephrine for severe anaphylaxis. (Tiêm epinephrine cấp cứu sốc phản vệ nặng.)', false, NOW()),
  (v_deck_id, 'epinephrine', '/ˌep.ɪˈnef.rɪn/', 'thuốc chống sốc phản vệ', 'Autoinjector delivers instant epinephrine. (Bút tiêm tự động truyền thuốc chống sốc ngay lập tức.)', false, NOW()),
  (v_deck_id, 'catheter', '/ˈkæθ.ə.tər/', 'ống thông tiểu / dẫn lưu', 'Insert urinary catheter safely. (Đặt ống thông tiểu một cách an toàn.)', false, NOW()),
  (v_deck_id, 'dialysis', '/daɪˈæl.ə.sɪs/', 'chạy thận nhân tạo', 'Kidney failure patient needs dialysis. (Bệnh nhân suy thận cần chạy thận nhân tạo.)', false, NOW()),
  (v_deck_id, 'sedation', '/sɪˈdeɪ.ʃən/', 'làm dịu / gây mê nhẹ', 'Perform procedure under conscious sedation. (Làm thủ thuật dưới trạng thái gây mê nhẹ có ý thức.)', false, NOW()),
  (v_deck_id, 'transfusion', '/trænsˈfjuː.ʒən/', 'truyền máu', 'Emergency whole blood transfusion. (Truyền máu toàn phần cấp cứu khẩn cấp.)', false, NOW()),
  (v_deck_id, 'cannula', '/ˈkæn.jə.lə/', 'ống luồn oxy mũi', 'Deliver oxygen via nasal cannula. (Cung cấp oxy qua ống luồn mũi.)', false, NOW()),
  (v_deck_id, 'pulse oximeter', '/pʌls ɒkˈsɪm.ɪ.tər/', 'kẹp đo nồng độ oxy (SpO2)', 'Attach pulse oximeter on the finger. (Kẹp máy đo nồng độ oxy SpO2 vào đầu ngón tay.)', false, NOW()),
  (v_deck_id, 'suction', '/ˈsʌk.ʃən/', 'hút đờm / hút dịch', 'Use medical suction to clear airway. (Dùng máy hút dịch để làm thông thoáng đường thở.)', false, NOW());

  -- =========================================================
  -- KHỐI: ECONOMICS_FINANCE.JSON (10 bài học)
  -- =========================================================

  -- Bài 21: Kinh Tế - Bài 1: Kinh Tế Vĩ Mô
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Kinh Tế - Bài 1: Kinh Tế Vĩ Mô', 'Thuật ngữ cốt lõi về kinh tế vĩ mô, lạm phát và tiền tệ.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'inflation', '/ɪnˈfleɪ.ʃən/', 'lạm phát', 'Control rising inflation. (Kiểm soát lạm phát gia tăng.)', false, NOW()),
  (v_deck_id, 'deflation', '/diːˈfleɪ.ʃən/', 'giảm phát', 'Deflation slows down buying. (Giảm phát làm chậm việc mua sắm.)', false, NOW()),
  (v_deck_id, 'recession', '/rɪˈseʃ.ən/', 'suy thoái', 'The economy entered a recession. (Nền kinh tế bước vào suy thoái.)', false, NOW()),
  (v_deck_id, 'fiscal policy', '/ˈfɪs.kəl ˈpɒl.ə.si/', 'chính sách tài khóa', 'Government adjusted fiscal policy. (Chính phủ đã điều chỉnh chính sách tài khóa.)', false, NOW()),
  (v_deck_id, 'monetary policy', '/ˈmʌn.ɪ.tri ˈpɒl.ə.si/', 'chính sách tiền tệ', 'Central bank manages monetary policy. (Ngân hàng trung ương quản lý chính sách tiền tệ.)', false, NOW()),
  (v_deck_id, 'deficit', '/ˈdef.ɪ.sɪt/', 'thâm hụt', 'Cut the budget deficit. (Cắt giảm thâm hụt ngân sách.)', false, NOW()),
  (v_deck_id, 'surplus', '/ˈsɜː.pləs/', 'thặng dư', 'Record trade surplus this year. (Thặng dư thương mại kỷ lục năm nay.)', false, NOW()),
  (v_deck_id, 'tariff', '/ˈtær.ɪf/', 'thuế quan', 'Impose tariffs on imports. (Áp thuế quan lên hàng nhập khẩu.)', false, NOW()),
  (v_deck_id, 'monopoly', '/məˈnɒp.əl.i/', 'độc quyền', 'Prevent market monopoly. (Ngăn chặn độc quyền thị trường.)', false, NOW()),
  (v_deck_id, 'interest rate', '/ˈɪn.trəst reɪt/', 'lãi suất', 'Banks increased the interest rate. (Ngân hàng đã tăng lãi suất.)', false, NOW()),
  (v_deck_id, 'depreciation', '/dɪˌpriː.ʃiˈeɪ.ʃən/', 'mất giá / khấu hao', 'Currency depreciation hurts trade. (Đồng tiền mất giá gây hại thương mại.)', false, NOW()),
  (v_deck_id, 'commodity', '/kəˈmɒd.ə.ti/', 'hàng hóa', 'Oil is an important commodity. (Dầu mỏ là một hàng hóa quan trọng.)', false, NOW()),
  (v_deck_id, 'revenue', '/ˈrev.ən.juː/', 'doanh thu', 'Annual revenue grew quickly. (Doanh thu hàng năm tăng trưởng nhanh.)', false, NOW()),
  (v_deck_id, 'expenditure', '/ɪkˈspen.dɪ.tʃər/', 'chi tiêu', 'Limit public expenditure. (Hạn chế chi tiêu công.)', false, NOW()),
  (v_deck_id, 'subsidy', '/ˈsʌb.sɪ.di/', 'trợ cấp', 'Farms receive a government subsidy. (Trang trại nhận tiền trợ cấp chính phủ.)', false, NOW());

  -- Bài 22: Kinh Tế - Bài 2: Tài Chính & Đầu Tư
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Kinh Tế - Bài 2: Tài Chính & Đầu Tư', 'Thuật ngữ thị trường chứng khoán, đầu tư và ngân hàng.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'liquidity', '/lɪˈkwɪd.ə.ti/', 'thanh khoản', 'Cash has high liquidity. (Tiền mặt có tính thanh khoản cao.)', false, NOW()),
  (v_deck_id, 'dividend', '/ˈdɪv.ɪ.dend/', 'cổ tức', 'Pay cash dividend to shareholders. (Trả cổ tức bằng tiền cho cổ đông.)', false, NOW()),
  (v_deck_id, 'equity', '/ˈek.wɪ.ti/', 'vốn cổ phần', 'Sell equity for funding. (Bán vốn cổ phần để lấy vốn.)', false, NOW()),
  (v_deck_id, 'portfolio', '/ˌpɔːtˈfəʊ.li.əʊ/', 'danh mục đầu tư', 'Diversify your portfolio. (Đa dạng hóa danh mục đầu tư của bạn.)', false, NOW()),
  (v_deck_id, 'volatility', '/ˌvɒl.əˈtɪl.ə.ti/', 'biến động giá', 'Stock price volatility is high. (Biến động giá cổ phiếu đang ở mức cao.)', false, NOW()),
  (v_deck_id, 'leverage', '/ˈliː.vər.ɪdʒ/', 'đòn bẩy tài chính', 'Using leverage increases risk. (Dùng đòn bẩy tài chính làm tăng rủi ro.)', false, NOW()),
  (v_deck_id, 'collateral', '/kəˈlæt.ər.əl/', 'tài sản thế chấp', 'Put up a house as collateral. (Dùng ngôi nhà làm tài sản thế chấp.)', false, NOW()),
  (v_deck_id, 'yield', '/jiːld/', 'lợi tức / sinh lời', 'Bond yield rose slightly. (Lợi tức trái phiếu tăng nhẹ.)', false, NOW()),
  (v_deck_id, 'valuation', '/ˌvæl.juˈeɪ.ʃən/', 'định giá', 'The company valuation soared. (Định giá công ty tăng vọt.)', false, NOW()),
  (v_deck_id, 'bankruptcy', '/ˈbæŋ.krəpt.si/', 'phá sản', 'File for bankruptcy. (Nộp đơn xin phá sản.)', false, NOW()),
  (v_deck_id, 'merger', '/ˈmɜː.dʒər/', 'sáp nhập', 'A huge corporate merger. (Một vụ sáp nhập doanh nghiệp lớn.)', false, NOW()),
  (v_deck_id, 'acquisition', '/ˌæk.wɪˈzɪʃ.ən/', 'thâu tóm / mua lại', 'The acquisition was completed. (Vụ thâu tóm đã hoàn tất.)', false, NOW()),
  (v_deck_id, 'default', '/dɪˈfɒlt/', 'vỡ nợ', 'Default on loan payments. (Vỡ nợ các khoản thanh toán.)', false, NOW()),
  (v_deck_id, 'asset', '/ˈæs.et/', 'tài sản', 'Manage company assets well. (Quản lý tốt tài sản công ty.)', false, NOW()),
  (v_deck_id, 'liability', '/ˌlaɪ.əˈbɪl.ə.ti/', 'khoản nợ', 'Total assets exceed liabilities. (Tổng tài sản vượt quá các khoản nợ.)', false, NOW());

  -- Bài 23: Kinh Tế - Bài 3: Ngân Hàng & Tín Dụng
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Kinh Tế - Bài 3: Ngân Hàng & Tín Dụng', 'Thuật ngữ hệ thống ngân hàng, cho vay và hạn mức tín dụng.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'mortgage', '/ˈmɔː.ɡɪdʒ/', 'khoản vay mua nhà', 'Apply for a 30-year home mortgage. (Nộp đơn xin vay mua nhà kỳ hạn 30 năm.)', false, NOW()),
  (v_deck_id, 'credit limit', '/ˈkred.ɪt ˈlɪm.ɪt/', 'hạn mức tín dụng', 'Increase credit card limit. (Nâng hạn mức thẻ tín dụng.)', false, NOW()),
  (v_deck_id, 'overdraft', '/ˈəʊ.və.drɑːft/', 'thấu chi tài khoản', 'Avoid overdraft bank fees. (Tránh các khoản phí thấu chi tài khoản ngân hàng.)', false, NOW()),
  (v_deck_id, 'principal', '/ˈprɪn.sə.pəl/', 'tiền gốc vay', 'Pay off the loan principal monthly. (Trả dần tiền gốc vay hàng tháng.)', false, NOW()),
  (v_deck_id, 'insolvency', '/ɪnˈsɒl.vən.si/', 'mất khả năng thanh toán', 'Firm facing corporate insolvency. (Doanh nghiệp đang đối mặt nguy cơ mất khả năng thanh toán.)', false, NOW()),
  (v_deck_id, 'underwriting', '/ˈʌn.dəˌraɪ.tɪŋ/', 'thẩm định bảo lãnh rủi ro', 'Loan underwriting assesses borrower credit. (Thẩm định cho vay đánh giá uy tín người vay.)', false, NOW()),
  (v_deck_id, 'clearing', '/ˈklɪə.rɪŋ/', 'bù trừ liên ngân hàng', 'Interbank clearing takes two days. (Bù trừ liên ngân hàng mất hai ngày làm việc.)', false, NOW()),
  (v_deck_id, 'wire transfer', '/ˈwaɪə ˌtræns.fɜːr/', 'chuyển khoản điện tử', 'Send money via wire transfer. (Gửi tiền qua hình thức chuyển khoản điện tử.)', false, NOW()),
  (v_deck_id, 'remittance', '/rɪˈmɪt.əns/', 'kiều hối / tiền gửi về', 'Overseas remittance boosted the economy. (Lượng kiều hối nước ngoài thúc đẩy kinh tế.)', false, NOW()),
  (v_deck_id, 'escrow', '/ˈes.krəʊ/', 'tài khoản ủy thác trung gian', 'Hold purchase funds in escrow. (Giữ tiền mua hàng trong tài khoản ủy thác trung gian.)', false, NOW()),
  (v_deck_id, 'solvency', '/ˈsɒl.vən.si/', 'khả năng chi trả nợ', 'Maintain long-term financial solvency. (Duy trì khả năng chi trả tài chính dài hạn.)', false, NOW()),
  (v_deck_id, 'guarantor', '/ˌɡær.ənˈtɔːr/', 'người bảo lãnh vay', 'Sign as a loan guarantor. (Ký tên với tư cách là người bảo lãnh khoản vay.)', false, NOW()),
  (v_deck_id, 'amortization', '/əˌmɔː.tɪˈzeɪ.ʃən/', 'khấu trừ dần nợ gốc', 'Follow the loan amortization schedule. (Theo dõi bảng lịch trình khấu trừ dần nợ gốc.)', false, NOW()),
  (v_deck_id, 'deposit', '/dɪˈpɒz.ɪt/', 'tiền gửi tiết kiệm', 'Make a fixed-term cash deposit. (Gửi tiền tiết kiệm có kỳ hạn cố định.)', false, NOW()),
  (v_deck_id, 'bad debt', '/ˌbæd ˈdet/', 'nợ xấu khó đòi', 'Commercial banks write off bad debt. (Các ngân hàng thương mại xóa sổ nợ xấu.)', false, NOW());

  -- Bài 24: Kinh Tế - Bài 4: Kế Toán & Kiểm Toán
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Kinh Tế - Bài 4: Kế Toán & Kiểm Toán', 'Thuật ngữ báo cáo tài chính, kiểm toán và thuế doanh nghiệp.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'balance sheet', '/ˈbæl.əns ˌʃiːt/', 'bảng cân đối kế toán', 'Audit the annual balance sheet. (Kiểm toán bảng cân đối kế toán hàng năm.)', false, NOW()),
  (v_deck_id, 'income statement', '/ˈɪn.kʌm ˌsteɪt.mənt/', 'báo cáo kết quả kinh doanh', 'Review quarterly income statement. (Xem xét báo cáo kết quả kinh doanh theo quý.)', false, NOW()),
  (v_deck_id, 'cash flow', '/ˈkæʃ ˌfləʊ/', 'dòng tiền lưu chuyển', 'Positive operating cash flow. (Dòng tiền hoạt động kinh doanh dương.)', false, NOW()),
  (v_deck_id, 'auditor', '/ˈɔː.dɪ.tər/', 'kiểm toán viên', 'Independent external financial auditor. (Kiểm toán viên tài chính độc lập bên ngoài.)', false, NOW()),
  (v_deck_id, 'ledger', '/ˈledʒ.ər/', 'sổ cái kế toán', 'Record entries in general ledger. (Ghi chép các nghiệp vụ vào sổ cái chung.)', false, NOW()),
  (v_deck_id, 'accounts payable', '/əˌkaʊnts ˈpeɪ.ə.bəl/', 'khoản phải trả người bán', 'Manage accounts payable promptly. (Quản lý các khoản phải trả người bán kịp thời.)', false, NOW()),
  (v_deck_id, 'accounts receivable', '/əˌkaʊnts rɪˈsiː.və.bəl/', 'khoản phải thu khách hàng', 'Collect accounts receivable on time. (Thu hồi các khoản phải thu khách hàng đúng hạn.)', false, NOW()),
  (v_deck_id, 'gross profit', '/ɡrəʊs ˈprɒf.ɪt/', 'lợi nhuận gộp', 'Gross profit margin increased. (Tỷ suất lợi nhuận gộp đã tăng lên.)', false, NOW()),
  (v_deck_id, 'net profit', '/net ˈprɒf.ɪt/', 'lợi nhuận ròng / lãi thuần', 'Calculate company net profit after taxes. (Tính lợi nhuận ròng sau thuế của công ty.)', false, NOW()),
  (v_deck_id, 'overhead', '/ˈəʊ.və.hed/', 'chi phí gián tiếp vận hành', 'Cut unnecessary office overhead costs. (Cắt giảm các chi phí vận hành văn phòng không cần thiết.)', false, NOW()),
  (v_deck_id, 'reconciliation', '/ˌrek.ənˌsɪl.iˈeɪ.ʃən/', 'đối chiếu sổ sách', 'Perform monthly bank reconciliation. (Thực hiện đối chiếu số dư ngân hàng hàng tháng.)', false, NOW()),
  (v_deck_id, 'inventory', '/ˈɪn.vən.tər.i/', 'hàng tồn kho', 'Count physical store inventory. (Kiểm kê hàng tồn kho thực tế tại cửa hàng.)', false, NOW()),
  (v_deck_id, 'fiscal year', '/ˈfɪs.kəl ˌjɪər/', 'năm tài chính', 'Close books at fiscal year end. (Khóa sổ kế toán vào cuối năm tài chính.)', false, NOW()),
  (v_deck_id, 'withholding tax', '/wɪðˈhəʊl.dɪŋ ˌtæks/', 'thuế khấu trừ tại nguồn', 'Deduct withholding tax from payroll. (Khấu trừ thuế tại nguồn trực tiếp từ bảng lương.)', false, NOW()),
  (v_deck_id, 'write-off', '/ˈraɪt.ɒf/', 'xóa sổ tài sản mất giá', 'Record a tax write-off on loss. (Ghi nhận khoản xóa sổ giảm trừ thuế do thua lỗ.)', false, NOW());

  -- Bài 25: Kinh Tế - Bài 5: Thương Mại & Xuất Nhập Khẩu
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Kinh Tế - Bài 5: Thương Mại & Xuất Nhập Khẩu', 'Thuật ngữ giao thương quốc tế, hải quan và vận chuyển biển.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'export', '/ˈek.spɔːt/', 'xuất khẩu', 'Export agricultural goods abroad. (Xuất khẩu nông sản ra thị trường nước ngoài.)', false, NOW()),
  (v_deck_id, 'import', '/ˈɪm.pɔːt/', 'nhập khẩu', 'Import raw industrial materials. (Nhập khẩu nguyên liệu thô công nghiệp.)', false, NOW()),
  (v_deck_id, 'customs', '/ˈkʌs.təmz/', 'hải quan cửa khẩu', 'Clear shipments through port customs. (Thông quan các lô hàng qua hải quan cảng.)', false, NOW()),
  (v_deck_id, 'embargo', '/ɪmˈbɑː.ɡəʊ/', 'lệnh cấm vận thương mại', 'Lift the economic trade embargo. (Dỡ bỏ lệnh cấm vận thương mại kinh tế.)', false, NOW()),
  (v_deck_id, 'quota', '/ˈkwəʊ.tə/', 'hạn ngạch nhập khẩu', 'Fill the annual textile import quota. (Sử dụng hết hạn ngạch nhập khẩu dệt may hàng năm.)', false, NOW()),
  (v_deck_id, 'bill of lading', '/ˌbɪl əv ˈleɪ.dɪŋ/', 'vận đơn đường biển', 'Sign the original ocean bill of lading. (Ký vào vận đơn đường biển gốc.)', false, NOW()),
  (v_deck_id, 'certificate of origin', '/səˌtɪf.ɪ.kət əv ˈɒr.ɪ.dʒɪn/', 'chứng nhận xuất xứ (C/O)', 'Provide a certificate of origin for goods. (Cung cấp chứng nhận xuất xứ C/O cho hàng hóa.)', false, NOW()),
  (v_deck_id, 'freight', '/freɪt/', 'cước phí vận chuyển hàng', 'Pay ocean container freight charges. (Thanh toán cước phí vận chuyển container đường biển.)', false, NOW()),
  (v_deck_id, 'dumping', '/ˈdʌm.pɪŋ/', 'bán phá giá thị trường', 'Impose anti-dumping duties on steel. (Áp thuế chống bán phá giá lên mặt hàng thép.)', false, NOW()),
  (v_deck_id, 'letter of credit', '/ˌlet.ər əv ˈkred.ɪt/', 'thư tín dụng thanh toán (L/C)', 'Open a confirmed letter of credit. (Mở một thư tín dụng thanh toán L/C đã xác nhận.)', false, NOW()),
  (v_deck_id, 'consignment', '/kənˈsaɪn.mənt/', 'lô hàng gửi bán', 'Receive a large cargo consignment. (Tiếp nhận một lô hàng hóa lớn gửi đến.)', false, NOW()),
  (v_deck_id, 'free trade', '/ˌfriː ˈtreɪd/', 'thương mại tự do', 'Sign a bilateral free trade agreement. (Ký hiệp định thương mại tự do song phương.)', false, NOW()),
  (v_deck_id, 'demurrage', '/dɪˈmʌr.ɪdʒ/', 'phí lưu bãi container', 'Avoid expensive port demurrage fees. (Tránh các khoản phí lưu bãi container đắt đỏ tại cảng.)', false, NOW()),
  (v_deck_id, 'stevedore', '/ˈstiː.və.dɔːr/', 'bốc xếp hàng tại cảng', 'Port stevedores unload shipping containers. (Công nhân bốc xếp cảng dỡ các container hàng.)', false, NOW()),
  (v_deck_id, 'forwarder', '/ˈfɔː.wə.dər/', 'đại lý giao nhận vận tải', 'Hire an international freight forwarder. (Thuê một đại lý giao nhận vận tải quốc tế.)', false, NOW());

  -- Bài 26: Kinh Tế - Bài 6: Marketing & Thị Trường
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Kinh Tế - Bài 6: Marketing & Thị Trường', 'Thuật ngữ tiếp thị, hành vi người tiêu dùng và phân khúc.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'segmentation', '/ˌseɡ.menˈteɪ.ʃən/', 'phân khúc thị trường', 'Customer demographic segmentation. (Phân khúc thị trường theo nhân khẩu học khách hàng.)', false, NOW()),
  (v_deck_id, 'branding', '/ˈbræn.dɪŋ/', 'xây dựng thương hiệu', 'Invest heavily in brand identity and branding. (Đầu tư mạnh mẽ vào nhận diện và xây dựng thương hiệu.)', false, NOW()),
  (v_deck_id, 'conversion rate', '/kənˈvɜː.ʃən reɪt/', 'tỷ lệ chuyển đổi mua', 'Optimize website sales conversion rate. (Tối ưu hóa tỷ lệ chuyển đổi bán hàng trên website.)', false, NOW()),
  (v_deck_id, 'retargeting', '/riːˈtɑː.ɡɪt.ɪŋ/', 'tiếp thị bám đuôi lại', 'Run retargeting ads on social media. (Chạy quảng cáo bám đuôi lại trên mạng xã hội.)', false, NOW()),
  (v_deck_id, 'churn rate', '/ˈtʃɜːn ˌreɪt/', 'tỷ lệ khách rời bỏ', 'Lower SaaS customer churn rate. (Giảm tỷ lệ khách hàng rời bỏ dịch vụ phần mềm.)', false, NOW()),
  (v_deck_id, 'lead generation', '/ˈliːd ˌdʒen.ə.reɪ.ʃən/', 'thu hút khách tiềm năng', 'Inbound marketing for lead generation. (Tiếp thị nội dung để thu hút khách hàng tiềm năng.)', false, NOW()),
  (v_deck_id, 'funnel', '/ˈfʌn.əl/', 'phễu bán hàng', 'Guide users through the sales funnel. (Dẫn dắt người dùng qua các bước của phễu bán hàng.)', false, NOW()),
  (v_deck_id, 'endorsement', '/ɪnˈdɔːs.mənt/', 'quảng bá qua người nổi tiếng', 'Celebrity product endorsement deal. (Hợp đồng quảng bá sản phẩm qua người nổi tiếng.)', false, NOW()),
  (v_deck_id, 'touchpoint', '/ˈtʌtʃ.pɔɪnt/', 'điểm chạm khách hàng', 'Improve every digital customer touchpoint. (Cải thiện mọi điểm chạm kỹ thuật số với khách hàng.)', false, NOW()),
  (v_deck_id, 'positioning', '/pəˈzɪʃ.ən.ɪŋ/', 'định vị sản phẩm', 'Strategic premium market positioning. (Định vị chiến lược tại phân khúc thị trường cao cấp.)', false, NOW()),
  (v_deck_id, 'copywriting', '/ˈkɒp.iˌraɪ.tɪŋ/', 'viết lời quảng cáo', 'Persuasive landing page copywriting. (Nghệ thuật viết lời quảng cáo thuyết phục trên trang đích.)', false, NOW()),
  (v_deck_id, 'demographics', '/ˌdem.əˈɡræf.ɪks/', 'nhân khẩu học', 'Analyze target customer demographics. (Phân tích nhân khẩu học nhóm khách hàng mục tiêu.)', false, NOW()),
  (v_deck_id, 'affinity', '/əˈfɪn.ə.ti/', 'sự gắn kết yêu thích', 'Build strong brand loyalty and affinity. (Xây dựng lòng trung thành và sự yêu thích thương hiệu.)', false, NOW()),
  (v_deck_id, 'organic', '/ɔːˈɡæn.ɪk/', 'tiếp cận tự nhiên (không trả phí)', 'SEO generates steady organic web traffic. (SEO mang lại lượng truy cập tự nhiên ổn định.)', false, NOW()),
  (v_deck_id, 'call to action', '/ˌkɔːl tuː ˈæk.ʃən/', 'lời kêu gọi hành động (CTA)', 'Click the prominent call to action button. (Bấm vào nút kêu gọi hành động nổi bật.)', false, NOW());

  -- Bài 27: Kinh Tế - Bài 7: Bất Động Sản & Định Giá
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Kinh Tế - Bài 7: Bất Động Sản & Định Giá', 'Thuật ngữ nhà đất, định giá tài sản và quy hoạch.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'appraisal', '/əˈpreɪ.zəl/', 'thẩm định giá trị', 'Order an independent property appraisal. (Yêu cầu thẩm định giá trị bất động sản độc lập.)', false, NOW()),
  (v_deck_id, 'leasehold', '/ˈliːs.həʊld/', 'quyền thuê đất có thời hạn', 'Buy commercial property on a leasehold. (Mua bất động sản thương mại theo quyền thuê có thời hạn.)', false, NOW()),
  (v_deck_id, 'freehold', '/ˈfriː.həʊld/', 'sở hữu vĩnh viễn', 'Residential apartment with freehold title. (Căn hộ chung cư có sổ đỏ sở hữu vĩnh viễn.)', false, NOW()),
  (v_deck_id, 'zoning', '/ˈzəʊ.nɪŋ/', 'quy hoạch phân khu', 'City zoning laws restrict commercial buildings. (Luật quy hoạch đô thị hạn chế xây cao ốc thương mại.)', false, NOW()),
  (v_deck_id, 'tenant', '/ˈten.ənt/', 'người thuê nhà / mặt bằng', 'Sign rental contract with the new tenant. (Ký hợp đồng thuê nhà với người thuê mới.)', false, NOW()),
  (v_deck_id, 'landlord', '/ˈlænd.lɔːd/', 'chủ nhà / chủ cho thuê', 'Pay monthly rent to the property landlord. (Trả tiền thuê nhà hàng tháng cho chủ nhà.)', false, NOW()),
  (v_deck_id, 'occupancy', '/ˈɒk.jə.pən.si/', 'tỷ lệ lấp đầy phòng', 'Hotel reached 90 percent room occupancy. (Khách sạn đạt tỷ lệ lấp đầy phòng 90%.)', false, NOW()),
  (v_deck_id, 'speculation', '/ˌspek.jəˈleɪ.ʃən/', 'đầu cơ đất đai', 'Land speculation drove house prices up. (Đầu cơ đất đai đã đẩy giá nhà ở tăng cao.)', false, NOW()),
  (v_deck_id, 'easement', '/ˈiːz.mənt/', 'quyền đi nhờ lối đi chung', 'Grant legal easement for public utility access. (Cấp quyền đi nhờ pháp lý cho việc tiếp cận đường ống công cộng.)', false, NOW()),
  (v_deck_id, 'depreciation', '/dɪˌpriː.ʃiˈeɪ.ʃən/', 'khấu hao nhà xưởng', 'Calculate annual real estate depreciation. (Tính toán khấu hao bất động sản hàng năm.)', false, NOW()),
  (v_deck_id, 'equity', '/ˈek.wɪ.ti/', 'giá trị thực sau trừ nợ', 'Home equity grew as property values rose. (Giá trị thực của ngôi nhà tăng khi giá thị trường đi lên.)', false, NOW()),
  (v_deck_id, 'deed', '/diːd/', 'văn tự / giấy chứng nhận quyền sở hữu', 'Transfer property title deed at city registry. (Chuyển nhượng giấy chứng nhận quyền sở hữu tại văn phòng đăng ký.)', false, NOW()),
  (v_deck_id, 'foreclosure', '/fɔːˈkləʊ.ʒər/', 'phát mãi xiết nợ nhà đất', 'Bank initiated foreclosure on unpaid mortgage. (Ngân hàng bắt đầu phát mãi xiết nợ do không trả thế chấp.)', false, NOW()),
  (v_deck_id, 'brokerage', '/ˈbrəʊ.kər.ɪdʒ/', 'phí hoa hồng môi giới', 'Pay standard real estate brokerage commission. (Thanh toán tiền hoa hồng môi giới bất động sản theo tiêu chuẩn.)', false, NOW()),
  (v_deck_id, 'gentrification', '/ˌdʒen.trɪ.fɪˈkeɪ.ʃən/', 'chỉnh trang đô thị hóa', 'Urban gentrification revitalized old neighborhoods. (Chỉnh trang đô thị hóa đã làm hồi sinh các khu phố cũ.)', false, NOW());

  -- Bài 28: Kinh Tế - Bài 8: Chuỗi Cung Ứng & Hậu Cần
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Kinh Tế - Bài 8: Chuỗi Cung Ứng & Hậu Cần', 'Thuật ngữ chuỗi cung ứng, kho vận và logistics vận tải.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'logistics', '/ləˈdʒɪs.tɪks/', 'hậu cần / kho vận', 'Optimize global supply chain logistics. (Tối ưu hóa dịch vụ hậu cần chuỗi cung ứng toàn cầu.)', false, NOW()),
  (v_deck_id, 'procurement', '/prəˈkjʊə.mənt/', 'mua sắm đấu thầu', 'Streamline raw materials procurement process. (Hợp lý hóa quy trình mua sắm nguyên liệu thô.)', false, NOW()),
  (v_deck_id, 'warehouse', '/ˈweə.haʊs/', 'kho chứa hàng hóa', 'Automated robots sort items in the warehouse. (Robot tự động phân loại hàng hóa trong kho.)', false, NOW()),
  (v_deck_id, 'fulfillment', '/fʊlˈfɪl.mənt/', 'xử lý hoàn tất đơn hàng', 'E-commerce order fulfillment center. (Trung tâm xử lý hoàn tất đơn hàng thương mại điện tử.)', false, NOW()),
  (v_deck_id, 'lead time', '/ˈliːd ˌtaɪm/', 'thời gian từ đặt đến nhận hàng', 'Shorten manufacturing and delivery lead time. (Rút ngắn thời gian sản xuất và giao hàng.)', false, NOW()),
  (v_deck_id, 'just-in-time', '/ˌdʒʌst.ɪnˈtaɪm/', 'vừa đúng lúc (JIT)', 'Toyota pioneered just-in-time production. (Toyota tiên phong áp dụng mô hình sản xuất vừa đúng lúc.)', false, NOW()),
  (v_deck_id, 'consignment', '/kənˈsaɪn.mənt/', 'lô hàng hóa', 'Track the ocean cargo consignment. (Theo dõi lộ trình lô hàng hóa vận chuyển đường biển.)', false, NOW()),
  (v_deck_id, 'bottleneck', '/ˈbɒt.əl.nek/', 'ách tắc chuỗi cung ứng', 'Port congestion created a severe shipping bottleneck. (Tắc nghẽn tại cảng biển gây ra điểm ách tắc vận tải nghiêm trọng.)', false, NOW()),
  (v_deck_id, 'distributor', '/dɪˈstrɪb.jə.tər/', 'nhà phân phối', 'Authorize regional beverage distributors. (Cấp quyền cho các nhà phân phối đồ uống khu vực.)', false, NOW()),
  (v_deck_id, 'freight', '/freɪt/', 'hàng hóa chuyên chở', 'Air freight is faster than sea shipping. (Vận chuyển hàng hóa bằng đường hàng không nhanh hơn đường biển.)', false, NOW()),
  (v_deck_id, 'traceability', '/ˌtreɪ.səˈbɪl.ə.ti/', 'truy xuất nguồn gốc', 'Blockchain ensures food supply traceability. (Công nghệ blockchain đảm bảo truy xuất nguồn gốc thực phẩm.)', false, NOW()),
  (v_deck_id, 'deadstock', '/ˈded.stɒk/', 'hàng tồn kho ứ đọng', 'Discount unsold deadstock inventory. (Giảm giá thanh lý lượng hàng tồn kho ứ đọng không bán được.)', false, NOW()),
  (v_deck_id, 'fleet', '/fliːt/', 'đội xe vận tải', 'Manage electric delivery truck fleet. (Quản lý đội xe tải giao hàng chạy điện.)', false, NOW()),
  (v_deck_id, 'expedite', '/ˈek.spə.daɪt/', 'đẩy nhanh tiến độ', 'Pay extra fee to expedite delivery. (Trả thêm phí để đẩy nhanh tiến độ giao hàng.)', false, NOW()),
  (v_deck_id, 'pallet', '/ˈpæl.ət/', 'kệ nâng để hàng', 'Stack wooden storage pallets securely. (Xếp chồng các kệ nâng gỗ để hàng một cách chắc chắn.)', false, NOW());

  -- Bài 29: Kinh Tế - Bài 9: Bảo Hiểm & Quản Trị Rủi Ro
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Kinh Tế - Bài 9: Bảo Hiểm & Quản Trị Rủi Ro', 'Thuật ngữ bảo hiểm nhân thọ, phi nhân thọ và hợp đồng bồi thường.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'premium', '/ˈpriː.mi.əm/', 'phí bảo hiểm định kỳ', 'Pay monthly life insurance premium. (Đóng phí bảo hiểm nhân thọ định kỳ hàng tháng.)', false, NOW()),
  (v_deck_id, 'deductible', '/dɪˈdʌk.tə.bəl/', 'mức miễn bồi thường', 'High deductible lowers monthly insurance costs. (Mức miễn bồi thường cao giúp giảm chi phí bảo hiểm hàng tháng.)', false, NOW()),
  (v_deck_id, 'claim', '/kleɪm/', 'yêu cầu bồi thường bảo hiểm', 'File an insurance claim after car accident. (Nộp đơn yêu cầu bồi thường bảo hiểm sau tai nạn xe hơi.)', false, NOW()),
  (v_deck_id, 'indemnity', '/ɪnˈdem.nə.ti/', 'tiền bồi thường thiệt hại', 'Insurance policy provides financial indemnity. (Hợp đồng bảo hiểm chi trả tiền bồi thường thiệt hại tài chính.)', false, NOW()),
  (v_deck_id, 'beneficiary', '/ˌben.ɪˈfɪʃ.ər.i/', 'người thụ hưởng', 'Name spouse as the primary beneficiary. (Chỉ định vợ/chồng là người thụ hưởng quyền lợi chính.)', false, NOW()),
  (v_deck_id, 'underwriter', '/ˈʌn.dəˌraɪ.tər/', 'chuyên viên thẩm định rủi ro', 'Insurance underwriter evaluates applicant health risk. (Chuyên viên thẩm định đánh giá rủi ro sức khỏe của người nộp đơn.)', false, NOW()),
  (v_deck_id, 'actuary', '/ˈæk.tʃu.ə.ri/', 'chuyên gia định phí bảo hiểm', 'Actuaries calculate statistical mortality tables. (Các chuyên gia định phí tính toán bảng thống kê tỷ lệ tử vong.)', false, NOW()),
  (v_deck_id, 'coverage', '/ˈkʌv.ər.ɪdʒ/', 'phạm vi bảo vệ bảo hiểm', 'Comprehensive auto coverage includes flood damage. (Gói bảo hiểm ô tô toàn diện bao gồm cả thiệt hại do ngập lụt.)', false, NOW()),
  (v_deck_id, 'liability', '/ˌlaɪ.əˈbɪl.ə.ti/', 'trách nhiệm dân sự', 'Third-party vehicle liability insurance. (Bảo hiểm trách nhiệm dân sự bắt buộc đối với bên thứ ba.)', false, NOW()),
  (v_deck_id, 'lapse', '/læps/', 'mất hiệu lực hợp đồng', 'Policy will lapse if unpaid after grace period. (Hợp đồng bảo hiểm sẽ mất hiệu lực nếu không đóng phí sau gia hạn.)', false, NOW()),
  (v_deck_id, 'rider', '/ˈraɪ.dər/', 'điều khoản bổ sung bảo hiểm', 'Add critical illness insurance rider. (Mua thêm điều khoản bổ sung bảo hiểm bệnh hiểm nghèo.)', false, NOW()),
  (v_deck_id, 'reinsurance', '/ˌriː.ɪnˈʃʊə.rəns/', 'tái bảo hiểm', 'Insurers buy reinsurance to share catastrophic risk. (Các công ty bảo hiểm mua tái bảo hiểm để chia sẻ rủi ro thảm họa.)', false, NOW()),
  (v_deck_id, 'annuity', '/əˈnjuː.ə.ti/', 'khoản niên kim định kỳ', 'Retirees purchase fixed income annuity. (Người nghỉ hưu mua gói niên kim trả tiền định kỳ cố định.)', false, NOW()),
  (v_deck_id, 'surrender', '/səˈren.dər/', 'hủy hợp đồng rút tiền sớm', 'Policy surrender value after five years. (Giá trị hoàn lại khi hủy hợp đồng bảo hiểm sau 5 năm.)', false, NOW()),
  (v_deck_id, 'subrogation', '/ˌsʌb.rəˈɡeɪ.ʃən/', 'quyền thế vị đòi bồi thường', 'Insurers exercise subrogation to recover damages from at-fault party. (Công ty bảo hiểm dùng quyền thế vị để đòi tiền bên gây lỗi.)', false, NOW());

  -- Bài 30: Kinh Tế - Bài 10: Khởi Nghiệp & Vốn Mạo Hiểm
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Kinh Tế - Bài 10: Khởi Nghiệp & Vốn Mạo Hiểm', 'Thuật ngữ Startup, gọi vốn đầu tư thiên thần và định giá.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'venture capital', '/ˈven.tʃər ˌkæp.ɪ.təl/', 'vốn đầu tư mạo hiểm (VC)', 'Raise Series A venture capital funding. (Gọi vốn đầu tư mạo hiểm vòng Series A.)', false, NOW()),
  (v_deck_id, 'angel investor', '/ˈeɪn.dʒəl ɪnˌves.tər/', 'nhà đầu tư thiên thần', 'Angel investor provided initial seed capital. (Nhà đầu tư thiên thần đã rót vốn hạt giống ban đầu.)', false, NOW()),
  (v_deck_id, 'burn rate', '/ˈbɜːn ˌreɪt/', 'tốc độ đốt tiền vốn', 'Control monthly startup cash burn rate. (Kiểm soát tốc độ đốt tiền mặt hàng tháng của công ty khởi nghiệp.)', false, NOW()),
  (v_deck_id, 'runway', '/ˈrʌn.weɪ/', 'thời gian sống còn của vốn', 'Startup has eighteen months of cash runway. (Công ty khởi nghiệp có đủ tiền để duy trì hoạt động trong 18 tháng.)', false, NOW()),
  (v_deck_id, 'pitch deck', '/ˈpɪtʃ ˌdek/', 'bài thuyết trình gọi vốn', 'Present pitch deck to interested investors. (Trình bày bài thuyết trình gọi vốn trước các nhà đầu tư quan tâm.)', false, NOW()),
  (v_deck_id, 'bootstrapping', '/ˈbuːtˌstræp.ɪŋ/', 'tự lực cánh sinh (không gọi vốn)', 'Founder built software through bootstrapping. (Người sáng lập tự lực xây dựng phần mềm mà không cần gọi vốn bên ngoài.)', false, NOW()),
  (v_deck_id, 'unicorn', '/ˈjuː.nɪ.kɔːn/', 'công ty kỳ lân (định giá > 1 tỷ USD)', 'Fintech startup achieved unicorn status. (Công ty khởi nghiệp công nghệ tài chính đã đạt danh hiệu kỳ lân tỷ đô.)', false, NOW()),
  (v_deck_id, 'exit strategy', '/ˈek.sɪt ˌstræt.ə.dʒi/', 'chiến lược thoái vốn', 'IPO is a common startup exit strategy. (Phát hành cổ phiếu lần đầu ra công chúng IPO là chiến lược thoái vốn phổ biến.)', false, NOW()),
  (v_deck_id, 'incubator', '/ˈɪŋ.kjə.beɪ.tər/', 'vườn ươm khởi nghiệp', 'Join university tech startup incubator. (Tham gia vào vườn ươm khởi nghiệp công nghệ của trường đại học.)', false, NOW()),
  (v_deck_id, 'term sheet', '/ˈtɜːm ˌʃiːt/', 'bản điều khoản đầu tư sơ bộ', 'Sign preliminary investment term sheet. (Ký kết bản điều khoản đầu tư sơ bộ với quỹ.)', false, NOW()),
  (v_deck_id, 'dilution', '/daɪˈluː.ʃən/', 'sự pha loãng cổ phần', 'Avoid excessive founder equity dilution. (Tránh pha loãng cổ phần quá mức của người sáng lập.)', false, NOW()),
  (v_deck_id, 'traction', '/ˈtræk.ʃən/', 'sức hút / đà tăng trưởng người dùng', 'App showed strong early user traction. (Ứng dụng đã chứng minh được sức hút tăng trưởng người dùng mạnh mẽ ban đầu.)', false, NOW()),
  (v_deck_id, 'pivot', '/ˈpɪv.ət/', 'chuyển hướng kinh doanh', 'Startup pivoted to enterprise B2B software. (Công ty khởi nghiệp đã chuyển hướng sang mảng phần mềm doanh nghiệp B2B.)', false, NOW()),
  (v_deck_id, 'vesting', '/ˈves.tɪŋ/', 'thời gian tích lũy cổ phần', 'Four-year employee stock vesting schedule. (Lịch trình tích lũy nhận cổ phần thưởng cho nhân viên trong 4 năm.)', false, NOW()),
  (v_deck_id, 'due diligence', '/ˌdʒuː ˈdɪl.ɪ.dʒəns/', 'thẩm định pháp lý & tài chính', 'Conduct due diligence before signing deal. (Tiến hành thẩm định pháp lý và tài chính trước khi ký hợp đồng.)', false, NOW());

  -- =========================================================
  -- KHỐI: ENGINEERING.JSON (10 bài học)
  -- =========================================================

  -- Bài 31: Kỹ Thuật - Bài 1: Cơ Khí & Vật Liệu
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Kỹ Thuật - Bài 1: Cơ Khí & Vật Liệu', 'Thuật ngữ kỹ thuật cơ khí, cơ học vật liệu và gia công.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'tensile strength', '/ˈten.saɪl streŋθ/', 'độ bền kéo', 'Steel has high tensile strength. (Thép có độ bền kéo cao.)', false, NOW()),
  (v_deck_id, 'elasticity', '/ˌiː.læsˈtɪs.ə.ti/', 'độ đàn hồi', 'Rubber has high elasticity. (Cao su có độ đàn hồi cao.)', false, NOW()),
  (v_deck_id, 'friction', '/ˈfrɪk.ʃən/', 'ma sát', 'Oil reduces friction. (Dầu giúp giảm ma sát.)', false, NOW()),
  (v_deck_id, 'fatigue', '/fəˈtiːɡ/', 'mỏi kim loại', 'Check wings for metal fatigue. (Kiểm tra hiện tượng mỏi kim loại ở cánh máy bay.)', false, NOW()),
  (v_deck_id, 'alloy', '/ˈæl.ɔɪ/', 'hợp kim', 'Brass is a copper alloy. (Đồng thau là hợp kim của đồng.)', false, NOW()),
  (v_deck_id, 'thermodynamics', '/ˌθɜː.məʊ.daɪˈnæm.ɪks/', 'nhiệt động lực học', 'Study thermodynamics laws. (Nghiên cứu các định luật nhiệt động lực học.)', false, NOW()),
  (v_deck_id, 'tolerance', '/ˈtɒl.ər.əns/', 'dung sai', 'Machined with tight tolerance. (Được gia công với dung sai chặt chẽ.)', false, NOW()),
  (v_deck_id, 'torque', '/tɔːk/', 'mô-men xoắn', 'The motor delivers high torque. (Động cơ tạo mô-men xoắn cao.)', false, NOW()),
  (v_deck_id, 'viscosity', '/vɪsˈkɒs.ə.ti/', 'độ nhớt', 'Honey has high viscosity. (Mật ong có độ nhớt cao.)', false, NOW()),
  (v_deck_id, 'aerodynamics', '/ˌeə.rəʊ.daɪˈnæm.ɪks/', 'khí động học', 'Improve car aerodynamics. (Cải thiện khí động học của xe.)', false, NOW()),
  (v_deck_id, 'corrosion', '/kəˈrəʊ.ʒən/', 'ăn mòn / rỉ sét', 'Paint prevents metal corrosion. (Sơn giúp ngăn chặn kim loại bị ăn mòn.)', false, NOW()),
  (v_deck_id, 'pneumatics', '/njuːˈmæt.ɪks/', 'khí nén', 'Pneumatic tools are powerful. (Các dụng cụ khí nén hoạt động rất mạnh.)', false, NOW()),
  (v_deck_id, 'hydraulics', '/haɪˈdrɒl.ɪks/', 'thủy lực', 'Operate hydraulic brakes. (Vận hành hệ thống phanh thủy lực.)', false, NOW()),
  (v_deck_id, 'machining', '/məˈʃiː.nɪŋ/', 'gia công cơ khí', 'Precision CNC machining. (Gia công cơ khí chính xác CNC.)', false, NOW()),
  (v_deck_id, 'welding', '/ˈwel.dɪŋ/', 'hàn nối', 'Laser welding metal parts. (Hàn nối các chi tiết kim loại bằng laser.)', false, NOW());

  -- Bài 32: Kỹ Thuật - Bài 2: Điện & Điện Tử
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Kỹ Thuật - Bài 2: Điện & Điện Tử', 'Thuật ngữ mạch điện, linh kiện bán dẫn và truyền tải điện năng.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'semiconductor', '/ˌsem.i.kənˈdʌk.tər/', 'chất bán dẫn', 'Silicon is the basis of semiconductor chips. (Silicon là nền tảng của các chip bán dẫn.)', false, NOW()),
  (v_deck_id, 'capacitance', '/kəˈpæs.ɪ.təns/', 'điện dung tụ điện', 'Measure capacitor electrical capacitance. (Đo chỉ số điện dung của tụ điện.)', false, NOW()),
  (v_deck_id, 'inductance', '/ɪnˈdʌk.təns/', 'độ tự cảm cuộn dây', 'Inductance resists sudden current changes. (Độ tự cảm cản trở sự thay đổi dòng điện đột ngột.)', false, NOW()),
  (v_deck_id, 'resistor', '/rɪˈzɪs.tər/', 'điện trở', 'Add a resistor to limit circuit current. (Thêm một điện trở để hạn chế dòng điện trong mạch.)', false, NOW()),
  (v_deck_id, 'voltage', '/ˈvəʊl.tɪdʒ/', 'điện áp / hiệu điện thế', 'Step up alternating current voltage. (Tăng hiệu điện thế của dòng điện xoay chiều.)', false, NOW()),
  (v_deck_id, 'current', '/ˈkʌr.ənt/', 'cường độ dòng điện', 'High electrical current generates heat. (Dòng điện cường độ cao sinh ra nhiệt lớn.)', false, NOW()),
  (v_deck_id, 'transistor', '/trænˈzɪs.tər/', 'bóng bán dẫn đóng ngắt', 'Billions of transistors in one modern CPU. (Hàng tỷ bóng bán dẫn trong một chip CPU hiện đại.)', false, NOW()),
  (v_deck_id, 'microcontroller', '/ˌmaɪ.krəʊ.kənˈtrəʊ.lər/', 'vi điều khiển', 'Program the embedded microcontroller chip. (Lập trình cho chip vi điều khiển nhúng.)', false, NOW()),
  (v_deck_id, 'transformer', '/trænsˈfɔː.mər/', 'máy biến áp', 'Substation transformer steps down grid power. (Máy biến áp tại trạm hạ thế điện lưới.)', false, NOW()),
  (v_deck_id, 'short circuit', '/ˌʃɔːt ˈsɜː.kɪt/', 'ngắn mạch / chập điện', 'Fuse blows during an electrical short circuit. (Cầu chì ngắt khi xảy ra hiện tượng chập điện ngắn mạch.)', false, NOW()),
  (v_deck_id, 'oscilloscope', '/əˈsɪl.ə.skəʊp/', 'máy hiện sóng điện tử', 'View signal wave on the oscilloscope screen. (Quan sát dạng sóng tín hiệu trên màn hình máy hiện sóng.)', false, NOW()),
  (v_deck_id, 'diode', '/ˈdaɪ.əʊd/', 'đi-ốt chỉnh lưu một chiều', 'Light emitting diode (LED) saves electricity. (Đi-ốt phát quang LED giúp tiết kiệm điện năng.)', false, NOW()),
  (v_deck_id, 'grounding', '/ˈɡraʊn.dɪŋ/', 'nối đất an toàn', 'Proper appliance electrical grounding prevents shock. (Nối đất an toàn cho thiết bị giúp tránh điện giật.)', false, NOW()),
  (v_deck_id, 'inverter', '/ɪnˈvɜː.tər/', 'bộ nghịch lưu biến tần', 'Solar inverter converts DC power to AC. (Bộ biến tần năng lượng mặt trời đổi điện 1 chiều sang xoay chiều.)', false, NOW()),
  (v_deck_id, 'printed circuit board', '/ˌprɪn.tɪd ˈsɜː.kɪt bɔːd/', 'bo mạch in (PCB)', 'Solder components onto the printed circuit board. (Hàn các linh kiện điện tử lên bo mạch in PCB.)', false, NOW());

  -- Bài 33: Kỹ Thuật - Bài 3: Xây Dựng & Kết Cấu
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Kỹ Thuật - Bài 3: Xây Dựng & Kết Cấu', 'Thuật ngữ kỹ thuật xây dựng dân dụng, cầu đường và bê tông.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'foundation', '/faʊnˈdeɪ.ʃən/', 'móng công trình', 'Pour concrete for skyscraper foundation. (Đổ bê tông làm móng cho tòa nhà chọc trời.)', false, NOW()),
  (v_deck_id, 'load-bearing', '/ˈləʊdˌbeə.rɪŋ/', 'chịu lực chính', 'Never demolish a structural load-bearing wall. (Không bao giờ được phá dỡ bức tường chịu lực chính.)', false, NOW()),
  (v_deck_id, 'blueprint', '/ˈbluː.prɪnt/', 'bản vẽ thiết kế', 'Engineers study architectural blueprints carefully. (Các kỹ sư nghiên cứu kỹ lưỡng các bản vẽ thiết kế kiến trúc.)', false, NOW()),
  (v_deck_id, 'reinforcement', '/ˌriː.ɪnˈfɔːs.mənt/', 'cốt thép gia cố', 'Reinforced concrete uses steel bar reinforcement. (Bê tông cốt thép sử dụng thanh thép gia cố bên trong.)', false, NOW()),
  (v_deck_id, 'beam', '/biːm/', 'dầm chịu lực ngang', 'Steel beams support the upper building floors. (Các dầm thép chịu lực nâng đỡ các tầng trên của tòa nhà.)', false, NOW()),
  (v_deck_id, 'column', '/ˈkɒl.əm/', 'cột trụ đứng', 'Vertical concrete columns support the bridge deck. (Các cột trụ bê tông đứng đỡ mặt cầu.)', false, NOW()),
  (v_deck_id, 'scaffolding', '/ˈskæf.əl.dɪŋ/', 'giàn giáo xây dựng', 'Workers erect metal safety scaffolding. (Công nhân dựng giàn giáo an toàn bằng kim loại.)', false, NOW()),
  (v_deck_id, 'excavation', '/ˌek.skəˈveɪ.ʃən/', 'đào móng đất', 'Excavation began for the basement levels. (Công tác đào đất bắt đầu cho các tầng hầm.)', false, NOW()),
  (v_deck_id, 'surveying', '/səˈveɪ.ɪŋ/', 'trắc địa đo đạc', 'Land surveying determines exact property boundaries. (Đo đạc trắc địa xác định chính xác ranh giới khu đất.)', false, NOW()),
  (v_deck_id, 'pavement', '/ˈpeɪv.mənt/', 'mặt đường nhựa', 'Asphalt pavement withstands heavy traffic loads. (Mặt đường nhựa asphalt chịu được tải trọng giao thông lớn.)', false, NOW()),
  (v_deck_id, 'retaining wall', '/rɪˈteɪ.nɪŋ ˌwɔːl/', 'tường chắn đất', 'Build a retaining wall to prevent landslides. (Xây tường chắn đất để ngăn chặn sạt lở đất.)', false, NOW()),
  (v_deck_id, 'curing', '/ˈkjʊə.rɪŋ/', 'bảo dưỡng bê tông', 'Proper water curing ensures concrete strength. (Bảo dưỡng tưới nước đúng cách đảm bảo độ bền bê tông.)', false, NOW()),
  (v_deck_id, 'abutment', '/əˈbʌt.mənt/', 'mố cầu', 'Bridge abutment anchors the end span securely. (Mố cầu neo giữ nhịp cuối cây cầu một cách vững chắc.)', false, NOW()),
  (v_deck_id, 'cantilever', '/ˈkæn.tɪˌliː.vər/', 'dầm công-xôn nhô ra', 'Modern house with a large cantilever roof. (Ngôi nhà hiện đại với mái che dạng dầm công-xôn nhô ra lớn.)', false, NOW()),
  (v_deck_id, 'settlement', '/ˈset.əl.mənt/', 'lún sụt nền móng', 'Soil testing prevents building ground settlement. (Thí nghiệm nén đất giúp ngăn chặn hiện tượng lún sụt công trình.)', false, NOW());

  -- Bài 34: Kỹ Thuật - Bài 4: Tự Động Hóa & Robot
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Kỹ Thuật - Bài 4: Tự Động Hóa & Robot', 'Thuật ngữ cánh tay robot, cảm biến công nghiệp và PLC.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'actuator', '/ˈæk.tʃu.eɪ.tər/', 'cơ cấu chấp hành', 'Linear actuator drives robotic arm movement. (Cơ cấu chấp hành tuyến tính điều khiển chuyển động cánh tay robot.)', false, NOW()),
  (v_deck_id, 'sensor', '/ˈsen.sər/', 'cảm biến', 'Infrared sensors detect approaching obstacles. (Cảm biến hồng ngoại phát hiện các vật cản đang đến gần.)', false, NOW()),
  (v_deck_id, 'servomotor', '/ˈsɜː.vəʊˌməʊ.tər/', 'động cơ servo chính xác', 'Servomotors provide precise angular rotation control. (Động cơ servo mang lại khả năng điều khiển góc quay chính xác.)', false, NOW()),
  (v_deck_id, 'kinematics', '/ˌkɪn.ɪˈmæt.ɪks/', 'động học chuyển động', 'Inverse kinematics calculates robot joint angles. (Động học ngược tính toán góc xoay của các khớp robot.)', false, NOW()),
  (v_deck_id, 'feedback loop', '/ˈfiːd.bæk ˌluːp/', 'vòng phản hồi kín', 'PID controller uses closed feedback loop. (Bộ điều khiển PID sử dụng vòng phản hồi kín để tự hiệu chỉnh.)', false, NOW()),
  (v_deck_id, 'programmable logic controller', '/ˈprəʊ.ɡræm.ə.bəl ˈlɒdʒ.ɪk kənˈtrəʊ.lər/', 'bộ điều khiển PLC', 'Industrial factory lines are automated via PLC. (Dây chuyền nhà máy công nghiệp được tự động hóa qua PLC.)', false, NOW()),
  (v_deck_id, 'end-effector', '/ˌend ɪˈfek.tər/', 'đầu kẹp gắp robot', 'Robotic vacuum gripper end-effector. (Đầu kẹp gắp robot sử dụng giác hút chân không.)', false, NOW()),
  (v_deck_id, 'encoder', '/ɪnˈkəʊ.dər/', 'bộ mã hóa góc quay', 'Optical encoder measures shaft rotation speed. (Bộ mã hóa quang học đo tốc độ quay của trục động cơ.)', false, NOW()),
  (v_deck_id, 'conveyor', '/kənˈveɪ.ər/', 'băng tải công nghiệp', 'Assembled products move along the conveyor belt. (Sản phẩm lắp ráp di chuyển dọc theo băng chuyền băng tải.)', false, NOW()),
  (v_deck_id, 'teleoperation', '/ˌtel.i.ɒp.ərˈeɪ.ʃən/', 'điều khiển từ xa', 'Surgeons perform robotic surgery via teleoperation. (Bác sĩ phẫu thuật bằng robot thông qua điều khiển từ xa.)', false, NOW()),
  (v_deck_id, 'calibration', '/ˌkæl.ɪˈbreɪ.ʃən/', 'hiệu chuẩn độ chính xác', 'Routine calibration keeps robot sensors accurate. (Hiệu chuẩn định kỳ giữ cho cảm biến robot luôn đo chính xác.)', false, NOW()),
  (v_deck_id, 'haptic', '/ˈhæp.tɪk/', 'xúc giác phản hồi lực', 'VR glove provides realistic haptic feedback. (Găng tay thực tế ảo mang lại phản hồi xúc giác chân thực.)', false, NOW()),
  (v_deck_id, 'gantry', '/ˈɡæn.tri/', 'khung dàn trượt công nghiệp', 'Gantry robot picks and places heavy steel plates. (Robot khung dàn trượt nâng và đặt các tấm thép nặng.)', false, NOW()),
  (v_deck_id, 'degrees of freedom', '/dɪˈɡriːz əv ˈfriː.dəm/', 'bậc tự do chuyển động', 'Six degrees of freedom articulated robotic arm. (Cánh tay robot khớp nối có sáu bậc tự do chuyển động.)', false, NOW()),
  (v_deck_id, 'payload capacity', '/ˈpeɪ.ləʊd kəˈpæs.ə.ti/', 'tải trọng tối đa nâng được', 'Heavy-duty robot has 200 kg payload capacity. (Robot hạng nặng có tải trọng nâng tối đa lên đến 200 kg.)', false, NOW());

  -- Bài 35: Kỹ Thuật - Bài 5: Năng Lượng & Lưới Điện
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Kỹ Thuật - Bài 5: Năng Lượng & Lưới Điện', 'Thuật ngữ năng lượng tái tạo, pin, lưới điện thông minh và truyền tải.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'photovoltaic', '/ˌfəʊ.təʊ.vɒlˈteɪ.ɪk/', 'quang điện mặt trời', 'Rooftop photovoltaic solar panel installation. (Lắp đặt hệ thống pin quang điện mặt trời trên mái nhà.)', false, NOW()),
  (v_deck_id, 'wind turbine', '/ˈwɪnd ˌtɜː.baɪn/', 'tua-bin gió', 'Offshore wind turbines generate clean power. (Tua-bin gió ngoài khơi tạo ra nguồn điện sạch.)', false, NOW()),
  (v_deck_id, 'grid', '/ɡrɪd/', 'lưới điện quốc gia', 'Feed surplus solar energy into the power grid. (Hòa lượng điện mặt trời dư thừa vào lưới điện quốc gia.)', false, NOW()),
  (v_deck_id, 'substation', '/ˈsʌbˌsteɪ.ʃən/', 'trạm biến áp', 'High-voltage electrical substation. (Trạm biến áp điện cao thế.)', false, NOW()),
  (v_deck_id, 'transmission', '/trænzˈmɪʃ.ən/', 'truyền tải điện', 'Long-distance high-voltage power transmission. (Truyền tải điện năng cao thế trên khoảng cách xa.)', false, NOW()),
  (v_deck_id, 'blackout', '/ˈblæk.aʊt/', 'mất điện diện rộng', 'Storm caused a massive citywide power blackout. (Cơn bão gây ra sự cố mất điện trên diện rộng toàn thành phố.)', false, NOW()),
  (v_deck_id, 'electrolyzer', '/ɪˈlek.trə.laɪ.zər/', 'bình điện phân', 'Green hydrogen produced via water electrolyzer. (Hydro xanh được sản xuất qua bình điện phân nước.)', false, NOW()),
  (v_deck_id, 'fuel cell', '/ˈfjuː.əl ˌsel/', 'pin nhiên liệu', 'Hydrogen fuel cells power zero-emission buses. (Pin nhiên liệu hydro vận hành xe buýt không phát thải.)', false, NOW()),
  (v_deck_id, 'battery pack', '/ˈbæt.ər.i pæk/', 'khối pin lưu trữ', 'Electric vehicle lithium-ion battery pack. (Khối pin lưu trữ lithium-ion của xe điện.)', false, NOW()),
  (v_deck_id, 'geothermal', '/ˌdʒiː.əʊˈθɜː.məl/', 'địa nhiệt', 'Geothermal power plant taps volcanic heat. (Nhà máy điện địa nhiệt khai thác nguồn nhiệt núi lửa.)', false, NOW()),
  (v_deck_id, 'hydroelectric', '/ˌhaɪ.drəʊ.ɪˈlek.trɪk/', 'thủy điện', 'Dam generates hydroelectric power. (Con đập tạo ra nguồn năng lượng thủy điện.)', false, NOW()),
  (v_deck_id, 'smart grid', '/ˈsmɑːt ɡrɪd/', 'lưới điện thông minh', 'Smart grids balance energy supply and demand. (Lưới điện thông minh cân bằng cung và cầu năng lượng.)', false, NOW()),
  (v_deck_id, 'efficiency', '/ɪˈfɪʃ.ən.si/', 'hiệu suất chuyển đổi', 'Solar cell energy conversion efficiency. (Hiệu suất chuyển đổi năng lượng của tế bào quang điện.)', false, NOW()),
  (v_deck_id, 'degradation', '/ˌdeɡ.rəˈdeɪ.ʃən/', 'sự chai pin / suy giảm', 'Slow battery storage capacity degradation. (Làm chậm quá trình suy giảm dung lượng chai pin.)', false, NOW()),
  (v_deck_id, 'biomass', '/ˈbaɪ.əʊˌmæs/', 'sinh khối sinh học', 'Burn organic agricultural biomass for power. (Đốt chất thải sinh khối nông nghiệp hữu cơ để phát điện.)', false, NOW());

  -- Bài 36: Kỹ Thuật - Bài 6: Kỹ Thuật Hóa Học & Vật Liệu
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Kỹ Thuật - Bài 6: Kỹ Thuật Hóa Học & Vật Liệu', 'Thuật ngữ phản ứng hóa học, chưng cất, polyme và xúc tác.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'catalyst', '/ˈkæt.əl.ɪst/', 'chất xúc tác', 'Platinum acts as a reaction catalyst. (Bạch kim đóng vai trò là chất xúc tác phản ứng.)', false, NOW()),
  (v_deck_id, 'polymer', '/ˈpɒl.ɪ.mər/', 'hợp chất polyme', 'Synthetic polymers are used in plastics manufacturing. (Polyme tổng hợp được sử dụng trong sản xuất nhựa.)', false, NOW()),
  (v_deck_id, 'distillation', '/ˌdɪs.tɪˈleɪ.ʃən/', 'chưng cất tách chất', 'Fractional distillation separates crude oil components. (Chưng cất phân đoạn tách các thành phần dầu thô.)', false, NOW()),
  (v_deck_id, 'reactor', '/riˈæk.tər/', 'bình phản ứng hóa học', 'Control temperature inside chemical reactor. (Kiểm soát nhiệt độ bên trong bình phản ứng hóa học.)', false, NOW()),
  (v_deck_id, 'combustion', '/kəmˈbʌs.tʃən/', 'quá trình đốt cháy', 'Incomplete fuel combustion releases carbon monoxide. (Đốt cháy nhiên liệu không hoàn toàn sinh ra khí CO độc.)', false, NOW()),
  (v_deck_id, 'corrosion', '/kəˈrəʊ.ʒən/', 'ăn mòn hóa học', 'Acidic chemicals accelerate pipe corrosion. (Hóa chất axit đẩy nhanh tốc độ ăn mòn đường ống.)', false, NOW()),
  (v_deck_id, 'crystallization', '/ˌkrɪs.təl.aɪˈzeɪ.ʃən/', 'sự kết tinh chất rắn', 'Purify pharmaceutical drugs by crystallization. (Tinh chế dược phẩm bằng phương pháp kết tinh.)', false, NOW()),
  (v_deck_id, 'solubility', '/ˌsɒl.jəˈbɪl.ə.ti/', 'độ hòa tan trong dung môi', 'Higher water temperature increases sugar solubility. (Nhiệt độ nước cao hơn làm tăng độ hòa tan của đường.)', false, NOW()),
  (v_deck_id, 'exothermic', '/ˌek.səʊˈθɜː.mɪk/', 'tỏa nhiệt', 'An exothermic chemical reaction releases heat. (Phản ứng hóa học tỏa nhiệt giải phóng năng lượng nhiệt.)', false, NOW()),
  (v_deck_id, 'endothermic', '/ˌen.dəʊˈθɜː.mɪk/', 'thu nhiệt', 'Endothermic reactions absorb surrounding energy. (Phản ứng thu nhiệt hấp thụ năng lượng từ môi trường xung quanh.)', false, NOW()),
  (v_deck_id, 'viscosity', '/vɪsˈkɒs.ə.ti/', 'độ nhớt dòng chảy', 'Measure fluid dynamic viscosity accurately. (Đo đạc chính xác độ nhớt động lực học của chất lỏng.)', false, NOW()),
  (v_deck_id, 'filtration', '/fɪlˈtreɪ.ʃən/', 'quá trình lọc tách', 'Membrane filtration purifies drinking water. (Lọc màng bán thấm làm sạch nước uống tinh khiết.)', false, NOW()),
  (v_deck_id, 'synthesis', '/ˈsɪn.θə.sɪs/', 'tổng hợp hóa học', 'Chemical synthesis of active pharmaceutical ingredients. (Tổng hợp hóa học các hoạt chất dược phẩm.)', false, NOW()),
  (v_deck_id, 'composite', '/ˈkɒm.pə.zɪt/', 'vật liệu hỗn hợp composite', 'Carbon composite makes airplanes lighter. (Vật liệu composite sợi carbon giúp máy bay nhẹ hơn.)', false, NOW()),
  (v_deck_id, 'emulsion', '/ɪˈmʌl.ʃən/', 'nhũ tương hỗn hợp', 'Homogenizer blends stable oil-water emulsion. (Máy đồng hóa phối trộn hỗn hợp nhũ tương dầu nước ổn định.)', false, NOW());

  -- Bài 37: Kỹ Thuật - Bài 7: Viễn Thông & Tín Hiệu
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Kỹ Thuật - Bài 7: Viễn Thông & Tín Hiệu', 'Thuật ngữ truyền thông không dây, cáp quang, 5G và điều chế.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'bandwidth', '/ˈbænd.wɪtθ/', 'băng thông truyền dữ liệu', 'Fiber optic network provides high bandwidth. (Mạng cáp quang cung cấp băng thông truyền tải lớn.)', false, NOW()),
  (v_deck_id, 'modulation', '/ˌmɒdʒ.əˈleɪ.ʃən/', 'điều chế sóng tín hiệu', 'Frequency modulation (FM) for radio broadcast. (Điều chế tần số FM dùng cho phát thanh radio.)', false, NOW()),
  (v_deck_id, 'attenuation', '/əˌten.juˈeɪ.ʃən/', 'suy hao tín hiệu', 'Optical amplifiers compensate for signal attenuation. (Bộ khuếch đại quang học bù đắp suy hao tín hiệu trên đường truyền.)', false, NOW()),
  (v_deck_id, 'multiplexing', '/ˈmʌl.tɪ.pleks.ɪŋ/', 'ghép kênh truyền dẫn', 'Wavelength division multiplexing increases capacity. (Ghép kênh phân chia theo bước sóng nâng cao dung lượng.)', false, NOW()),
  (v_deck_id, 'antenna', '/ænˈten.ə/', 'ăng-ten thu phát sóng', 'MIMO antenna array powers 5G base stations. (Dàn ăng-ten MIMO trang bị cho các trạm thu phát 5G.)', false, NOW()),
  (v_deck_id, 'interference', '/ˌɪn.təˈfɪə.rəns/', 'nhiễu sóng vô tuyến', 'Shield cables to prevent electromagnetic interference. (Bọc dây cáp để chống nhiễu sóng điện từ.)', false, NOW()),
  (v_deck_id, 'spectrum', '/ˈspek.trəm/', 'phổ tần số vô tuyến', 'Government auctions radio frequency spectrum. (Chính phủ đấu giá phổ tần số vô tuyến viễn thông.)', false, NOW()),
  (v_deck_id, 'packet loss', '/ˈpæk.ɪt lɒs/', 'mất gói tin mạng', 'Packet loss causes choppy video calls. (Mất gói tin khiến cuộc gọi video bị giật lag.)', false, NOW()),
  (v_deck_id, 'jitter', '/ˈdʒɪt.ər/', 'biến thiên độ trễ gói', 'Low jitter ensures smooth gaming streaming. (Độ biến thiên trễ thấp giúp truyền phát chơi game mượt mà.)', false, NOW()),
  (v_deck_id, 'repeater', '/rɪˈpiː.tər/', 'bộ lặp khuếch đại sóng', 'Install wireless signal repeater on the second floor. (Lắp đặt bộ lặp khuếch đại sóng không dây ở tầng hai.)', false, NOW()),
  (v_deck_id, 'base station', '/ˈbeɪs ˌsteɪ.ʃən/', 'trạm thu phát gốc (BTS)', 'Cellular base stations cover urban regions. (Các trạm thu phát sóng di động phủ kín khu vực đô thị.)', false, NOW()),
  (v_deck_id, 'duplex', '/ˈdʒuː.pleks/', 'truyền song công 2 chiều', 'Full duplex enables simultaneous transmission. (Truyền song công toàn phần cho phép gửi nhận đồng thời.)', false, NOW()),
  (v_deck_id, 'demodulation', '/diːˌmɒdʒ.əˈleɪ.ʃən/', 'giải điều chế tín hiệu', 'Receiver demodulates incoming radio signal. (Máy thu thực hiện giải điều chế tín hiệu sóng vô tuyến nhận được.)', false, NOW()),
  (v_deck_id, 'transceiver', '/trænˈsiː.vər/', 'bộ thu phát tích hợp', 'Optical transceiver plugs into router switch. (Bộ thu phát quang cắm trực tiếp vào thiết bị chuyển mạch switch.)', false, NOW()),
  (v_deck_id, 'throughput', '/ˈθruː.pʊt/', 'tốc độ truyền thực tế', '5G achieves multi-gigabit throughput. (Mạng 5G đạt tốc độ truyền tải dữ liệu thực tế nhiều gigabit.)', false, NOW());

  -- Bài 38: Kỹ Thuật - Bài 8: Hàng Không & Vũ Trụ
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Kỹ Thuật - Bài 8: Hàng Không & Vũ Trụ', 'Thuật ngữ máy bay, động cơ phản lực, quỹ đạo và tên lửa.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'propulsion', '/prəˈpʌl.ʃən/', 'hệ thống đẩy tên lửa/phản lực', 'Rocket propulsion generates massive thrust. (Hệ thống đẩy tên lửa tạo ra lực đẩy khổng lồ.)', false, NOW()),
  (v_deck_id, 'thrust', '/θrʌst/', 'lực đẩy phản lực', 'Jet engines produce enormous takeoff thrust. (Động cơ phản lực tạo ra lực đẩy cất cánh cực lớn.)', false, NOW()),
  (v_deck_id, 'orbit', '/ˈɔː.bɪt/', 'quỹ đạo quay quanh', 'Satellite operates in low Earth orbit. (Vệ tinh hoạt động trên quỹ đạo Trái Đất tầm thấp.)', false, NOW()),
  (v_deck_id, 'payload', '/ˈpeɪ.ləʊd/', 'khối hàng tải trọng vũ trụ', 'Rocket carried scientific satellite payload. (Tên lửa mang theo tải trọng là vệ tinh khoa học.)', false, NOW()),
  (v_deck_id, 'avionics', '/ˌeɪ.viˈɒn.ɪks/', 'thiết bị điện tử hàng không', 'Modern cockpit digital avionics system. (Hệ thống thiết bị điện tử hàng không kỹ thuật số trong buồng lái.)', false, NOW()),
  (v_deck_id, 'fuselage', '/ˈfjuː.zəl.ɑːʒ/', 'thân máy bay', 'Lightweight composite airplane fuselage. (Thân máy bay làm bằng vật liệu composite siêu nhẹ.)', false, NOW()),
  (v_deck_id, 'altitude', '/ˈæl.tɪ.tjuːd/', 'độ cao so với mực biển', 'Commercial jets cruise at 35,000 feet altitude. (Máy bay thương mại bay ở độ cao 35.000 feet.)', false, NOW()),
  (v_deck_id, 'turbulence', '/ˈtɜː.bjə.ləns/', 'vùng nhiễu động không khí', 'Fasten seatbelts during sudden flight turbulence. (Thắt dây an toàn khi máy bay đi vào vùng nhiễu động không khí.)', false, NOW()),
  (v_deck_id, 'reentry', '/riːˈen.tri/', 'tái nhập bầu khí quyển', 'Heat shield protects spacecraft atmospheric reentry. (Tấm chắn nhiệt bảo vệ tàu vũ trụ khi tái nhập bầu khí quyển.)', false, NOW()),
  (v_deck_id, 'aerofoil', '/ˈeə.rə.fɔɪl/', 'cánh biên dạng khí động', 'Aerofoil wing shape generates aerodynamic lift. (Biên dạng cánh khí động học tạo ra lực nâng.)', false, NOW()),
  (v_deck_id, 'drag', '/dræɡ/', 'lực cản không khí', 'Streamlined nose cone minimizes air drag. (Mũi nón thuôn gọn giúp giảm thiểu tối đa lực cản không khí.)', false, NOW()),
  (v_deck_id, 'mach', '/mɑːk/', 'vận tốc âm thanh (Mach)', 'Fighter jet broke Mach 2 speed barrier. (Chiến đấu cơ đã vượt ngưỡng vận tốc gấp 2 lần âm thanh Mach 2.)', false, NOW()),
  (v_deck_id, 'trajectory', '/trəˈdʒek.tər.i/', 'quỹ đạo đường bay', 'Calculate precise missile flight trajectory. (Tính toán đường bay chính xác của tên lửa.)', false, NOW()),
  (v_deck_id, 'telemetry', '/təˈlem.ə.tri/', 'dữ liệu truyền từ vệ tinh', 'Ground station receives spacecraft telemetry. (Trạm mặt đất tiếp nhận dữ liệu đo từ xa gửi về từ tàu vũ trụ.)', false, NOW()),
  (v_deck_id, 'thruster', '/ˈθrʌs.tər/', 'động cơ phản lực vi chỉnh', 'Fire attitude thrusters to dock with ISS. (Kích hoạt động cơ vi chỉnh để cập bến trạm vũ trụ quốc tế.)', false, NOW());

  -- Bài 39: Kỹ Thuật - Bài 9: Kỹ Thuật Ô Tô & Cơ Điện Tử
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Kỹ Thuật - Bài 9: Kỹ Thuật Ô Tô & Cơ Điện Tử', 'Thuật ngữ động cơ xe hơi, xe điện EV, phanh ABS và truyền động.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'drivetrain', '/ˈdraɪv.treɪn/', 'hệ thống truyền động xe', 'All-wheel drive drivetrain delivers road grip. (Hệ thống dẫn động bốn bánh toàn thời gian giúp bám đường tốt.)', false, NOW()),
  (v_deck_id, 'combustion engine', '/kəmˈbʌs.tʃən ˈen.dʒɪn/', 'động cơ đốt trong (ICE)', 'Transition from combustion engine to electric motors. (Chuyển đổi từ động cơ đốt trong sang động cơ điện.)', false, NOW()),
  (v_deck_id, 'transmission', '/trænzˈmɪʃ.ən/', 'hộp số xe ô tô', 'Eight-speed automatic vehicle transmission. (Hộp số tự động tám cấp trên xe ô tô.)', false, NOW()),
  (v_deck_id, 'regenerative braking', '/rɪˈdʒen.ər.ə.tɪv ˈbreɪ.kɪŋ/', 'phanh tái sinh thu hồi điện', 'Regenerative braking recharges EV battery when slowing. (Phanh tái sinh nạp lại điện cho pin xe điện khi giảm tốc.)', false, NOW()),
  (v_deck_id, 'differential', '/ˌdɪf.əˈren.ʃəl/', 'bộ vi sai bánh xe', 'Differential allows wheels to turn at different speeds. (Bộ vi sai cho phép các bánh xe quay ở các tốc độ khác nhau khi vào cua.)', false, NOW()),
  (v_deck_id, 'suspension', '/səˈspen.ʃən/', 'hệ thống giảm xóc', 'Air suspension absorbs road bumps smoothly. (Hệ thống giảm xóc khí nén dập tắt dao động mặt đường êm ái.)', false, NOW()),
  (v_deck_id, 'chassis', '/ˈʃæs.i/', 'khung gầm xe ô tô', 'Rigid aluminum vehicle chassis framework. (Khung gầm xe ô tô bằng nhôm cứng cáp.)', false, NOW()),
  (v_deck_id, 'anti-lock braking', '/ˌæn.ti.lɒk ˈbreɪ.kɪŋ/', 'chống bó cứng phanh (ABS)', 'ABS prevents wheels from skidding on wet roads. (Hệ thống ABS ngăn bánh xe bị trượt lết trên đường ướt.)', false, NOW()),
  (v_deck_id, 'turbocharger', '/ˈtɜː.bəʊˌtʃɑː.dʒər/', 'bộ tăng áp khí nạp', 'Turbocharger forces compressed air into cylinders. (Bộ tăng áp nén thêm không khí vào buồng đốt xi-lanh.)', false, NOW()),
  (v_deck_id, 'exhaust', '/ɪɡˈzɔːst/', 'khí thải ống xả', 'Catalytic converter cleans harmful exhaust fumes. (Bộ chuyển đổi xúc tác xử lý khí thải độc hại.)', false, NOW()),
  (v_deck_id, 'radiator', '/ˈreɪ.di.eɪ.tər/', 'két nước làm mát động cơ', 'Coolant flows through the front radiator. (Dung dịch làm mát chảy qua két nước tản nhiệt phía trước.)', false, NOW()),
  (v_deck_id, 'clutch', '/klʌtʃ/', 'bộ ly hợp / chân côn', 'Depress clutch pedal to change manual gears. (Đạp chân côn để chuyển số sàn.)', false, NOW()),
  (v_deck_id, 'powertrain', '/ˈpaʊə.treɪn/', 'hệ thống sinh lực kéo', 'Dual motor electric vehicle powertrain. (Hệ sinh lực kéo xe điện sử dụng hai mô-tơ độc lập.)', false, NOW()),
  (v_deck_id, 'aerodynamics', '/ˌeə.rəʊ.daɪˈnæm.ɪks/', 'khí động học thân xe', 'Flush door handles improve aerodynamics. (Tay nắm cửa ẩn phẳng giúp tối ưu khí động học.)', false, NOW()),
  (v_deck_id, 'steering', '/ˈstɪə.rɪŋ/', 'hệ thống lái / vô lăng', 'Electronic power steering gives responsive control. (Trợ lực lái điện mang lại cảm giác điều khiển nhạy bén.)', false, NOW());

  -- Bài 40: Kỹ Thuật - Bài 10: An Toàn & Tiêu Chuẩn Công Nghiệp
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Kỹ Thuật - Bài 10: An Toàn & Tiêu Chuẩn Công Nghiệp', 'Thuật ngữ an toàn lao động, tiêu chuẩn ISO và kiểm soát chất lượng.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'compliance', '/kəmˈplaɪ.əns/', 'sự tuân thủ tiêu chuẩn', 'Ensure strict compliance with ISO 9001. (Đảm bảo tuân thủ nghiêm ngặt tiêu chuẩn chất lượng ISO 9001.)', false, NOW()),
  (v_deck_id, 'hazard', '/ˈhæz.əd/', 'mối nguy hiểm lao động', 'Identify workplace chemical and electrical hazards. (Nhận diện các mối nguy hiểm về hóa chất và điện tại nơi làm việc.)', false, NOW()),
  (v_deck_id, 'personal protective equipment', '/ˈpɜː.sən.əl prəˈtek.tɪv ɪˈkwɪp.mənt/', 'đồ bảo hộ cá nhân (PPE)', 'Wear required PPE including hard hat and goggles. (Mặc đầy đủ đồ bảo hộ cá nhân gồm mũ cứng và kính an toàn.)', false, NOW()),
  (v_deck_id, 'ergonomics', '/ˌɜː.ɡəˈnɒm.ɪks/', 'công thái học lao động', 'Ergonomics design prevents repetitive strain injury. (Thiết kế công thái học giúp phòng tránh chấn thương do lặp động tác.)', false, NOW()),
  (v_deck_id, 'risk assessment', '/ˈrɪsk əˌses.mənt/', 'đánh giá mức độ rủi ro', 'Conduct safety risk assessment before factory operation. (Tiến hành đánh giá rủi ro an toàn trước khi vận hành nhà máy.)', false, NOW()),
  (v_deck_id, 'mitigation', '/ˌmɪt.ɪˈɡeɪ.ʃən/', 'giảm thiểu tác hại rủi ro', 'Implement hazard mitigation procedures. (Triển khai các quy trình giảm thiểu tác hại của mối nguy.)', false, NOW()),
  (v_deck_id, 'quality assurance', '/ˌkwɒl.ə.ti əˈʃɔː.rəns/', 'đảm bảo chất lượng (QA)', 'QA department audits production standards. (Bộ phận đảm bảo chất lượng kiểm tra các tiêu chuẩn sản xuất.)', false, NOW()),
  (v_deck_id, 'quality control', '/ˌkwɒl.ə.ti kənˈtrəʊl/', 'kiểm soát chất lượng (QC)', 'QC inspector tests finished goods for defects. (KTV kiểm soát chất lượng kiểm tra lỗi sản phẩm thành phẩm.)', false, NOW()),
  (v_deck_id, 'standardization', '/ˌstæn.də.daɪˈzeɪ.ʃən/', 'tiêu chuẩn hóa quy trình', 'Global manufacturing parts standardization. (Tiêu chuẩn hóa các linh kiện sản xuất trên toàn cầu.)', false, NOW()),
  (v_deck_id, 'lockout-tagout', '/ˈlɒk.aʊt ˈtæɡ.aʊt/', 'khóa cách ly nguồn điện', 'Follow lockout-tagout before repairing machinery. (Thực hiện khóa cách ly nguồn điện trước khi sửa chữa máy móc.)', false, NOW()),
  (v_deck_id, 'inspection', '/ɪnˈspek.ʃən/', 'thanh tra / kiểm tra an toàn', 'Annual government boiler safety inspection. (Thanh tra an toàn nồi hơi định kỳ hàng năm của nhà nước.)', false, NOW()),
  (v_deck_id, 'ventilation', '/ˌven.tɪˈleɪ.ʃən/', 'thông gió nhà xưởng', 'Exhaust ventilation clears welding fumes. (Hệ thống thông gió hút mùi giúp làm sạch khói hàn trong xưởng.)', false, NOW()),
  (v_deck_id, 'fire retardant', '/ˈfaɪə rɪˌtɑː.dənt/', 'chất chống cháy', 'Treat building insulation with fire retardant chemicals. (Xử lý vật liệu cách nhiệt công trình bằng hóa chất chống cháy.)', false, NOW()),
  (v_deck_id, 'emergency stop', '/ɪˈmɜː.dʒən.si stɒp/', 'nút dừng khẩn cấp', 'Hit the red emergency stop button immediately. (Nhấn nút dừng khẩn cấp màu đỏ ngay lập tức.)', false, NOW()),
  (v_deck_id, 'incident report', '/ˈɪn.sɪ.dənt rɪˌpɔːt/', 'biên bản sự cố tai nạn', 'File an incident report after the equipment failure. (Lập biên bản sự cố tai nạn sau khi thiết bị gặp trục trặc.)', false, NOW());

  -- =========================================================
  -- KHỐI: LAW_POLITICS.JSON (8 bài học)
  -- =========================================================

  -- Bài 41: Luật & Chính Trị - Bài 1: Luật Pháp & Tòa Án
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Luật & Chính Trị - Bài 1: Luật Pháp & Tòa Án', 'Thuật ngữ pháp lý quốc tế, hợp đồng và tố tụng tại tòa.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'jurisdiction', '/ˌdʒʊə.rɪsˈdɪk.ʃən/', 'thẩm quyền phán quyết', 'Within court jurisdiction. (Thuộc thẩm quyền của tòa án.)', false, NOW()),
  (v_deck_id, 'plaintiff', '/ˈpleɪn.tɪf/', 'nguyên đơn / người kiện', 'The plaintiff filed a claim. (Nguyên đơn đã nộp đơn khởi kiện.)', false, NOW()),
  (v_deck_id, 'defendant', '/dɪˈfen.dənt/', 'bị đơn / bị cáo', 'The defendant pled not guilty. (Bị cáo tuyên bố không có tội.)', false, NOW()),
  (v_deck_id, 'precedent', '/ˈpres.ɪ.dənt/', 'án lệ', 'Set a new legal precedent. (Thiết lập một án lệ pháp lý mới.)', false, NOW()),
  (v_deck_id, 'statute', '/ˈstætʃ.uːt/', 'đạo luật', 'Passed by national statute. (Được thông qua theo đạo luật quốc gia.)', false, NOW()),
  (v_deck_id, 'litigation', '/ˌlɪt.ɪˈɡeɪ.ʃən/', 'kiện tụng / tranh tụng', 'Avoid costly litigation. (Tránh các vụ kiện tụng tốn kém.)', false, NOW()),
  (v_deck_id, 'verdict', '/ˈvɜː.dɪkt/', 'phán quyết', 'The jury reached a verdict. (Bồi thẩm đoàn đã đưa ra phán quyết.)', false, NOW()),
  (v_deck_id, 'arbitration', '/ˌɑː.bɪˈtreɪ.ʃən/', 'trọng tài phân xử', 'Settle by commercial arbitration. (Giải quyết bằng trọng tài thương mại.)', false, NOW()),
  (v_deck_id, 'testimony', '/ˈtes.tɪ.mə.ni/', 'lời khai nhân chứng', 'The witness gave testimony. (Nhân chứng đã đưa ra lời khai.)', false, NOW()),
  (v_deck_id, 'injunction', '/ɪnˈdʒʌŋk.ʃən/', 'lệnh đình chỉ', 'Court issued an injunction. (Tòa án ban hành lệnh đình chỉ.)', false, NOW()),
  (v_deck_id, 'liability', '/ˌlaɪ.əˈbɪl.ə.ti/', 'trách nhiệm pháp lý', 'Accept legal liability. (Chấp nhận trách nhiệm pháp lý.)', false, NOW()),
  (v_deck_id, 'prosecution', '/ˌprɒs.ɪˈkjuː.ʃən/', 'bên công tố', 'The prosecution showed evidence. (Bên công tố đã đưa ra bằng chứng.)', false, NOW()),
  (v_deck_id, 'sovereignty', '/ˈsɒv.rɪn.ti/', 'chủ quyền quốc gia', 'Respect national sovereignty. (Tôn trọng chủ quyền quốc gia.)', false, NOW()),
  (v_deck_id, 'treaty', '/ˈtriː.ti/', 'hiệp ước', 'Sign a peace treaty. (Ký kết một hiệp ước hòa bình.)', false, NOW()),
  (v_deck_id, 'ratify', '/ˈræt.ɪ.faɪ/', 'phê chuẩn', 'Parliament ratified the treaty. (Quốc hội đã phê chuẩn hiệp ước.)', false, NOW());

  -- Bài 42: Luật & Chính Trị - Bài 2: Sở Hữu Trí Tuệ & Doanh Nghiệp
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Luật & Chính Trị - Bài 2: Sở Hữu Trí Tuệ & Doanh Nghiệp', 'Thuật ngữ bản quyền, bằng sáng chế, nhãn hiệu và phá sản.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'patent', '/ˈpeɪ.tənt/', 'bằng sáng chế', 'File for a software invention patent. (Nộp đơn xin cấp bằng sáng chế cho phát minh phần mềm.)', false, NOW()),
  (v_deck_id, 'copyright', '/ˈkɒp.i.raɪt/', 'bản quyền tác giả', 'Protect artwork under international copyright. (Bảo vệ tác phẩm nghệ thuật theo luật bản quyền quốc tế.)', false, NOW()),
  (v_deck_id, 'trademark', '/ˈtreɪd.mɑːk/', 'nhãn hiệu thương mại', 'Register the brand logo as a trademark. (Đăng ký biểu trưng thương hiệu làm nhãn hiệu thương mại.)', false, NOW()),
  (v_deck_id, 'infringement', '/ɪnˈfrɪndʒ.mənt/', 'hành vi vi phạm quyền', 'Sued the competitor for copyright infringement. (Khởi kiện đối thủ vì hành vi vi phạm bản quyền.)', false, NOW()),
  (v_deck_id, 'non-disclosure agreement', '/ˌnɒn.dɪˈskləʊ.ʒər əˌɡriː.mənt/', 'thỏa thuận bảo mật (NDA)', 'Sign an NDA before viewing trade secrets. (Ký thỏa thuận bảo mật NDA trước khi xem bí mật kinh doanh.)', false, NOW()),
  (v_deck_id, 'royalty', '/ˈrɔɪ.əl.ti/', 'tiền bản quyền sử dụng', 'Pay 5 percent sales royalty to inventor. (Trả 5% tiền bản quyền trên doanh thu cho nhà sáng chế.)', false, NOW()),
  (v_deck_id, 'incorporation', '/ɪnˌkɔː.pərˈeɪ.ʃən/', 'thành lập doanh nghiệp', 'File articles of corporate incorporation. (Nộp hồ sơ xin thành lập doanh nghiệp.)', false, NOW()),
  (v_deck_id, 'fiduciary', '/fɪˈdʒuː.ʃi.ər.i/', 'trách nhiệm ủy thác bảo toàn', 'Directors hold fiduciary duty to shareholders. (Hội đồng quản trị chịu trách nhiệm ủy thác bảo toàn quyền lợi cổ đông.)', false, NOW()),
  (v_deck_id, 'antitrust', '/ˌæn.tiˈtrʌst/', 'chống độc quyền kinh doanh', 'Antitrust regulators probe tech mega-merger. (Cơ quan chống độc quyền điều tra thương vụ sáp nhập công nghệ lớn.)', false, NOW()),
  (v_deck_id, 'whistleblower', '/ˈwɪs.əlˌbləʊ.ər/', 'người tố giác sai phạm', 'Laws protect whistleblowers from retaliation. (Luật pháp bảo vệ người tố giác sai phạm khỏi bị trả đũa.)', false, NOW()),
  (v_deck_id, 'subpoena', '/səˈpiː.nə/', 'trát đòi hầu tòa', 'Executive received a court witness subpoena. (Vị giám đốc đã nhận trát đòi hầu tòa làm nhân chứng.)', false, NOW()),
  (v_deck_id, 'affidavit', '/ˌæf.ɪˈdeɪ.vɪt/', 'bản tuyên thệ có công chứng', 'Sign a sworn affidavit under legal oath. (Ký bản tuyên thệ có công chứng dưới lời thề trước pháp luật.)', false, NOW()),
  (v_deck_id, 'settlement', '/ˈset.əl.mənt/', 'thỏa thuận hòa giải', 'Reach a confidential financial settlement. (Đạt được một thỏa thuận hòa giải tài chính bảo mật.)', false, NOW()),
  (v_deck_id, 'waiver', '/ˈweɪ.vər/', 'văn bản từ bỏ quyền', 'Sign a liability waiver before skydiving. (Ký giấy miễn trừ từ bỏ quyền khiếu nại trước khi nhảy dù.)', false, NOW()),
  (v_deck_id, 'indemnity', '/ɪnˈdem.nə.ti/', 'cam kết bồi hoàn thiệt hại', 'Contract contains an indemnity clause. (Hợp đồng có điều khoản cam kết bồi hoàn thiệt hại.)', false, NOW());

  -- Bài 43: Luật & Chính Trị - Bài 3: Luật Hình Sự & Tư Pháp
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Luật & Chính Trị - Bài 3: Luật Hình Sự & Tư Pháp', 'Thuật ngữ tố tụng hình sự, tội phạm, điều tra và nhà tù.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'felony', '/ˈfel.ə.ni/', 'trọng tội nghiêm trọng', 'Armed robbery is classified as a felony. (Cướp có vũ trang được xếp vào loại trọng tội nghiêm trọng.)', false, NOW()),
  (v_deck_id, 'misdemeanor', '/ˌmɪs.dɪˈmiː.nər/', 'tội nhẹ / vi phạm nhỏ', 'Minor trespassing is considered a misdemeanor. (Xâm nhập trái phép nhẹ bị coi là tội nhẹ.)', false, NOW()),
  (v_deck_id, 'bail', '/beɪl/', 'tiền bảo lãnh tại ngoại', 'Judge set bail at fifty thousand dollars. (Thẩm phán ấn định số tiền bảo lãnh tại ngoại là 50.000 đô la.)', false, NOW()),
  (v_deck_id, 'parole', '/pəˈrəʊl/', 'tha tù trước thời hạn có điều kiện', 'Inmate was released on good behavior parole. (Tù nhân được tha tù trước thời hạn có điều kiện nhờ cải tạo tốt.)', false, NOW()),
  (v_deck_id, 'probation', '/prəˈbeɪ.ʃən/', 'án treo / quản chế', 'First-time offender received two years probation. (Người phạm tội lần đầu nhận mức án treo 2 năm.)', false, NOW()),
  (v_deck_id, 'custody', '/ˈkʌs.tə.di/', 'tạm giữ hình sự', 'Police took the suspect into custody. (Cảnh sát đã tạm giữ hình sự nghi phạm.)', false, NOW()),
  (v_deck_id, 'interrogation', '/ɪnˌter.əˈɡeɪ.ʃən/', 'thẩm vấn tra hỏi', 'Detectives conducted formal suspect interrogation. (Các thám tử đã tiến hành thẩm vấn chính thức nghi phạm.)', false, NOW()),
  (v_deck_id, 'warrant', '/ˈwɒr.ənt/', 'lệnh bắt / lệnh khám xét', 'Officers obtained a judicial search warrant. (Cảnh sát đã có được lệnh khám xét từ tòa án.)', false, NOW()),
  (v_deck_id, 'homicide', '/ˈhɒm.ɪ.saɪd/', 'tội giết người', 'Police opened an active homicide investigation. (Cảnh sát đã mở cuộc điều tra vụ án giết người.)', false, NOW()),
  (v_deck_id, 'fraud', '/frɔːd/', 'tội gian lận lừa đảo', 'Bank employee charged with financial wire fraud. (Nhân viên ngân hàng bị buộc tội gian lận chuyển tiền qua mạng.)', false, NOW()),
  (v_deck_id, 'embezzlement', '/ɪmˈbez.əl.mənt/', 'tội tham ô biển thủ', 'Corporate treasurer convicted of fund embezzlement. (Thủ quỹ công ty bị kết án vì tội tham ô biển thủ công quỹ.)', false, NOW()),
  (v_deck_id, 'acquittal', '/əˈkwɪt.əl/', 'tuyên trắng án vô tội', 'Jury returned an acquittal verdict for defendant. (Bồi thẩm đoàn đã đưa ra phán quyết tuyên trắng án cho bị cáo.)', false, NOW()),
  (v_deck_id, 'perjury', '/ˈpɜː.dʒər.i/', 'tội khai man trước tòa', 'Witness faced charges of criminal court perjury. (Nhân chứng đối mặt với cáo buộc tội khai man trước tòa án.)', false, NOW()),
  (v_deck_id, 'extradition', '/ˌek.strəˈdɪʃ.ən/', 'dẫn độ tội phạm quốc tế', 'Countries signed a bilateral extradition treaty. (Hai quốc gia đã ký hiệp ước dẫn độ tội phạm song phương.)', false, NOW()),
  (v_deck_id, 'rehabilitation', '/ˌriː.həˌbɪl.ɪˈteɪ.ʃən/', 'cải tạo tái hòa nhập', 'Prison programs focus on prisoner social rehabilitation. (Các chương trình trong tù tập trung vào cải tạo tái hòa nhập xã hội.)', false, NOW());

  -- Bài 44: Luật & Chính Trị - Bài 4: Chính Trị & Bộ Máy Nhà Nước
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Luật & Chính Trị - Bài 4: Chính Trị & Bộ Máy Nhà Nước', 'Thuật ngữ tam quyền phân lập, hiến pháp và thể chế chính trị.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'constitution', '/ˌkɒn.stɪˈtʃuː.ʃən/', 'hiến pháp quốc gia', 'Rights protected under the national constitution. (Các quyền được bảo vệ theo hiến pháp quốc gia.)', false, NOW()),
  (v_deck_id, 'legislature', '/ˈledʒ.ɪ.slə.tʃər/', 'cơ quan lập pháp (quốc hội)', 'The state legislature passed the education bill. (Cơ quan lập pháp bang đã thông qua dự luật giáo dục.)', false, NOW()),
  (v_deck_id, 'judiciary', '/dʒuːˈdɪʃ.ər.i/', 'nhánh tư pháp (tòa án)', 'An independent judiciary upholds the rule of law. (Một nhánh tư pháp độc lập giữ vững tinh thần thượng tôn pháp luật.)', false, NOW()),
  (v_deck_id, 'executive', '/ɪɡˈzek.jə.tɪv/', 'nhánh hành pháp (chính phủ)', 'The president heads the executive government branch. (Tổng thống đứng đầu nhánh hành pháp của chính phủ.)', false, NOW()),
  (v_deck_id, 'referendum', '/ˌref.əˈren.dəm/', 'trưng cầu dân ý', 'Citizens voted in a national constitutional referendum. (Công dân đã bỏ phiếu trong cuộc trưng cầu dân ý sửa đổi hiến pháp.)', false, NOW()),
  (v_deck_id, 'democracy', '/dɪˈmɒk.rə.si/', 'nền dân chủ', 'Free press is essential for representative democracy. (Báo chí tự do là điều thiết yếu cho một nền dân chủ đại diện.)', false, NOW()),
  (v_deck_id, 'authoritarian', '/ɔːˌθɒr.ɪˈteə.ri.ən/', 'chuyên chế / độc đoán', 'Living under a strict authoritarian military regime. (Sống dưới một chế độ quân sự chuyên chế nghiêm ngặt.)', false, NOW()),
  (v_deck_id, 'bureaucracy', '/bjʊəˈrɒk.rə.si/', 'bộ máy quan liêu / hành chính', 'Streamline government administrative bureaucracy. (Tinh gọn bộ máy hành chính công của chính phủ.)', false, NOW()),
  (v_deck_id, 'impeachment', '/ɪmˈpiːtʃ.mənt/', 'luận tội phế truất', 'Parliament initiated official presidential impeachment proceedings. (Quốc hội đã bắt đầu tiến trình luận tội phế truất tổng thống.)', false, NOW()),
  (v_deck_id, 'coalition', '/ˌkəʊ.əˈlɪʃ.ən/', 'chính phủ liên hiệp các đảng', 'Parties formed a ruling parliamentary coalition. (Các đảng phái đã thành lập một chính phủ liên hiệp cầm quyền trong quốc hội.)', false, NOW()),
  (v_deck_id, 'veto', '/ˈviː.təʊ/', 'quyền phủ quyết dự luật', 'The governor exercised a veto on the tax bill. (Thống đốc đã sử dụng quyền phủ quyết đối với dự luật thuế.)', false, NOW()),
  (v_deck_id, 'sovereignty', '/ˈsɒv.rɪn.ti/', 'chủ quyền lãnh thổ', 'Defend national sovereignty and territorial borders. (Bảo vệ chủ quyền quốc gia và biên giới lãnh thổ.)', false, NOW()),
  (v_deck_id, 'cabinet', '/ˈkæb.ɪ.nət/', 'nội các chính phủ', 'Prime minister reshuffled the government cabinet. (Thủ tướng đã cải tổ lại nội các chính phủ.)', false, NOW()),
  (v_deck_id, 'filibuster', '/ˈfɪl.ɪ.bʌs.tər/', 'chiến thuật câu giờ chặn luật', 'Senator launched a 10-hour speech filibuster. (Thượng nghị sĩ thực hiện diễn thuyết câu giờ suốt 10 tiếng để chặn luật.)', false, NOW()),
  (v_deck_id, 'devolution', '/ˌdiː.vəˈluː.ʃən/', 'phân cấp quyền lực cho địa phương', 'Power devolution granted more autonomy to regions. (Phân cấp quyền lực trao nhiều quyền tự chủ hơn cho các vùng.)', false, NOW());

  -- Bài 45: Luật & Chính Trị - Bài 5: Ngoại Giao & Quan Hệ Quốc Tế
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Luật & Chính Trị - Bài 5: Ngoại Giao & Quan Hệ Quốc Tế', 'Thuật ngữ đại sứ quán, trừng phạt kinh tế, hiệp định và ngoại giao.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'diplomacy', '/dɪˈpləʊ.mə.si/', 'nghệ thuật ngoại giao', 'Resolve international crises through peaceful diplomacy. (Giải quyết các cuộc khủng hoảng quốc tế bằng con đường ngoại giao hòa bình.)', false, NOW()),
  (v_deck_id, 'ambassador', '/æmˈbæs.ə.dər/', 'đại sứ đặc mệnh toàn quyền', 'Appoint a new extraordinary ambassador to France. (Bổ nhiệm một đại sứ đặc mệnh toàn quyền mới tại Pháp.)', false, NOW()),
  (v_deck_id, 'sanction', '/ˈsæŋk.ʃən/', 'lệnh trừng phạt kinh tế', 'UN imposed economic sanctions on the aggressor. (Liên Hợp Quốc đã áp đặt các lệnh trừng phạt kinh tế lên quốc gia gây hấn.)', false, NOW()),
  (v_deck_id, 'bilateral', '/ˌbaɪˈlæt.ər.əl/', 'song phương (hai bên)', 'Sign a bilateral trade and investment pact. (Ký kết hiệp định thương mại và đầu tư song phương.)', false, NOW()),
  (v_deck_id, 'multilateral', '/ˌmʌl.tiˈlæt.ər.əl/', 'đa phương (nhiều nước)', 'Participate in multilateral climate negotiations. (Tham gia vào các cuộc đàm phán khí hậu đa phương.)', false, NOW()),
  (v_deck_id, 'embassy', '/ˈem.bə.si/', 'đại sứ quán', 'Protest held outside the foreign country embassy. (Cuộc biểu tình diễn ra bên ngoài trụ sở đại sứ quán nước ngoài.)', false, NOW()),
  (v_deck_id, 'consulate', '/ˈkɒn.sjə.lət/', 'lãnh sự quán (cấp thị thực)', 'Apply for travel visa at the regional consulate. (Nộp đơn xin cấp thị thực du lịch tại lãnh sự quán khu vực.)', false, NOW()),
  (v_deck_id, 'protocol', '/ˈprəʊ.tə.kɒl/', 'nghi thức lễ tân ngoại giao', 'Strict diplomatic protocol observed during royal visits. (Nghi thức ngoại giao nghiêm ngặt được tuân thủ trong các chuyến thăm hoàng gia.)', false, NOW()),
  (v_deck_id, 'asylum', '/əˈsaɪ.ləm/', 'tị nạn chính trị', 'Dissident granted political asylum overseas. (Nhà bất đồng chính kiến được cấp quyền tị nạn chính trị ở nước ngoài.)', false, NOW()),
  (v_deck_id, 'hegemony', '/hɪˈɡem.ə.ni/', 'sự bá quyền chi phối', 'Challenging global superpowers military hegemony. (Thách thức sự bá quyền quân sự của các siêu cường toàn cầu.)', false, NOW()),
  (v_deck_id, 'summit', '/ˈsʌm.ɪt/', 'hội nghị thượng đỉnh', 'World leaders gathered for the G7 economic summit. (Các nhà lãnh đạo thế giới tề tựu tại hội nghị thượng đỉnh kinh tế G7.)', false, NOW()),
  (v_deck_id, 'envoy', '/ˈen.vɔɪ/', 'đặc phái viên hòa bình', 'Special UN envoy traveled to broker a ceasefire. (Đặc phái viên Liên Hợp Quốc lên đường dàn xếp thỏa thuận ngừng bắn.)', false, NOW()),
  (v_deck_id, 'annexation', '/ˌæn.ekˈseɪ.ʃən/', 'thôn tính sáp nhập lãnh thổ', 'Condemn illegal military land annexation. (Lên án hành vi dùng quân sự thôn tính sáp nhập lãnh thổ bất hợp pháp.)', false, NOW()),
  (v_deck_id, 'ceasefire', '/ˈsiːs.faɪər/', 'thỏa thuận ngừng bắn', 'Parties agreed to a temporary humanitarian ceasefire. (Các bên đã đồng ý một thỏa thuận ngừng bắn nhân đạo tạm thời.)', false, NOW()),
  (v_deck_id, 'neutrality', '/njuːˈtræl.ə.ti/', 'chính sách trung lập', 'Switzerland maintains centuries-long armed neutrality. (Thụy Sĩ duy trì chính sách trung lập vũ trang kéo dài hàng thế kỷ.)', false, NOW());

  -- Bài 46: Luật & Chính Trị - Bài 6: Quyền Con Người & Luật Quốc Tế
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Luật & Chính Trị - Bài 6: Quyền Con Người & Luật Quốc Tế', 'Thuật ngữ nhân quyền, công ước Geneva và tội ác chiến tranh.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'human rights', '/ˈhjuː.mən raɪts/', 'quyền con người (nhân quyền)', 'Universal Declaration of Human Rights. (Tuyên ngôn Quốc tế về Quyền Con người.)', false, NOW()),
  (v_deck_id, 'discrimination', '/dɪˌskrɪm.ɪˈneɪ.ʃən/', 'sự phân biệt đối xử', 'Prohibit racial and gender employment discrimination. (Nghiêm cấm phân biệt đối xử về chủng tộc và giới tính trong việc làm.)', false, NOW()),
  (v_deck_id, 'genocide', '/ˈdʒen.ə.saɪd/', 'tội ác diệt chủng', 'International court prosecuted crimes of genocide. (Tòa án quốc tế đã truy tố tội ác diệt chủng.)', false, NOW()),
  (v_deck_id, 'war crime', '/ˈwɔː ˌkraɪm/', 'tội ác chiến tranh', 'Targeting civilians violates Geneva Conventions as a war crime. (Nhắm vào dân thường là tội ác chiến tranh vi phạm Công ước Geneva.)', false, NOW()),
  (v_deck_id, 'refugee', '/ˌref.juˈdʒiː/', 'người tị nạn chiến tranh', 'UN agency protects millions of displaced refugees. (Cơ quan Liên Hợp Quốc bảo vệ hàng triệu người tị nạn mất nhà cửa.)', false, NOW()),
  (v_deck_id, 'persecution', '/ˌpɜː.sɪˈkjuː.ʃən/', 'sự đàn áp bách hại', 'Flee religious and ethnic persecution. (Bỏ trốn khỏi sự đàn áp bách hại tôn giáo và sắc tộc.)', false, NOW()),
  (v_deck_id, 'habeas corpus', '/ˌheɪ.bi.əs ˈkɔː.pəs/', 'quyền bảo thân không bị giam oan', 'Habeas corpus guarantees prompt trial without unlawful detention. (Quyền bảo thân đảm bảo được xét xử kịp thời mà không bị giam giữ trái luật.)', false, NOW()),
  (v_deck_id, 'amnesty', '/ˈæm.nə.sti/', 'đại xá / ân xá chính trị', 'Government granted general amnesty to political prisoners. (Chính phủ đã ban hành lệnh đại xá chung cho các tù nhân chính trị.)', false, NOW()),
  (v_deck_id, 'indigenous', '/ɪnˈdɪdʒ.ɪ.nəs/', 'người bản địa nguyên trú', 'Protect legal land rights of indigenous populations. (Bảo vệ quyền sở hữu đất đai hợp pháp của các cộng đồng người bản địa.)', false, NOW()),
  (v_deck_id, 'censorship', '/ˈsen.sə.ʃɪp/', 'kiểm duyệt báo chí thông tin', 'Strict government censorship on social media. (Sự kiểm duyệt thông tin nghiêm ngặt của chính phủ trên mạng xã hội.)', false, NOW()),
  (v_deck_id, 'dissent', '/dɪˈsent/', 'ý kiến bất đồng phản biện', 'Democracy allows peaceful political dissent. (Nền dân chủ cho phép sự bất đồng ý kiến phản biện chính trị trong hòa bình.)', false, NOW()),
  (v_deck_id, 'tribunal', '/traɪˈbjuː.nəl/', 'tòa án đặc biệt phân xử', 'International Criminal Tribunal for former Yugoslavia. (Tòa án Hình sự Quốc tế xét xử các tội phạm ở Nam Tư cũ.)', false, NOW()),
  (v_deck_id, 'impunity', '/ɪmˈpjuː.nə.ti/', 'sự thoát tội không bị phạt', 'End the culture of impunity for corrupt officials. (Chấm dứt thói quen thoát tội không bị trừng phạt của các quan chức tham nhũng.)', false, NOW()),
  (v_deck_id, 'stateless', '/ˈsteɪt.ləs/', 'người không quốc tịch', 'Provide legal identity documents to stateless people. (Cung cấp giấy tờ tùy thân pháp lý cho những người không có quốc tịch.)', false, NOW()),
  (v_deck_id, 'arbitrary', '/ˈɑː.bɪ.trər.i/', 'tùy tiện độc đoán', 'Prohibit arbitrary arrest without clear evidence. (Nghiêm cấm việc bắt giữ tùy tiện khi không có bằng chứng rõ ràng.)', false, NOW());

  -- Bài 47: Luật & Chính Trị - Bài 7: Bầu Cử & Đảng Phái
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Luật & Chính Trị - Bài 7: Bầu Cử & Đảng Phái', 'Thuật ngữ bầu cử, phiếu bầu, vận động hành lang và cử tri.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'electorate', '/iˈlek.tər.ət/', 'toàn thể cử tri bỏ phiếu', 'The electorate demanded economic reforms. (Toàn thể cử tri đòi hỏi các cuộc cải cách kinh tế cấp bách.)', false, NOW()),
  (v_deck_id, 'ballot', '/ˈbæl.ət/', 'lá phiếu bầu bí mật', 'Voters cast secret paper ballots at polling booths. (Cử tri bỏ những lá phiếu giấy bí mật tại các phòng bỏ phiếu.)', false, NOW()),
  (v_deck_id, 'constituency', '/kənˈstɪtʃ.u.ən.si/', 'đơn vị bầu cử khu vực', 'Member of Parliament represents his home constituency. (Nghị sĩ quốc hội đại diện cho đơn vị bầu cử quê nhà của mình.)', false, NOW()),
  (v_deck_id, 'turnout', '/ˈtɜːn.aʊt/', 'tỷ lệ cử tri đi bầu', 'Record high 85 percent election voter turnout. (Tỷ lệ cử tri đi bầu cử đạt mức kỷ lục 85%.)', false, NOW()),
  (v_deck_id, 'gerrymandering', '/ˈdʒer.iˌmæn.dər.ɪŋ/', 'vẽ lại ranh giới khu bầu cử trục lợi', 'Parties use gerrymandering to manipulate seat counts. (Các đảng phái dùng thủ thuật vẽ lại ranh giới bầu cử để thao túng số ghế.)', false, NOW()),
  (v_deck_id, 'lobbying', '/ˈlɒb.i.ɪŋ/', 'vận động hành lang chính sách', 'Corporate lobbying influences environmental regulations. (Vận động hành lang của doanh nghiệp tác động đến các quy định môi trường.)', false, NOW()),
  (v_deck_id, 'manifesto', '/ˌmæn.ɪˈfes.təʊ/', 'cương lĩnh tranh cử của đảng', 'Party published its election campaign manifesto. (Đảng phái đã công bố cương lĩnh chiến dịch tranh cử của mình.)', false, NOW()),
  (v_deck_id, 'incumbent', '/ɪnˈkʌm.bənt/', 'người đang đương chức', 'The incumbent president won reelection by a slim margin. (Vị tổng thống đương nhiệm đã tái đắc cử với cách biệt sít sao.)', false, NOW()),
  (v_deck_id, 'suffrage', '/ˈsʌf.rɪdʒ/', 'quyền bầu cử phổ thông', 'Universal suffrage gives every adult the right to vote. (Quyền bầu cử phổ thông trao cho mọi người trưởng thành quyền bỏ phiếu.)', false, NOW()),
  (v_deck_id, 'bipartisan', '/ˌbaɪˈpɑː.tɪ.zæn/', 'lưỡng đảng đồng thuận', 'Infrastructure bill passed with bipartisan support. (Dự luật cơ sở hạ tầng được thông qua với sự ủng hộ của cả hai đảng.)', false, NOW()),
  (v_deck_id, 'poll', '/pəʊl/', 'thăm dò dư luận', 'Opinion polls show candidates tied neck and neck. (Các cuộc thăm dò dư luận cho thấy các ứng viên đang bám đuổi sít sao.)', false, NOW()),
  (v_deck_id, 'landslide', '/ˈlænd.slaɪd/', 'thắng lợi áp đảo vang dội', 'Prime minister won a historic landslide election victory. (Thủ tướng đã giành chiến thắng bầu cử áp đảo mang tính lịch sử.)', false, NOW()),
  (v_deck_id, 'absentee', '/ˌæb.sənˈtiː/', 'bỏ phiếu vắng mặt qua thư', 'Soldiers overseas voted by absentee mail ballot. (Binh sĩ đóng quân ở nước ngoài bỏ phiếu bằng thư gửi từ xa.)', false, NOW()),
  (v_deck_id, 'partisanship', '/ˌpɑː.tɪˈzæn.ʃɪp/', 'tính bè phái đảng phái cực đoan', 'Bitter political partisanship stalled congressional progress. (Tính bè phái đảng phái gay gắt làm đình trệ công việc của quốc hội.)', false, NOW()),
  (v_deck_id, 'caucus', '/ˈkɔː.kəs/', 'hội nghị kín nội bộ đảng', 'State party members met at the presidential caucus. (Các đảng viên trong bang đã họp tại hội nghị kín chọn ứng viên tổng thống.)', false, NOW());

  -- Bài 48: Luật & Chính Trị - Bài 8: Luật Môi Trường & Hiệp Ước
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('Luật & Chính Trị - Bài 8: Luật Môi Trường & Hiệp Ước', 'Thuật ngữ luật bảo vệ môi trường, hạn ngạch khí thải và bồi thường sinh thái.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'carbon tax', '/ˈkɑː.bən ˌtæks/', 'thuế phát thải carbon', 'Levy carbon tax on fossil fuel industrial polluters. (Đánh thuế phát thải carbon lên các nhà máy ô nhiễm dùng nhiên liệu hóa thạch.)', false, NOW()),
  (v_deck_id, 'biodiversity', '/ˌbaɪ.əʊ.daɪˈvɜː.sə.ti/', 'đa dạng sinh học', 'Law preserves rainforest flora and fauna biodiversity. (Luật bảo tồn sự đa dạng sinh học của động thực vật rừng nhiệt đới.)', false, NOW()),
  (v_deck_id, 'sustainability', '/səˌsteɪ.nəˈbɪl.ə.ti/', 'tính bền vững sinh thái', 'Incorporate ecological sustainability in project planning. (Đưa tiêu chí bền vững sinh thái vào quy hoạch dự án.)', false, NOW()),
  (v_deck_id, 'conservation', '/ˌkɒn.səˈveɪ.ʃən/', 'bảo tồn thiên nhiên', 'Wildlife conservation park safeguards endangered species. (Vườn bảo tồn thiên nhiên hoang dã bảo vệ các loài có nguy cơ tuyệt chủng.)', false, NOW()),
  (v_deck_id, 'cap-and-trade', '/ˌkæp.ənˈtreɪd/', 'hạn ngạch mua bán khí thải', 'Cap-and-trade market limits total national greenhouse emissions. (Thị trường mua bán hạn ngạch giới hạn tổng lượng khí thải nhà kính quốc gia.)', false, NOW()),
  (v_deck_id, 'polluter-pays', '/pəˌluː.tərˈpeɪz/', 'nguyên tắc kẻ gây ô nhiễm phải trả', 'Polluter-pays principle mandates cleanup remediation. (Nguyên tắc người gây ô nhiễm phải trả tiền bắt buộc phải khắc phục hậu quả.)', false, NOW()),
  (v_deck_id, 'deforestation', '/diːˌfɒr.ɪˈsteɪ.ʃən/', 'nạn phá rừng bừa bãi', 'Enforce criminal bans against illegal Amazon deforestation. (Thực thi các lệnh cấm hình sự đối với nạn phá rừng Amazon bất hợp pháp.)', false, NOW()),
  (v_deck_id, 'effluent', '/ˈef.lu.ənt/', 'nước thải công nghiệp xả ra', 'Factory punished for discharging untreated toxic effluent. (Nhà máy bị phạt vì xả nước thải độc hại chưa qua xử lý ra sông.)', false, NOW()),
  (v_deck_id, 'remediation', '/rɪˌmiː.diˈeɪ.ʃən/', 'khắc phục phục hồi môi trường', 'Soil contamination environmental cleanup remediation. (Công tác làm sạch và phục hồi môi trường đất bị nhiễm độc.)', false, NOW()),
  (v_deck_id, 'ecosystem', '/ˈiː.kəʊˌsɪs.təm/', 'hệ sinh thái tự nhiên', 'Oil spill severely damaged the marine coastal ecosystem. (Vụ tràn dầu đã làm tổn hại nghiêm trọng hệ sinh thái ven biển.)', false, NOW()),
  (v_deck_id, 'renewable', '/rɪˈnjuː.ə.bəl/', 'năng lượng tái tạo', 'Transition national energy mix to 100 percent renewable. (Chuyển đổi cơ cấu năng lượng quốc gia sang 100% tái tạo.)', false, NOW()),
  (v_deck_id, 'endangered', '/ɪnˈdeɪn.dʒəd/', 'loài có nguy cơ tuyệt chủng', 'Black rhino listed as a critically endangered mammal. (Tê giác đen được liệt kê là loài động vật có vú cực kỳ nguy cấp.)', false, NOW()),
  (v_deck_id, 'jurisprudence', '/ˌdʒʊə.rɪsˈpruː.dəns/', 'triết học pháp lý / khoa học luật', 'Environmental jurisprudence balances development with ecology. (Triết học pháp lý môi trường cân bằng giữa phát triển và sinh thái.)', false, NOW()),
  (v_deck_id, 'stewardship', '/ˈstjuː.əd.ʃɪp/', 'trách nhiệm quản lý bảo vệ', 'Responsible stewardship of global ocean resources. (Trách nhiệm quản lý và bảo vệ có trách nhiệm đối với tài nguyên biển toàn cầu.)', false, NOW()),
  (v_deck_id, 'containment', '/kənˈteɪn.mənt/', 'khoanh vùng ngăn chặn rò rỉ', 'Deploy floating barriers for chemical spill containment. (Thả phao chắn nổi để khoanh vùng ngăn chặn tràn hóa chất.)', false, NOW());

  -- =========================================================
  -- KHỐI: TOEIC_WORKPLACE.JSON (12 bài học)
  -- =========================================================

  -- Bài 49: TOEIC - Bài 1: Hợp Đồng & Đàm Phán
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('TOEIC - Bài 1: Hợp Đồng & Đàm Phán', '50 chủ đề TOEIC thiết yếu - Bài 1: Đàm phán và hợp đồng thương mại.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'negotiate', '/nəˈɡəʊ.ʃi.eɪt/', 'đàm phán', 'Negotiate a better deal. (Đàm phán một thỏa thuận tốt hơn.)', false, NOW()),
  (v_deck_id, 'agreement', '/əˈɡriː.mənt/', 'thỏa thuận', 'Sign the agreement today. (Ký thỏa thuận hôm nay.)', false, NOW()),
  (v_deck_id, 'provision', '/prəˈvɪʒ.ən/', 'điều khoản', 'Review contract provisions. (Xem lại các điều khoản hợp đồng.)', false, NOW()),
  (v_deck_id, 'terminate', '/ˈtɜː.mɪ.neɪt/', 'chấm dứt / hủy bỏ', 'Terminate the contract early. (Chấm dứt hợp đồng sớm.)', false, NOW()),
  (v_deck_id, 'abide by', '/əˈbaɪd baɪ/', 'tuân thủ', 'Abide by company policies. (Tuân thủ các chính sách công ty.)', false, NOW()),
  (v_deck_id, 'obligation', '/ˌɒb.lɪˈɡeɪ.ʃən/', 'nghĩa vụ', 'Fulfill contractual obligations. (Hoàn thành các nghĩa vụ hợp đồng.)', false, NOW()),
  (v_deck_id, 'binding', '/ˈbaɪn.dɪŋ/', 'ràng buộc', 'A legally binding contract. (Một hợp đồng có tính ràng buộc pháp lý.)', false, NOW()),
  (v_deck_id, 'breach', '/briːtʃ/', 'vi phạm', 'Breach of contract terms. (Vi phạm các điều khoản hợp đồng.)', false, NOW()),
  (v_deck_id, 'clause', '/klɔːz/', 'điều khoản riêng', 'Read the confidentiality clause. (Đọc điều khoản bảo mật.)', false, NOW()),
  (v_deck_id, 'comply', '/kəmˈplaɪ/', 'tuân theo', 'Comply with safety rules. (Tuân theo các quy tắc an toàn.)', false, NOW()),
  (v_deck_id, 'party', '/ˈpɑː.ti/', 'bên tham gia', 'Both parties agreed. (Cả hai bên đều đã đồng ý.)', false, NOW()),
  (v_deck_id, 'settlement', '/ˈset.əl.mənt/', 'dàn xếp', 'Reach a financial settlement. (Đạt được một thỏa thuận dàn xếp tài chính.)', false, NOW()),
  (v_deck_id, 'renew', '/rɪˈnjuː/', 'gia hạn', 'Renew the lease contract. (Gia hạn hợp đồng thuê.)', false, NOW()),
  (v_deck_id, 'assurance', '/əˈʃɔː.rəns/', 'cam đoan', 'Give assurance of quality. (Đưa ra cam đoan về chất lượng.)', false, NOW()),
  (v_deck_id, 'specific', '/spəˈsɪf.ɪk/', 'cụ thể', 'Follow specific instructions. (Làm theo các hướng dẫn cụ thể.)', false, NOW());

  -- Bài 50: TOEIC - Bài 2: Tuyển Dụng & Nhân Sự
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('TOEIC - Bài 2: Tuyển Dụng & Nhân Sự', '50 chủ đề TOEIC thiết yếu - Bài 2: Tuyển dụng, phỏng vấn và đãi ngộ.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'applicant', '/ˈæp.lɪ.kənt/', 'người ứng tuyển', 'Interview the top applicant. (Phỏng vấn người ứng tuyển xuất sắc nhất.)', false, NOW()),
  (v_deck_id, 'candidate', '/ˈkæn.dɪ.dət/', 'ứng viên', 'Select the right candidate. (Lựa chọn ứng viên phù hợp.)', false, NOW()),
  (v_deck_id, 'qualification', '/ˌkwɒl.ɪ.fɪˈkeɪ.ʃən/', 'bằng cấp / chuyên môn', 'Have relevant qualifications. (Có bằng cấp chuyên môn phù hợp.)', false, NOW()),
  (v_deck_id, 'recruit', '/rɪˈkruːt/', 'tuyển dụng', 'Recruit talented engineers. (Tuyển dụng các kỹ sư tài năng.)', false, NOW()),
  (v_deck_id, 'compensation', '/ˌkɒm.penˈseɪ.ʃən/', 'đãi ngộ / lương thưởng', 'Offer fair compensation. (Đưa ra mức đãi ngộ công bằng.)', false, NOW()),
  (v_deck_id, 'probation', '/prəˈbeɪ.ʃən/', 'thử việc', 'Pass the probation period. (Vượt qua thời gian thử việc.)', false, NOW()),
  (v_deck_id, 'incentive', '/ɪnˈsen.tɪv/', 'tiền thưởng khích lệ', 'Sales performance incentives. (Tiền thưởng khích lệ theo doanh số.)', false, NOW()),
  (v_deck_id, 'appraisal', '/əˈpreɪ.zəl/', 'đánh giá nhân viên', 'Annual employee appraisal. (Đánh giá nhân viên hàng năm.)', false, NOW()),
  (v_deck_id, 'turnover', '/ˈtɜːnˌəʊ.vər/', 'luân chuyển nhân viên', 'Reduce employee turnover. (Giảm tỷ lệ luân chuyển nhân viên.)', false, NOW()),
  (v_deck_id, 'promotion', '/prəˈməʊ.ʃən/', 'thăng chức', 'Earn a promotion to manager. (Được thăng chức lên làm quản lý.)', false, NOW()),
  (v_deck_id, 'pension', '/ˈpen.ʃən/', 'lương hưu', 'Contribute to pension fund. (Đóng góp vào quỹ lương hưu.)', false, NOW()),
  (v_deck_id, 'severance', '/ˈsev.ər.əns/', 'trợ cấp thôi việc', 'Receive a severance package. (Nhận gói trợ cấp thôi việc.)', false, NOW()),
  (v_deck_id, 'competence', '/ˈkɒm.pɪ.təns/', 'năng lực', 'Demonstrate high competence. (Thể hiện năng lực làm việc cao.)', false, NOW()),
  (v_deck_id, 'resume', '/ˈrez.juː.meɪ/', 'hồ sơ xin việc', 'Send your updated resume. (Gửi hồ sơ xin việc mới nhất của bạn.)', false, NOW()),
  (v_deck_id, 'hire', '/haɪər/', 'thuê / tuyển', 'Hire ten new staff members. (Tuyển dụng 10 nhân viên mới.)', false, NOW());

  -- Bài 51: TOEIC - Bài 3: Hội Nghị & Thuyết Trình
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('TOEIC - Bài 3: Hội Nghị & Thuyết Trình', '50 chủ đề TOEIC thiết yếu - Bài 3: Hội nghị, hội thảo và diễn thuyết.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'agenda', '/əˈdʒen.də/', 'chương trình nghị sự', 'Follow the meeting agenda items. (Làm theo các mục trong chương trình nghị sự cuộc họp.)', false, NOW()),
  (v_deck_id, 'keynote', '/ˈkiː.nəʊt/', 'bài phát biểu chủ đạo', 'CEO delivered the opening keynote speech. (CEO đã đọc bài phát biểu chủ đạo khai mạc.)', false, NOW()),
  (v_deck_id, 'venue', '/ˈven.juː/', 'địa điểm tổ chức', 'Convention center is the event venue. (Trung tâm hội nghị là địa điểm tổ chức sự kiện.)', false, NOW()),
  (v_deck_id, 'handout', '/ˈhænd.aʊt/', 'tài liệu phát tay', 'Distribute presentation handouts to audience. (Phát tài liệu thuyết trình cho người nghe.)', false, NOW()),
  (v_deck_id, 'adjourn', '/əˈdʒɜːn/', 'tạm hoãn / bế mạc cuộc họp', 'The chairman adjourned the board meeting. (Chủ tọa đã tuyên bố bế mạc cuộc họp hội đồng.)', false, NOW()),
  (v_deck_id, 'consensus', '/kənˈsen.səs/', 'sự đồng thuận chung', 'Reach a unanimous group consensus. (Đạt được sự đồng thuận nhất trí của toàn nhóm.)', false, NOW()),
  (v_deck_id, 'facilitate', '/fəˈsɪl.ɪ.teɪt/', 'điều phối / hỗ trợ thuận lợi', 'Moderator facilitates group workshop discussions. (Người điều phối giúp buổi thảo luận nhóm diễn ra thuận lợi.)', false, NOW()),
  (v_deck_id, 'minutes', '/ˈmɪn.ɪts/', 'biên bản cuộc họp', 'Secretary took detailed meeting minutes. (Thư ký đã ghi chép biên bản cuộc họp chi tiết.)', false, NOW()),
  (v_deck_id, 'attendee', '/ə.tenˈdiː/', 'người tham dự sự kiện', 'Over five hundred conference attendees registered. (Hơn 500 người tham dự hội nghị đã đăng ký.)', false, NOW()),
  (v_deck_id, 'receptive', '/rɪˈsep.tɪv/', 'cởi mở tiếp thu ý kiến', 'Audience was very receptive to new ideas. (Khán giả rất cởi mở tiếp thu các ý tưởng mới.)', false, NOW()),
  (v_deck_id, 'demonstration', '/ˌdem.ənˈstreɪ.ʃən/', 'buổi trình diễn sản phẩm', 'Live software feature product demonstration. (Buổi trình diễn trực tiếp tính năng sản phẩm phần mềm.)', false, NOW()),
  (v_deck_id, 'symposium', '/sɪmˈpəʊ.zi.əm/', 'hội thảo chuyên đề khoa học', 'Annual medical research symposium. (Hội thảo chuyên đề nghiên cứu y khoa thường niên.)', false, NOW()),
  (v_deck_id, 'panelist', '/ˈpæn.əl.ɪst/', 'diễn giả tọa đàm', 'Invited expert panelists answered questions. (Các diễn giả chuyên gia được mời đã trả lời câu hỏi.)', false, NOW()),
  (v_deck_id, 'convene', '/kənˈviːn/', 'triệu tập hội nghị', 'Convene an extraordinary shareholder meeting. (Triệu tập một cuộc họp đại hội đồng cổ đông bất thường.)', false, NOW()),
  (v_deck_id, 'brainstorm', '/ˈbreɪn.stɔːm/', 'động não tìm ý tưởng', 'Team met to brainstorm creative marketing ideas. (Cả nhóm họp lại để động não tìm ý tưởng tiếp thị sáng tạo.)', false, NOW());

  -- Bài 52: TOEIC - Bài 4: Văn Phòng & Thiết Bị
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('TOEIC - Bài 4: Văn Phòng & Thiết Bị', '50 chủ đề TOEIC thiết yếu - Bài 4: Vận hành văn phòng, vật tư và thiết bị.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'stationery', '/ˈsteɪ.ʃən.ər.i/', 'văn phòng phẩm', 'Order pens and notebooks from stationery shop. (Đặt mua bút và sổ tay từ cửa hàng văn phòng phẩm.)', false, NOW()),
  (v_deck_id, 'copier', '/ˈkɒp.i.ər/', 'máy photocopy', 'Photocopier ran out of paper trays. (Máy photocopy đã hết giấy trong khay nạp.)', false, NOW()),
  (v_deck_id, 'shredder', '/ˈʃred.ər/', 'máy hủy tài liệu', 'Destroy sensitive financial documents in shredder. (Hủy các tài liệu tài chính nhạy cảm bằng máy hủy giấy.)', false, NOW()),
  (v_deck_id, 'cartridge', '/ˈkɑː.trɪdʒ/', 'hộp mực máy in', 'Replace the black toner printer cartridge. (Thay hộp mực in màu đen cho máy in.)', false, NOW()),
  (v_deck_id, 'memo', '/ˈmem.əʊ/', 'thông báo nội bộ', 'Circulate an internal office policy memo. (Gửi lưu hành bản thông báo chính sách nội bộ văn phòng.)', false, NOW()),
  (v_deck_id, 'filing cabinet', '/ˈfaɪ.lɪŋ ˌkæb.ɪ.nət/', 'tủ hồ sơ lưu trữ', 'Organize client folders in the filing cabinet. (Sắp xếp kẹp hồ sơ khách hàng vào tủ lưu trữ.)', false, NOW()),
  (v_deck_id, 'ergonomic', '/ˌɜː.ɡəˈnɒm.ɪk/', 'công thái học bảo vệ lưng', 'Adjustable ergonomic office desk chair. (Ghế văn phòng công thái học điều chỉnh được độ cao.)', false, NOW()),
  (v_deck_id, 'cluttered', '/ˈklʌt.əd/', 'bừa bộn lộn xộn', 'Keep desk clean and uncluttered. (Giữ bàn làm việc sạch sẽ và không bừa bộn.)', false, NOW()),
  (v_deck_id, 'receptionist', '/rɪˈsep.ʃən.ɪst/', 'nhân viên lễ tân', 'The front receptionist greeted company visitors. (Nhân viên lễ tân phía trước đã chào đón khách đến công ty.)', false, NOW()),
  (v_deck_id, 'maintenance', '/ˈmeɪn.tən.əns/', 'bảo trì sửa chữa máy', 'Elevators undergoing routine monthly maintenance. (Thang máy đang được bảo trì sửa chữa định kỳ hàng tháng.)', false, NOW()),
  (v_deck_id, 'reimbursement', '/ˌriː.ɪmˈbɜːs.mənt/', 'hoàn trả chi phí công tác', 'Submit travel receipts for expense reimbursement. (Nộp hóa đơn đi lại để nhận hoàn tiền công tác phí.)', false, NOW()),
  (v_deck_id, 'cubicle', '/ˈkjuː.bɪ.kəl/', 'ngăn bàn làm việc riêng', 'Employees work in partitioned office cubicles. (Nhân viên làm việc trong các ngăn bàn làm việc có vách ngăn.)', false, NOW()),
  (v_deck_id, 'inventory', '/ˈɪn.vən.tər.i/', 'kiểm kê đồ dùng', 'Count office supplies supply inventory. (Kiểm kê số lượng đồ dùng văn phòng tồn kho.)', false, NOW()),
  (v_deck_id, 'shred', '/ʃred/', 'cắt vụn giấy tờ', 'Shred confidential customer records securely. (Cắt vụn hồ sơ khách hàng mật một cách an toàn.)', false, NOW()),
  (v_deck_id, 'jam', '/dʒæm/', 'kẹt giấy máy in', 'Clear the paper jam inside the laser printer. (Gỡ bỏ phần giấy bị kẹt bên trong máy in laser.)', false, NOW());

  -- Bài 53: TOEIC - Bài 5: Mua Sắm & Đặt Hàng
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('TOEIC - Bài 5: Mua Sắm & Đặt Hàng', '50 chủ đề TOEIC thiết yếu - Bài 5: Mua bán, hóa đơn, chiết khấu và kho bãi.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'invoice', '/ˈɪn.vɔɪs/', 'hóa đơn thanh toán', 'Send an itemized invoice to the client. (Gửi hóa đơn thanh toán chi tiết cho khách hàng.)', false, NOW()),
  (v_deck_id, 'purchase order', '/ˈpɜː.tʃəs ˌɔː.dər/', 'đơn đặt hàng (PO)', 'Approve the official purchase order form. (Phê duyệt biểu mẫu đơn đặt hàng chính thức.)', false, NOW()),
  (v_deck_id, 'discount', '/ˈdɪs.kaʊnt/', 'chiết khấu giảm giá', 'Offer a 10 percent volume discount. (Đưa ra mức chiết khấu giảm giá 10% cho số lượng lớn.)', false, NOW()),
  (v_deck_id, 'quote', '/kwəʊt/', 'bảng báo giá', 'Request a price quote from the supplier. (Yêu cầu bảng báo giá từ nhà cung cấp.)', false, NOW()),
  (v_deck_id, 'supplier', '/səˈplaɪ.ər/', 'nhà cung ứng hàng', 'Source materials from reliable local suppliers. (Nhập vật liệu từ các nhà cung ứng địa phương uy tín.)', false, NOW()),
  (v_deck_id, 'vendor', '/ˈven.dər/', 'bên bán hàng / nhà thầu', 'Select preferred software technology vendor. (Lựa chọn nhà bán hàng công nghệ phần mềm ưu tiên.)', false, NOW()),
  (v_deck_id, 'bulk', '/bʌlk/', 'số lượng lớn hàng hóa', 'Buying in bulk reduces unit packaging cost. (Mua hàng với số lượng lớn giúp giảm chi phí đóng gói từng đơn vị.)', false, NOW()),
  (v_deck_id, 'catalogue', '/ˈkæt.əl.ɒɡ/', 'danh mục sản phẩm', 'Browse the new office furniture catalogue. (Xem qua danh mục sản phẩm nội thất văn phòng mới.)', false, NOW()),
  (v_deck_id, 'requisition', '/ˌrek.wɪˈzɪʃ.ən/', 'phiếu yêu cầu mua hàng', 'Fill out an equipment purchase requisition. (Điền vào phiếu yêu cầu mua sắm trang thiết bị.)', false, NOW()),
  (v_deck_id, 'backorder', '/ˈbækˌɔː.dər/', 'đơn hàng chờ nhập kho', 'Item is on backorder until next month. (Mặt hàng này đang chờ nhập thêm vào kho tháng tới.)', false, NOW()),
  (v_deck_id, 'receipt', '/rɪˈsiːt/', 'biên lai thu tiền', 'Keep the cash register payment receipt. (Giữ lại biên lai thanh toán từ máy tính tiền.)', false, NOW()),
  (v_deck_id, 'warranty', '/ˈwɒr.ən.ti/', 'bảo hành sản phẩm', 'Electronics covered by two-year warranty. (Đồ điện tử được bảo hành chính hãng trong hai năm.)', false, NOW()),
  (v_deck_id, 'refund', '/ˈriː.fʌnd/', 'hoàn lại tiền', 'Issue full refund for defective item. (Hoàn lại toàn bộ tiền cho sản phẩm bị lỗi.)', false, NOW()),
  (v_deck_id, 'merchandise', '/ˈmɜː.tʃən.daɪs/', 'hàng hóa trưng bày', 'Display promotional merchandise on store shelves. (Trưng bày hàng hóa khuyến mãi trên các kệ hàng.)', false, NOW()),
  (v_deck_id, 'estimate', '/ˈes.tɪ.meɪt/', 'bản ước tính chi phí', 'Provide cost estimate for building renovation. (Cung cấp bản ước tính chi phí cải tạo tòa nhà.)', false, NOW());

  -- Bài 54: TOEIC - Bài 6: Chăm Sóc Khách Hàng
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('TOEIC - Bài 6: Chăm Sóc Khách Hàng', '50 chủ đề TOEIC thiết yếu - Bài 6: Khiếu nại, phản hồi và sự hài lòng.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'inquiry', '/ɪnˈkwaɪə.ri/', 'yêu cầu hỏi thông tin', 'Respond promptly to customer product inquiries. (Phản hồi nhanh chóng các yêu cầu hỏi thông tin sản phẩm.)', false, NOW()),
  (v_deck_id, 'complaint', '/kəmˈpleɪnt/', 'khiếu nại phàn nàn', 'Handle customer service service complaints politely. (Xử lý các khiếu nại dịch vụ khách hàng một cách lịch sự.)', false, NOW()),
  (v_deck_id, 'satisfaction', '/ˌsæt.ɪsˈfæk.ʃən/', 'sự hài lòng của khách', 'Measure client overall satisfaction scores. (Đo lường điểm số mức độ hài lòng tổng thể của khách hàng.)', false, NOW()),
  (v_deck_id, 'feedback', '/ˈfiːd.bæk/', 'ý kiến đóng góp', 'We value your valuable product feedback. (Chúng tôi rất trân trọng những ý kiến đóng góp quý báu của bạn.)', false, NOW()),
  (v_deck_id, 'resolve', '/rɪˈzɒlv/', 'giải quyết ổn thỏa', 'Support agent resolved technical billing issue. (Nhân viên hỗ trợ đã giải quyết ổn thỏa sự cố thanh toán kỹ thuật.)', false, NOW()),
  (v_deck_id, 'courteous', '/ˈkɜː.ti.əs/', 'lịch sự nhã nhặn', 'Always maintain a courteous tone on phone. (Luôn giữ giọng điệu lịch sự nhã nhặn khi nghe điện thoại.)', false, NOW()),
  (v_deck_id, 'loyalty', '/ˈlɔɪ.əl.ti/', 'lòng trung thành khách', 'Reward customer loyalty with point discounts. (Thưởng cho lòng trung thành của khách bằng điểm giảm giá.)', false, NOW()),
  (v_deck_id, 'promptly', '/ˈprɒmpt.li/', 'kịp thời / ngay tức khắc', 'Emails should be answered promptly within hours. (Email cần được trả lời kịp thời trong vòng vài giờ.)', false, NOW()),
  (v_deck_id, 'apologize', '/əˈpɒl.ə.dʒaɪz/', 'xin lỗi chân thành', 'Apologize for unexpected shipment delivery delay. (Xin lỗi vì sự cố giao hàng chậm trễ ngoài dự kiến.)', false, NOW()),
  (v_deck_id, 'representative', '/ˌrep.rɪˈzen.tə.tɪv/', 'đại diện chăm sóc khách', 'Speak directly to a customer representative. (Nói chuyện trực tiếp với đại diện chăm sóc khách hàng.)', false, NOW()),
  (v_deck_id, 'survey', '/ˈsɜː.veɪ/', 'phiếu khảo sát ý kiến', 'Complete short post-call customer survey. (Hoàn thành bài khảo sát ý kiến ngắn sau cuộc gọi.)', false, NOW()),
  (v_deck_id, 'escalate', '/ˈes.kə.leɪt/', 'chuyển cấp cao hơn giải quyết', 'Escalate unresolved tickets to tier-two support. (Chuyển các yêu cầu chưa giải quyết lên cấp hỗ trợ 2.)', false, NOW()),
  (v_deck_id, 'patron', '/ˈpeɪ.trən/', 'khách hàng quen thuộc', 'Thank regular patrons for continued business. (Cảm ơn các khách hàng quen thuộc đã luôn ủng hộ kinh doanh.)', false, NOW()),
  (v_deck_id, 'compensate', '/ˈkɒm.pən.seɪt/', 'đền bù thiệt hại', 'Compensate customer with a free meal voucher. (Đền bù thiệt hại cho khách bằng phiếu ăn miễn phí.)', false, NOW()),
  (v_deck_id, 'reputation', '/ˌrep.jəˈteɪ.ʃən/', 'uy tín thương hiệu', 'Good service builds an outstanding business reputation. (Dịch vụ tốt xây dựng uy tín kinh doanh vượt trội.)', false, NOW());

  -- Bài 55: TOEIC - Bài 7: Vận Chuyển & Giao Hàng
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('TOEIC - Bài 7: Vận Chuyển & Giao Hàng', '50 chủ đề TOEIC thiết yếu - Bài 7: Vận chuyển, bưu điện và kho bãi.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'shipment', '/ˈʃɪp.mənt/', 'chuyến hàng / kiện hàng', 'Track international cargo package shipment. (Theo dõi lộ trình chuyến hàng kiện hàng quốc tế.)', false, NOW()),
  (v_deck_id, 'courier', '/ˈkʊr.i.ər/', 'người chuyển phát nhanh', 'Courier delivered urgent contract to headquarters. (Người chuyển phát nhanh đã giao hợp đồng khẩn đến trụ sở.)', false, NOW()),
  (v_deck_id, 'fragile', '/ˈfrædʒ.aɪl/', 'dễ vỡ cẩn thận', 'Label glass parcel box as fragile. (Dán nhãn hàng dễ vỡ lên hộp bưu kiện thủy tinh.)', false, NOW()),
  (v_deck_id, 'express', '/ɪkˈspres/', 'chuyển phát hỏa tốc', 'Choose overnight express mail shipping. (Chọn hình thức giao thư hỏa tốc qua đêm.)', false, NOW()),
  (v_deck_id, 'tracking', '/ˈtræk.ɪŋ/', 'mã theo dõi bưu kiện', 'Enter parcel tracking number online. (Nhập mã theo dõi bưu kiện trực tuyến.)', false, NOW()),
  (v_deck_id, 'postage', '/ˈpəʊ.stɪdʒ/', 'cước phí bưu điện', 'Calculate international airmail envelope postage. (Tính toán cước phí bưu điện phong bì thư quốc tế.)', false, NOW()),
  (v_deck_id, 'recipient', '/rɪˈsɪp.i.ənt/', 'người nhận bưu phẩm', 'Package signed by the intended recipient. (Bưu phẩm đã được người nhận dự kiến ký nhận.)', false, NOW()),
  (v_deck_id, 'dispatcher', '/dɪˈspætʃ.ər/', 'điều phối viên vận tải', 'Freight dispatcher coordinates truck driver routes. (Điều phối viên vận tải phân chia tuyến đường cho tài xế xe tải.)', false, NOW()),
  (v_deck_id, 'destination', '/ˌdes.tɪˈneɪ.ʃən/', 'điểm đến giao hàng', 'Arrive safely at final delivery destination. (Đến nơi an toàn tại điểm giao hàng cuối cùng.)', false, NOW()),
  (v_deck_id, 'customs duty', '/ˈkʌs.təmz ˌdjuː.ti/', 'thuế hải quan nhập khẩu', 'Pay import customs duty before parcel pickup. (Nộp thuế hải quan nhập khẩu trước khi nhận bưu phẩm.)', false, NOW()),
  (v_deck_id, 'consignment', '/kənˈsaɪn.mənt/', 'lô hàng vận tải', 'Consignment delayed due to harbor storm. (Lô hàng bị hoãn giao do bão lớn ở bến cảng.)', false, NOW()),
  (v_deck_id, 'air freight', '/ˈeə ˌfreɪt/', 'vận chuyển đường hàng không', 'Ship perishable flowers via air freight. (Vận chuyển hoa tươi dễ hỏng bằng đường hàng không.)', false, NOW()),
  (v_deck_id, 'clearance', '/ˈklɪə.rəns/', 'thông quan hàng hóa', 'Customs clearance took three business days. (Việc thông quan hải quan mất ba ngày làm việc.)', false, NOW()),
  (v_deck_id, 'damage', '/ˈdæm.ɪdʒ/', 'hư hỏng tổn thất', 'Inspect carton boxes for shipping damage. (Kiểm tra xem thùng carton có bị hư hỏng do vận chuyển không.)', false, NOW()),
  (v_deck_id, 'overnight', '/ˌəʊ.vəˈnaɪt/', 'giao ngay qua đêm', 'Guaranteed overnight parcel delivery service. (Dịch vụ cam kết giao bưu kiện ngay qua đêm.)', false, NOW());

  -- Bài 56: TOEIC - Bài 8: Khách Sạn & Đặt Phòng
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('TOEIC - Bài 8: Khách Sạn & Đặt Phòng', '50 chủ đề TOEIC thiết yếu - Bài 8: Lưu trú, dịch vụ khách sạn và phòng nghỉ.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'reservation', '/ˌrez.əˈveɪ.ʃən/', 'đặt phòng trước', 'Confirm hotel luxury suite room reservation. (Xác nhận việc đặt phòng trước hạng sang tại khách sạn.)', false, NOW()),
  (v_deck_id, 'vacancy', '/ˈveɪ.kən.si/', 'phòng còn trống', 'No room vacancy during summer holiday. (Không còn phòng trống nào trong kỳ nghỉ hè.)', false, NOW()),
  (v_deck_id, 'amenity', '/əˈmen.ə.ti/', 'tiện ích dịch vụ', 'Resort amenities include swimming pool and spa. (Tiện ích khu nghỉ dưỡng bao gồm hồ bơi và spa.)', false, NOW()),
  (v_deck_id, 'check-in', '/ˈtʃek.ɪn/', 'nhận phòng làm thủ tục', 'Hotel guest check-in starts at 2 PM. (Giờ làm thủ tục nhận phòng khách sạn bắt đầu từ 2 giờ chiều.)', false, NOW()),
  (v_deck_id, 'check-out', '/ˈtʃek.aʊt/', 'trả phòng thanh toán', 'Request a late hotel check-out time. (Xin gia hạn thời gian trả phòng muộn hơn.)', false, NOW()),
  (v_deck_id, 'housekeeping', '/ˈhaʊsˌkiː.pɪŋ/', 'dọn phòng buồng phòng', 'Housekeeping changes bed sheets daily. (Bộ phận dọn phòng thay ga trải giường hàng ngày.)', false, NOW()),
  (v_deck_id, 'complimentary', '/ˌkɒm.plɪˈmen.tər.i/', 'miễn phí kèm theo', 'Enjoy complimentary continental buffet breakfast. (Thưởng thức bữa sáng tự chọn miễn phí kèm theo.)', false, NOW()),
  (v_deck_id, 'concierge', '/kɒn.siˈeəʒ/', 'nhân viên hỗ trợ du khách', 'Concierge booked theater performance tickets. (Nhân viên hỗ trợ du khách đã đặt vé xem kịch.)', false, NOW()),
  (v_deck_id, 'accommodate', '/əˈkɒm.ə.deɪt/', 'đáp ứng chỗ ở cho', 'Hotel can accommodate up to 500 guests. (Khách sạn có thể đáp ứng chỗ ở cho tối đa 500 khách.)', false, NOW()),
  (v_deck_id, 'suite', '/swiːt/', 'phòng cao cấp liên hoàn', 'Book a presidential suite with ocean view. (Đặt phòng cao cấp tổng thống hướng nhìn ra biển.)', false, NOW()),
  (v_deck_id, 'deposit', '/dɪˈpɒz.ɪt/', 'tiền đặt cọc giữ phòng', 'Pay one night room advance deposit. (Thanh toán tiền đặt cọc trước một đêm tiền phòng.)', false, NOW()),
  (v_deck_id, 'bellhop', '/ˈbel.hɒp/', 'nhân viên xách hành lý', 'Tip the hotel bellhop for carrying bags. (Bồi dưỡng tiền cho nhân viên xách hành lý lên phòng.)', false, NOW()),
  (v_deck_id, 'minibar', '/ˈmɪn.i.bɑːr/', 'tủ lạnh mini trong phòng', 'Drinks in room minibar incur extra charges. (Đồ uống trong tủ lạnh mini phòng sẽ tính thêm phí.)', false, NOW()),
  (v_deck_id, 'valet', '/ˈvæl.eɪ/', 'dịch vụ đỗ xe cho khách', 'Hand car keys to hotel valet parking. (Giao chìa khóa xe cho nhân viên đỗ xe hộ của khách sạn.)', false, NOW()),
  (v_deck_id, 'adjoining', '/əˈdʒɔɪ.nɪŋ/', 'phòng thông nhau kế bên', 'Family booked two adjoining hotel rooms. (Gia đình đã đặt hai phòng có cửa thông nhau kế bên.)', false, NOW());

  -- Bài 57: TOEIC - Bài 9: Ẩm Thực & Tiếp Khách
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('TOEIC - Bài 9: Ẩm Thực & Tiếp Khách', '50 chủ đề TOEIC thiết yếu - Bài 9: Nhà hàng, tiệc tối và tiếp đãi đối tác.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'appetizer', '/ˈæp.ə.taɪ.zər/', 'món khai vị', 'Order shrimp salad as dinner appetizer. (Gọi món salad tôm làm món khai vị cho bữa tối.)', false, NOW()),
  (v_deck_id, 'entree', '/ˈɒn.treɪ/', 'món ăn chính', 'Grilled salmon is tonight chef entree. (Cá hồi nướng là món ăn chính tối nay của bếp trưởng.)', false, NOW()),
  (v_deck_id, 'beverage', '/ˈbev.ər.ɪdʒ/', 'đồ uống giải khát', 'Complimentary cold beverage served upon arrival. (Đồ uống giải khát mát lạnh miễn phí phục vụ khi đến.)', false, NOW()),
  (v_deck_id, 'banquet', '/ˈbæŋ.kwɪt/', 'bữa tiệc lớn sang trọng', 'Host annual corporate awards banquet. (Tổ chức bữa tiệc lớn trao giải thưởng thường niên công ty.)', false, NOW()),
  (v_deck_id, 'catering', '/ˈkeɪ.tər.ɪŋ/', 'dịch vụ tiệc lưu động', 'Hire external catering for wedding reception. (Thuê dịch vụ tiệc lưu động bên ngoài cho tiệc cưới.)', false, NOW()),
  (v_deck_id, 'cuisine', '/kwɪˈziːn/', 'ẩm thực / phong cách nấu', 'Restaurant specializes in authentic Italian cuisine. (Nhà hàng chuyên về ẩm thực phong cách Ý truyền thống.)', false, NOW()),
  (v_deck_id, 'dietary', '/ˈdaɪ.ə.tər.i/', 'chế độ ăn kiêng', 'Inform waiter of specific dietary restrictions. (Thông báo cho bồi bàn biết về chế độ ăn kiêng riêng biệt.)', false, NOW()),
  (v_deck_id, 'dessert', '/dɪˈzɜːt/', 'món tráng miệng', 'Chocolate lava cake for sweet dessert. (Bánh sô-cô-la chảy làm món tráng miệng ngọt ngào.)', false, NOW()),
  (v_deck_id, 'hospitality', '/ˌhɒs.pɪˈtæl.ə.ti/', 'sự hiếu khách tiếp đón', 'Thank business partner for generous hospitality. (Cảm ơn đối tác kinh doanh vì sự tiếp đón nồng hậu.)', false, NOW()),
  (v_deck_id, 'buffet', '/ˈbʊf.eɪ/', 'tiệc tự chọn món', 'Help yourself to the seafood buffet. (Mời bạn tự do lấy thức ăn tại quầy tiệc tự chọn hải sản.)', false, NOW()),
  (v_deck_id, 'gratuity', '/ɡrəˈtʃuː.ə.ti/', 'tiền boa / tiền phục vụ', 'Bill includes an 18 percent gratuity. (Hóa đơn đã bao gồm 18% tiền phục vụ tip.)', false, NOW()),
  (v_deck_id, 'sommelier', '/sɒmˈel.jeɪ/', 'chuyên gia nếm rượu vang', 'Sommelier recommended a fine red wine. (Chuyên gia nếm rượu đã gợi ý một loại vang đỏ hảo hạng.)', false, NOW()),
  (v_deck_id, 'culinary', '/ˈkʌl.ɪ.nər.i/', 'thuộc về nấu nướng ẩm thực', 'Chef won international culinary arts awards. (Bếp trưởng đoạt giải thưởng nghệ thuật ẩm thực quốc tế.)', false, NOW()),
  (v_deck_id, 'delicacy', '/ˈdel.ɪ.kə.si/', 'món đặc sản sơn hào hải vị', 'Caviar is considered a luxury delicacy. (Trứng cá tầm được coi là món đặc sản xa xỉ.)', false, NOW()),
  (v_deck_id, 'patronage', '/ˈpæt.rə.nɪdʒ/', 'sự lui tới ủng hộ quán', 'We appreciate your loyal dining patronage. (Chúng tôi rất trân trọng sự lui tới ủng hộ quán của quý khách.)', false, NOW());

  -- Bài 58: TOEIC - Bài 10: Hàng Không & Đi Công Tác
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('TOEIC - Bài 10: Hàng Không & Đi Công Tác', '50 chủ đề TOEIC thiết yếu - Bài 10: Sân bay, chuyến bay và vé máy bay.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'boarding pass', '/ˈbɔː.dɪŋ ˌpɑːs/', 'thẻ lên máy bay', 'Show your mobile boarding pass at the gate. (Xuất trình thẻ lên máy bay trên điện thoại tại cổng.)', false, NOW()),
  (v_deck_id, 'itinerary', '/aɪˈtɪn.ər.ər.i/', 'lịch trình chuyến đi', 'Travel agent sent the business trip itinerary. (Đại lý du lịch đã gửi lịch trình chuyến đi công tác.)', false, NOW()),
  (v_deck_id, 'layover', '/ˈleɪˌəʊ.vər/', 'thời gian quá cảnh transit', 'Three-hour layover in Tokyo Narita airport. (Thời gian quá cảnh 3 tiếng tại sân bay Narita Tokyo.)', false, NOW()),
  (v_deck_id, 'baggage claim', '/ˈbæɡ.ɪdʒ ˌkleɪm/', 'khu nhận lại hành lý ký gửi', 'Collect suitcases at baggage claim belt 4. (Nhận va li tại băng chuyền khu nhận hành lý số 4.)', false, NOW()),
  (v_deck_id, 'departure', '/dɪˈpɑː.tʃər/', 'giờ khởi hành cất cánh', 'Flight departure delayed by one hour. (Giờ khởi hành chuyến bay bị trễ một tiếng đồng hồ.)', false, NOW()),
  (v_deck_id, 'arrival', '/əˈraɪ.vəl/', 'giờ máy bay hạ cánh', 'Check estimated flight arrival screen. (Kiểm tra màn hình dự kiến giờ máy bay hạ cánh.)', false, NOW()),
  (v_deck_id, 'carry-on', '/ˈkær.i.ɒn/', 'hành lý xách tay', 'One small carry-on bag allowed in cabin. (Cho phép mang một kiện hành lý xách tay nhỏ vào khoang.)', false, NOW()),
  (v_deck_id, 'customs', '/ˈkʌs.təmz/', 'hải quan sân bay', 'Declare luxury goods at airport customs. (Khai báo hàng xa xỉ tại hải quan sân bay.)', false, NOW()),
  (v_deck_id, 'terminal', '/ˈtɜː.mɪ.nəl/', 'nhà ga sân bay', 'International flights depart from Terminal 2. (Các chuyến bay quốc tế cất cánh từ Nhà ga T2.)', false, NOW()),
  (v_deck_id, 'shuttle', '/ˈʃʌt.əl/', 'xe buýt đưa đón sân bay', 'Take free hotel airport shuttle bus. (Đi xe buýt đưa đón sân bay miễn phí của khách sạn.)', false, NOW()),
  (v_deck_id, 'standby', '/ˈstænd.baɪ/', 'vé chờ chỗ giờ chót', 'Passenger flew on standby for earlier flight. (Hành khách bay theo vé chờ giờ chót cho chuyến bay sớm hơn.)', false, NOW()),
  (v_deck_id, 'jet lag', '/ˈdʒet ˌlæɡ/', 'mệt mỏi do lệch múi giờ', 'Drink water to recover from transatlantic jet lag. (Uống nước để hồi phục sau chứng lệch múi giờ bay qua Đại Tây Dương.)', false, NOW()),
  (v_deck_id, 'overhead bin', '/ˌəʊ.və.hed ˈbɪn/', 'khoang để hành lý trên đầu', 'Stow backpack securely in overhead bin. (Cất ba lô gọn gàng vào khoang để hành lý phía trên đầu.)', false, NOW()),
  (v_deck_id, 'aisle', '/aɪl/', 'lối đi giữa các hàng ghế', 'Passenger preferred an aisle seat over window. (Hành khách thích ghế cạnh lối đi hơn ghế cạnh cửa sổ.)', false, NOW()),
  (v_deck_id, 'turbulence', '/ˈtɜː.bjə.ləns/', 'rung lắc nhiễu động', 'Flight experienced minor turbulence over mountains. (Chuyến bay gặp rung lắc nhiễu động nhẹ khi qua vùng núi.)', false, NOW());

  -- Bài 59: TOEIC - Bài 11: Ngân Hàng & Thanh Toán Doanh Nghiệp
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('TOEIC - Bài 11: Ngân Hàng & Thanh Toán Doanh Nghiệp', '50 chủ đề TOEIC thiết yếu - Bài 11: Thanh toán, chuyển khoản và sao kê.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'statement', '/ˈsteɪt.mənt/', 'sao kê tài khoản', 'Download monthly bank account statement. (Tải xuống bản sao kê tài khoản ngân hàng hàng tháng.)', false, NOW()),
  (v_deck_id, 'balance', '/ˈbæl.əns/', 'số dư tài khoản', 'Maintain minimum required checking balance. (Duy trì số dư tối thiểu bắt buộc trong tài khoản vãng lai.)', false, NOW()),
  (v_deck_id, 'transaction', '/trænˈzæk.ʃən/', 'giao dịch chuyển tiền', 'ATM transaction receipt printed out. (Biên lai giao dịch rút tiền tại cây ATM đã được in ra.)', false, NOW()),
  (v_deck_id, 'teller', '/ˈtel.ər/', 'giao dịch viên ngân hàng', 'Bank teller helped cash the foreign check. (Giao dịch viên ngân hàng đã hỗ trợ rút tiền mặt từ séc ngoại tệ.)', false, NOW()),
  (v_deck_id, 'withdrawal', '/wɪðˈdrɔː.əl/', 'rút tiền mặt', 'Make a daily cash ATM withdrawal. (Thực hiện rút tiền mặt hàng ngày tại cây ATM.)', false, NOW()),
  (v_deck_id, 'transfer', '/trænsˈfɜːr/', 'chuyển khoản tiền', 'Transfer funds between corporate accounts. (Chuyển tiền qua lại giữa các tài khoản doanh nghiệp.)', false, NOW()),
  (v_deck_id, 'overdraft', '/ˈəʊ.və.drɑːft/', 'thấu chi ngân hàng', 'Bank approved short-term overdraft facility. (Ngân hàng đã phê duyệt hạn mức thấu chi ngắn hạn.)', false, NOW()),
  (v_deck_id, 'interest', '/ˈɪn.trəst/', 'tiền lãi sinh lời', 'Savings account earns 5 percent annual interest. (Tài khoản tiết kiệm sinh tiền lãi 5% mỗi năm.)', false, NOW()),
  (v_deck_id, 'direct debit', '/daɪˌrekt ˈdeb.ɪt/', 'trích nợ tự động tài khoản', 'Pay monthly electricity bill via direct debit. (Thanh toán tiền điện hàng tháng qua trích nợ tự động.)', false, NOW()),
  (v_deck_id, 'wire', '/waɪər/', 'chuyển khoản điện tín', 'Wire money to overseas supplier immediately. (Chuyển tiền điện tín sang cho nhà cung cấp nước ngoài ngay.)', false, NOW()),
  (v_deck_id, 'currency', '/ˈkʌr.ən.si/', 'tiền tệ ngoại hối', 'Exchange local currency at airport bank. (Đổi tiền tệ địa phương tại quầy ngân hàng sân bay.)', false, NOW()),
  (v_deck_id, 'exchange rate', '/ɪksˈtʃeɪndʒ reɪt/', 'tỷ giá hối đoái', 'Favorable USD to VND foreign exchange rate. (Tỷ giá hối đoái ngoại tệ USD sang VND đang rất có lợi.)', false, NOW()),
  (v_deck_id, 'remittance', '/rɪˈmɪt.əns/', 'chuyển tiền kiều hối', 'Send family financial remittance overseas. (Gửi tiền kiều hối tài chính về cho gia đình ở nước ngoài.)', false, NOW()),
  (v_deck_id, 'check', '/tʃek/', 'tờ séc thanh toán', 'Write a payment check for supplier. (Viết một tờ séc thanh toán cho nhà cung cấp.)', false, NOW()),
  (v_deck_id, 'ledger', '/ˈledʒ.ər/', 'sổ theo dõi thu chi', 'Accountant audited internal company cash ledger. (Kế toán đã kiểm toán sổ theo dõi thu chi tiền mặt nội bộ.)', false, NOW());

  -- Bài 60: TOEIC - Bài 12: Kế Hoạch & Mục Tiêu Kinh Doanh
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('TOEIC - Bài 12: Kế Hoạch & Mục Tiêu Kinh Doanh', '50 chủ đề TOEIC thiết yếu - Bài 12: Chiến lược, cột mốc và mục tiêu kinh doanh.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'strategy', '/ˈstræt.ə.dʒi/', 'chiến lược kinh doanh', 'Develop aggressive digital marketing strategy. (Phát triển chiến lược tiếp thị kỹ thuật số đột phá.)', false, NOW()),
  (v_deck_id, 'objective', '/əbˈdʒek.tɪv/', 'mục tiêu trọng tâm', 'Achieve core quarterly business profit objectives. (Đạt được các mục tiêu lợi nhuận kinh doanh trọng tâm theo quý.)', false, NOW()),
  (v_deck_id, 'milestone', '/ˈmaɪl.stəʊn/', 'cột mốc quan trọng', 'Project reached its first major milestone on time. (Dự án đã đạt được cột mốc quan trọng đầu tiên đúng hạn.)', false, NOW()),
  (v_deck_id, 'benchmark', '/ˈbentʃ.mɑːk/', 'tiêu chuẩn đối chuẩn', 'Measure performance against industry competitor benchmark. (Đo lường hiệu suất dựa trên tiêu chuẩn đối chuẩn của đối thủ.)', false, NOW()),
  (v_deck_id, 'forecast', '/ˈfɔː.kɑːst/', 'dự báo tương lai', 'Economic forecast predicts double-digit growth. (Dự báo kinh tế đưa ra mức tăng trưởng hai con số.)', false, NOW()),
  (v_deck_id, 'expansion', '/ɪkˈspæn.ʃən/', 'mở rộng quy mô thị trường', 'Plan aggressive retail store market expansion. (Lên kế hoạch mở rộng thị trường chuỗi cửa hàng bán lẻ.)', false, NOW()),
  (v_deck_id, 'feasibility', '/ˌfiː.zəˈbɪl.ə.ti/', 'tính khả thi dự án', 'Conduct comprehensive factory construction feasibility study. (Tiến hành nghiên cứu tính khả thi xây dựng nhà máy.)', false, NOW()),
  (v_deck_id, 'contingency', '/kənˈtɪn.dʒən.si/', 'kế hoạch dự phòng rủi ro', 'Prepare contingency plan for supply disruptions. (Chuẩn bị kế hoạch dự phòng cho sự cố gián đoạn nguồn cung.)', false, NOW()),
  (v_deck_id, 'target', '/ˈtɑː.ɡɪt/', 'chỉ tiêu cần đạt', 'Exceed annual commercial sales revenue targets. (Vượt chỉ tiêu doanh thu bán hàng thương mại hàng năm.)', false, NOW()),
  (v_deck_id, 'initiative', '/ɪˈnɪʃ.ə.tɪv/', 'sáng kiến đổi mới', 'Launch green eco-friendly corporate initiative. (Phát động sáng kiến thân thiện với môi trường của doanh nghiệp.)', false, NOW()),
  (v_deck_id, 'streamline', '/ˈstriːm.laɪn/', 'tinh gọn quy trình', 'Streamline customer onboarding software workflow. (Tinh gọn quy trình phần mềm tiếp nhận khách hàng mới.)', false, NOW()),
  (v_deck_id, 'diversify', '/daɪˈvɜː.sɪ.faɪ/', 'đa dạng hóa sản phẩm', 'Diversify company investment and product portfolio. (Đa dạng hóa danh mục đầu tư và sản phẩm của công ty.)', false, NOW()),
  (v_deck_id, 'deliverable', '/dɪˈlɪv.ər.ə.bəl/', 'sản phẩm bàn giao dự án', 'Submit all final consulting project deliverables. (Bàn giao tất cả các sản phẩm dự án tư vấn cuối cùng.)', false, NOW()),
  (v_deck_id, 'sustainable', '/səˈsteɪ.nə.bəl/', 'phát triển bền vững', 'Ensure long-term sustainable corporate profit growth. (Đảm bảo tăng trưởng lợi nhuận doanh nghiệp bền vững lâu dài.)', false, NOW()),
  (v_deck_id, 'timeline', '/ˈtaɪm.laɪn/', 'tiến độ thời gian', 'Stick strictly to the planned project timeline. (Tuân thủ nghiêm ngặt theo đúng tiến độ thời gian của dự án.)', false, NOW());

  -- =========================================================
  -- KHỐI: IELTS_ACADEMIC.JSON (10 bài học)
  -- =========================================================

  -- Bài 61: IELTS Academic - Bài 1: Môi Trường & Khí Hậu
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('IELTS Academic - Bài 1: Môi Trường & Khí Hậu', 'Từ vựng IELTS Band 7.0+ về biến đổi khí hậu, sinh thái và năng lượng.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'degradation', '/ˌdeɡ.rəˈdeɪ.ʃən/', 'suy thoái môi trường', 'Soil degradation threatens global food security. (Suy thoái đất đai đe dọa an ninh lương thực toàn cầu.)', false, NOW()),
  (v_deck_id, 'emissions', '/iˈmɪʃ.ənz/', 'khí thải độc hại', 'Reduce industrial greenhouse gas emissions. (Cắt giảm lượng khí thải nhà kính trong công nghiệp.)', false, NOW()),
  (v_deck_id, 'sustainable', '/səˈsteɪ.nə.bəl/', 'bền vững sinh thái', 'Adopt sustainable agriculture farming methods. (Áp dụng các phương pháp canh tác nông nghiệp bền vững.)', false, NOW()),
  (v_deck_id, 'biodiversity', '/ˌbaɪ.əʊ.daɪˈvɜː.sə.ti/', 'đa dạng sinh học', 'Deforestation threatens tropical rainforest biodiversity. (Phá rừng đe dọa sự đa dạng sinh học của rừng nhiệt đới.)', false, NOW()),
  (v_deck_id, 'renewable', '/rɪˈnjuː.ə.bəl/', 'năng lượng tái tạo', 'Invest heavily in renewable solar and wind power. (Đầu tư mạnh mẽ vào năng lượng mặt trời và gió tái tạo.)', false, NOW()),
  (v_deck_id, 'depletion', '/dɪˈpliː.ʃən/', 'sự cạn kiệt tài nguyên', 'Prevent groundwater resource depletion. (Ngăn chặn sự cạn kiệt nguồn tài nguyên nước ngầm.)', false, NOW()),
  (v_deck_id, 'contamination', '/kənˌtæm.ɪˈneɪ.ʃən/', 'sự ô nhiễm chất độc', 'Toxic chemical river contamination harmed fish. (Sự ô nhiễm hóa chất độc hại trên sông làm chết cá.)', false, NOW()),
  (v_deck_id, 'ecological', '/ˌiː.kəˈlɒdʒ.ɪ.kəl/', 'thuộc về sinh thái', 'Restore damaged coastal ecological balance. (Khôi phục lại sự cân bằng sinh thái ven biển bị tổn hại.)', false, NOW()),
  (v_deck_id, 'fossil fuel', '/ˈfɒs.əl ˌfjuː.əl/', 'nhiên liệu hóa thạch', 'Phasing out coal and oil fossil fuel power plants. (Từng bước loại bỏ các nhà máy điện dùng nhiên liệu hóa thạch.)', false, NOW()),
  (v_deck_id, 'conservation', '/ˌkɒn.səˈveɪ.ʃən/', 'bảo tồn thiên nhiên', 'Wildlife conservation programs save endangered animals. (Các chương trình bảo tồn động vật hoang dã cứu thú nguy cấp.)', false, NOW()),
  (v_deck_id, 'catastrophe', '/kəˈtæs.trə.fi/', 'thảm họa thiên tai', 'Floods triggered a regional environmental catastrophe. (Lũ lụt đã gây ra một thảm họa môi trường trên toàn khu vực.)', false, NOW()),
  (v_deck_id, 'precipitation', '/prɪˌsɪp.ɪˈteɪ.ʃən/', 'lượng mưa hàng năm', 'Region receives low annual rainfall precipitation. (Khu vực này nhận lượng mưa kết tủa hàng năm rất thấp.)', false, NOW()),
  (v_deck_id, 'arid', '/ˈær.ɪd/', 'khô cằn cằn cỗi', 'Crops struggle in harsh arid desert climates. (Cây trồng khó phát triển trong điều kiện khí hậu sa mạc khô cằn.)', false, NOW()),
  (v_deck_id, 'glacier', '/ˈɡlæs.i.ər/', 'sông băng tan chảy', 'Rising temperatures cause polar glaciers to melt. (Nhiệt độ tăng cao khiến các con sông băng ở vùng cực tan chảy.)', false, NOW()),
  (v_deck_id, 'carbon footprint', '/ˌkɑː.bən ˈfʊt.prɪnt/', 'dấu chân carbon', 'Flying less reduces your personal carbon footprint. (Ít đi máy bay hơn giúp giảm dấu chân carbon cá nhân của bạn.)', false, NOW());

  -- Bài 62: IELTS Academic - Bài 2: Giáo Dục & Sư Phạm
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('IELTS Academic - Bài 2: Giáo Dục & Sư Phạm', 'Từ vựng IELTS Band 7.0+ về hệ thống giáo dục, phương pháp giảng dạy.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'curriculum', '/kəˈrɪk.jə.ləm/', 'chương trình giảng dạy', 'Modernize national school science curriculum. (Hiện đại hóa chương trình giảng dạy khoa học trong trường học.)', false, NOW()),
  (v_deck_id, 'pedagogy', '/ˈped.ə.ɡɒdʒ.i/', 'khoa học sư phạm', 'Innovative student-centered classroom pedagogy. (Phương pháp sư phạm sáng tạo lấy học sinh làm trung tâm.)', false, NOW()),
  (v_deck_id, 'literacy', '/ˈlɪt.ər.ə.si/', 'khả năng biết chữ', 'Programs increased adult reading literacy rates. (Các chương trình đã nâng cao tỷ lệ biết đọc biết chữ ở người lớn.)', false, NOW()),
  (v_deck_id, 'cognition', '/kɒɡˈnɪʃ.ən/', 'nhận thức tư duy', 'Language learning enhances children brain cognition. (Học ngôn ngữ nâng cao khả năng nhận thức tư duy của não trẻ.)', false, NOW()),
  (v_deck_id, 'tertiary', '/ˈtɜː.ʃər.i/', 'giáo dục đại học (bậc 3)', 'Enroll in tertiary university education. (Theo học tại các bậc giáo dục đại học và cao đẳng.)', false, NOW()),
  (v_deck_id, 'rote learning', '/ˌrəʊt ˈlɜː.nɪŋ/', 'học vẹt thuộc lòng', 'Critical thinking is superior to mechanical rote learning. (Tư duy phản biện vượt trội hơn hẳn so với học vẹt máy móc.)', false, NOW()),
  (v_deck_id, 'vocational', '/vəʊˈkeɪ.ʃən.əl/', 'học nghề thực hành', 'Hands-on vocational technical school training. (Đào tạo kỹ thuật thực hành tại các trường dạy nghề.)', false, NOW()),
  (v_deck_id, 'plagiarism', '/ˈpleɪ.dʒər.ɪ.zəm/', 'đạo văn sao chép', 'Universities strictly penalize academic plagiarism. (Các trường đại học xử phạt nghiêm khắc hành vi đạo văn học thuật.)', false, NOW()),
  (v_deck_id, 'evaluation', '/ɪˌvæl.juˈeɪ.ʃən/', 'đánh giá kết quả', 'Comprehensive continuous student assessment evaluation. (Đánh giá toàn diện kết quả học tập liên tục của học sinh.)', false, NOW()),
  (v_deck_id, 'faculty', '/ˈfæk.əl.ti/', 'đội ngũ giảng viên', 'Distinguished university academic faculty professors. (Đội ngũ các giáo sư giảng viên đại học danh tiếng.)', false, NOW()),
  (v_deck_id, 'dissertation', '/ˌdɪs.əˈteɪ.ʃən/', 'luận văn tốt nghiệp', 'Defend doctoral dissertation before committee. (Bảo vệ luận văn tiến sĩ trước hội đồng chấm thi.)', false, NOW()),
  (v_deck_id, 'extracurricular', '/ˌek.strə.kəˈrɪk.jə.lər/', 'hoạt động ngoại khóa', 'Participate in sports extracurricular activities. (Tham gia vào các hoạt động thể thao ngoại khóa bổ ích.)', false, NOW()),
  (v_deck_id, 'tuition', '/tʃuːˈɪʃ.ən/', 'học phí đại học', 'Scholarships cover full university tuition fees. (Học bổng chi trả toàn bộ tiền học phí đại học.)', false, NOW()),
  (v_deck_id, 'alumni', '/əˈlʌm.naɪ/', 'cựu sinh viên', 'Network with successful university school alumni. (Kết nối mạng lưới với các cựu sinh viên thành đạt.)', false, NOW()),
  (v_deck_id, 'aptitude', '/ˈæp.tɪ.tʃuːd/', 'năng khiếu bẩm sinh', 'Standardized academic aptitude entry tests. (Các bài kiểm tra năng khiếu học thuật đầu vào chuẩn hóa.)', false, NOW());

  -- Bài 63: IELTS Academic - Bài 3: Đô Thị Hóa & Dân Số
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('IELTS Academic - Bài 3: Đô Thị Hóa & Dân Số', 'Từ vựng IELTS Band 7.0+ về phát triển thành phố, mật độ dân số.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'urbanization', '/ˌɜː.bən.aɪˈzeɪ.ʃən/', 'đô thị hóa', 'Rapid urbanization transforms rural provinces. (Đô thị hóa nhanh chóng làm biến đổi các tỉnh nông thôn.)', false, NOW()),
  (v_deck_id, 'infrastructure', '/ˈɪn.frəˌstrʌk.tʃər/', 'cơ sở hạ tầng', 'Upgrade public transport rail infrastructure. (Nâng cấp cơ sở hạ tầng đường sắt giao thông công cộng.)', false, NOW()),
  (v_deck_id, 'congestion', '/kənˈdʒes.tʃən/', 'ùn tắc giao thông', 'Subways relieve heavy downtown traffic congestion. (Tàu điện ngầm giúp giải tỏa ùn tắc giao thông khu trung tâm.)', false, NOW()),
  (v_deck_id, 'metropolis', '/məˈtrɒp.əl.ɪs/', 'siêu đô thị lớn', 'Tokyo is a bustling global metropolis. (Tokyo là một siêu đô thị toàn cầu nhộn nhịp.)', false, NOW()),
  (v_deck_id, 'sprawl', '/sprɔːl/', 'lan rộng đô thị bừa bãi', 'Suburban sprawl consumes surrounding farmland. (Đô thị lan rộng bừa bãi nuốt chửng đất nông nghiệp xung quanh.)', false, NOW()),
  (v_deck_id, 'density', '/ˈden.sə.ti/', 'mật độ dân số', 'High population density in inner city districts. (Mật độ dân số cao ở các quận nội thành.)', false, NOW()),
  (v_deck_id, 'demographic', '/ˌdem.əˈɡræf.ɪk/', 'nhân khẩu học', 'Aging population shifts national demographic trends. (Già hóa dân số làm thay đổi xu hướng nhân khẩu học quốc gia.)', false, NOW()),
  (v_deck_id, 'migration', '/maɪˈɡreɪ.ʃən/', 'di cư dân số', 'Rural-to-urban population labor migration. (Làn sóng di cư lao động từ nông thôn ra thành thị.)', false, NOW()),
  (v_deck_id, 'amenity', '/əˈmen.ə.ti/', 'tiện ích công cộng', 'Access to parks and cultural public amenities. (Tiếp cận các công viên và tiện ích văn hóa công cộng.)', false, NOW()),
  (v_deck_id, 'gentrification', '/ˌdʒen.trɪ.fɪˈkeɪ.ʃən/', 'chỉnh trang đô thị', 'Gentrification increases neighborhood housing rent. (Chỉnh trang đô thị làm tăng giá thuê nhà trong khu vực.)', false, NOW()),
  (v_deck_id, 'slum', '/slʌm/', 'khu ổ chuột nghèo', 'Upgrade basic sanitation in urban slums. (Nâng cấp điều kiện vệ sinh cơ bản trong các khu ổ chuột.)', false, NOW()),
  (v_deck_id, 'sanitation', '/ˌsæn.ɪˈteɪ.ʃən/', 'hệ thống vệ sinh nước thải', 'Clean drinking water and sewage sanitation. (Nước uống sạch và hệ thống vệ sinh xử lý nước thải.)', false, NOW()),
  (v_deck_id, 'commute', '/kəˈmjuːt/', 'đi lại làm việc hàng ngày', 'Long daily highway commute into the city. (Quãng đường đi lại làm việc hàng ngày dài trên đường cao tốc.)', false, NOW()),
  (v_deck_id, 'habitation', '/ˌhæb.ɪˈteɪ.ʃən/', 'nơi cư trú sinh sống', 'Build sustainable human space habitation. (Xây dựng nơi cư trú sinh sống bền vững cho con người.)', false, NOW()),
  (v_deck_id, 'zoning', '/ˈzəʊ.nɪŋ/', 'quy hoạch phân vùng', 'Strict municipal zoning limits factory construction. (Quy hoạch phân vùng chặt chẽ hạn chế xây dựng nhà máy.)', false, NOW());

  -- Bài 64: IELTS Academic - Bài 4: Tâm Lý Học & Hành Vi
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('IELTS Academic - Bài 4: Tâm Lý Học & Hành Vi', 'Từ vựng IELTS Band 7.0+ về tâm lý con người, hành vi và cảm xúc.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'subconscious', '/ˌsʌbˈkɒn.ʃəs/', 'tiềm thức bên trong', 'Dreams reveal hidden subconscious desires. (Những giấc mơ hé lộ những khao khát ẩn sâu trong tiềm thức.)', false, NOW()),
  (v_deck_id, 'cognitive', '/ˈkɒɡ.nə.tɪv/', 'thuộc về nhận thức', 'Puzzles improve older adults cognitive abilities. (Trò chơi giải đố nâng cao năng lực nhận thức của người già.)', false, NOW()),
  (v_deck_id, 'perception', '/pəˈsep.ʃən/', 'sự nhận thức cảm quan', 'Sensory perception shapes our view of reality. (Nhận thức cảm quan định hình cách ta nhìn thế giới thực.)', false, NOW()),
  (v_deck_id, 'trauma', '/ˈtrɔː.mə/', 'chấn thương tâm lý', 'Overcoming childhood emotional trauma. (Vượt qua những chấn thương tâm lý từ thời thơ ấu.)', false, NOW()),
  (v_deck_id, 'empathy', '/ˈem.pə.θi/', 'sự đồng cảm thấu hiểu', 'Deep empathy strengthens interpersonal relationships. (Sự đồng cảm sâu sắc củng cố các mối quan hệ giữa người với người.)', false, NOW()),
  (v_deck_id, 'resilience', '/rɪˈzɪl.jəns/', 'khả năng kiên cường vượt khó', 'Emotional psychological resilience in times of adversity. (Khả năng kiên cường tâm lý trong những thời điểm nghịch cảnh.)', false, NOW()),
  (v_deck_id, 'stimulus', '/ˈstɪm.jə.ləs/', 'tác nhân kích thích', 'Respond instinctively to a loud auditory stimulus. (Phản ứng theo bản năng trước tác nhân kích thích âm thanh lớn.)', false, NOW()),
  (v_deck_id, 'phobia', '/ˈfəʊ.bi.ə/', 'nỗi ám ảnh sợ hãi', 'Therapy helps cure severe height phobia. (Trị liệu giúp chữa khỏi nỗi ám ảnh sợ độ cao nghiêm trọng.)', false, NOW()),
  (v_deck_id, 'introvert', '/ˈɪn.trə.vɜːt/', 'người hướng nội', 'Introverts recharge energy in quiet solitude. (Người hướng nội nạp lại năng lượng trong sự tĩnh lặng một mình.)', false, NOW()),
  (v_deck_id, 'extrovert', '/ˈek.strə.vɜːt/', 'người hướng ngoại', 'Extroverts thrive in lively social gatherings. (Người hướng ngoại tỏa sáng trong các buổi tụ họp xã hội sôi nổi.)', false, NOW()),
  (v_deck_id, 'conditioning', '/kənˈdɪʃ.ən.ɪŋ/', 'phản xạ có điều kiện', 'Pavlov classic behavioral conditioning experiment. (Thí nghiệm phản xạ có điều kiện hành vi kinh điển của Pavlov.)', false, NOW()),
  (v_deck_id, 'neurosis', '/njʊəˈrəʊ.sɪs/', 'chứng loạn thần kinh chức năng', 'Anxiety neurosis treated with counseling therapy. (Chứng loạn thần kinh lo âu được điều trị bằng liệu pháp tư vấn.)', false, NOW()),
  (v_deck_id, 'inhibitions', '/ˌɪn.hɪˈbɪʃ.ənz/', 'sự ức chế rụt rè', 'Alcohol lowers social behavioral inhibitions. (Rượu bia làm giảm bớt sự ức chế rụt rè trong giao tiếp xã hội.)', false, NOW()),
  (v_deck_id, 'bias', '/ˈbaɪ.əs/', 'định kiến thiên lệch', 'Confirmation bias distorts objective evaluation. (Định kiến xác nhận làm bóp méo việc đánh giá khách quan.)', false, NOW()),
  (v_deck_id, 'hallucination', '/həˌluː.sɪˈneɪ.ʃən/', 'ảo giác / hoang tưởng', 'High fever triggered temporary visual hallucinations. (Cơn sốt cao đã gây ra những cơn ảo giác thị giác tạm thời.)', false, NOW());

  -- Bài 65: IELTS Academic - Bài 5: Văn Hóa & Di Sản
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('IELTS Academic - Bài 5: Văn Hóa & Di Sản', 'Từ vựng IELTS Band 7.0+ về di sản lịch sử, phong tục và nghệ thuật.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'heritage', '/ˈher.ɪ.tɪdʒ/', 'di sản văn hóa', 'UNESCO protects global ancient cultural heritage. (UNESCO bảo vệ các di sản văn hóa cổ xưa của nhân loại.)', false, NOW()),
  (v_deck_id, 'indigenous', '/ɪnˈdɪdʒ.ɪ.nəs/', 'người bản địa', 'Preserve languages of indigenous tribes. (Bảo tồn tiếng nói của các bộ lạc bản địa.)', false, NOW()),
  (v_deck_id, 'folklore', '/ˈfəʊk.lɔːr/', 'truyện dân gian truyền khẩu', 'Traditional myths passed down in national folklore. (Các truyền thuyết truyền thống được lưu truyền trong văn học dân gian.)', false, NOW()),
  (v_deck_id, 'artifact', '/ˈɑː.tɪ.fækt/', 'cổ vật khảo cổ', 'Ancient pottery artifacts exhibited in museum. (Các cổ vật đồ gốm cổ xưa được trưng bày trong bảo tàng.)', false, NOW()),
  (v_deck_id, 'assimilation', '/əˌsɪm.ɪˈleɪ.ʃən/', 'sự đồng hóa văn hóa', 'Immigrant cultural assimilation into society. (Sự đồng hóa văn hóa của người nhập cư vào xã hội sở tại.)', false, NOW()),
  (v_deck_id, 'custom', '/ˈkʌs.təm/', 'phong tục tập quán', 'Respect local wedding customs and rituals. (Tôn trọng các phong tục và nghi thức cưới hỏi địa phương.)', false, NOW()),
  (v_deck_id, 'monument', '/ˈmɒn.jə.mənt/', 'tượng đài kỷ niệm', 'Historic marble monument honors national heroes. (Tượng đài bằng đá cẩm thạch lịch sử tôn vinh các anh hùng dân tộc.)', false, NOW()),
  (v_deck_id, 'preservation', '/ˌprez.əˈveɪ.ʃən/', 'bảo tồn gìn giữ', 'Architectural preservation of historic old quarters. (Công tác bảo tồn kiến trúc của các khu phố cổ lịch sử.)', false, NOW()),
  (v_deck_id, 'anthropology', '/ˌæn.θrəˈpɒl.ə.dʒi/', 'nhân chủng học', 'Study human evolution in cultural anthropology. (Nghiên cứu sự tiến hóa của loài người trong nhân chủng học văn hóa.)', false, NOW()),
  (v_deck_id, 'relic', '/ˈrel.ɪk/', 'di tích / di vật cổ', 'Holy religious relics preserved in temple. (Các di vật tôn giáo thiêng liêng được lưu giữ trong ngôi đền.)', false, NOW()),
  (v_deck_id, 'aesthetic', '/esˈθet.ɪk/', 'tính thẩm mỹ nghệ thuật', 'Minimalist Japanese architectural aesthetic. (Tính thẩm mỹ kiến trúc tối giản mang phong cách Nhật Bản.)', false, NOW()),
  (v_deck_id, 'diversity', '/daɪˈvɜː.sə.ti/', 'sự đa dạng phong phú', 'Celebrate rich international cultural diversity. (Tôn vinh sự đa dạng văn hóa quốc tế phong phú.)', false, NOW()),
  (v_deck_id, 'lineage', '/ˈlɪn.i.ɪdʒ/', 'dòng dõi huyết thống', 'Trace royal family genealogical lineage. (Truy tìm dòng dõi gia phả của gia đình hoàng gia.)', false, NOW()),
  (v_deck_id, 'secular', '/ˈsek.jə.lər/', 'thế tục (phi tôn giáo)', 'Public schools operate as secular institutions. (Trường công lập hoạt động như những cơ sở giáo dục thế tục.)', false, NOW()),
  (v_deck_id, 'excavation', '/ˌek.skəˈveɪ.ʃən/', 'khai quật khảo cổ', 'Archaeological excavation uncovered royal tombs. (Cuộc khai quật khảo cổ học đã phát lộ các lăng mộ hoàng gia.)', false, NOW());

  -- Bài 66: IELTS Academic - Bài 6: Toàn Cầu Hóa & Xã Hội
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('IELTS Academic - Bài 6: Toàn Cầu Hóa & Xã Hội', 'Từ vựng IELTS Band 7.0+ về toàn cầu hóa, bất bình đẳng và xã hội.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'globalization', '/ˌɡləʊ.bəl.aɪˈzeɪ.ʃən/', 'toàn cầu hóa', 'Economic globalization connects distant world markets. (Toàn cầu hóa kinh tế kết nối các thị trường xa xôi trên thế giới.)', false, NOW()),
  (v_deck_id, 'inequality', '/ˌɪn.ɪˈkwɒl.ə.ti/', 'bất bình đẳng xã hội', 'Address widening global wealth inequality gaps. (Giải quyết khoảng cách bất bình đẳng giàu nghèo toàn cầu ngày càng tăng.)', false, NOW()),
  (v_deck_id, 'poverty', '/ˈpɒv.ə.ti/', 'nghèo đói bần cùng', 'Eradicate extreme poverty through job creation. (Xóa bỏ tình trạng nghèo đói cùng cực thông qua tạo việc làm.)', false, NOW()),
  (v_deck_id, 'integration', '/ˌɪn.tɪˈɡreɪ.ʃən/', 'hội nhập quốc tế', 'Regional economic integration within ASEAN bloc. (Hội nhập kinh tế khu vực trong khối các nước ASEAN.)', false, NOW()),
  (v_deck_id, 'homogenization', '/həˌmɒdʒ.ɪ.naɪˈzeɪ.ʃən/', 'đồng nhất hóa đơn điệu', 'Westernization leads to cultural homogenization. (Tây phương hóa dẫn đến sự đồng nhất hóa văn hóa đơn điệu.)', false, NOW()),
  (v_deck_id, 'polarization', '/ˌpəʊ.lər.aɪˈzeɪ.ʃən/', 'sự phân cực chia rẽ', 'Political polarization divides society deeply. (Sự phân cực chính trị chia rẽ xã hội một cách sâu sắc.)', false, NOW()),
  (v_deck_id, 'marginalized', '/ˈmɑː.dʒɪ.nəl.aɪzd/', 'bên lề xã hội / yếu thế', 'Empower marginalized minority social groups. (Trao quyền cho các nhóm xã hội thiểu số yếu thế bên lề.)', false, NOW()),
  (v_deck_id, 'affluence', '/ˈæf.lu.əns/', 'sự giàu có sung túc', 'Growing consumer affluence in middle classes. (Sự giàu có sung túc ngày càng tăng trong tầng lớp trung lưu.)', false, NOW()),
  (v_deck_id, 'interdependence', '/ˌɪn.tə.dɪˈpen.dəns/', 'phụ thuộc lẫn nhau', 'Global trade creates mutual economic interdependence. (Thương mại toàn cầu tạo ra sự phụ thuộc kinh tế lẫn nhau.)', false, NOW()),
  (v_deck_id, 'mobility', '/məʊˈbɪl.ə.ti/', 'sự dịch chuyển giai cấp', 'Education provides upward social mobility. (Giáo dục mang lại cơ hội dịch chuyển lên các nấc thang xã hội cao hơn.)', false, NOW()),
  (v_deck_id, 'exploitation', '/ˌek.splɔɪˈteɪ.ʃən/', 'bóc lột sức lao động', 'Enact laws to prevent child labor exploitation. (Ban hành luật để ngăn chặn nạn bóc lột sức lao động trẻ em.)', false, NOW()),
  (v_deck_id, 'philanthropy', '/fɪˈlæn.θrə.pi/', 'từ thiện bác ái', 'Billionaire dedicated wealth to global healthcare philanthropy. (Tỷ phú dành tài sản làm từ thiện bác ái cho y tế toàn cầu.)', false, NOW()),
  (v_deck_id, 'xenophobia', '/ˌzen.əˈfəʊ.bi.ə/', 'bài ngoại sợ người lạ', 'Condemn all forms of racial xenophobia. (Lên án mọi hình thức bài ngoại và phân biệt sắc tộc.)', false, NOW()),
  (v_deck_id, 'solidarity', '/ˌsɒl.ɪˈdær.ə.ti/', 'tinh thần đoàn kết', 'Show international solidarity during natural disasters. (Thể hiện tinh thần đoàn kết quốc tế trong thảm họa thiên tai.)', false, NOW()),
  (v_deck_id, 'welfare', '/ˈwel.feər/', 'phúc lợi xã hội', 'Government funds unemployment social welfare benefits. (Chính phủ chi trả các khoản phúc lợi xã hội trợ cấp thất nghiệp.)', false, NOW());

  -- Bài 67: IELTS Academic - Bài 7: Khoa Học Vũ Trụ & Thiên Văn
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('IELTS Academic - Bài 7: Khoa Học Vũ Trụ & Thiên Văn', 'Từ vựng IELTS Band 7.0+ về thiên văn học, các vì sao và vũ trụ học.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'astronomy', '/əˈstrɒn.ə.mi/', 'thiên văn học', 'Telescopes revolutionized modern observational astronomy. (Kính viễn vọng đã cách mạng hóa ngành thiên văn học quan sát hiện đại.)', false, NOW()),
  (v_deck_id, 'celestial', '/sɪˈles.ti.əl/', 'thuộc về thiên thể bầu trời', 'Observe distant celestial bodies in night sky. (Quan sát các thiên thể xa xôi trên bầu trời đêm.)', false, NOW()),
  (v_deck_id, 'constellation', '/ˌkɒn.stəˈleɪ.ʃən/', 'chòm sao trên trời', 'Sailors navigated using the Orion constellation. (Thủy thủ định hướng đường đi bằng chòm sao Lạp Hộ.)', false, NOW()),
  (v_deck_id, 'extraterrestrial', '/ˌek.strə.təˈres.tri.əl/', 'ngoài Trái Đất', 'Search for intelligent extraterrestrial alien life. (Tìm kiếm sự sống thông minh ngoài Trái Đất.)', false, NOW()),
  (v_deck_id, 'gravity', '/ˈɡræv.ə.ti/', 'trọng lực lực hút', 'Planetary gravity keeps moons in stable orbit. (Trọng lực hành tinh giữ cho các mặt trăng quay trên quỹ đạo ổn định.)', false, NOW()),
  (v_deck_id, 'light-year', '/ˈlaɪtˌjɪər/', 'năm ánh sáng (khoảng cách)', 'Nearest star system is four light-years away. (Hệ sao gần nhất cách chúng ta 4 năm ánh sáng.)', false, NOW()),
  (v_deck_id, 'supernova', '/ˌsuː.pəˈnəʊ.və/', 'vụ nổ siêu tân tinh', 'Dying massive star collapses into a supernova. (Ngôi sao khổng lồ sắp chết sụp đổ tạo thành vụ nổ siêu tân tinh.)', false, NOW()),
  (v_deck_id, 'nebula', '/ˈneb.jə.lə/', 'tinh vân vũ trụ', 'New stars form inside giant gas nebulae. (Những ngôi sao mới hình thành bên trong các đám tinh vân khí khổng lồ.)', false, NOW()),
  (v_deck_id, 'black hole', '/ˌblæk ˈhəʊl/', 'hố đen vũ trụ', 'Nothing can escape the gravity of a black hole. (Không có gì có thể thoát khỏi lực hấp dẫn của một hố đen.)', false, NOW()),
  (v_deck_id, 'telescope', '/ˈtel.ɪ.skəʊp/', 'kính viễn vọng', 'James Webb space telescope captures deep universe. (Kính viễn vọng không gian James Webb chụp vũ trụ sâu thẳm.)', false, NOW()),
  (v_deck_id, 'interstellar', '/ˌɪn.təˈstel.ər/', 'giữa các vì sao', 'Voyager probe entered cold interstellar space. (Tàu thăm dò Voyager đã tiến vào không gian lạnh giá giữa các vì sao.)', false, NOW()),
  (v_deck_id, 'cosmology', '/kɒzˈmɒl.ə.dʒi/', 'vũ trụ học', 'Big Bang theory explains origin in cosmology. (Thuyết Vụ Nổ Lớn giải thích nguồn gốc vũ trụ trong vũ trụ học.)', false, NOW()),
  (v_deck_id, 'asteroid', '/ˈæs.tər.ɔɪd/', 'tiểu hành tinh', 'Asteroid belt orbits between Mars and Jupiter. (Vành đai tiểu hành tinh quay giữa Sao Hỏa và Sao Mộc.)', false, NOW()),
  (v_deck_id, 'eclipse', '/ɪˈklɪps/', 'nhật thực / nguyệt thực', 'Total solar eclipse darkened daylight skies. (Nhật thực toàn phần làm tối sầm bầu trời ban ngày.)', false, NOW()),
  (v_deck_id, 'rover', '/ˈrəʊ.vər/', 'xe tự hành thám hiểm', 'NASA robotic rover explores surface of Mars. (Xe tự hành robot của NASA thám hiểm bề mặt Sao Hỏa.)', false, NOW());

  -- Bài 68: IELTS Academic - Bài 8: Khảo Cổ & Lịch Sử
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('IELTS Academic - Bài 8: Khảo Cổ & Lịch Sử', 'Từ vựng IELTS Band 7.0+ về lịch sử nhân loại, hóa thạch và khảo cổ.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'archaeology', '/ˌɑː.kiˈɒl.ə.dʒi/', 'khảo cổ học', 'Archaeology uncovers ancient civilizations. (Khảo cổ học khám phá các nền văn minh cổ đại.)', false, NOW()),
  (v_deck_id, 'fossil', '/ˈfɒs.əl/', 'hóa thạch xương', 'Dinosaur fossil preserved in sedimentary rock. (Hóa thạch khủng long được bảo tồn trong đá trầm tích.)', false, NOW()),
  (v_deck_id, 'chronology', '/krəˈnɒl.ə.dʒi/', 'niên đại học theo thời gian', 'Carbon dating establishes historical chronology. (Định tuổi bằng đồng vị carbon xác lập niên đại lịch sử.)', false, NOW()),
  (v_deck_id, 'civilization', '/ˌsɪv.əl.aɪˈzeɪ.ʃən/', 'nền văn minh', 'Ancient Mesopotamian irrigation civilization. (Nền văn minh thủy lợi Lưỡng Hà cổ đại.)', false, NOW()),
  (v_deck_id, 'dynasty', '/ˈdɪn.ə.sti/', 'triều đại phong kiến', 'Ming dynasty ruled China for centuries. (Triều đại nhà Minh cai trị Trung Quốc trong nhiều thế kỷ.)', false, NOW()),
  (v_deck_id, 'excavate', '/ˈek.skə.veɪt/', 'khai quật đất đá', 'Excavate buried Roman empire ruins. (Khai quật tàn tích đế chế La Mã bị chôn vùi.)', false, NOW()),
  (v_deck_id, 'manuscript', '/ˈmæn.jə.skrɪpt/', 'bản thảo viết tay cổ', 'Medieval illuminated parchment manuscript. (Bản thảo viết tay cổ thời Trung cổ trên giấy da cừu.)', false, NOW()),
  (v_deck_id, 'heirloom', '/ˈeə.luːm/', 'vật gia bảo truyền đời', 'Antique sword passed down as family heirloom. (Thanh gươm cổ được truyền lại như một vật gia bảo của gia đình.)', false, NOW()),
  (v_deck_id, 'inscription', '/ɪnˈskrɪp.ʃən/', 'văn khắc bia đá', 'Ancient hieroglyphic stone temple inscription. (Văn khắc chữ tượng hình cổ trên bia đá ngôi đền.)', false, NOW()),
  (v_deck_id, 'nomadic', '/nəʊˈmæd.ɪk/', 'du mục di cư', 'Nomadic pastoralists herded livestock on steppes. (Những người du mục chăn thả gia súc trên thảo nguyên.)', false, NOW()),
  (v_deck_id, 'prehistoric', '/ˌpriː.hɪˈstɒr.ɪk/', 'thời tiền sử', 'Prehistoric cave drawings of wild animals. (Những bức vẽ trong hang động thời tiền sử về các loài thú hoang.)', false, NOW()),
  (v_deck_id, 'antiquity', '/ænˈtɪk.wə.ti/', 'thời cổ đại xa xưa', 'Classical antiquity philosophy of ancient Greece. (Triết học thời cổ đại kinh điển của Hy Lạp cổ.)', false, NOW()),
  (v_deck_id, 'settlement', '/ˈset.əl.mənt/', 'khu định cư ban đầu', 'Early agricultural human river settlement. (Khu định cư nông nghiệp ban đầu của con người ven sông.)', false, NOW()),
  (v_deck_id, 'strata', '/ˈstrɑː.tə/', 'các tầng địa chất', 'Geologists examine layers of rock strata. (Các nhà địa chất học kiểm tra các tầng lớp địa chất đá.)', false, NOW()),
  (v_deck_id, 'feudalism', '/ˈfjuː.dəl.ɪ.zəm/', 'chế độ phong kiến', 'Knights pledged loyalty in medieval feudalism. (Các hiệp sĩ thề trung thành trong chế độ phong kiến thời Trung cổ.)', false, NOW());

  -- Bài 69: IELTS Academic - Bài 9: Động Vật Học & Sinh Thái
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('IELTS Academic - Bài 9: Động Vật Học & Sinh Thái', 'Từ vựng IELTS Band 7.0+ về hành vi động vật, thích nghi và chuỗi thức ăn.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'predator', '/ˈpred.ə.tər/', 'thú săn mồi', 'Lions are apex carnivore predators in savannah. (Sư tử là thú săn mồi ăn thịt đầu bảng trên thảo nguyên.)', false, NOW()),
  (v_deck_id, 'prey', '/preɪ/', 'con mồi', 'Camouflage protects small insects from predators prey. (Ngụy trang giúp bảo vệ côn trùng nhỏ làm con mồi khỏi kẻ săn.)', false, NOW()),
  (v_deck_id, 'camouflage', '/ˈkæm.ə.flɑːʒ/', 'ngụy trang màu sắc', 'Chameleon changes skin color for camouflage. (Tắc kè hoa đổi màu da để ngụy trang ẩn mình.)', false, NOW()),
  (v_deck_id, 'nocturnal', '/nɒkˈtɜː.nəl/', 'hoạt động về đêm', 'Owls are nocturnal birds with sharp hearing. (Cú mèo là loài chim ăn đêm có thính giác cực kỳ nhạy bén.)', false, NOW()),
  (v_deck_id, 'diurnal', '/daɪˈɜː.nəl/', 'hoạt động ban ngày', 'Most mammals follow a diurnal waking pattern. (Phần lớn động vật có vú tuân theo thói quen thức ban ngày.)', false, NOW()),
  (v_deck_id, 'hibernation', '/ˌhaɪ.bəˈneɪ.ʃən/', 'ngủ đông tích mỡ', 'Bears enter deep winter hibernation. (Gấu bước vào giấc ngủ đông sâu suốt mùa đông.)', false, NOW()),
  (v_deck_id, 'migration', '/maɪˈɡreɪ.ʃən/', 'di cư theo mùa', 'Annual bird flock migration to warmer climates. (Đàn chim di cư hàng năm tới những vùng khí hậu ấm áp hơn.)', false, NOW()),
  (v_deck_id, 'adaptation', '/ˌæd.æpˈteɪ.ʃən/', 'sự thích nghi môi trường', 'Camel water retention physiological adaptation. (Sự thích nghi sinh lý giữ nước của loài lạc đà.)', false, NOW()),
  (v_deck_id, 'symbiosis', '/ˌsɪm.baɪˈəʊ.sɪs/', 'cộng sinh cùng có lợi', 'Clownfish and sea anemone live in symbiosis. (Cá hề và hải quỳ sống cộng sinh cùng có lợi với nhau.)', false, NOW()),
  (v_deck_id, 'parasite', '/ˈpær.ə.saɪt/', 'sinh vật ký sinh', 'Fleas are blood-sucking external parasites. (Bọ chét là loài sinh vật ký sinh hút máu bên ngoài.)', false, NOW()),
  (v_deck_id, 'herbivore', '/ˈhɜː.bɪ.vɔːr/', 'động vật ăn cỏ', 'Elephants and giraffes are large herbivores. (Voi và hươu cao cổ là những loài động vật ăn cỏ to lớn.)', false, NOW()),
  (v_deck_id, 'carnivore', '/ˈkɑː.nɪ.vɔːr/', 'động vật ăn thịt', 'Tigers are solitary hunting carnivores. (Hổ là loài động vật ăn thịt đi săn đơn độc.)', false, NOW()),
  (v_deck_id, 'omnivore', '/ˈɒm.nɪ.vɔːr/', 'động vật ăn tạp', 'Bears eat berries and fish as omnivores. (Gấu ăn cả quả mọng lẫn cá vì chúng là loài ăn tạp.)', false, NOW()),
  (v_deck_id, 'territorial', '/ˌter.ɪˈtɔː.ri.əl/', 'bảo vệ lãnh thổ', 'Wolves are fierce territorial pack animals. (Chó sói là loài động vật sống theo bầy bảo vệ lãnh thổ quyết liệt.)', false, NOW()),
  (v_deck_id, 'instinct', '/ˈɪn.stɪŋkt/', 'bản năng sinh tồn', 'Birds build nests by natural survival instinct. (Chim làm tổ nhờ bản năng sinh tồn tự nhiên.)', false, NOW());

  -- Bài 70: IELTS Academic - Bài 10: Di Truyền & Sinh Học Phân Tử
  INSERT INTO decks (title, description, language, card_count, created_at)
  VALUES ('IELTS Academic - Bài 10: Di Truyền & Sinh Học Phân Tử', 'Từ vựng IELTS Band 7.0+ về ADN, gen, tế bào và công nghệ sinh học.', 'en', 15, NOW())
  RETURNING id INTO v_deck_id;

  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES
  (v_deck_id, 'chromosome', '/ˈkrəʊ.mə.səʊm/', 'nhiễm sắc thể', 'Humans have 23 pairs of chromosomes. (Con người có 23 cặp nhiễm sắc thể trong mỗi tế bào.)', false, NOW()),
  (v_deck_id, 'mutation', '/mjuːˈteɪ.ʃən/', 'đột biến gen', 'Genetic DNA mutation causes rare hereditary diseases. (Đột biến gen ADN gây ra các bệnh di truyền hiếm gặp.)', false, NOW()),
  (v_deck_id, 'genome', '/ˈdʒiː.nəʊm/', 'bộ gen sinh vật', 'Scientists mapped the complete human genome. (Các nhà khoa học đã giải mã bản đồ toàn bộ hệ gen người.)', false, NOW()),
  (v_deck_id, 'hereditary', '/hɪˈred.ɪ.tər.i/', 'di truyền từ cha mẹ', 'Eye color is a hereditary physical trait. (Màu mắt là một đặc điểm hình thể di truyền từ cha mẹ.)', false, NOW()),
  (v_deck_id, 'cloning', '/ˈkləʊ.nɪŋ/', 'nhân bản vô tính', 'Ethical debates surround animal genetic cloning. (Những tranh luận đạo đức xoay quanh việc nhân bản vô tính động vật.)', false, NOW()),
  (v_deck_id, 'stem cell', '/ˈstem ˌsel/', 'tế bào gốc', 'Stem cells can differentiate into specialized tissue. (Tế bào gốc có thể biệt hóa thành các mô chuyên biệt.)', false, NOW()),
  (v_deck_id, 'recombinant', '/riːˈkɒm.bɪ.nənt/', 'tái tổ hợp ADN', 'Recombinant DNA technology produces human insulin. (Công nghệ ADN tái tổ hợp sản xuất ra insulin cho người.)', false, NOW()),
  (v_deck_id, 'organism', '/ˈɔː.ɡən.ɪ.zəm/', 'sinh vật sống', 'Genetically modified living organism (GMO). (Sinh vật sống bị biến đổi gen di truyền GMO.)', false, NOW()),
  (v_deck_id, 'cellular', '/ˈsel.jə.lər/', 'thuộc về tế bào', 'Cellular respiration produces biological energy. (Hô hấp tế bào tạo ra năng lượng sinh học cho cơ thể.)', false, NOW()),
  (v_deck_id, 'enzyme', '/ˈen.zaɪm/', 'men xúc tác sinh học', 'Enzymes catalyze vital metabolic reactions. (Các enzym xúc tác các phản ứng trao đổi chất quan trọng.)', false, NOW()),
  (v_deck_id, 'dominant', '/ˈdɒm.ɪ.nənt/', 'gen trội', 'Brown eye color is a dominant genetic allele. (Màu mắt nâu là một alen tính trạng gen trội.)', false, NOW()),
  (v_deck_id, 'recessive', '/rɪˈses.ɪv/', 'gen lặn', 'Blue eyes express only when both genes are recessive. (Mắt xanh chỉ biểu hiện khi cả hai gen đều là gen lặn.)', false, NOW()),
  (v_deck_id, 'transgenic', '/trænzˈdʒen.ɪk/', 'chuyển gen khác loài', 'Transgenic crops resist agricultural pests. (Cây trồng chuyển gen có khả năng kháng sâu bệnh nông nghiệp.)', false, NOW()),
  (v_deck_id, 'mitosis', '/maɪˈtəʊ.sɪs/', 'nguyên phân tế bào', 'Cell divides into two identical nuclei in mitosis. (Tế bào phân chia thành hai nhân giống hệt nhau trong nguyên phân.)', false, NOW()),
  (v_deck_id, 'meiosis', '/maɪˈəʊ.sɪs/', 'giảm phân sinh sản', 'Meiosis produces gamete reproductive sperm cells. (Quá trình giảm phân tạo ra các tế bào sinh sản giao tử.)', false, NOW());

END $$;
