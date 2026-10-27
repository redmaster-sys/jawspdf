(function () {
  'use strict';

  const API_BASE = window.location.protocol === 'http:' ? '' : 'http://127.0.0.1:4290';

  // Görseldeki 7 Sütun ve 30 Aracın Birebir Tanımı (Ekran görüntüsü 2026-10-18 215347.png)
  const CATEGORIES = [
    { id: 'organize', title: 'PDF DÜZENLE', color: '#D06F59' },
    { id: 'optimize', title: "PDF'İ İYİLEŞTİR", color: '#68b836' },
    { id: 'to-pdf', title: "PDF'E DÖNÜŞTÜR", color: '#f2b705' },
    { id: 'from-pdf', title: "PDF'DEN DÖNÜŞTÜR", color: '#3b6998' },
    { id: 'edit', title: "PDF'İ DÜZENLE", color: '#9b59b6' },
    { id: 'security', title: 'PDF GÜVENLİĞİ', color: '#4a76a8' },
    { id: 'ai', title: 'PDF INTELLIGENCE', color: '#6c5ce7' }
  ];

  const TOOLS = [
    // 1. PDF DÜZENLE (6 Araç)
    {
      id: 'merge',
      cat: 'organize',
      name: 'PDF birleştir',
      badge: '⇅',
      color: '#D06F59',
      accept: '.pdf',
      btnLabel: 'PDF Dosyaları Seç',
      actionLabel: 'PDF Birleştir',
      desc: 'Birden fazla PDF dosyasını istediğiniz sırayla tek bir PDF belgesinde birleştirin.'
    },
    {
      id: 'split',
      cat: 'organize',
      name: 'PDF ayır',
      badge: '✂',
      color: '#D06F59',
      accept: '.pdf',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: 'PDF Ayır',
      desc: 'Bir PDF sayfasını veya belirli bir sayfa aralığını bağımsız PDF dosyalarına ayırın.'
    },
    {
      id: 'remove-pages',
      cat: 'organize',
      name: 'Sayfaları kaldır',
      badge: '✕',
      color: '#D06F59',
      accept: '.pdf',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: 'Sayfaları Kaldır',
      desc: 'PDF belgenizden istemediğiniz bir veya birden fazla sayfayı seçerek kalıcı olarak silin.'
    },
    {
      id: 'extract-pages',
      cat: 'organize',
      name: 'Sayfaları ayıkla',
      badge: '↱',
      color: '#D06F59',
      accept: '.pdf',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: 'Sayfaları Ayıkla',
      desc: 'Sadece seçtiğiniz sayfaları içeren yeni ve temiz bir PDF belgesi oluşturun.'
    },
    {
      id: 'organize',
      cat: 'organize',
      name: 'PDF düzenle',
      badge: '⇅',
      color: '#D06F59',
      accept: '.pdf',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: 'Sayfa Sırasını Kaydet',
      desc: 'PDF sayfalarının sırasını dilediğiniz düzende yeniden sıralayın.'
    },
    {
      id: 'scan-to-pdf',
      cat: 'organize',
      name: "PDF'e Tara",
      badge: '📷',
      color: '#D06F59',
      accept: '.jpg,.jpeg,.png,.webp,.pdf',
      btnLabel: 'Belge Fotoğrafı Seç',
      actionLabel: "Belgeyi PDF'e Tara",
      desc: 'Kamera veya galeriden alınan belge fotoğraflarını otomatik kontrast ve netleştirmeyle A4 PDF yapın.'
    },

    // 2. PDF'İ İYİLEŞTİR (3 Araç)
    {
      id: 'compress',
      cat: 'optimize',
      name: 'PDF Küçültme',
      badge: '↙',
      color: '#68b836',
      accept: '.pdf',
      btnLabel: 'PDF Dosyaları Seç',
      actionLabel: 'PDF Küçült',
      desc: 'Maksimum görüntü kalitesini koruyarak PDF dosyanızın boyutunu önemli ölçüde küçültün.'
    },
    {
      id: 'repair',
      cat: 'optimize',
      name: "PDF'i onar",
      badge: '🛠',
      color: '#68b836',
      accept: '.pdf',
      btnLabel: 'Bozuk PDF Seç',
      actionLabel: "PDF'i Onar",
      desc: 'Bozulmuş XRef tablolarını ve hasarlı PDF akışlarını onararak verilerinizi kurtarın.'
    },
    {
      id: 'ocr',
      cat: 'optimize',
      name: 'OCR PDF',
      badge: 'OCR',
      color: '#68b836',
      accept: '.pdf,.jpg,.png',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: 'OCR Metin Tanımayı Başlat',
      desc: 'Taranmış PDF belgelerini seçilebilir ve aranabilir metin katmanlı PDF dosyalarına dönüştürün.'
    },

    // 3. PDF'E DÖNÜŞTÜR (5 Araç)
    {
      id: 'jpg-to-pdf',
      cat: 'to-pdf',
      name: 'JPG PDF Çevirme',
      badge: 'JPG',
      color: '#f2b705',
      accept: '.jpg,.jpeg,.png,.webp',
      btnLabel: 'JPG Görüntüleri Seç',
      actionLabel: "PDF'e Dönüştür",
      desc: "Saniyeler içinde JPG görüntüleri PDF'e çevirin. Yönünü ve marjları kolayca ayarlayın."
    },
    {
      id: 'word-to-pdf',
      cat: 'to-pdf',
      name: 'Word PDF Çevirme',
      badge: 'W',
      color: '#3b6998',
      accept: '.docx,.doc',
      btnLabel: 'Word Dosyaları Seç',
      actionLabel: "Word'ü PDF'e Dönüştür",
      desc: 'DOC ve DOCX dosyalarını mizanpaj ve tablolarını koruyarak kolayca PDF belgesine dönüştürün.'
    },
    {
      id: 'ppt-to-pdf',
      cat: 'to-pdf',
      name: "POWERPOINT'den PDF'e",
      badge: 'P',
      color: '#D06F59',
      accept: '.pptx,.ppt',
      btnLabel: 'PowerPoint Dosyaları Seç',
      actionLabel: "Sunumu PDF'e Dönüştür",
      desc: 'PPT ve PPTX slayt gösterilerini kolayca okunabilir geniş ekran PDF belgesine dönüştürün.'
    },
    {
      id: 'excel-to-pdf',
      cat: 'to-pdf',
      name: 'Excel PDF Çevirme',
      badge: 'X',
      color: '#4caf50',
      accept: '.xlsx,.xls',
      btnLabel: 'Excel Dosyaları Seç',
      actionLabel: "Excel'i PDF'e Dönüştür",
      desc: 'Excel elektronik tablolarını hücre ve başlık yapısını koruyarak PDF sayfasına dönüştürün.'
    },
    {
      id: 'html-to-pdf',
      cat: 'to-pdf',
      name: "HTML'den PDF'e",
      badge: '🌐',
      color: '#f2b705',
      accept: '.html,.htm',
      btnLabel: 'HTML Dosyası Seç',
      actionLabel: "HTML'i PDF'e Dönüştür",
      desc: 'HTML web sayfalarını ve CSS stillerini tek tıkla vektörel PDF belgesine çevirin.'
    },

    // 4. PDF'DEN DÖNÜŞTÜR (5 Araç)
    {
      id: 'pdf-to-jpg',
      cat: 'from-pdf',
      name: 'PDF JPG Çevirme',
      badge: '🖼️',
      color: '#f2b705',
      accept: '.pdf',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: "JPG'ye Dönüştür",
      desc: 'Her bir PDF sayfasını yüksek çözünürlüklü (300 DPI) bir JPG görüntüsüne dönüştürün.'
    },
    {
      id: 'pdf-to-word',
      cat: 'from-pdf',
      name: 'PDF Word Çevirme',
      badge: 'W',
      color: '#3b6998',
      accept: '.pdf',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: "Word'e (.docx) Dönüştür",
      desc: 'PDF dosyalarınızı kolayca düzenlenebilir DOC ve DOCX belgelerine dönüştürün.'
    },
    {
      id: 'pdf-to-ppt',
      cat: 'from-pdf',
      name: "PDF'den POWERPOINT'e",
      badge: 'P',
      color: '#D06F59',
      accept: '.pdf',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: "PowerPoint'e (.pptx) Dönüştür",
      desc: 'PDF belgelerinizi düzenlenebilir PPT ve PPTX slayt sunumlarına dönüştürün.'
    },
    {
      id: 'pdf-to-excel',
      cat: 'from-pdf',
      name: "PDF'den EXCEL'e",
      badge: 'X',
      color: '#4caf50',
      accept: '.pdf',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: "Excel'e (.xlsx) Dönüştür",
      desc: 'PDF içerisindeki verileri ve tabloları saniyeler içinde Microsoft Excel elektronik tablolarına çekin.'
    },
    {
      id: 'pdf-to-pdfa',
      cat: 'from-pdf',
      name: "PDF'den PDF/A'ya",
      badge: '/A',
      color: '#4a76a8',
      accept: '.pdf',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: "PDF/A'ya Dönüştür",
      desc: 'Uzun süreli kurumsal arşivleme için PDF belgelerinizi ISO standartlı PDF/A-2b formatına çevirin.'
    },

    // 5. PDF'İ DÜZENLE (6 Araç)
    {
      id: 'rotate',
      cat: 'edit',
      name: "PDF'i döndür",
      badge: '↻',
      color: '#9b59b6',
      accept: '.pdf',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: "PDF'i Döndür",
      desc: 'PDF sayfalarını 90°, 180° veya 270° açıyla istediğiniz yöne döndürün.'
    },
    {
      id: 'page-numbers',
      cat: 'edit',
      name: 'Sayfa numarası ekle',
      badge: '123',
      color: '#9b59b6',
      accept: '.pdf',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: 'Sayfa Numarası Ekle',
      desc: 'PDF belgenize konum ve biçim seçerek otomatik sayfa numaraları ekleyin.'
    },
    {
      id: 'watermark',
      cat: 'edit',
      name: 'Filigran ekle',
      badge: 'STAMP',
      color: '#9b59b6',
      accept: '.pdf',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: 'Filigran Ekle',
      desc: 'PDF sayfalarınıza saniyeler içinde özel metin ve şeffaf kurumsal filigran damgası vurun.'
    },
    {
      id: 'crop',
      cat: 'edit',
      name: 'PDF Kırpma',
      badge: 'crop',
      color: '#9b59b6',
      accept: '.pdf',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: 'PDF Kenarlarını Kırp',
      desc: 'PDF belgenizin kenar boşluklarını ve görünür sayfa alanını hassas şekilde kırpın.'
    },
    {
      id: 'edit-pdf',
      cat: 'edit',
      name: "PDF'i düzenle",
      badge: '✎',
      color: '#9b59b6',
      accept: '.pdf',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: 'Düzenlemeyi Kaydet',
      desc: 'PDF sayfasına doğrudan metin kutusu, inceleme notu ve vurgu çerçevesi ekleyin.'
    },
    {
      id: 'forms',
      cat: 'edit',
      name: 'PDF Formlar',
      badge: '☑',
      color: '#9b59b6',
      accept: '.pdf',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: 'Form Alanlarını İşle',
      desc: 'Etkileşimli PDF form alanları (AcroForm) oluşturun ve form verilerini doğrudan belgeye işleyin.'
    },

    // 6. PDF GÜVENLİĞİ (5 Araç)
    {
      id: 'unlock',
      cat: 'security',
      name: 'PDF kilidini aç',
      badge: '🔓',
      color: '#4a76a8',
      accept: '.pdf',
      btnLabel: 'Kilitli PDF Seç',
      actionLabel: 'PDF Kilidini Aç',
      desc: 'PDF parola ve yazdırma/kopyalama kısıtlamalarını kaldırarak belgenizi özgürce kullanın.'
    },
    {
      id: 'protect',
      cat: 'security',
      name: "PDF'i koru",
      badge: '🛡',
      color: '#4a76a8',
      accept: '.pdf',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: "256-Bit AES ile Şifrele",
      desc: 'PDF dosyalarınızı yetkisiz erişime karşı gerçek 256-bit AES şifresiyle koruma altına alın.'
    },
    {
      id: 'sign',
      cat: 'security',
      name: 'PDF imzala',
      badge: '✒',
      color: '#4a76a8',
      accept: '.pdf',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: 'Belgeyi İmzala',
      desc: 'Canlı imza pedinde el yazısı imzanızı çizin ve zaman damgalı olarak PDF belgenize ekleyin.'
    },
    {
      id: 'redact',
      cat: 'security',
      name: "PDF'yi Düzelt",
      badge: '▬',
      color: '#4a76a8',
      accept: '.pdf',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: 'Hassas Veriyi Sansürle',
      desc: 'Gizli metinleri ve hassas bilgileri PDF içerisinden geri döndürülemez biçimde kalıcı olarak karartın.'
    },
    {
      id: 'compare',
      cat: 'security',
      name: 'PDF Karşılaştırma',
      badge: '⊞',
      color: '#4a76a8',
      accept: '.pdf',
      btnLabel: 'Karşılaştırılacak PDF Seç',
      actionLabel: 'İki PDF Belgesini Karşılaştır',
      desc: 'İki PDF sürümü arasındaki metin ve revizyon farklarını yan yana tespit eden fark raporu üretin.'
    },

    // 7. PDF INTELLIGENCE / YAPAY ZEKA (3 Araç)
    {
      id: 'ai-summary',
      cat: 'ai',
      name: 'Yapay Zeka Özetleyici',
      badge: '✨',
      color: '#6c5ce7',
      accept: '.pdf',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: 'Yapay Zeka ile Özetle',
      desc: 'Uzun PDF raporlarını saniyeler içinde analiz ederek yönetici özeti ve anahtar maddeler çıkarın.'
    },
    {
      id: 'translate',
      cat: 'ai',
      name: 'PDF çevir',
      badge: '文A',
      color: '#6c5ce7',
      accept: '.pdf',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: 'PDF Belgesini Çevir',
      desc: 'PDF belgelerinizi sayfa düzenini koruyarak Türkçe, İngilizce ve Almanca arasında çevirin.'
    },
    {
      id: 'pdf-to-markdown',
      cat: 'ai',
      name: "PDF'den Markdown'a",
      badge: '{#}',
      color: '#6c5ce7',
      accept: '.pdf',
      btnLabel: 'PDF Dosyası Seç',
      actionLabel: "Markdown'a (.md) Dönüştür",
      desc: 'PDF başlıklarını, maddelerini ve metin hiyerarşisini LLM/yazılım uyumlu temiz Markdown formatına çevirin.'
    }
  ];

  let activeCategory = 'all';
  let searchQuery = '';
  let currentTool = TOOLS[9]; // Varsayılan: JPG PDF Çevirme
  let uploadedFilePaths = [];
  let uploadedFileNames = [];
  let generatedFiles = [];
  let activeIosTab = 'home';
  let favoriteToolIds = ['jpg-to-pdf', 'merge', 'compress', 'pdf-to-word', 'sign', 'ai-summary'];

  // DOM Referansları
  const convertDropdown = document.getElementById('ConvertDropdown');
  const megaDropdown = document.getElementById('MegaDropdown');
  const matrixGrid7 = document.getElementById('MatrixGrid7');
  const matrixSection = document.getElementById('MatrixSection');
  const toolsGrid = document.getElementById('ToolsGrid');
  const allToolsGridSection = document.getElementById('AllToolsGridSection');
  const heroBanner = document.getElementById('HeroBanner');
  const toolWorkspaceView = document.getElementById('ToolWorkspaceView');
  const studioMainView = document.getElementById('StudioMainView');
  const appStoreMainView = document.getElementById('AppStoreMainView');
  const toastContainer = document.getElementById('ToastContainer');

  function showToast(msg, color) {
    const el = document.createElement('div');
    el.className = 'toast';
    if (color) el.style.borderLeftColor = color;
    el.textContent = msg;
    toastContainer.appendChild(el);
    setTimeout(() => el.remove(), 3400);
  }

  function closeAllDropdowns() {
    convertDropdown.classList.add('hidden');
    megaDropdown.classList.add('hidden');
    document.getElementById('NavConvertBtn').classList.remove('active');
    document.getElementById('NavAllToolsBtn').classList.remove('active');
  }

  // 1. AÇILIR MENÜLERİ VE 7 SÜTUNLU MATRİSİ OLUŞTUR
  function buildMenusAndMatrix() {
    // Convert Dropdown (2 Sütun: PDF'E DÖNÜŞTÜR & PDF'DEN DÖNÜŞTÜR - Ekran görüntüsü 215446.png)
    const toPdfTools = TOOLS.filter(t => t.cat === 'to-pdf');
    const fromPdfTools = TOOLS.filter(t => t.cat === 'from-pdf');

    document.getElementById('ConvertToCol').innerHTML = `
      <div class="mega-col-title">PDF'E DÖNÜŞTÜR</div>
      ${toPdfTools.map(t => `
        <button class="mega-item" data-open-tool="${t.id}">
          <span class="mega-icon" style="background:${t.color}">${t.badge}</span>
          <span>${t.name}</span>
        </button>
      `).join('')}
    `;

    document.getElementById('ConvertFromCol').innerHTML = `
      <div class="mega-col-title">PDF'DEN DÖNÜŞTÜR</div>
      ${fromPdfTools.map(t => `
        <button class="mega-item" data-open-tool="${t.id}">
          <span class="mega-icon" style="background:${t.color}">${t.badge}</span>
          <span>${t.name}</span>
        </button>
      `).join('')}
    `;

    // 7 Sütunlu Mega Menü & 7 Sütunlu Sayfa İçi Matris (Ekran görüntüsü 215347.png)
    const colsHtml = CATEGORIES.map(cat => {
      const catTools = TOOLS.filter(t => t.cat === cat.id);
      return `
        <div>
          <div class="mega-col-title">${cat.title}</div>
          ${catTools.map(t => `
            <button class="mega-item" data-open-tool="${t.id}">
              <span class="mega-icon" style="background:${t.color}">${t.badge}</span>
              <span>${t.name}</span>
            </button>
          `).join('')}
        </div>
      `;
    }).join('');

    megaDropdown.innerHTML = colsHtml;
    matrixGrid7.innerHTML = colsHtml;

    document.querySelectorAll('[data-open-tool]').forEach(btn => {
      btn.addEventListener('click', () => {
        const tid = btn.getAttribute('data-open-tool');
        closeAllDropdowns();
        openToolWorkspace(tid);
      });
    });
  }

  // 2. 30 ARAÇ KART IZGARASINI RENDER ET
  function renderToolsGrid() {
    const filtered = TOOLS.filter(t => {
      if (activeCategory !== 'all' && t.cat !== activeCategory) return false;
      if (searchQuery) {
        const q = searchQuery.toLowerCase();
        if (!`${t.name} ${t.desc}`.toLowerCase().includes(q)) return false;
      }
      return true;
    });

    toolsGrid.innerHTML = filtered.map(t => {
      const catObj = CATEGORIES.find(c => c.id === t.cat);
      return `
        <article class="tool-card" data-card-tool="${t.id}">
          <div class="tool-card-top">
            <div class="tool-badge-icon" style="background:${t.color}">${t.badge}</div>
            <span class="tool-cat-tag">${catObj ? catObj.title : ''}</span>
          </div>
          <h3>${t.name}</h3>
          <p>${t.desc}</p>
        </article>
      `;
    }).join('');

    toolsGrid.querySelectorAll('[data-card-tool]').forEach(card => {
      card.addEventListener('click', () => {
        openToolWorkspace(card.getAttribute('data-card-tool'));
      });
    });
  }

  // 3. SEÇİLEN ARACIN ÖZEL ÇALIŞMA EKRANINI AÇ
  function openToolWorkspace(toolId) {
    const tool = TOOLS.find(t => t.id === toolId) || TOOLS[0];
    currentTool = tool;
    uploadedFilePaths = [];
    uploadedFileNames = [];

    // Görünümü Stüdyo moduna geçir
    studioMainView.classList.remove('hidden');
    appStoreMainView.classList.add('hidden');
    document.getElementById('TabStudioBtn').classList.add('active');
    document.getElementById('TabAppStoreBtn').classList.remove('active');

    heroBanner.classList.add('hidden');
    matrixSection.classList.add('hidden');
    allToolsGridSection.classList.add('hidden');
    toolWorkspaceView.classList.remove('hidden');
    document.getElementById('WorkspaceResultCard').classList.add('hidden');

    const iconBadge = document.getElementById('WsToolIconBadge');
    iconBadge.style.background = tool.color;
    iconBadge.textContent = tool.badge;
    document.getElementById('WsToolTitle').textContent = tool.name;
    document.getElementById('WsToolDesc').textContent = tool.desc;
    document.getElementById('BtnPickFilesLabel').textContent = tool.btnLabel;
    document.getElementById('HiddenFileInput').setAttribute('accept', tool.accept);
    document.getElementById('WsSidebarHeading').textContent = `${tool.name} Seçenekleri`;
    document.getElementById('BtnExecuteToolText').textContent = tool.actionLabel;

    renderSelectedFiles();
    renderDynamicOptionsForTool(tool);
  }

  function renderSelectedFiles() {
    const listEl = document.getElementById('SelectedFilesList');
    if (uploadedFileNames.length === 0) {
      listEl.innerHTML = `
        <div class="file-pill-item" style="background:#F2EFE6; border-color:#bae6fd; color:#0369a1;">
          <span>ℹ️ Dosya seçmezseniz <strong>JawsPDF Hazır Örnek Belgesi</strong> ile otomatik çalışır.</span>
          <span style="font-weight:800;">Hazır ✓</span>
        </div>
      `;
      return;
    }
    listEl.innerHTML = uploadedFileNames.map((fn, idx) => `
      <div class="file-pill-item">
        <span>📄 ${fn}</span>
        <button class="ws-back-btn" data-remove-idx="${idx}" style="position:static; padding:4px 10px; font-size:11px;">Kaldır</button>
      </div>
    `).join('');

    listEl.querySelectorAll('[data-remove-idx]').forEach(btn => {
      btn.addEventListener('click', () => {
        const i = Number(btn.getAttribute('data-remove-idx'));
        uploadedFileNames.splice(i, 1);
        uploadedFilePaths.splice(i, 1);
        renderSelectedFiles();
      });
    });
  }

  // Araca özel yan panel seçeneklerini oluştur
  function renderDynamicOptionsForTool(tool) {
    const container = document.getElementById('WsDynamicOptions');

    if (tool.id === 'jpg-to-pdf') {
      container.innerHTML = `
        <div class="opt-group">
          <label class="opt-label">Sayfa Yönü</label>
          <div class="orientation-cards">
            <button type="button" class="orient-btn active" data-orient="portrait">📄 Dikey (Portre)</button>
            <button type="button" class="orient-btn" data-orient="landscape">🖼️ Yatay (Manzara)</button>
          </div>
          <input type="hidden" id="OptOrientation" value="portrait" />
        </div>
        <div class="opt-group">
          <label class="opt-label">Kenar Boşluğu (Marj)</label>
          <select id="OptMargin" class="opt-select">
            <option value="none">Kenar Boşluğu Yok</option>
            <option value="small" selected>Küçük Kenar Boşluğu (Önerilen)</option>
            <option value="big">Büyük Kenar Boşluğu</option>
          </select>
        </div>
      `;
      container.querySelectorAll('.orient-btn').forEach(b => {
        b.addEventListener('click', () => {
          container.querySelectorAll('.orient-btn').forEach(x => x.classList.remove('active'));
          b.classList.add('active');
          document.getElementById('OptOrientation').value = b.getAttribute('data-orient');
        });
      });
    } else if (tool.id === 'compress') {
      container.innerHTML = `
        <div class="opt-group">
          <label class="opt-label">Sıkıştırma Seviyesi</label>
          <select id="OptCompressionLevel" class="opt-select">
            <option value="extreme">Üstün Sıkıştırma (Maksimum Boyut Tasarrufu)</option>
            <option value="recommended" selected>Önerilen Sıkıştırma (Yüksek Kalite &amp; Küçük Boyut)</option>
            <option value="less">Daha Az Sıkıştırma (En Yüksek Görüntü Kalitesi)</option>
          </select>
        </div>
      `;
    } else if (tool.id === 'split') {
      container.innerHTML = `
        <div class="opt-group">
          <label class="opt-label">Ayrılacak Sayfa Aralığı</label>
          <input type="text" id="OptPageRange" class="opt-input" value="1-2" placeholder="Örn: 1-2 veya 1,3" />
        </div>
      `;
    } else if (tool.id === 'remove-pages') {
      container.innerHTML = `
        <div class="opt-group">
          <label class="opt-label">Kaldırılacak Sayfa Numaraları</label>
          <input type="text" id="OptPagesToRemove" class="opt-input" value="2" placeholder="Örn: 2 veya 1,3" />
        </div>
      `;
    } else if (tool.id === 'extract-pages') {
      container.innerHTML = `
        <div class="opt-group">
          <label class="opt-label">Ayıklanacak Sayfa Numaraları</label>
          <input type="text" id="OptPagesToExtract" class="opt-input" value="1,3" placeholder="Örn: 1,3" />
        </div>
      `;
    } else if (tool.id === 'organize') {
      container.innerHTML = `
        <div class="opt-group">
          <label class="opt-label">Yeni Sayfa Sıralaması (Boş bırakılırsa ters çevirir)</label>
          <input type="text" id="OptPageOrder" class="opt-input" value="3,1,2" placeholder="Örn: 3,1,2" />
        </div>
      `;
    } else if (tool.id === 'scan-to-pdf') {
      container.innerHTML = `
        <div class="opt-group">
          <label class="opt-label">📱 Telefon / Cihaz Kamerası</label>
          <input type="file" id="MobileCameraInput" accept="image/*" capture="environment" multiple style="display:none;" />
          <button type="button" id="BtnMobileCameraCapture" class="btn-select-files" style="width:100%; padding:11px 14px; font-size:13.5px; border-radius:10px; justify-content:center; margin-bottom:8px;">
            📸 Telefon Kamerasıyla Çek
          </button>
          <button type="button" id="BtnOpenLiveWebcam" class="btn-folder-top" style="width:100%; justify-content:center; padding:10px 14px;">
            🎥 Canlı Kamerayı Ekranda Aç
          </button>
        </div>
        <div id="LiveCameraBox" class="hidden" style="margin-bottom:14px; background:#141413; border-radius:12px; padding:10px; text-align:center;">
          <video id="LiveCameraVideo" autoplay playsinline style="width:100%; border-radius:8px; border:2px solid #D06F59; background:#000;"></video>
          <div style="display:flex; gap:8px; margin-top:8px;">
            <button type="button" id="BtnSnapFrame" class="btn-res-primary" style="flex:1;">📸 Fotoğraf Çek</button>
            <button type="button" id="BtnCloseCamera" class="btn-res-secondary" style="padding:8px 10px;">Kapat</button>
          </div>
        </div>
        <div class="opt-group">
          <label class="opt-label">Tarama Görsel Filtresi</label>
          <select id="OptScanFilter" class="opt-select">
            <option value="bw" selected>Siyah-Beyaz Net Belge (OCR Uyumlu)</option>
            <option value="gray">Gri Tonlama</option>
            <option value="color">Renkli Orijinal Kontrast</option>
          </select>
        </div>
      `;

      const mobInput = document.getElementById('MobileCameraInput');
      document.getElementById('BtnMobileCameraCapture').addEventListener('click', () => mobInput.click());
      mobInput.addEventListener('change', e => handleSelectedBrowserFiles(e.target.files));

      let activeStream = null;
      const camBox = document.getElementById('LiveCameraBox');
      const videoEl = document.getElementById('LiveCameraVideo');

      document.getElementById('BtnOpenLiveWebcam').addEventListener('click', async () => {
        try {
          activeStream = await navigator.mediaDevices.getUserMedia({
            video: { facingMode: { ideal: 'environment' }, width: { ideal: 1920 }, height: { ideal: 1080 } },
            audio: false
          });
          videoEl.srcObject = activeStream;
          camBox.classList.remove('hidden');
          showToast('🎥 Kamera açıldı! Belgeyi hizalayıp "Fotoğraf Çek" butonuna basın.', '#D06F59');
        } catch (err) {
          mobInput.click();
        }
      });

      document.getElementById('BtnSnapFrame').addEventListener('click', async () => {
        if (!videoEl.videoWidth) return;
        const c = document.createElement('canvas');
        c.width = videoEl.videoWidth;
        c.height = videoEl.videoHeight;
        c.getContext('2d').drawImage(videoEl, 0, 0);
        const dataUrl = c.toDataURL('image/jpeg', 0.92);
        const snapName = `Kamera_Belge_${Date.now()}.jpg`;
        try {
          const res = await fetch(`${API_BASE}/api/upload`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ files: [{ name: snapName, dataUrl }] })
          });
          const data = await res.json();
          if (data && data.ok) {
            uploadedFilePaths.push(...data.savedPaths);
            uploadedFileNames.push(snapName);
            renderSelectedFiles();
            showToast('📸 Kamera görüntüsü eklendi! Şimdi "Belgeyi PDF\'e Tara" butonuna basabilirsiniz.', '#16a34a');
          }
        } catch (_) {}
      });

      document.getElementById('BtnCloseCamera').addEventListener('click', () => {
        if (activeStream) {
          activeStream.getTracks().forEach(t => t.stop());
          activeStream = null;
        }
        camBox.classList.add('hidden');
      });
    } else if (tool.id === 'rotate') {
      container.innerHTML = `
        <div class="opt-group">
          <label class="opt-label">Döndürme Açısı (Saat Yönünde)</label>
          <select id="OptRotateAngle" class="opt-select">
            <option value="90" selected>Sağa 90° Döndür</option>
            <option value="180">180° Baş Aşağı Döndür</option>
            <option value="270">Sola 90° (270°) Döndür</option>
          </select>
        </div>
      `;
    } else if (tool.id === 'page-numbers') {
      container.innerHTML = `
        <div class="opt-group">
          <label class="opt-label">Sayfa Numarası Konumu</label>
          <select id="OptPageNumPos" class="opt-select">
            <option value="bottom-center" selected>Alt Orta (Sayfa 1 / N)</option>
            <option value="bottom-right">Alt Sağ Köşe</option>
            <option value="top-right">Üst Sağ Köşe</option>
          </select>
        </div>
      `;
    } else if (tool.id === 'watermark') {
      container.innerHTML = `
        <div class="opt-group">
          <label class="opt-label">Filigran Metni</label>
          <input type="text" id="OptWatermarkText" class="opt-input" value="JawsPDF ONAYLI" />
        </div>
      `;
    } else if (tool.id === 'crop') {
      container.innerHTML = `
        <div class="opt-group">
          <label class="opt-label">Kenar Boşluğu Kırpma Miktarı (Punto)</label>
          <input type="number" id="OptCropMargin" class="opt-input" value="28" min="5" max="120" />
        </div>
      `;
    } else if (tool.id === 'edit-pdf') {
      container.innerHTML = `
        <div class="opt-group">
          <label class="opt-label">Sayfaya Eklenecek Başlık / İnceleme Notu</label>
          <input type="text" id="OptEditText" class="opt-input" value="JawsPDF Kontrol Notu: Belge Onaylandı ✓" />
        </div>
      `;
    } else if (tool.id === 'forms') {
      container.innerHTML = `
        <div class="opt-group">
          <label class="opt-label">Form Alanı 1: Ad Soyad</label>
          <input type="text" id="OptFormName" class="opt-input" value="JawsPDF" />
        </div>
        <div class="opt-group">
          <label class="opt-label">Form Alanı 2: Onay / Açıklama</label>
          <input type="text" id="OptFormNote" class="opt-input" value="Kurumsal Onay Tamamlandı" />
        </div>
      `;
    } else if (tool.id === 'protect' || tool.id === 'unlock') {
      container.innerHTML = `
        <div class="opt-group">
          <label class="opt-label">${tool.id === 'protect' ? 'Belgeye Verilecek AES-256 Şifresi' : 'Açılacak PDF Şifresi'}</label>
          <input type="text" id="OptPassword" class="opt-input" value="Jaws2026" />
        </div>
      `;
    } else if (tool.id === 'sign') {
      container.innerHTML = `
        <div class="opt-group">
          <label class="opt-label">İmzalayan Adı Soyadı</label>
          <input type="text" id="OptSignerName" class="opt-input" value="JawsPDF" />
        </div>
        <div class="opt-group">
          <label class="opt-label">Canlı İmza Çizim Alanı (Fare ile çizebilirsiniz)</label>
          <canvas id="SignatureCanvas" width="300" height="110" style="border:1.5px dashed #D06F59; border-radius:10px; background:#FAF9F5; cursor:crosshair; width:100%;"></canvas>
          <button type="button" class="ws-back-btn" id="ClearSigBtn" style="position:static; margin-top:6px; font-size:11px; padding:4px 10px;">İmzayı Temizle</button>
        </div>
      `;
      initSignaturePad();
    } else if (tool.id === 'redact') {
      container.innerHTML = `
        <div class="opt-group">
          <label class="opt-label">Kalıcı Olarak Karartılacak Kelime / İfade</label>
          <input type="text" id="OptRedactTerm" class="opt-input" value="Gizlilik" />
        </div>
      `;
    } else if (tool.id === 'translate') {
      container.innerHTML = `
        <div class="opt-group">
          <label class="opt-label">Hedef Çeviri Dili</label>
          <select id="OptTargetLang" class="opt-select">
            <option value="EN" selected>İngilizce (English)</option>
            <option value="DE">Almanca (Deutsch)</option>
            <option value="TR">Türkçe (Turkish)</option>
          </select>
        </div>
      `;
    } else {
      container.innerHTML = `
        <div class="opt-group">
          <label class="opt-label">İşlem Kalitesi</label>
          <select class="opt-select">
            <option selected>Yüksek Hassasiyet (Vektörel &amp; 300 DPI)</option>
            <option>Hızlı Standart Mod</option>
          </select>
        </div>
      `;
    }
  }

  function initSignaturePad() {
    const canvas = document.getElementById('SignatureCanvas');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    ctx.strokeStyle = '#D06F59';
    ctx.lineWidth = 2.6;
    ctx.lineCap = 'round';

    // Başlangıçta örnek zarif bir imza çizgisi koy
    ctx.beginPath();
    ctx.moveTo(35, 75);
    ctx.bezierCurveTo(85, 25, 140, 95, 210, 45);
    ctx.lineTo(255, 65);
    ctx.stroke();

    let drawing = false;
    const getPos = e => {
      const r = canvas.getBoundingClientRect();
      const clientX = e.touches ? e.touches[0].clientX : e.clientX;
      const clientY = e.touches ? e.touches[0].clientY : e.clientY;
      return {
        x: ((clientX - r.left) / r.width) * canvas.width,
        y: ((clientY - r.top) / r.height) * canvas.height
      };
    };

    canvas.addEventListener('mousedown', e => {
      drawing = true;
      const p = getPos(e);
      ctx.beginPath();
      ctx.moveTo(p.x, p.y);
    });
    canvas.addEventListener('mousemove', e => {
      if (!drawing) return;
      const p = getPos(e);
      ctx.lineTo(p.x, p.y);
      ctx.stroke();
    });
    window.addEventListener('mouseup', () => { drawing = false; });

    const clearBtn = document.getElementById('ClearSigBtn');
    if (clearBtn) {
      clearBtn.addEventListener('click', () => {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
      });
    }
  }

  function collectToolOptions() {
    const opts = {};
    const val = id => {
      const el = document.getElementById(id);
      return el ? el.value : undefined;
    };
    if (val('OptOrientation')) opts.orientation = val('OptOrientation');
    if (val('OptMargin')) opts.margin = val('OptMargin');
    if (val('OptCompressionLevel')) opts.compressionLevel = val('OptCompressionLevel');
    if (val('OptPageRange')) opts.pageRange = val('OptPageRange');
    if (val('OptPagesToRemove')) opts.pagesToRemove = val('OptPagesToRemove');
    if (val('OptPagesToExtract')) opts.pagesToExtract = val('OptPagesToExtract');
    if (val('OptPageOrder')) opts.pageOrder = val('OptPageOrder');
    if (val('OptScanFilter')) opts.scanFilter = val('OptScanFilter');
    if (val('OptRotateAngle')) opts.angle = Number(val('OptRotateAngle'));
    if (val('OptPageNumPos')) opts.position = val('OptPageNumPos');
    if (val('OptWatermarkText')) opts.watermarkText = val('OptWatermarkText');
    if (val('OptCropMargin')) opts.cropMarginPt = Number(val('OptCropMargin'));
    if (val('OptEditText')) opts.editText = val('OptEditText');
    if (val('OptFormName')) opts.formName = val('OptFormName');
    if (val('OptFormNote')) opts.formNote = val('OptFormNote');
    if (val('OptPassword')) opts.password = val('OptPassword');
    if (val('OptSignerName')) opts.signerName = val('OptSignerName');
    if (val('OptRedactTerm')) opts.redactTerm = val('OptRedactTerm');
    if (val('OptTargetLang')) opts.targetLang = val('OptTargetLang');

    const sigCanvas = document.getElementById('SignatureCanvas');
    if (sigCanvas) {
      opts.signatureDataUrl = sigCanvas.toDataURL('image/png');
    }
    return opts;
  }

  // 4. DOSYA SEÇİMİ VE SÜRÜKLE-BIRAK YÜKLEME
  async function handleSelectedBrowserFiles(fileList) {
    if (!fileList || fileList.length === 0) return;
    showToast('📤 Dosyalar yerel motora aktarılıyor…', '#D06F59');

    const payloadFiles = [];
    for (const file of Array.from(fileList)) {
      const dataUrl = await new Promise(resolve => {
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result);
        reader.readAsDataURL(file);
      });
      payloadFiles.push({ name: file.name, dataUrl });
    }

    try {
      const res = await fetch(`${API_BASE}/api/upload`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ files: payloadFiles })
      });
      const data = await res.json();
      if (data && data.ok) {
        uploadedFilePaths.push(...data.savedPaths);
        uploadedFileNames.push(...payloadFiles.map(f => f.name));
        renderSelectedFiles();
        showToast(`✓ ${payloadFiles.length} dosya hazır!`, '#16a34a');
      }
    } catch (_) {
      showToast('Sunucu bağlantısı bekleniyor…', '#D06F59');
    }
  }

  // 5. SEÇİLİ ARACI ÇALIŞTIR (/api/run-tool)
  async function executeToolOnBackend(toolId, customOptions) {
    const btn = document.getElementById('BtnExecuteTool');
    const origText = document.getElementById('BtnExecuteToolText').textContent;
    document.getElementById('BtnExecuteToolText').textContent = 'İşleniyor… Lütfen Bekleyin';
    btn.disabled = true;

    try {
      const res = await fetch(`${API_BASE}/api/run-tool`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          toolId: toolId || currentTool.id,
          inputFiles: uploadedFilePaths,
          options: customOptions || collectToolOptions()
        })
      });
      const data = await res.json();
      btn.disabled = false;
      document.getElementById('BtnExecuteToolText').textContent = origText;

      if (!data || !data.ok) {
        showToast(`Hata: ${(data && data.error) || 'İşlem başarısız oldu'}`, '#D06F59');
        return null;
      }

      if (Array.isArray(data.files)) {
        generatedFiles = data.files;
      }

      // Sonuç kartını doldur ve göster
      const resCard = document.getElementById('WorkspaceResultCard');
      resCard.classList.remove('hidden');
      document.getElementById('ResultFileName').textContent = `${data.outputName} (${data.sizeKB} KB)`;
      document.getElementById('ResultSummaryText').textContent = data.summary;

      const thumb = document.getElementById('ResultPreviewThumb');
      if (data.previewDataUrl) {
        thumb.src = data.previewDataUrl;
        thumb.style.display = 'block';
      } else {
        thumb.style.display = 'none';
      }

      const extraPre = document.getElementById('ResultExtraText');
      const extraContent =
        data.extra &&
        (data.extra.aiText ||
          data.extra.extractedText ||
          data.extra.markdownPreview ||
          data.extra.translatedPreview ||
          data.extra.diffPreview);
      if (extraContent) {
        extraPre.textContent = extraContent;
        extraPre.classList.remove('hidden');
      } else {
        extraPre.classList.add('hidden');
      }

      document.getElementById('BtnDownloadResult').href = `${API_BASE}${data.downloadUrl}`;
      document.getElementById('BtnDownloadResult').setAttribute('download', data.outputName);
      document.getElementById('BtnOpenResultInline').href = `${API_BASE}${data.inlineUrl}`;

      showToast(`✓ ${data.outputName} başarıyla oluşturuldu!`, '#16a34a');
      return data;
    } catch (e) {
      btn.disabled = false;
      document.getElementById('BtnExecuteToolText').textContent = origText;
      showToast('Yerel motor yanıt vermedi.', '#D06F59');
      return null;
    }
  }

  // 6. ÇIKTI KLASÖRÜNÜ VE MODALINI AÇ
  async function openOutputFolderModal() {
    try {
      const res = await fetch(`${API_BASE}/api/open-folder`, { method: 'POST' });
      const data = await res.json();
      if (data && Array.isArray(data.files)) {
        generatedFiles = data.files;
      }
    } catch (_) {}

    const listEl = document.getElementById('OutputFilesModalList');
    if (!generatedFiles || generatedFiles.length === 0) {
      listEl.innerHTML = `<div style="text-align:center; padding:24px; color:#78766F;">Henüz üretilmiş bir dosya yok. Herhangi bir aracı çalıştırdığınızda burada listelenir.</div>`;
    } else {
      listEl.innerHTML = generatedFiles.map(f => `
        <div class="file-pill-item" style="background:#FAF9F5;">
          <div style="min-width:0; flex:1;">
            <div style="font-weight:800; color:#141413;">📄 ${f.name}</div>
            <div style="font-size:11.5px; color:#78766F;">Boyut: <strong>${f.sizeKB} KB</strong> • ${f.mtime} • <code>${f.fullPath}</code></div>
          </div>
          <div style="display:flex; gap:6px;">
            <a class="btn-res-secondary" href="${API_BASE}${f.inlineUrl}" target="_blank" style="padding:6px 10px; font-size:12px;">▶️ Aç</a>
            <a class="btn-res-primary" href="${API_BASE}${f.downloadUrl}" download="${f.name}" style="padding:6px 10px; font-size:12px;">💾 İndir</a>
          </div>
        </div>
      `).join('');
    }
    document.getElementById('OutputFolderModal').classList.remove('hidden');
    showToast('📂 Çıktı klasörü ve Windows Gezgini açıldı.');
  }

  // 7. iPHONE 16 PRO SİMÜLATÖRÜ (5 SEKME TAM ETKİLEŞİMLİ)
  function renderIphoneSimulator() {
    const body = document.getElementById('IphoneBodyContent');
    const badge = document.getElementById('IosActiveTabBadge');

    if (activeIosTab === 'home') {
      badge.textContent = 'Ana Ekran';
      const recentSlice = generatedFiles.slice(0, 3);
      body.innerHTML = `
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
          <strong style="font-size:13px;">Son dosyalar</strong>
          <button id="IosRefreshFilesBtn" style="border:none; background:transparent; color:#D06F59; font-size:11.5px; font-weight:700; cursor:pointer;">Yenile</button>
        </div>
        <div style="display:grid; grid-template-columns:repeat(3,1fr); gap:8px; margin-bottom:16px;">
          ${
            recentSlice.length > 0
              ? recentSlice.map(f => `
                  <a href="${API_BASE}${f.inlineUrl}" target="_blank" style="text-decoration:none; background:#FAF9F5; border:1px solid #E6E4DC; border-radius:10px; padding:10px 6px; text-align:center; color:#141413;">
                    <div style="font-size:20px;">📄</div>
                    <div style="font-size:10px; font-weight:700; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; margin-top:4px;">${f.name}</div>
                    <div style="font-size:9px; color:#78766F;">${f.sizeKB} KB</div>
                  </a>
                `).join('')
              : `<div style="grid-column:span 3; background:#FAF9F5; border:1px solid #E6E4DC; border-radius:10px; padding:12px; font-size:11px; color:#78766F; text-align:center;">Bir araca tıklayarak ilk PDF çıktınızı üretin.</div>`
          }
        </div>

        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
          <strong style="font-size:13px;">Favori Araçlar ⭐</strong>
          <button id="IosSeeAllToolsBtn" style="border:none; background:transparent; color:#D06F59; font-size:11.5px; font-weight:700; cursor:pointer;">Tümünü göster</button>
        </div>
        <div class="ios-mini-grid">
          ${TOOLS.filter(t => favoriteToolIds.includes(t.id)).map(t => `
            <div class="ios-mini-card" data-ios-run="${t.id}">
              <div class="mega-icon" style="background:${t.color}; margin:0 auto;">${t.badge}</div>
              <span>${t.name}</span>
            </div>
          `).join('')}
        </div>
      `;
    } else if (activeIosTab === 'files') {
      badge.textContent = `Dosyalar (${generatedFiles.length})`;
      body.innerHTML = `
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
          <strong style="font-size:13px;">Üretilen Belgelerim</strong>
          <button id="IosOpenFolderBtn" style="border:none; background:#F6E6E1; color:#D06F59; padding:4px 8px; border-radius:6px; font-size:11px; font-weight:700; cursor:pointer;">📂 Klasörü Aç</button>
        </div>
        <div style="display:flex; flex-direction:column; gap:8px;">
          ${
            generatedFiles.length > 0
              ? generatedFiles.map(f => `
                  <div style="background:#FAF9F5; border:1px solid #E6E4DC; border-radius:10px; padding:10px; display:flex; align-items:center; justify-content:space-between;">
                    <div style="min-width:0; flex:1;">
                      <div style="font-size:11.5px; font-weight:800; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">📄 ${f.name}</div>
                      <div style="font-size:10px; color:#78766F;">${f.sizeKB} KB • ${f.mtime}</div>
                    </div>
                    <a href="${API_BASE}${f.downloadUrl}" download="${f.name}" style="background:#16a34a; color:#fff; text-decoration:none; font-size:10.5px; font-weight:700; padding:5px 9px; border-radius:6px;">İndir</a>
                  </div>
                `).join('')
              : `<div style="text-align:center; padding:24px; font-size:12px; color:#78766F;">Henüz dosya yok.</div>`
          }
        </div>
      `;
    } else if (activeIosTab === 'tools') {
      badge.textContent = '30 PDF Aracı';
      body.innerHTML = `
        <div style="font-size:11px; color:#78766F; margin-bottom:10px;">Araca dokunduğunuzda anında çalıştırılır:</div>
        <div class="ios-mini-grid">
          ${TOOLS.map(t => `
            <div class="ios-mini-card" data-ios-run="${t.id}">
              <div class="mega-icon" style="background:${t.color}; margin:0 auto;">${t.badge}</div>
              <span>${t.name}</span>
            </div>
          `).join('')}
        </div>
      `;
    } else if (activeIosTab === 'scanner') {
      badge.textContent = 'Kamera Tarayıcı';
      body.innerHTML = `
        <div style="background:#F2EFE6; color:#141413; border:1px solid #E6E4DC; border-radius:16px; padding:14px; text-align:center;">
          <div style="font-size:11px; color:#D06F59; font-weight:700; margin-bottom:8px;">iOS VisionKit Otomatik Belge Algılayıcı</div>
          <div style="background:#FAF9F5; color:#141413; border:3px solid #D06F59; border-radius:10px; padding:16px; min-height:220px; text-align:left;">
            <div style="display:flex; justify-content:space-between;">
              <strong style="font-size:12px; color:#D06F59;">JawsPDF SCANNER</strong>
              <span style="font-size:10px; background:#dcfce7; color:#15803d; padding:2px 6px; border-radius:99px; font-weight:700;">Kenar Algılandı ✓</span>
            </div>
            <p style="font-size:11px; color:#3D3C37; margin-top:10px; line-height:1.5;">
              Belge perspektifi otomatik düzeltildi. Aşağıdaki deklanşör butonuna basarak doğrudan yüksek kontrastlı A4 PDF oluşturun.
            </p>
            <div style="margin-top:14px;">
              <label style="font-size:10.5px; font-weight:700; color:#5E5D57;">Filtre Modu:</label>
              <select id="IosScanFilterSelect" class="opt-select" style="padding:6px; font-size:11px; margin-top:4px;">
                <option value="bw" selected>Siyah-Beyaz Net Belge</option>
                <option value="color">Renkli Tarama</option>
              </select>
            </div>
          </div>
          <button id="IosTriggerScanBtn" style="margin-top:14px; width:58px; height:58px; border-radius:50%; border:4px solid #D06F59; background:#FAF9F5; cursor:pointer; font-size:22px;" title="Belgeyi PDF'e Tara">📸</button>
          <div style="font-size:11px; color:#5E5D57; margin-top:4px;">Deklanşöre Bas &amp; PDF Üret</div>
        </div>
      `;
    } else if (activeIosTab === 'templates') {
      badge.textContent = 'Şablon Oluşturucu';
      body.innerHTML = `
        <div style="background:#FAF9F5; border:1px solid #E6E4DC; border-radius:14px; padding:12px;">
          <div style="font-size:12.5px; font-weight:800; color:#141413; margin-bottom:8px;">Düzenlenebilir Şablondan PDF Üret</div>
          <div class="opt-group" style="margin-bottom:10px;">
            <label class="opt-label" style="font-size:11px;">Şablon Türü</label>
            <select id="IosTplType" class="opt-select" style="padding:7px; font-size:12px;">
              <option value="cv" selected>Profesyonel CV / Özgeçmiş</option>
              <option value="sozlesme">Kurumsal Hizmet Sözleşmesi</option>
              <option value="fatura">Resmi Teklif &amp; Fatura</option>
            </select>
          </div>
          <div class="opt-group" style="margin-bottom:10px;">
            <label class="opt-label" style="font-size:11px;">Ad Soyad / Başlık</label>
            <input type="text" id="IosTplName" class="opt-input" value="JawsPDF" style="padding:7px; font-size:12px;" />
          </div>
          <div class="opt-group" style="margin-bottom:10px;">
            <label class="opt-label" style="font-size:11px;">Unvan / Konu</label>
            <input type="text" id="IosTplRole" class="opt-input" value="Yazılım &amp; Ürün Mimarı" style="padding:7px; font-size:12px;" />
          </div>
          <div class="opt-group" style="margin-bottom:12px;">
            <label class="opt-label" style="font-size:11px;">İçerik Özeti</label>
            <textarea id="IosTplBio" class="opt-input" rows="3" style="padding:7px; font-size:11.5px;">JawsPDF 30-Araçlı iOS, iPadOS ve Masaüstü Belge Stüdyosu.</textarea>
          </div>
          <button id="IosCreateTemplatePdfBtn" class="btn-execute-tool" style="padding:10px; font-size:13px;">
            <span>➔ Şablondan PDF Oluştur</span>
          </button>
        </div>
      `;
    }

    // Simülatör içi dinamik buton dinleyicileri
    body.querySelectorAll('[data-ios-run]').forEach(card => {
      card.addEventListener('click', async () => {
        const tid = card.getAttribute('data-ios-run');
        showToast(`📱 iOS üzerinde '${tid}' çalıştırılıyor…`, '#D06F59');
        const res = await executeToolOnBackend(tid, {});
        if (res && res.ok) {
          activeIosTab = 'files';
          updateIosTabBarUI();
          renderIphoneSimulator();
        }
      });
    });

    const refreshBtn = document.getElementById('IosRefreshFilesBtn');
    if (refreshBtn) refreshBtn.addEventListener('click', syncServerStatus);

    const seeAllBtn = document.getElementById('IosSeeAllToolsBtn');
    if (seeAllBtn) {
      seeAllBtn.addEventListener('click', () => {
        activeIosTab = 'tools';
        updateIosTabBarUI();
        renderIphoneSimulator();
      });
    }

    const iosFolderBtn = document.getElementById('IosOpenFolderBtn');
    if (iosFolderBtn) iosFolderBtn.addEventListener('click', openOutputFolderModal);

    const scanBtn = document.getElementById('IosTriggerScanBtn');
    if (scanBtn) {
      scanBtn.addEventListener('click', async () => {
        const filter = document.getElementById('IosScanFilterSelect').value;
        showToast('📸 Belge taranıyor ve netleştiriliyor…', '#D06F59');
        const res = await executeToolOnBackend('scan-to-pdf', { scanFilter: filter });
        if (res && res.ok) {
          activeIosTab = 'files';
          updateIosTabBarUI();
          renderIphoneSimulator();
        }
      });
    }

    const tplBtn = document.getElementById('IosCreateTemplatePdfBtn');
    if (tplBtn) {
      tplBtn.addEventListener('click', async () => {
        const opts = {
          templateType: document.getElementById('IosTplType').value,
          personName: document.getElementById('IosTplName').value,
          personRole: document.getElementById('IosTplRole').value,
          personBio: document.getElementById('IosTplBio').value
        };
        const res = await executeToolOnBackend('template-pdf', opts);
        if (res && res.ok) {
          activeIosTab = 'files';
          updateIosTabBarUI();
          renderIphoneSimulator();
        }
      });
    }
  }

  function updateIosTabBarUI() {
    document.querySelectorAll('#IphoneTabBar .iphone-tab-btn').forEach(b => {
      b.classList.toggle('active', b.getAttribute('data-iostab') === activeIosTab);
    });
  }

  async function syncServerStatus() {
    try {
      const res = await fetch(`${API_BASE}/api/status`);
      const data = await res.json();
      if (data && Array.isArray(data.files)) {
        generatedFiles = data.files;
        renderIphoneSimulator();
      }
    } catch (_) {}
  }

  // 8. TÜM GENEL BUTON DİNLEYİCİLERİ
  document.getElementById('BrandHomeBtn').addEventListener('click', () => {
    closeAllDropdowns();
    studioMainView.classList.remove('hidden');
    appStoreMainView.classList.add('hidden');
    heroBanner.classList.remove('hidden');
    matrixSection.classList.remove('hidden');
    allToolsGridSection.classList.remove('hidden');
    toolWorkspaceView.classList.add('hidden');
    document.getElementById('TabStudioBtn').classList.add('active');
    document.getElementById('TabAppStoreBtn').classList.remove('active');
  });

  document.querySelectorAll('[data-quick-tool]').forEach(btn => {
    btn.addEventListener('click', () => {
      closeAllDropdowns();
      openToolWorkspace(btn.getAttribute('data-quick-tool'));
    });
  });

  document.getElementById('NavConvertBtn').addEventListener('click', e => {
    e.stopPropagation();
    const isHidden = convertDropdown.classList.contains('hidden');
    closeAllDropdowns();
    if (isHidden) {
      convertDropdown.classList.remove('hidden');
      document.getElementById('NavConvertBtn').classList.add('active');
    }
  });

  document.getElementById('NavAllToolsBtn').addEventListener('click', e => {
    e.stopPropagation();
    const isHidden = megaDropdown.classList.contains('hidden');
    closeAllDropdowns();
    if (isHidden) {
      megaDropdown.classList.remove('hidden');
      document.getElementById('NavAllToolsBtn').classList.add('active');
    }
  });

  document.addEventListener('click', e => {
    if (!e.target.closest('#ConvertDropdown') && !e.target.closest('#NavConvertBtn') &&
        !e.target.closest('#MegaDropdown') && !e.target.closest('#NavAllToolsBtn')) {
      closeAllDropdowns();
    }
  });

  document.getElementById('TabStudioBtn').addEventListener('click', () => {
    document.getElementById('TabStudioBtn').classList.add('active');
    document.getElementById('TabAppStoreBtn').classList.remove('active');
    studioMainView.classList.remove('hidden');
    appStoreMainView.classList.add('hidden');
  });

  document.getElementById('TabAppStoreBtn').addEventListener('click', () => {
    document.getElementById('TabAppStoreBtn').classList.add('active');
    document.getElementById('TabStudioBtn').classList.remove('active');
    appStoreMainView.classList.remove('hidden');
    studioMainView.classList.add('hidden');
    syncServerStatus();
  });

  document.getElementById('BtnSwitchBackStudio').addEventListener('click', () => {
    document.getElementById('TabStudioBtn').click();
  });

  document.getElementById('BtnJumpSimulator').addEventListener('click', () => {
    document.getElementById('LiveSimulatorSection').scrollIntoView({ behavior: 'smooth' });
  });

  document.getElementById('PosterCreateTemplateBtn').addEventListener('click', () => {
    activeIosTab = 'templates';
    updateIosTabBarUI();
    renderIphoneSimulator();
    document.getElementById('LiveSimulatorSection').scrollIntoView({ behavior: 'smooth' });
  });

  document.getElementById('ToggleMatrixBtn').addEventListener('click', () => {
    matrixSection.classList.toggle('hidden');
  });

  document.querySelectorAll('#CategoryPillsBar .cat-pill').forEach(pill => {
    pill.addEventListener('click', () => {
      document.querySelectorAll('#CategoryPillsBar .cat-pill').forEach(p => p.classList.remove('active'));
      pill.classList.add('active');
      activeCategory = pill.getAttribute('data-cat');
      renderToolsGrid();
    });
  });

  document.getElementById('ToolSearchInput').addEventListener('input', e => {
    searchQuery = e.target.value;
    renderToolsGrid();
  });

  document.getElementById('WsBackBtn').addEventListener('click', () => {
    heroBanner.classList.remove('hidden');
    matrixSection.classList.remove('hidden');
    allToolsGridSection.classList.remove('hidden');
    toolWorkspaceView.classList.add('hidden');
  });

  document.getElementById('BtnPickFiles').addEventListener('click', () => {
    document.getElementById('HiddenFileInput').click();
  });

  document.getElementById('HiddenFileInput').addEventListener('change', e => {
    handleSelectedBrowserFiles(e.target.files);
  });

  const dropzone = document.getElementById('DropzoneBox');
  dropzone.addEventListener('dragover', e => {
    e.preventDefault();
    dropzone.classList.add('dragover');
  });
  dropzone.addEventListener('dragleave', () => {
    dropzone.classList.remove('dragover');
  });
  dropzone.addEventListener('drop', e => {
    e.preventDefault();
    dropzone.classList.remove('dragover');
    handleSelectedBrowserFiles(e.dataTransfer.files);
  });

  document.getElementById('BtnLoadSample').addEventListener('click', () => {
    uploadedFilePaths = [];
    uploadedFileNames = [`JawsPDF_Hazir_Ornek_Dosya (${currentTool.name})`];
    renderSelectedFiles();
    executeToolOnBackend(currentTool.id);
  });

  document.getElementById('BtnExecuteTool').addEventListener('click', () => {
    executeToolOnBackend(currentTool.id);
  });

  document.getElementById('BtnOpenOutputFolder').addEventListener('click', openOutputFolderModal);
  document.getElementById('BtnResultOpenFolder').addEventListener('click', openOutputFolderModal);
  document.getElementById('CloseOutputModalBtn').addEventListener('click', () => {
    document.getElementById('OutputFolderModal').classList.add('hidden');
  });
  document.getElementById('CloseOutputModalFooterBtn').addEventListener('click', () => {
    document.getElementById('OutputFolderModal').classList.add('hidden');
  });
  document.getElementById('ForceExplorerOpenBtn').addEventListener('click', () => {
    fetch(`${API_BASE}/api/open-folder`, { method: 'POST' }).catch(() => {});
    showToast('🖥️ Windows Gezgini masaüstünde açıldı!');
  });

  document.querySelectorAll('#IphoneTabBar .iphone-tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      activeIosTab = btn.getAttribute('data-iostab');
      updateIosTabBarUI();
      renderIphoneSimulator();
    });
  });

  // Başlangıç
  buildMenusAndMatrix();
  renderToolsGrid();
  syncServerStatus();
})();
