export const TOPIC_CATEGORIES = [
  {
    id: 'it',
    title: { vi: 'IT & Phát triển Phần mềm', en: 'IT & Software Development', ja: 'IT・ソフトウェア開発' },
    desc: { 
      vi: 'Lập trình Web, Backend & Cơ sở dữ liệu, AI & Machine Learning, An toàn thông tin, DevOps, Mobile & Cloud Computing', 
      en: 'Web frontend, Backend & Database, AI, Cybersecurity, DevOps, Mobile & Cloud Computing', 
      ja: 'Web、バックエンド、AI、セキュリティ、DevOps、モバイル、クラウド開発' 
    },
    icon: '💻',
    tagColor: '#3b82f6',
    bgGradient: 'linear-gradient(135deg, rgba(59, 130, 246, 0.2), rgba(37, 99, 235, 0.05))',
    borderGlow: 'rgba(59, 130, 246, 0.35)',
    match: (deck) => {
      const t = (deck.title || '').toLowerCase();
      return !deck.user_id && (t.startsWith('it -') || t.startsWith('it:'));
    }
  },
  {
    id: 'medical',
    title: { vi: 'Y Khoa & Chăm Sóc Sức Khỏe', en: 'Medical & Healthcare', ja: '医学・ヘルスケア' },
    desc: { 
      vi: 'Giải phẫu học, Bệnh học lâm sàng, Dược lý & Kê đơn, Điều dưỡng thực hành, Tim mạch, Hô hấp & Chẩn đoán hình ảnh', 
      en: 'Anatomy, Clinical Pathology, Pharmacology, Nursing Practice, Cardiology & Diagnostics', 
      ja: '解剖学、臨床病理学、薬理学、看護実践、循環器、診断など' 
    },
    icon: '🏥',
    tagColor: '#ef4444',
    bgGradient: 'linear-gradient(135deg, rgba(239, 68, 68, 0.2), rgba(220, 38, 38, 0.05))',
    borderGlow: 'rgba(239, 68, 68, 0.35)',
    match: (deck) => {
      const t = (deck.title || '').toLowerCase();
      return !deck.user_id && (t.startsWith('y khoa -') || t.startsWith('y khoa:'));
    }
  },
  {
    id: 'economics',
    title: { vi: 'Kinh Tế & Tài Chính Doanh Nghiệp', en: 'Economics & Corporate Finance', ja: '経済・金融・ビジネス' },
    desc: { 
      vi: 'Kinh tế vi mô & vĩ mô, Tài chính ngân hàng, Kế toán & Kiểm toán, Marketing & Tiếp thị số, Quản trị nhân sự & Thương mại', 
      en: 'Micro & Macro Economics, Banking & Finance, Accounting & Auditing, Digital Marketing, HR & Trade', 
      ja: '経済学、金融、会計、デジタルマーケティング、人事管理、国際貿易' 
    },
    icon: '📊',
    tagColor: '#10b981',
    bgGradient: 'linear-gradient(135deg, rgba(16, 185, 129, 0.2), rgba(5, 150, 105, 0.05))',
    borderGlow: 'rgba(16, 185, 129, 0.35)',
    match: (deck) => {
      const t = (deck.title || '').toLowerCase();
      return !deck.user_id && (t.startsWith('kinh tế -') || t.startsWith('kinh tế:'));
    }
  },
  {
    id: 'engineering',
    title: { vi: 'Kỹ Thuật, Cơ Khí & Chế Tạo', en: 'Engineering & Manufacturing', ja: '工学・機械・製造' },
    desc: { 
      vi: 'Cơ khí chính xác & Máy móc, Kỹ thuật điện & Điện tử, Khoa học vật liệu, Kỹ thuật hóa học, Xây dựng & Tự động hóa Robot', 
      en: 'Precision Mechanics, Electrical & Electronics, Materials Science, Chemical Engineering, Civil & Automation', 
      ja: '精密機械、電気電子工学、材料科学、化学工学、土木建築、ロボット自動化' 
    },
    icon: '⚙️',
    tagColor: '#f59e0b',
    bgGradient: 'linear-gradient(135deg, rgba(245, 158, 11, 0.2), rgba(217, 119, 6, 0.05))',
    borderGlow: 'rgba(245, 158, 11, 0.35)',
    match: (deck) => {
      const t = (deck.title || '').toLowerCase();
      return !deck.user_id && (t.startsWith('kỹ thuật -') || t.startsWith('kỹ thuật:'));
    }
  },
  {
    id: 'law',
    title: { vi: 'Luật & Khoa Học Chính Trị', en: 'Law & Political Science', ja: '法学・政治学' },
    desc: { 
      vi: 'Hiến pháp & Nhà nước, Pháp luật dân sự & Hình sự, Thương mại quốc tế, Luật sở hữu trí tuệ, Ngoại giao & Quyền con người', 
      en: 'Constitutional Law, Civil & Criminal Law, International Trade Law, IP Law, Diplomacy & Human Rights', 
      ja: '憲法、民法、刑法、国際貿易法、知的財産法、外交関係、人権' 
    },
    icon: '⚖️',
    tagColor: '#8b5cf6',
    bgGradient: 'linear-gradient(135deg, rgba(139, 92, 246, 0.2), rgba(109, 40, 217, 0.05))',
    borderGlow: 'rgba(139, 92, 246, 0.35)',
    match: (deck) => {
      const t = (deck.title || '').toLowerCase();
      return !deck.user_id && (t.startsWith('luật & chính trị -') || t.startsWith('luật -') || t.startsWith('luật:'));
    }
  },
  {
    id: 'toeic',
    title: { vi: 'TOEIC - Tiếng Anh Thương Mại & Công Sở', en: 'TOEIC - Business & Workplace English', ja: 'TOEIC・ビジネス英語' },
    desc: { 
      vi: 'Hợp đồng thương mại, Đàm phán kinh doanh, Tổ chức cuộc họp, Quản trị nhân sự, Tài chính công ty & Dịch vụ khách hàng', 
      en: 'Contracts, Business Negotiations, Corporate Meetings, Human Resources, Corporate Finance & Customer Service', 
      ja: '契約書、ビジネス交渉、会議、人事労務、企業財務、カスタマーサービス' 
    },
    icon: '💼',
    tagColor: '#06b6d4',
    bgGradient: 'linear-gradient(135deg, rgba(6, 182, 212, 0.2), rgba(8, 145, 178, 0.05))',
    borderGlow: 'rgba(6, 182, 212, 0.35)',
    match: (deck) => {
      const t = (deck.title || '').toLowerCase();
      return !deck.user_id && (t.startsWith('toeic -') || t.startsWith('toeic:'));
    }
  },
  {
    id: 'ielts',
    title: { vi: 'IELTS Academic - Học Thuật Nâng Cao', en: 'IELTS Academic Vocabulary', ja: 'IELTS・アカデミック英語' },
    desc: { 
      vi: 'Môi trường & Biến đổi khí hậu, Giáo dục & Học đường, Khoa học tự nhiên, Đô thị hóa, Toàn cầu hóa & Bản sắc văn hóa', 
      en: 'Environment & Climate Change, Education, Natural Sciences, Urbanization, Globalization & Cultural Identity', 
      ja: '環境と気候変動、教育、自然科学、都市化、グローバル化、文化的多様性' 
    },
    icon: '🎓',
    tagColor: '#ec4899',
    bgGradient: 'linear-gradient(135deg, rgba(236, 72, 153, 0.2), rgba(219, 39, 119, 0.05))',
    borderGlow: 'rgba(236, 72, 153, 0.35)',
    match: (deck) => {
      const t = (deck.title || '').toLowerCase();
      return !deck.user_id && t.startsWith('ielts');
    }
  },
  {
    id: 'japanese',
    title: { vi: 'Tiếng Nhật - Giao Tiếp & JLPT', en: 'Japanese - Conversation & JLPT', ja: '日本語・日常会話・JLPT' },
    desc: { 
      vi: 'Từ vựng tiếng Nhật theo cấp độ JLPT N5 đến N1, Minna no Nihongo và mẫu câu giao tiếp đời sống', 
      en: 'Japanese vocabulary N5-N1 levels, Minna no Nihongo & everyday conversations', 
      ja: 'JLPT N5〜N1レベル別語彙、みんなの日本語、実用日常会話' 
    },
    icon: '🇯🇵',
    tagColor: '#f43f5e',
    bgGradient: 'linear-gradient(135deg, rgba(244, 63, 94, 0.2), rgba(225, 29, 72, 0.05))',
    borderGlow: 'rgba(244, 63, 94, 0.35)',
    match: (deck) => {
      const t = (deck.title || '').toLowerCase();
      return !deck.user_id && (deck.language === 'ja' || t.includes('n5') || t.includes('n4') || t.includes('n3') || t.includes('n2') || t.includes('n1') || t.includes('tiếng nhật'));
    }
  },
  {
    id: 'my',
    title: { vi: 'Bộ Thẻ Tự Tạo Của Tôi', en: 'My Custom Flashcards', ja: 'マイ単語帳' },
    desc: { 
      vi: 'Các bộ từ vựng cá nhân do chính bạn tạo ra hoặc trích xuất tự động từ tài liệu của bạn', 
      en: 'Personal flashcard decks created or extracted by you', 
      ja: '自分で作成またはテキストから自動抽出したオリジナル単語帳' 
    },
    icon: '👤',
    tagColor: '#14b8a6',
    bgGradient: 'linear-gradient(135deg, rgba(20, 184, 166, 0.2), rgba(13, 148, 136, 0.05))',
    borderGlow: 'rgba(20, 184, 166, 0.35)',
    match: (deck) => !!deck.user_id
  },
  {
    id: 'other',
    title: { vi: 'Bộ Thẻ Tổng Hợp Khác', en: 'Other Decks', ja: 'その他の単語帳' },
    desc: { 
      vi: 'Các bộ từ vựng và chủ đề tổng hợp khác trong kho học liệu', 
      en: 'Other general vocabulary flashcard collections', 
      ja: 'その他の教材・一般語彙集' 
    },
    icon: '📁',
    tagColor: '#94a3b8',
    bgGradient: 'linear-gradient(135deg, rgba(148, 163, 184, 0.2), rgba(100, 116, 139, 0.05))',
    borderGlow: 'rgba(148, 163, 184, 0.35)',
    match: () => true
  }
];

export const getDeckTopicId = (deck) => {
  if (deck.user_id) return 'my';
  for (const cat of TOPIC_CATEGORIES) {
    if (cat.id !== 'other' && cat.id !== 'my' && cat.match(deck)) {
      return cat.id;
    }
  }
  return 'other';
};

export const getTopicById = (topicId) => {
  return TOPIC_CATEGORIES.find(t => t.id === topicId) || TOPIC_CATEGORIES.find(t => t.id === 'other');
};

export const parseDeckLessonInfo = (title = '') => {
  const match = title.match(/Bài\s*(\d+)/i) || title.match(/Lesson\s*(\d+)/i) || title.match(/Unit\s*(\d+)/i);
  let cleanTitle = title;
  if (title.includes(':')) {
    cleanTitle = title.split(':').slice(1).join(':').trim();
  }
  return {
    lessonNumber: match ? match[1] : null,
    lessonLabel: match ? `Bài ${match[1]}` : null,
    cleanTitle: cleanTitle || title
  };
};
