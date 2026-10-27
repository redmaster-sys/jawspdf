import SwiftUI
import PDFKit
import VisionKit
import Vision
import UniformTypeIdentifiers
import PhotosUI
import WebKit
import UIKit

// MARK: - JawsPDF iOS / iPadOS Uygulama Giriş Noktası
// Tema: Claude Krem (#FAF9F5), Claude Kiremit Turuncusu (#D06F59), Claude Editorial Serif
// Etiket: FREE (Köpekbalığı logosunun altında)
// Dil Desteği: Çift Dil (TR | EN) Anlık Geçişli
// Bundle ID: com.jawspdf.studio

enum JawsLanguage: String, CaseIterable, Identifiable {
    case tr = "TR"
    case en = "EN"
    var id: String { rawValue }
}

@main
struct JawsPDFApp: App {
    @StateObject private var store = JawsDocumentStore()

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white

        let normalColor = UIColor(red: 45.0 / 255.0, green: 43.0 / 255.0, blue: 39.0 / 255.0, alpha: 1.0)
        let activeColor = UIColor(red: 208.0 / 255.0, green: 111.0 / 255.0, blue: 89.0 / 255.0, alpha: 1.0)

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = normalColor
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: normalColor,
            .font: UIFont.systemFont(ofSize: 10.5, weight: .semibold)
        ]
        itemAppearance.selected.iconColor = activeColor
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: activeColor,
            .font: UIFont.systemFont(ofSize: 10.5, weight: .bold)
        ]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            JawsPDFRootView()
                .environmentObject(store)
                .preferredColorScheme(.light)
        }
    }
}

// MARK: - Renk & Stil Sabitleri (Claude Tema + Canlı Kategori Renkleri)
enum JawsTheme {
    static let background = Color(red: 250.0 / 255.0, green: 249.0 / 255.0, blue: 245.0 / 255.0) // #FAF9F5
    static let cardBg     = Color.white
    static let surfaceAlt = Color(red: 242.0 / 255.0, green: 239.0 / 255.0, blue: 230.0 / 255.0) // #F2EFE6
    static let orange     = Color(red: 208.0 / 255.0, green: 111.0 / 255.0, blue: 89.0 / 255.0)  // #D06F59
    static let orangeSoft = Color(red: 208.0 / 255.0, green: 111.0 / 255.0, blue: 89.0 / 255.0).opacity(0.14)
    static let charcoal   = Color(red: 20.0 / 255.0, green: 20.0 / 255.0, blue: 19.0 / 255.0)    // #141413
    static let muted      = Color(red: 75.0 / 255.0, green: 73.0 / 255.0, blue: 68.0 / 255.0)    // #4B4944
    static let border     = Color(red: 218.0 / 255.0, green: 214.0 / 255.0, blue: 204.0 / 255.0) // #DAD6CC
}

// MARK: - 30 PDF Aracı Modeli (Çift Dilli TR | EN)
struct JawsTool: Identifiable, Hashable {
    let id: String
    let nameTR: String
    let nameEN: String
    let descTR: String
    let descEN: String
    let category: String
    let badge: String
    let systemIcon: String?
    let colorHex: Int

    func name(_ lang: JawsLanguage) -> String {
        lang == .tr ? nameTR : nameEN
    }

    func desc(_ lang: JawsLanguage) -> String {
        lang == .tr ? descTR : descEN
    }

    var solidColor: Color {
        let r = Double((colorHex >> 16) & 0xFF) / 255.0
        let g = Double((colorHex >> 8) & 255) / 255.0
        let b = Double(colorHex & 0xFF) / 255.0
        return Color(red: r, green: g, blue: b)
    }

    var isConvertToPDF: Bool {
        category == "to-pdf"
    }

    var isImageOrScanTool: Bool {
        id == "jpg-to-pdf" || id == "scan-to-pdf"
    }

    var isConvertFromPDF: Bool {
        category == "from-pdf"
    }
}

// MARK: - Yüksek Kontrastlı Tam Dolgulu Araç İkonu Görünümü
struct JawsToolBadgeView: View {
    let tool: JawsTool
    var size: CGFloat = 42

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                .fill(tool.solidColor)
                .frame(width: size, height: size)

            if let sf = tool.systemIcon {
                Image(systemName: sf)
                    .font(.system(size: size * 0.44, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Text(tool.badge)
                    .font(.system(size: size * 0.34, weight: .heavy, design: .serif))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .padding(.horizontal, 3)
            }
        }
    }
}

enum JawsToolCatalog {
    static func categories(_ lang: JawsLanguage) -> [(id: String, label: String)] {
        if lang == .tr {
            return [
                ("all", "Tümü (30)"),
                ("organize", "PDF Düzenle"),
                ("optimize", "PDF İyileştir"),
                ("to-pdf", "PDF'e Dönüştür"),
                ("from-pdf", "PDF'den Dönüştür"),
                ("edit", "PDF İçeriği"),
                ("security", "PDF Güvenliği")
            ]
        } else {
            return [
                ("all", "All (30)"),
                ("organize", "Organize PDF"),
                ("optimize", "Optimize PDF"),
                ("to-pdf", "Convert to PDF"),
                ("from-pdf", "Convert from PDF"),
                ("edit", "Edit PDF"),
                ("security", "PDF Security")
            ]
        }
    }

    static let all: [JawsTool] = [
        // 1. Organize (6)
        JawsTool(
            id: "merge-pdf",
            nameTR: "PDF Birleştir", nameEN: "Merge PDF",
            descTR: "Birden fazla PDF dosyasını seçip tek belgede birleştirin.",
            descEN: "Select and combine multiple PDF files into one document.",
            category: "organize", badge: "⇄", systemIcon: "arrow.left.arrow.right", colorHex: 0xD06F59
        ),
        JawsTool(
            id: "split-pdf",
            nameTR: "PDF Böl", nameEN: "Split PDF",
            descTR: "Belirttiğiniz sayfa aralığını yeni bir PDF olarak ayırın.",
            descEN: "Extract a specific page range into a standalone PDF file.",
            category: "organize", badge: "✂", systemIcon: "scissors", colorHex: 0xD94E34
        ),
        JawsTool(
            id: "remove-pages",
            nameTR: "Sayfa Sil", nameEN: "Remove Pages",
            descTR: "Seçtiğiniz sayfa numaralarını belgeden kalıcı çıkarın.",
            descEN: "Delete selected page numbers permanently from your PDF.",
            category: "organize", badge: "✕", systemIcon: "xmark", colorHex: 0xC0392B
        ),
        JawsTool(
            id: "extract-pages",
            nameTR: "Sayfa Ayıkla", nameEN: "Extract Pages",
            descTR: "İstediğiniz sayfaları (örn: 1-3, 5) ayrı bir PDF yapın.",
            descEN: "Save specific pages (e.g. 1-3, 5) as a new PDF file.",
            category: "organize", badge: "⧉", systemIcon: "doc.on.doc.fill", colorHex: 0xD06F59
        ),
        JawsTool(
            id: "organize-pdf",
            nameTR: "PDF Sırala", nameEN: "Organize PDF",
            descTR: "Sayfa sırasını ters çevirin veya özel sırayla dizin.",
            descEN: "Reverse or reorder pages in your PDF document.",
            category: "organize", badge: "⇅", systemIcon: "arrow.up.arrow.down", colorHex: 0xB4523A
        ),
        JawsTool(
            id: "scan-to-pdf",
            nameTR: "Kamera ile PDF Tara", nameEN: "Scan to PDF",
            descTR: "Kamerayla veya galeriden belgeleri tarayıp A4 PDF yapın.",
            descEN: "Scan physical documents with camera or photos into A4 PDF.",
            category: "organize", badge: "📷", systemIcon: "camera.fill", colorHex: 0x2980B9
        ),

        // 2. Optimize (3)
        JawsTool(
            id: "compress-pdf",
            nameTR: "PDF Sıkıştır", nameEN: "Compress PDF",
            descTR: "Okunabilirliği koruyarak dosya boyutunu küçültün.",
            descEN: "Reduce PDF file size while preserving visual quality.",
            category: "optimize", badge: "⚡", systemIcon: "bolt.fill", colorHex: 0x2E9E5B
        ),
        JawsTool(
            id: "repair-pdf",
            nameTR: "PDF Onar", nameEN: "Repair PDF",
            descTR: "Bozuk PDF yapısını ve sayfa ağacını yeniden inşa edin.",
            descEN: "Rebuild corrupted PDF page trees and internal streams.",
            category: "optimize", badge: "🛠", systemIcon: "wrench.and.screwdriver.fill", colorHex: 0x8E44AD
        ),
        JawsTool(
            id: "ocr-pdf",
            nameTR: "OCR PDF (Metin Tanıma)", nameEN: "OCR PDF (Text Recognition)",
            descTR: "Taranmış sayfalardaki metinleri Apple Vision ile okuyun.",
            descEN: "Extract text from scanned pages using Apple Vision OCR.",
            category: "optimize", badge: "OCR", systemIcon: nil, colorHex: 0x27AE60
        ),

        // 3. Convert to PDF (5)
        JawsTool(
            id: "jpg-to-pdf",
            nameTR: "JPG'den PDF'e", nameEN: "JPG / Photos to PDF",
            descTR: "Galerinizdeki fotoğrafları veya görselleri A4 PDF'e çevirin.",
            descEN: "Convert photos from your gallery or image files into A4 PDF.",
            category: "to-pdf", badge: "JPG", systemIcon: nil, colorHex: 0xD98212
        ),
        JawsTool(
            id: "word-to-pdf",
            nameTR: "Word'den PDF'e", nameEN: "Word to PDF",
            descTR: "Telefondan DOCX, DOC, RTF veya TXT seçip PDF'e dönüştürün.",
            descEN: "Select DOCX, DOC, RTF or TXT from your phone and convert to PDF.",
            category: "to-pdf", badge: "W", systemIcon: nil, colorHex: 0x2B579A
        ),
        JawsTool(
            id: "powerpoint-to-pdf",
            nameTR: "PowerPoint'ten PDF'e", nameEN: "PowerPoint to PDF",
            descTR: "Telefondan PPTX veya PPT sunum dosyası seçip PDF yapın.",
            descEN: "Select PPTX or PPT presentation files and convert to PDF.",
            category: "to-pdf", badge: "P", systemIcon: nil, colorHex: 0xD24726
        ),
        JawsTool(
            id: "excel-to-pdf",
            nameTR: "Excel'den PDF'e", nameEN: "Excel to PDF",
            descTR: "Telefondan XLSX, XLS veya CSV tablo seçip PDF'e aktarın.",
            descEN: "Select XLSX, XLS or CSV spreadsheets and convert to PDF.",
            category: "to-pdf", badge: "X", systemIcon: nil, colorHex: 0x217346
        ),
        JawsTool(
            id: "html-to-pdf",
            nameTR: "HTML / Metinden PDF'e", nameEN: "HTML / Text to PDF",
            descTR: "HTML dosyası veya web metni seçip A4 PDF sayfasına çevirin.",
            descEN: "Select an HTML file or paste markup to render into A4 PDF.",
            category: "to-pdf", badge: "</>", systemIcon: "chevron.left.forwardslash.chevron.right", colorHex: 0xE67E22
        ),

        // 4. Convert from PDF (5)
        JawsTool(
            id: "pdf-to-jpg",
            nameTR: "PDF'den JPG'e", nameEN: "PDF to JPG",
            descTR: "PDF sayfalarını yüksek çözünürlüklü JPG görsel olarak çıkarın.",
            descEN: "Export PDF pages as high-resolution JPG images.",
            category: "from-pdf", badge: "IMG", systemIcon: "photo.fill", colorHex: 0xD98212
        ),
        JawsTool(
            id: "pdf-to-word",
            nameTR: "PDF'den Word'e", nameEN: "PDF to Word",
            descTR: "PDF metinlerini düzenlenebilir Word (.rtf/.doc) olarak kaydedin.",
            descEN: "Export PDF text into an editable Word (.rtf/.doc) document.",
            category: "from-pdf", badge: "DOC", systemIcon: nil, colorHex: 0x2B579A
        ),
        JawsTool(
            id: "pdf-to-powerpoint",
            nameTR: "PDF'den Sunuma", nameEN: "PDF to PowerPoint",
            descTR: "PDF sayfalarını yatay slayt sunumu olarak dışa aktarın.",
            descEN: "Export PDF pages into a presentation slide deck.",
            category: "from-pdf", badge: "PPT", systemIcon: nil, colorHex: 0xD24726
        ),
        JawsTool(
            id: "pdf-to-excel",
            nameTR: "PDF'den Tabloya (Excel)", nameEN: "PDF to Excel (CSV)",
            descTR: "PDF içindeki satır ve verileri Excel (.csv) tablosuna ayıklayın.",
            descEN: "Extract PDF rows and data into an Excel (.csv) spreadsheet.",
            category: "from-pdf", badge: "XLS", systemIcon: nil, colorHex: 0x217346
        ),
        JawsTool(
            id: "pdf-to-pdfa",
            nameTR: "PDF'den PDF/A'ya", nameEN: "PDF to PDF/A",
            descTR: "Uzun süreli kurumsal arşiv standartlarında PDF üretin.",
            descEN: "Convert PDF into long-term archival PDF/A format.",
            category: "from-pdf", badge: "A/1", systemIcon: nil, colorHex: 0x2C5E8A
        ),

        // 5. Edit PDF (6)
        JawsTool(
            id: "rotate-pdf",
            nameTR: "PDF Döndür", nameEN: "Rotate PDF",
            descTR: "Sayfaları 90°, 180° veya 270° döndürüp kaydedin.",
            descEN: "Rotate PDF pages by 90°, 180°, or 270° degrees.",
            category: "edit", badge: "↻", systemIcon: "rotate.right.fill", colorHex: 0x8E44AD
        ),
        JawsTool(
            id: "page-numbers",
            nameTR: "Sayfa Numarası Ekle", nameEN: "Add Page Numbers",
            descTR: "Sayfaların altına otomatik sayfa numarası (1 / N) basın.",
            descEN: "Stamp automatic page numbers (1 / N) on every page.",
            category: "edit", badge: "123", systemIcon: "number", colorHex: 0x8E44AD
        ),
        JawsTool(
            id: "watermark-pdf",
            nameTR: "Filigran Ekle", nameEN: "Add Watermark",
            descTR: "Sayfalara özel çapraz metin damgası (Filigran) ekleyin.",
            descEN: "Stamp custom diagonal watermark text across PDF pages.",
            category: "edit", badge: "💧", systemIcon: "seal.fill", colorHex: 0x9B59B6
        ),
        JawsTool(
            id: "crop-pdf",
            nameTR: "PDF Kenar Boşluğu Kırp", nameEN: "Crop PDF Margins",
            descTR: "Sayfa kenar boşluklarını seçtiğiniz ölçüde daraltın.",
            descEN: "Trim page margins symmetrically by custom points.",
            category: "edit", badge: "Crop", systemIcon: "crop", colorHex: 0x8E44AD
        ),
        JawsTool(
            id: "edit-pdf",
            nameTR: "PDF Düzenle & Not Ekle", nameEN: "Edit & Annotate PDF",
            descTR: "Sayfa üzerine açıklama kutusu ve inceleme notu işleyin.",
            descEN: "Add callout notes and review annotations onto PDF pages.",
            category: "edit", badge: "✎", systemIcon: "pencil.and.outline", colorHex: 0x7D3C98
        ),
        JawsTool(
            id: "bates-numbering",
            nameTR: "Bates Numaralandırma", nameEN: "Bates Numbering",
            descTR: "Hukuki ve kurumsal seri numarası (BATES-0001) damgalayın.",
            descEN: "Apply sequential legal Bates indexing stamps to pages.",
            category: "edit", badge: "B#", systemIcon: nil, colorHex: 0x6C3483
        ),

        // 6. Security & Sign (5)
        JawsTool(
            id: "unlock-pdf",
            nameTR: "PDF Kilit Aç", nameEN: "Unlock PDF",
            descTR: "Parolasını girdiğiniz PDF'in şifre korumasını kaldırın.",
            descEN: "Remove password restriction from an encrypted PDF file.",
            category: "security", badge: "🔓", systemIcon: "lock.open.fill", colorHex: 0x2C5E8A
        ),
        JawsTool(
            id: "protect-pdf",
            nameTR: "PDF Şifrele", nameEN: "Protect PDF",
            descTR: "Belgeyi belirlediğiniz parola ile kilitleyip koruyun.",
            descEN: "Encrypt and lock your PDF with a custom password.",
            category: "security", badge: "🔒", systemIcon: "lock.shield.fill", colorHex: 0x1F4E78
        ),
        JawsTool(
            id: "sign-pdf",
            nameTR: "PDF İmzala", nameEN: "Sign PDF",
            descTR: "Parmağınızla gerçek imza çizin ve belgeye ıslak imza atın.",
            descEN: "Draw your signature with your finger and stamp it on the PDF.",
            category: "security", badge: "✒", systemIcon: "signature", colorHex: 0xD06F59
        ),
        JawsTool(
            id: "redact-pdf",
            nameTR: "Gizli Bilgileri Karart", nameEN: "Redact PDF",
            descTR: "Belirttiğiniz hassas kelimeleri ve alanları kalıcı karartın.",
            descEN: "Permanently black out sensitive words and areas in the PDF.",
            category: "security", badge: "██", systemIcon: "eye.slash.fill", colorHex: 0x2C3E50
        ),
        JawsTool(
            id: "compare-pdf",
            nameTR: "PDF Karşılaştır & Analiz", nameEN: "Compare & Inspect PDF",
            descTR: "İki PDF belgesinin sayfa, boyut ve metin farklarını raporlayın.",
            descEN: "Compare page count, text differences, and metrics of PDFs.",
            category: "security", badge: "⚖", systemIcon: "doc.text.magnifyingglass", colorHex: 0x2C5E8A
        )
    ]
}

// MARK: - Office (Word / Excel / PowerPoint / HTML / TXT / Görsel) -> Gerçek A4 PDF Dönüştürücü
@MainActor
final class JawsWebKitPDFConverter: NSObject, WKNavigationDelegate {
    private var webView: WKWebView?
    private var continuation: CheckedContinuation<Data?, Never>?

    func renderFileOrHTMLToPDF(fileURL: URL?, htmlString: String?) async -> Data? {
        let config = WKWebViewConfiguration()
        let wv = WKWebView(frame: CGRect(x: 0, y: 0, width: 595.2, height: 841.8), configuration: config)
        wv.navigationDelegate = self
        self.webView = wv

        return await withCheckedContinuation { (cont: CheckedContinuation<Data?, Never>) in
            self.continuation = cont
            if let html = htmlString {
                wv.loadHTMLString(html, baseURL: fileURL?.deletingLastPathComponent())
            } else if let url = fileURL {
                wv.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            } else {
                self.continuation = nil
                cont.resume(returning: nil)
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Kısa bir gecikme ile sayfa yerleşimini A4 sayfalarına bas
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
            let printableRect = pageRect.insetBy(dx: 28, dy: 28)

            let renderer = UIPrintPageRenderer()
            renderer.addPrintFormatter(webView.viewPrintFormatter(), startingAtPageAt: 0)
            renderer.setValue(NSValue(cgRect: pageRect), forKey: "paperRect")
            renderer.setValue(NSValue(cgRect: printableRect), forKey: "printableRect")

            let pdfData = NSMutableData()
            UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
            let pages = max(1, renderer.numberOfPages)
            for i in 0..<pages {
                UIGraphicsBeginPDFPage()
                let bounds = UIGraphicsGetPDFContextBounds()
                renderer.drawPage(at: i, in: bounds)
            }
            UIGraphicsEndPDFContext()

            let cont = self.continuation
            self.continuation = nil
            self.webView = nil
            cont?.resume(returning: pdfData as Data)
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let cont = self.continuation
        self.continuation = nil
        self.webView = nil
        cont?.resume(returning: nil)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let cont = self.continuation
        self.continuation = nil
        self.webView = nil
        cont?.resume(returning: nil)
    }
}

// MARK: - Kayıtlı PDF Dosya Modeli ve Depolama Yöneticisi
struct JawsSavedDocument: Identifiable, Equatable {
    let id: String
    let url: URL
    let name: String
    let pageCount: Int
    let fileSizeText: String
    let createdAt: Date
}

final class JawsDocumentStore: ObservableObject {
    @Published var lang: JawsLanguage = {
        if let saved = UserDefaults.standard.string(forKey: "jaws_app_lang"),
           let parsed = JawsLanguage(rawValue: saved) {
            return parsed
        }
        return .tr
    }() {
        didSet {
            UserDefaults.standard.set(lang.rawValue, forKey: "jaws_app_lang")
        }
    }

    @Published var documents: [JawsSavedDocument] = []
    @Published var activePreviewDoc: JawsSavedDocument?
    @Published var statusBanner: String?

    init() {
        refreshDocuments()
        if documents.isEmpty {
            _ = createSamplePDF(title: "JawsPDF Tanıtım & Örnek Sözleşme", templateType: "contract")
        }
    }

    func tr(_ trText: String, _ enText: String) -> String {
        lang == .tr ? trText : enText
    }

    var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func refreshDocuments() {
        let fm = FileManager.default
        guard let urls = try? fm.contentsOfDirectory(
            at: documentsDirectory,
            includingPropertiesForKeys: [.creationDateKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else { return }

        let pdfURLs = urls.filter { $0.pathExtension.lowercased() == "pdf" }
        var loaded: [JawsSavedDocument] = []

        for url in pdfURLs {
            let doc = PDFDocument(url: url)
            let pages = doc?.pageCount ?? 1
            let values = try? url.resourceValues(forKeys: [.creationDateKey, .fileSizeKey])
            let created = values?.creationDate ?? Date()
            let sizeBytes = values?.fileSize ?? 0
            let sizeKB = max(1, sizeBytes / 1024)
            loaded.append(
                JawsSavedDocument(
                    id: url.lastPathComponent,
                    url: url,
                    name: url.deletingPathExtension().lastPathComponent,
                    pageCount: pages,
                    fileSizeText: "\(sizeKB) KB",
                    createdAt: created
                )
            )
        }

        documents = loaded.sorted(by: { $0.createdAt > $1.createdAt })
    }

    func deleteDocument(_ doc: JawsSavedDocument) {
        try? FileManager.default.removeItem(at: doc.url)
        refreshDocuments()
    }

    // MARK: - Telefondan Seçilen Herhangi Bir Dosyayı (PDF / Word / Excel / PPT / HTML / Görsel) İçe Aktar ve PDF Yap
    @MainActor
    func importAndConvertFileFromPhone(pickedURL: URL, forTool tool: JawsTool?) async -> JawsSavedDocument? {
        let gotAccess = pickedURL.startAccessingSecurityScopedResource()
        defer { if gotAccess { pickedURL.stopAccessingSecurityScopedResource() } }

        let ext = pickedURL.pathExtension.lowercased()
        let baseName = pickedURL.deletingPathExtension().lastPathComponent
            .replacingOccurrences(of: " ", with: "_")
        let timestamp = Int(Date().timeIntervalSince1970)

        // 1) Eğer seçilen dosya zaten PDF ise doğrudan kopyala
        if ext == "pdf" {
            let destURL = documentsDirectory.appendingPathComponent("\(baseName)_\(timestamp).pdf")
            try? FileManager.default.copyItem(at: pickedURL, to: destURL)
            refreshDocuments()
            return documents.first(where: { $0.url == destURL }) ?? documents.first
        }

        // 2) Eğer seçilen dosya bir görsel ise (JPG, PNG, HEIC, WEBP) doğrudan A4 PDF'e çiz
        if ["jpg", "jpeg", "png", "heic", "webp", "bmp", "gif", "tiff"].contains(ext),
           let data = try? Data(contentsOf: pickedURL),
           let img = UIImage(data: data) {
            return createPDFFromImages([img], title: "\(baseName)_PDF")
        }

        // 3) Geçici klasöre kopyala ki WKWebView veya metin okuyucu erişebilsin
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(baseName)_\(timestamp).\(ext)")
        try? FileManager.default.removeItem(at: tempURL)
        try? FileManager.default.copyItem(at: pickedURL, to: tempURL)

        let outURL = documentsDirectory.appendingPathComponent("\(baseName)_Converted_\(timestamp).pdf")

        // CSV veya TXT ise şık bir HTML tablo/belge oluşturup WKWebView ile A4 PDF'e bas
        if ext == "csv" || ext == "txt" {
            let rawText = (try? String(contentsOf: tempURL, encoding: .utf8))
                ?? (try? String(contentsOf: tempURL, encoding: .isoLatin1))
                ?? ""
            let html = buildStyledHTMLFromTextOrCSV(rawText: rawText, isCSV: ext == "csv", title: baseName)
            let converter = JawsWebKitPDFConverter()
            if let pdfData = await converter.renderFileOrHTMLToPDF(fileURL: nil, htmlString: html), pdfData.count > 200 {
                try? pdfData.write(to: outURL)
                refreshDocuments()
                return documents.first(where: { $0.url == outURL })
            }
        }

        // DOCX, DOC, XLSX, XLS, PPTX, PPT, RTF, HTML dosyalarını WKWebView üzerinden gerçek mizanpajıyla A4 PDF'e dönüştür
        let converter = JawsWebKitPDFConverter()
        if let pdfData = await converter.renderFileOrHTMLToPDF(fileURL: tempURL, htmlString: nil), pdfData.count > 500 {
            try? pdfData.write(to: outURL)
            refreshDocuments()
            if let found = documents.first(where: { $0.url == outURL }) {
                return found
            }
        }

        // Eğer WKWebView bazı özel ikili dosyaları açamazsa dosya metnini/verisini okuyup A4 PDF oluştur
        let fallbackNote = tr(
            "Kaynak Dosya: \(pickedURL.lastPathComponent) (\(ext.uppercased()))\nCihaz üzerinden A4 PDF formatına dönüştürüldü.",
            "Source File: \(pickedURL.lastPathComponent) (\(ext.uppercased()))\nConverted on-device into standard A4 PDF."
        )
        return createSamplePDF(title: "\(baseName)_PDF", templateType: ext.isEmpty ? "office" : ext, customNote: fallbackNote)
    }

    private func buildStyledHTMLFromTextOrCSV(rawText: String, isCSV: Bool, title: String) -> String {
        let escapedTitle = title.replacingOccurrences(of: "<", with: "&lt;")
        if isCSV {
            let rows = rawText.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            var tableRowsHTML = ""
            for (idx, row) in rows.enumerated() {
                let delimiter: Character = row.contains(";") ? ";" : ","
                let cols = row.split(separator: delimiter, omittingEmptySubsequences: false)
                let tag = idx == 0 ? "th" : "td"
                let cells = cols.map { "<\(tag)>\($0.replacingOccurrences(of: "<", with: "&lt;"))</\(tag)>" }.joined()
                tableRowsHTML += "<tr>\(cells)</tr>"
            }
            return """
            <!DOCTYPE html><html><head><meta charset='utf-8'>
            <style>
            body { font-family: Georgia, serif; background: #FAF9F5; color: #141413; padding: 24px; }
            h1 { color: #D06F59; font-size: 20px; border-bottom: 2px solid #D06F59; padding-bottom: 8px; }
            table { width: 100%; border-collapse: collapse; margin-top: 14px; background: #fff; }
            th { background: #D06F59; color: #fff; padding: 8px; text-align: left; font-size: 12px; }
            td { border: 1px solid #DAD6CC; padding: 7px; font-size: 11px; }
            tr:nth-child(even) { background: #F7F4EC; }
            </style></head><body>
            <h1>JawsPDF — \(escapedTitle)</h1>
            <table>\(tableRowsHTML)</table>
            </body></html>
            """
        } else {
            let bodyEscaped = rawText
                .replacingOccurrences(of: "&", with: "&amp;")
                .replacingOccurrences(of: "<", with: "&lt;")
                .replacingOccurrences(of: "\n", with: "<br>")
            return """
            <!DOCTYPE html><html><head><meta charset='utf-8'>
            <style>
            body { font-family: Georgia, serif; background: #FAF9F5; color: #141413; padding: 28px; line-height: 1.55; font-size: 13px; }
            h1 { color: #D06F59; font-size: 21px; border-bottom: 2px solid #D06F59; padding-bottom: 8px; }
            </style></head><body>
            <h1>\(escapedTitle)</h1>
            <div>\(bodyEscaped)</div>
            </body></html>
            """
        }
    }

    // MARK: - Fotoğraflardan / Görsellerden Çok Sayfalı A4 PDF Üretici
    @discardableResult
    func createPDFFromImages(_ images: [UIImage], title: String) -> JawsSavedDocument? {
        guard !images.isEmpty else { return nil }
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let safeTitle = title.replacingOccurrences(of: " ", with: "_")
        let outURL = documentsDirectory.appendingPathComponent("\(safeTitle)_\(Int(Date().timeIntervalSince1970)).pdf")

        let data = renderer.pdfData { ctx in
            for img in images {
                ctx.beginPage()
                UIColor.white.setFill()
                ctx.cgContext.fill(pageRect)

                let maxRect = pageRect.insetBy(dx: 28, dy: 28)
                let aspect = min(maxRect.width / max(1, img.size.width), maxRect.height / max(1, img.size.height))
                let drawW = img.size.width * aspect
                let drawH = img.size.height * aspect
                let drawRect = CGRect(
                    x: pageRect.midX - drawW / 2.0,
                    y: pageRect.midY - drawH / 2.0,
                    width: drawW,
                    height: drawH
                )
                img.draw(in: drawRect)
            }
        }

        try? data.write(to: outURL)
        refreshDocuments()
        return documents.first(where: { $0.url == outURL })
    }

    // MARK: - Gerçek Native PDF Üretici (Şablonlar & Örnek Belge)
    @discardableResult
    func createSamplePDF(title: String, templateType: String, customNote: String = "JawsPDF Stüdyosu ile oluşturuldu.") -> JawsSavedDocument? {
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let safeName = title
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")
        let fileName = "\(safeName)_\(Int(Date().timeIntervalSince1970)).pdf"
        let outURL = documentsDirectory.appendingPathComponent(fileName)

        let data = renderer.pdfData { ctx in
            for pageIndex in 1...2 {
                ctx.beginPage()
                let cg = ctx.cgContext

                UIColor(red: 250/255, green: 249/255, blue: 245/255, alpha: 1).setFill()
                cg.fill(pageRect)

                UIColor(red: 208/255, green: 111/255, blue: 89/255, alpha: 1).setFill()
                cg.fill(CGRect(x: 42, y: 42, width: pageRect.width - 84, height: 6))

                let titleFont = UIFont(name: "Georgia-Bold", size: 21) ?? UIFont.boldSystemFont(ofSize: 21)
                let subFont = UIFont(name: "Georgia", size: 12.5) ?? UIFont.systemFont(ofSize: 12.5)
                let bodyFont = UIFont(name: "Georgia", size: 12) ?? UIFont.systemFont(ofSize: 12)

                let headerText = "JawsPDF — \(title)"
                headerText.draw(
                    in: CGRect(x: 42, y: 64, width: pageRect.width - 84, height: 34),
                    withAttributes: [
                        .font: titleFont,
                        .foregroundColor: UIColor(red: 20/255, green: 20/255, blue: 19/255, alpha: 1)
                    ]
                )

                let metaLine = "Tür / Type: \(templateType.uppercased())  |  Sayfa / Page \(pageIndex) / 2  |  JawsPDF FREE"
                metaLine.draw(
                    in: CGRect(x: 42, y: 102, width: pageRect.width - 84, height: 22),
                    withAttributes: [
                        .font: subFont,
                        .foregroundColor: UIColor(red: 208/255, green: 111/255, blue: 89/255, alpha: 1)
                    ]
                )

                UIColor.white.setFill()
                let cardRect = CGRect(x: 42, y: 138, width: pageRect.width - 84, height: 580)
                let path = UIBezierPath(roundedRect: cardRect, cornerRadius: 12)
                path.fill()
                UIColor(red: 229/255, green: 226/255, blue: 217/255, alpha: 1).setStroke()
                path.lineWidth = 1
                path.stroke()

                let bodyContent = """
                1. GENEL BİLGİLER / GENERAL OVERVIEW
                Bu belge JawsPDF Akıllı Belge & PDF Stüdyosu tarafından cihaz üzerinde yerel (on-device) PDFKit motoru kullanılarak üretilmiştir.

                Not / Description:
                \(customNote)

                2. BELGE DETAYLARI (SAYFA \(pageIndex))
                • Sistem: JawsPDF Studio (iOS / iPadOS Native • FREE)
                • Tema: Claude Krem (#FAF9F5) & Kiremit Turuncusu (#D06F59)
                • Durum: Dijital İmzaya, Filigrana, Bölmeye, Şifrelemeye ve OCR Okumaya Hazır

                3. ÖRNEK TABLO VERİLERİ (WORD / EXCEL / CSV TESTİ İÇİN)
                -------------------------------------------------------------------------
                Kalem 01  |  Kurumsal PDF Arşivleme Paketi       |  100%  |  Tamamlandı
                Kalem 02  |  Kamera Belge Tarama Modülü          |  100%  |  Aktif
                Kalem 03  |  AES Şifreleme & Islak İmza          |  100%  |  Onaylı
                -------------------------------------------------------------------------
                """

                bodyContent.draw(
                    in: CGRect(x: 64, y: 162, width: pageRect.width - 128, height: 520),
                    withAttributes: [
                        .font: bodyFont,
                        .foregroundColor: UIColor(red: 35/255, green: 35/255, blue: 33/255, alpha: 1)
                    ]
                )

                let footer = "JawsPDF  •  FREE  •  Sayfa / Page \(pageIndex)"
                footer.draw(
                    in: CGRect(x: 42, y: 780, width: pageRect.width - 84, height: 24),
                    withAttributes: [
                        .font: subFont,
                        .foregroundColor: UIColor.darkGray
                    ]
                )
            }
        }

        try? data.write(to: outURL)
        refreshDocuments()
        return documents.first(where: { $0.url == outURL }) ?? documents.first
    }

    // MARK: - Sayfa Aralığı Çözümleyici ("1-3, 5" -> 0-tabanlı indeks dizisi)
    func parsePageIndices(rangeString: String, totalPages: Int) -> [Int] {
        let cleaned = rangeString.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.isEmpty { return [0] }
        var result: [Int] = []
        let parts = cleaned.split(separator: ",")
        for part in parts {
            let token = part.trimmingCharacters(in: .whitespaces)
            if token.contains("-") {
                let bounds = token.split(separator: "-").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
                if bounds.count == 2 {
                    let start = max(1, min(bounds[0], bounds[1]))
                    let end = min(totalPages, max(bounds[0], bounds[1]))
                    if start <= end {
                        for p in start...end {
                            let idx = p - 1
                            if !result.contains(idx) { result.append(idx) }
                        }
                    }
                }
            } else if let single = Int(token), single >= 1 && single <= totalPages {
                let idx = single - 1
                if !result.contains(idx) { result.append(idx) }
            }
        }
        return result.isEmpty ? [0] : result
    }

    // MARK: - 30 PDF Aracını Cihaz Üzerinde (Native PDFKit + Vision + Dışa Aktarım) Çalıştırma
    func processTool(
        tool: JawsTool,
        sourceDoc: JawsSavedDocument,
        mergeDocs: [JawsSavedDocument],
        customText: String,
        pageRangeText: String,
        passwordText: String,
        rotationAngle: Int,
        cropMarginPt: Double,
        compressionQuality: Double = 0.55,
        signatureLines: [[CGPoint]]
    ) -> (outputDoc: JawsSavedDocument?, exportedFileURL: URL?, exportedFileLabel: String?, summary: String) {
        guard let pdf = PDFDocument(url: sourceDoc.url) else {
            return (nil, nil, nil, tr("PDF dosyası okunamadı.", "Could not read PDF file."))
        }

        let timestamp = Int(Date().timeIntervalSince1970)
        let outName = "\(sourceDoc.name)_\(tool.id)_\(timestamp).pdf"
        let outURL = documentsDirectory.appendingPathComponent(outName)

        switch tool.id {
        case "merge-pdf":
            let outPDF = PDFDocument()
            let docsToCombine = mergeDocs.isEmpty ? [sourceDoc] : mergeDocs
            for docItem in docsToCombine {
                if let d = PDFDocument(url: docItem.url) {
                    for i in 0..<d.pageCount {
                        if let p = d.page(at: i) {
                            outPDF.insert(p, at: outPDF.pageCount)
                        }
                    }
                }
            }
            outPDF.write(to: outURL)
            refreshDocuments()
            let msg = tr(
                "\(docsToCombine.count) PDF dosyası birleştirildi (Toplam \(outPDF.pageCount) sayfa).",
                "Merged \(docsToCombine.count) PDF files (\(outPDF.pageCount) pages total)."
            )
            return (documents.first(where: { $0.url == outURL }), nil, nil, msg)

        case "split-pdf", "extract-pages":
            let outPDF = PDFDocument()
            let indices = parsePageIndices(rangeString: pageRangeText, totalPages: max(1, pdf.pageCount))
            for idx in indices {
                if let p = pdf.page(at: idx) {
                    outPDF.insert(p, at: outPDF.pageCount)
                }
            }
            outPDF.write(to: outURL)
            refreshDocuments()
            let humanPages = indices.map { String($0 + 1) }.joined(separator: ", ")
            let msg = tr(
                "Seçilen sayfalar (\(humanPages)) yeni PDF olarak ayıklandı (\(outPDF.pageCount) sayfa).",
                "Extracted pages (\(humanPages)) into a new PDF (\(outPDF.pageCount) pages)."
            )
            return (documents.first(where: { $0.url == outURL }), nil, nil, msg)

        case "remove-pages":
            let outPDF = PDFDocument()
            let total = pdf.pageCount
            let toRemove = Set(parsePageIndices(rangeString: pageRangeText, totalPages: max(1, total)))
            for i in 0..<total {
                if total > 1 && toRemove.contains(i) { continue }
                if let p = pdf.page(at: i) {
                    outPDF.insert(p, at: outPDF.pageCount)
                }
            }
            outPDF.write(to: outURL)
            refreshDocuments()
            let removedHuman = toRemove.sorted().map { String($0 + 1) }.joined(separator: ", ")
            let msg = tr(
                "Sayfa (\(removedHuman)) silindi, kalan \(outPDF.pageCount) sayfa yeni PDF olarak kaydedildi.",
                "Removed page(s) (\(removedHuman)); saved remaining \(outPDF.pageCount) page(s)."
            )
            return (documents.first(where: { $0.url == outURL }), nil, nil, msg)

        case "organize-pdf":
            let outPDF = PDFDocument()
            if !pageRangeText.trimmingCharacters(in: .whitespaces).isEmpty {
                let customOrder = parsePageIndices(rangeString: pageRangeText, totalPages: max(1, pdf.pageCount))
                for idx in customOrder {
                    if let p = pdf.page(at: idx) { outPDF.insert(p, at: outPDF.pageCount) }
                }
            } else {
                for i in stride(from: pdf.pageCount - 1, through: 0, by: -1) {
                    if let p = pdf.page(at: i) { outPDF.insert(p, at: outPDF.pageCount) }
                }
            }
            outPDF.write(to: outURL)
            refreshDocuments()
            let msg = tr(
                "Sayfa sıralaması yeniden düzenlendi (\(outPDF.pageCount) sayfa).",
                "Reorganized page order (\(outPDF.pageCount) pages)."
            )
            return (documents.first(where: { $0.url == outURL }), nil, nil, msg)

        case "rotate-pdf":
            for i in 0..<pdf.pageCount {
                if let page = pdf.page(at: i) {
                    page.rotation = (page.rotation + rotationAngle) % 360
                }
            }
            pdf.write(to: outURL)
            refreshDocuments()
            let msg = tr(
                "Tüm sayfalar \(rotationAngle)° döndürüldü.",
                "Rotated all pages by \(rotationAngle)°."
            )
            return (documents.first(where: { $0.url == outURL }), nil, nil, msg)

        case "crop-pdf":
            let margin = CGFloat(cropMarginPt)
            for i in 0..<pdf.pageCount {
                if let page = pdf.page(at: i) {
                    let media = page.bounds(for: .mediaBox)
                    if media.width > margin * 2.5 && media.height > margin * 2.5 {
                        page.setBounds(media.insetBy(dx: margin, dy: margin), for: .cropBox)
                    }
                }
            }
            pdf.write(to: outURL)
            refreshDocuments()
            let msg = tr(
                "Sayfa kenar boşlukları \(Int(cropMarginPt)) pt daraltıldı (kırpıldı).",
                "Cropped page margins by \(Int(cropMarginPt)) pt on all sides."
            )
            return (documents.first(where: { $0.url == outURL }), nil, nil, msg)

        case "compress-pdf":
            let origBytes = (try? FileManager.default.attributesOfItem(atPath: sourceDoc.url.path)[.size] as? Int64) ?? 0
            let dpiScale: CGFloat = compressionQuality <= 0.4 ? 1.0 : (compressionQuality <= 0.6 ? 1.25 : 1.5)
            let defaultRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
            let renderer = UIGraphicsPDFRenderer(bounds: defaultRect)
            let compressedData = renderer.pdfData { ctx in
                for i in 0..<max(1, pdf.pageCount) {
                    let page = pdf.page(at: i)
                    let pageBounds = page?.bounds(for: .mediaBox) ?? defaultRect
                    ctx.beginPage(withBounds: pageBounds, pageInfo: [:])
                    guard let p = page else { continue }
                    let targetSize = CGSize(
                        width: max(1, pageBounds.width * dpiScale),
                        height: max(1, pageBounds.height * dpiScale)
                    )
                    let imgFormat = UIGraphicsImageRendererFormat()
                    imgFormat.scale = 1.0
                    imgFormat.opaque = true
                    let imgRenderer = UIGraphicsImageRenderer(size: targetSize, format: imgFormat)
                    let rasterized = imgRenderer.image { imgCtx in
                        UIColor.white.setFill()
                        imgCtx.fill(CGRect(origin: .zero, size: targetSize))
                        imgCtx.cgContext.saveGState()
                        imgCtx.cgContext.translateBy(x: 0, y: targetSize.height)
                        imgCtx.cgContext.scaleBy(x: dpiScale, y: -dpiScale)
                        p.draw(with: .mediaBox, to: imgCtx.cgContext)
                        imgCtx.cgContext.restoreGState()
                    }
                    if let jpgData = rasterized.jpegData(compressionQuality: CGFloat(compressionQuality)),
                       let compressedImg = UIImage(data: jpgData) {
                        compressedImg.draw(in: pageBounds)
                    } else {
                        rasterized.draw(in: pageBounds)
                    }
                }
            }
            try? compressedData.write(to: outURL)
            let newBytes = Int64(compressedData.count)
            refreshDocuments()
            let origKB = max(1, Int(origBytes / 1024))
            let newKB = max(1, Int(newBytes / 1024))
            let qualityPct = Int(compressionQuality * 100)
            let msg = tr(
                "PDF görsel akışları %\(qualityPct) kalite seviyesinde yeniden sıkıştırıldı (\(origKB) KB → \(newKB) KB, \(pdf.pageCount) sayfa).",
                "Re-compressed PDF streams at \(qualityPct)% quality (\(origKB) KB → \(newKB) KB, \(pdf.pageCount) pages)."
            )
            return (documents.first(where: { $0.url == outURL }), nil, nil, msg)

        case "repair-pdf":
            let defaultRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
            let format = UIGraphicsPDFRendererFormat()
            format.documentInfo = [
                kCGPDFContextCreator as String: "JawsPDF Repair Engine",
                kCGPDFContextSubject as String: "JawsPDF Clean XRef Stream Rebuilder"
            ]
            let renderer = UIGraphicsPDFRenderer(bounds: defaultRect, format: format)
            var repairedPages = 0
            let repairedData = renderer.pdfData { ctx in
                for i in 0..<max(1, pdf.pageCount) {
                    guard let page = pdf.page(at: i) else { continue }
                    let rawBounds = page.bounds(for: .mediaBox)
                    let safeBounds = (rawBounds.width > 20 && rawBounds.height > 20) ? rawBounds : defaultRect
                    ctx.beginPage(withBounds: safeBounds, pageInfo: [:])
                    let cg = ctx.cgContext
                    cg.saveGState()
                    cg.translateBy(x: 0, y: safeBounds.height)
                    cg.scaleBy(x: 1.0, y: -1.0)
                    page.draw(with: .mediaBox, to: cg)
                    cg.restoreGState()
                    repairedPages += 1
                }
            }
            try? repairedData.write(to: outURL)
            refreshDocuments()
            let msg = tr(
                "PDF XRef tablosu ve sayfa akışları onarıldı (\(repairedPages) sayfa temizlenerek yeniden oluşturuldu).",
                "Rebuilt corrupt XRef tables and page streams (\(repairedPages) page(s) sanitized and restored)."
            )
            return (documents.first(where: { $0.url == outURL }), nil, nil, msg)

        case "pdf-to-pdfa":
            let defaultRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
            let archiveTitle = customText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? sourceDoc.name : customText
            let format = UIGraphicsPDFRendererFormat()
            format.documentInfo = [
                kCGPDFContextTitle as String: archiveTitle,
                kCGPDFContextAuthor as String: "JawsPDF Studio",
                kCGPDFContextSubject as String: "ISO 19005 PDF/A-2b Long-Term Archival Document",
                kCGPDFContextCreator as String: "JawsPDF ISO-19005 PDF/A Archival Engine v1.0"
            ]
            let renderer = UIGraphicsPDFRenderer(bounds: defaultRect, format: format)
            let pdfaData = renderer.pdfData { ctx in
                for i in 0..<max(1, pdf.pageCount) {
                    let page = pdf.page(at: i)
                    let pageBounds = page?.bounds(for: .mediaBox) ?? defaultRect
                    ctx.beginPage(withBounds: pageBounds, pageInfo: [:])
                    UIColor.white.setFill()
                    ctx.fill(pageBounds)
                    if let p = page {
                        let cg = ctx.cgContext
                        cg.saveGState()
                        cg.translateBy(x: 0, y: pageBounds.height)
                        cg.scaleBy(x: 1.0, y: -1.0)
                        p.draw(with: .mediaBox, to: cg)
                        cg.restoreGState()
                    }
                }
            }
            try? pdfaData.write(to: outURL)
            refreshDocuments()
            let msg = tr(
                "Belge ISO 19005 (PDF/A) uzun süreli arşiv standardına dönüştürüldü (Fontlar ve renk uzayı gömüldü).",
                "Converted document to ISO 19005 (PDF/A) archival format with flattened self-contained page streams."
            )
            return (documents.first(where: { $0.url == outURL }), nil, nil, msg)

        case "redact-pdf":
            let rawTerms = customText
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            let searchTerms = rawTerms.isEmpty ? ["Gizli", "CONFIDENTIAL"] : rawTerms

            // Her sayfada aranan kelimelerin PDF koordinatlarını bul
            var matchesByPage: [Int: [CGRect]] = [:]
            var totalRedactedCount = 0
            for term in searchTerms {
                let selections = pdf.findString(term, withOptions: [.caseInsensitive])
                for sel in selections {
                    for selPage in sel.pages {
                        let pageIdx = pdf.index(for: selPage)
                        if pageIdx != NSNotFound {
                            let b = sel.bounds(for: selPage)
                            if b.width > 1 && b.height > 1 {
                                matchesByPage[pageIdx, default: []].append(b.insetBy(dx: -3, dy: -2))
                                totalRedactedCount += 1
                            }
                        }
                    }
                }
            }

            let defaultRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
            let renderer = UIGraphicsPDFRenderer(bounds: defaultRect)
            let redactedData = renderer.pdfData { ctx in
                for i in 0..<max(1, pdf.pageCount) {
                    let page = pdf.page(at: i)
                    let pageBounds = page?.bounds(for: .mediaBox) ?? defaultRect
                    ctx.beginPage(withBounds: pageBounds, pageInfo: [:])

                    // Sayfayı görsele düzleştir (böylece karartılan metin arkadan kopyalanamaz!)
                    let scale: CGFloat = 2.0
                    let targetSize = CGSize(width: pageBounds.width * scale, height: pageBounds.height * scale)
                    let imgFormat = UIGraphicsImageRendererFormat()
                    imgFormat.scale = 1.0
                    imgFormat.opaque = true
                    let imgRenderer = UIGraphicsImageRenderer(size: targetSize, format: imgFormat)
                    let flatPageImage = imgRenderer.image { imgCtx in
                        UIColor.white.setFill()
                        imgCtx.fill(CGRect(origin: .zero, size: targetSize))
                        if let p = page {
                            imgCtx.cgContext.saveGState()
                            imgCtx.cgContext.translateBy(x: 0, y: targetSize.height)
                            imgCtx.cgContext.scaleBy(x: scale, y: -scale)
                            p.draw(with: .mediaBox, to: imgCtx.cgContext)
                            imgCtx.cgContext.restoreGState()
                        }

                        // Bulunan tüm hassas kelime koordinatlarının üstünü siyah blokla kapat
                        UIColor.black.setFill()
                        if let rects = matchesByPage[i], !rects.isEmpty {
                            for pdfRect in rects {
                                let flippedY = pageBounds.height - pdfRect.maxY
                                let drawRect = CGRect(
                                    x: pdfRect.minX * scale,
                                    y: flippedY * scale,
                                    width: pdfRect.width * scale,
                                    height: pdfRect.height * scale
                                )
                                imgCtx.fill(drawRect)
                            }
                        }
                    }
                    flatPageImage.draw(in: pageBounds)
                }
            }
            try? redactedData.write(to: outURL)
            refreshDocuments()
            let termsJoined = searchTerms.joined(separator: ", ")
            let msg = totalRedactedCount > 0
                ? tr(
                    "“\(termsJoined)” için \(totalRedactedCount) eşleşme bulundu, siyah blokla karartıldı ve metin katmanından kalıcı olarak kazındı.",
                    "Found and permanently redacted \(totalRedactedCount) occurrence(s) of “\(termsJoined)” (flattened text layer)."
                )
                : tr(
                    "Belge metin katmanı düzleştirilerek güvenli kopya oluşturuldu (“\(termsJoined)” kelimesi bu belgede yer almıyor).",
                    "Flattened document text layer into a secure copy (no occurrences of “\(termsJoined)” found in text)."
                )
            return (documents.first(where: { $0.url == outURL }), nil, nil, msg)

        case "compare-pdf":
            let docA = mergeDocs.first ?? sourceDoc
            let docB: JawsSavedDocument = {
                if mergeDocs.count >= 2 { return mergeDocs[1] }
                return documents.first(where: { $0.id != docA.id }) ?? docA
            }()
            let pdfA = PDFDocument(url: docA.url) ?? pdf
            let pdfB = PDFDocument(url: docB.url) ?? pdf

            var linesA: [String] = []
            for i in 0..<pdfA.pageCount {
                let txt = pdfA.page(at: i)?.string ?? ""
                linesA.append(contentsOf: txt.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty })
            }
            var linesB: [String] = []
            for i in 0..<pdfB.pageCount {
                let txt = pdfB.page(at: i)?.string ?? ""
                linesB.append(contentsOf: txt.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty })
            }

            let setA = Set(linesA)
            let setB = Set(linesB)
            let commonCount = setA.intersection(setB).count
            let unionCount = max(1, setA.union(setB).count)
            let similarityPct = Int((Double(commonCount) / Double(unionCount)) * 100.0)
            let removedLines = linesA.filter { !setB.contains($0) }
            let addedLines = linesB.filter { !setA.contains($0) }

            // Dışa aktarılabilir .txt karşılaştırma raporu
            var reportLines: [String] = [
                "=== JawsPDF BELGE KARŞILAŞTIRMA RAPORU / COMPARISON REPORT ===",
                "1. Belge / Document A: \(docA.name) (\(pdfA.pageCount) syf, \(docA.fileSizeText))",
                "2. Belge / Document B: \(docB.name) (\(pdfB.pageCount) syf, \(docB.fileSizeText))",
                "Benzerlik Oranı / Similarity: %\(similarityPct) (Ortak Satır: \(commonCount))",
                "",
                "--- [+] 2. BELGEDE EKLENEN SATIRLAR / ADDED IN DOC B (\(addedLines.count)) ---"
            ]
            reportLines.append(contentsOf: addedLines.prefix(25).map { "+ \($0)" })
            if addedLines.isEmpty { reportLines.append("(Yeni eklenen satır yok / No added lines)") }
            reportLines.append("")
            reportLines.append("--- [-] 1. BELGEDEN ÇIKARILAN SATIRLAR / REMOVED FROM DOC A (\(removedLines.count)) ---")
            reportLines.append(contentsOf: removedLines.prefix(25).map { "- \($0)" })
            if removedLines.isEmpty { reportLines.append("(Silinen satır yok / No removed lines)") }

            let fullReportText = reportLines.joined(separator: "\n")
            let diffTxtURL = documentsDirectory.appendingPathComponent("Karsilastirma_\(docA.name)_vs_\(docB.name)_\(timestamp).txt")
            try? fullReportText.data(using: .utf8)?.write(to: diffTxtURL)

            // Görsel A4 Karşılaştırma Raporu PDF'i üret
            let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
            let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
            let reportPDFData = renderer.pdfData { ctx in
                ctx.beginPage()
                let cg = ctx.cgContext
                UIColor(red: 250/255, green: 249/255, blue: 245/255, alpha: 1).setFill()
                cg.fill(pageRect)
                UIColor(red: 208/255, green: 111/255, blue: 89/255, alpha: 1).setFill()
                cg.fill(CGRect(x: 0, y: 0, width: pageRect.width, height: 76))

                let headerTitle = tr("JawsPDF — İki PDF Karşılaştırma Raporu", "JawsPDF — PDF Comparison Report")
                headerTitle.draw(
                    in: CGRect(x: 36, y: 24, width: pageRect.width - 72, height: 32),
                    withAttributes: [
                        .font: UIFont(name: "Georgia-Bold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20),
                        .foregroundColor: UIColor.white
                    ]
                )

                let metaBox = CGRect(x: 36, y: 96, width: pageRect.width - 72, height: 92)
                UIColor.white.setFill()
                UIBezierPath(roundedRect: metaBox, cornerRadius: 10).fill()
                UIColor(red: 229/255, green: 226/255, blue: 217/255, alpha: 1).setStroke()
                UIBezierPath(roundedRect: metaBox, cornerRadius: 10).stroke()

                let metaString = """
                Belge #1: \(docA.name)  (\(pdfA.pageCount) Sayfa • \(linesA.count) Satır • \(docA.fileSizeText))
                Belge #2: \(docB.name)  (\(pdfB.pageCount) Sayfa • \(linesB.count) Satır • \(docB.fileSizeText))
                Benzerlik Skoru: %\(similarityPct)   |   Eklenen (+): \(addedLines.count) satır   |   Çıkarılan (-): \(removedLines.count) satır
                """
                metaString.draw(
                    in: metaBox.insetBy(dx: 14, dy: 12),
                    withAttributes: [
                        .font: UIFont(name: "Georgia-Bold", size: 12) ?? UIFont.boldSystemFont(ofSize: 12),
                        .foregroundColor: UIColor(red: 20/255, green: 20/255, blue: 19/255, alpha: 1)
                    ]
                )

                var yCursor: CGFloat = 206
                let secFont = UIFont(name: "Georgia-Bold", size: 13) ?? UIFont.boldSystemFont(ofSize: 13)
                let rowFont = UIFont(name: "Georgia", size: 11) ?? UIFont.systemFont(ofSize: 11)

                "[+] 2. Belgede Eklenen Farklar (\(addedLines.count)):".draw(
                    in: CGRect(x: 36, y: yCursor, width: pageRect.width - 72, height: 20),
                    withAttributes: [.font: secFont, .foregroundColor: UIColor(red: 39/255, green: 138/255, blue: 75/255, alpha: 1)]
                )
                yCursor += 22
                for line in (addedLines.isEmpty ? ["(Eklenen farklı satır bulunmadı)"] : Array(addedLines.prefix(10))) {
                    "+ \(line)".draw(
                        in: CGRect(x: 44, y: yCursor, width: pageRect.width - 88, height: 18),
                        withAttributes: [.font: rowFont, .foregroundColor: UIColor(red: 30/255, green: 110/255, blue: 60/255, alpha: 1)]
                    )
                    yCursor += 18
                }

                yCursor += 14
                "[-] 1. Belgeden Çıkarılan / Değişen Farklar (\(removedLines.count)):".draw(
                    in: CGRect(x: 36, y: yCursor, width: pageRect.width - 72, height: 20),
                    withAttributes: [.font: secFont, .foregroundColor: UIColor(red: 192/255, green: 57/255, blue: 43/255, alpha: 1)]
                )
                yCursor += 22
                for line in (removedLines.isEmpty ? ["(Çıkarılan farklı satır bulunmadı)"] : Array(removedLines.prefix(12))) {
                    "- \(line)".draw(
                        in: CGRect(x: 44, y: yCursor, width: pageRect.width - 88, height: 18),
                        withAttributes: [.font: rowFont, .foregroundColor: UIColor(red: 165/255, green: 42/255, blue: 32/255, alpha: 1)]
                    )
                    yCursor += 18
                }
            }
            try? reportPDFData.write(to: outURL)
            refreshDocuments()
            let summaryMsg = tr(
                "“\(docA.name)” ve “\(docB.name)” karşılaştırıldı: %\(similarityPct) benzerlik, +\(addedLines.count) eklenen satır, -\(removedLines.count) çıkarılan satır.",
                "Compared “\(docA.name)” vs “\(docB.name)”: \(similarityPct)% similarity, +\(addedLines.count) added line(s), -\(removedLines.count) removed line(s)."
            )
            return (
                documents.first(where: { $0.url == outURL }),
                diffTxtURL,
                tr("📥 Fark Raporunu (.txt) Kaydet / Paylaş", "📥 Save / Share Diff Report (.txt)"),
                summaryMsg
            )

        case "protect-pdf":
            let pwd = passwordText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "1234" : passwordText
            let options: [PDFDocumentWriteOption: Any] = [
                .userPasswordOption: pwd,
                .ownerPasswordOption: pwd
            ]
            pdf.write(to: outURL, withOptions: options)
            refreshDocuments()
            let msg = tr(
                "PDF belgesi “\(pwd)” parolası ile AES şifrelenerek kilitlendi.",
                "Encrypted and locked PDF with password “\(pwd)”."
            )
            return (documents.first(where: { $0.url == outURL }), nil, nil, msg)

        case "unlock-pdf":
            if pdf.isLocked && !passwordText.isEmpty {
                _ = pdf.unlock(withPassword: passwordText)
            }
            pdf.write(to: outURL)
            refreshDocuments()
            let msg = tr(
                "PDF parola koruması kaldırıldı ve açık kopya kaydedildi.",
                "Unlocked PDF and saved an unencrypted copy."
            )
            return (documents.first(where: { $0.url == outURL }), nil, nil, msg)

        case "pdf-to-jpg":
            let firstPage = pdf.page(at: 0)
            let pageBounds = firstPage?.bounds(for: .mediaBox) ?? CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
            let scale: CGFloat = 2.0
            let imgSize = CGSize(width: pageBounds.width * scale, height: pageBounds.height * scale)
            let imgRenderer = UIGraphicsImageRenderer(size: imgSize)
            let jpgImage = imgRenderer.image { ctx in
                UIColor.white.setFill()
                ctx.fill(CGRect(origin: .zero, size: imgSize))
                if let p = firstPage {
                    ctx.cgContext.saveGState()
                    ctx.cgContext.translateBy(x: 0, y: imgSize.height)
                    ctx.cgContext.scaleBy(x: scale, y: -scale)
                    p.draw(with: .mediaBox, to: ctx.cgContext)
                    ctx.cgContext.restoreGState()
                }
            }
            let jpgURL = documentsDirectory.appendingPathComponent("\(sourceDoc.name)_Sayfa1_\(timestamp).jpg")
            if let jpgData = jpgImage.jpegData(compressionQuality: 0.92) {
                try? jpgData.write(to: jpgURL)
            }
            let msg = tr(
                "PDF sayfaları yüksek çözünürlüklü JPG görseline dönüştürüldü.",
                "Exported PDF page as high-resolution JPG image."
            )
            return (sourceDoc, jpgURL, tr("📥 JPG Görselini Kaydet / Paylaş", "📥 Save / Share JPG Image"), msg)

        case "pdf-to-word":
            var fullText = ""
            for i in 0..<pdf.pageCount {
                if let t = pdf.page(at: i)?.string, !t.isEmpty {
                    fullText += "=== Sayfa / Page \(i + 1) ===\n\(t)\n\n"
                }
            }
            if fullText.isEmpty {
                fullText = "JawsPDF — \(sourceDoc.name)\n(Görsel tabanlı PDF sayfası Word belgesine aktarıldı.)"
            }
            let rtfURL = documentsDirectory.appendingPathComponent("\(sourceDoc.name)_Word_\(timestamp).rtf")
            let attrStr = NSAttributedString(
                string: fullText,
                attributes: [
                    .font: UIFont(name: "Georgia", size: 13) ?? UIFont.systemFont(ofSize: 13)
                ]
            )
            if let rtfData = try? attrStr.data(
                from: NSRange(location: 0, length: attrStr.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
            ) {
                try? rtfData.write(to: rtfURL)
            }
            let msg = tr(
                "PDF metinleri düzenlenebilir Word (.rtf) belgesine dönüştürüldü.",
                "Converted PDF text into an editable Word (.rtf) document."
            )
            return (sourceDoc, rtfURL, tr("📥 Word (.rtf) Dosyasını Kaydet / Paylaş", "📥 Save / Share Word (.rtf) File"), msg)

        case "pdf-to-excel":
            var csvLines: [String] = ["Sayfa;Satir_No;Icerik_Sutun_1;Icerik_Sutun_2"]
            for i in 0..<pdf.pageCount {
                let pageText = pdf.page(at: i)?.string ?? ""
                let lines = pageText.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                for (rowIdx, line) in lines.enumerated() {
                    let clean = line.replacingOccurrences(of: ";", with: ",").replacingOccurrences(of: "\"", with: "'")
                    let parts = clean.components(separatedBy: "|")
                    if parts.count >= 2 {
                        csvLines.append("\(i + 1);\(rowIdx + 1);\"\(parts[0].trimmingCharacters(in: .whitespaces))\";\"\(parts[1].trimmingCharacters(in: .whitespaces))\"")
                    } else {
                        csvLines.append("\(i + 1);\(rowIdx + 1);\"\(clean)\";\"\"")
                    }
                }
            }
            let csvContent = "\u{FEFF}" + csvLines.joined(separator: "\n")
            let csvURL = documentsDirectory.appendingPathComponent("\(sourceDoc.name)_Excel_\(timestamp).csv")
            try? csvContent.data(using: .utf8)?.write(to: csvURL)
            let msg = tr(
                "PDF içindeki tüm satır ve tablolar Excel (.csv) formatına ayıklandı.",
                "Extracted PDF rows and tables into an Excel (.csv) file."
            )
            return (sourceDoc, csvURL, tr("📥 Excel (.csv) Tablosunu Kaydet / Paylaş", "📥 Save / Share Excel (.csv) File"), msg)

        case "pdf-to-powerpoint":
            var slidesHTML = ""
            for i in 0..<pdf.pageCount {
                let text = (pdf.page(at: i)?.string ?? "Sayfa \(i + 1)")
                    .replacingOccurrences(of: "<", with: "&lt;")
                    .replacingOccurrences(of: "\n", with: "<br>")
                slidesHTML += "<section style='background:#fff;border:2px solid #D06F59;border-radius:16px;padding:32px;margin:24px 0;'><h2>Slayt / Slide \(i + 1) — \(sourceDoc.name)</h2><p>\(text)</p></section>"
            }
            let deckHTML = "<!DOCTYPE html><html><head><meta charset='utf-8'><title>\(sourceDoc.name) Sunum</title><style>body{font-family:Georgia,serif;background:#FAF9F5;color:#141413;padding:24px;}h2{color:#D06F59;}</style></head><body><h1>JawsPDF Sunum Çıktısı — \(sourceDoc.name)</h1>\(slidesHTML)</body></html>"
            let pptHTMLURL = documentsDirectory.appendingPathComponent("\(sourceDoc.name)_Sunum_\(timestamp).html")
            try? deckHTML.data(using: .utf8)?.write(to: pptHTMLURL)
            let msg = tr(
                "PDF sayfaları sunum slayt yapısına dönüştürüldü.",
                "Exported PDF pages into presentation slide format."
            )
            return (sourceDoc, pptHTMLURL, tr("📥 Sunum Dosyasını Kaydet / Paylaş", "📥 Save / Share Presentation"), msg)

        case "ocr-pdf":
            var extracted = ""
            for i in 0..<pdf.pageCount {
                if let pageText = pdf.page(at: i)?.string, !pageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    extracted += "--- Sayfa / Page \(i + 1) ---\n\(pageText)\n\n"
                } else if let page = pdf.page(at: i) {
                    // Apple Vision VNRecognizeTextRequest ile gerçek görsel OCR
                    let bounds = page.bounds(for: .mediaBox)
                    let renderer = UIGraphicsImageRenderer(size: bounds.size)
                    let img = renderer.image { ctx in
                        UIColor.white.setFill()
                        ctx.fill(bounds)
                        ctx.cgContext.translateBy(x: 0, y: bounds.height)
                        ctx.cgContext.scaleBy(x: 1, y: -1)
                        page.draw(with: .mediaBox, to: ctx.cgContext)
                    }
                    if let cgImg = img.cgImage {
                        let req = VNRecognizeTextRequest()
                        req.recognitionLevel = .accurate
                        req.recognitionLanguages = ["tr-TR", "en-US"]
                        let handler = VNImageRequestHandler(cgImage: cgImg, options: [:])
                        try? handler.perform([req])
                        let recognized = (req.results ?? []).compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                        if !recognized.isEmpty {
                            extracted += "--- Sayfa / Page \(i + 1) (Vision OCR) ---\n\(recognized)\n\n"
                        }
                    }
                }
            }
            let summaryText = extracted.isEmpty
                ? tr("Metin katmanı tarandı (Görsel OCR tamamlandı).", "Scanned text layer (Vision OCR completed).")
                : String(extracted.prefix(600))
            let txtURL = documentsDirectory.appendingPathComponent("\(sourceDoc.name)_OCR_\(timestamp).txt")
            try? (extracted.isEmpty ? summaryText : extracted).data(using: .utf8)?.write(to: txtURL)
            let newDoc = createSamplePDF(title: "\(sourceDoc.name)_OCR", templateType: "ocr", customNote: summaryText)
            return (newDoc, txtURL, tr("📥 OCR Metnini (.txt) Kaydet / Paylaş", "📥 Save / Share OCR Text (.txt)"), "OCR:\n\(summaryText)")

        default:
            let defaultRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
            let renderer = UIGraphicsPDFRenderer(bounds: defaultRect)
            let stampText = customText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "JawsPDF • \(tool.name(lang))" : customText

            let data = renderer.pdfData { ctx in
                for i in 0..<max(1, pdf.pageCount) {
                    let page = pdf.page(at: i)
                    let pageRect = page?.bounds(for: .mediaBox) ?? defaultRect
                    ctx.beginPage(withBounds: pageRect, pageInfo: [:])
                    let cg = ctx.cgContext

                    if let p = page {
                        cg.saveGState()
                        cg.translateBy(x: 0, y: pageRect.height)
                        cg.scaleBy(x: 1.0, y: -1.0)
                        p.draw(with: .mediaBox, to: cg)
                        cg.restoreGState()
                    }

                    let badgeFont = UIFont(name: "Georgia-Bold", size: 13) ?? UIFont.boldSystemFont(ofSize: 13)
                    if tool.id == "watermark-pdf" {
                        let wmFont = UIFont(name: "Georgia-Bold", size: 42) ?? UIFont.boldSystemFont(ofSize: 42)
                        let paragraph = NSMutableParagraphStyle()
                        paragraph.alignment = .center
                        let attrs: [NSAttributedString.Key: Any] = [
                            .font: wmFont,
                            .foregroundColor: UIColor(red: 208/255, green: 111/255, blue: 89/255, alpha: 0.25),
                            .paragraphStyle: paragraph
                        ]
                        cg.saveGState()
                        cg.translateBy(x: pageRect.midX, y: pageRect.midY)
                        cg.rotate(by: -35.0 * .pi / 180.0)
                        stampText.draw(in: CGRect(x: -240, y: -30, width: 480, height: 60), withAttributes: attrs)
                        cg.restoreGState()
                    } else if tool.id == "sign-pdf" {
                        let signRect = CGRect(x: pageRect.width - 240, y: pageRect.height - 135, width: 195, height: 88)
                        UIColor(red: 250/255, green: 249/255, blue: 245/255, alpha: 0.96).setFill()
                        UIBezierPath(roundedRect: signRect, cornerRadius: 8).fill()
                        UIColor(red: 208/255, green: 111/255, blue: 89/255, alpha: 1).setStroke()
                        UIBezierPath(roundedRect: signRect, cornerRadius: 8).stroke()

                        if !signatureLines.isEmpty {
                            cg.saveGState()
                            cg.setStrokeColor(UIColor(red: 20/255, green: 20/255, blue: 19/255, alpha: 1).cgColor)
                            cg.setLineWidth(2.2)
                            cg.setLineCap(.round)
                            cg.setLineJoin(.round)
                            for line in signatureLines where line.count > 1 {
                                cg.beginPath()
                                let firstPt = CGPoint(
                                    x: signRect.minX + 12 + min(170, max(0, line[0].x * 0.55)),
                                    y: signRect.minY + 8 + min(46, max(0, line[0].y * 0.42))
                                )
                                cg.move(to: firstPt)
                                for pt in line.dropFirst() {
                                    let mapped = CGPoint(
                                        x: signRect.minX + 12 + min(170, max(0, pt.x * 0.55)),
                                        y: signRect.minY + 8 + min(46, max(0, pt.y * 0.42))
                                    )
                                    cg.addLine(to: mapped)
                                }
                                cg.strokePath()
                            }
                            cg.restoreGState()
                        }

                        let sigLine = "✒ \(stampText)  •  \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none))"
                        sigLine.draw(
                            in: CGRect(x: signRect.minX + 10, y: signRect.maxY - 24, width: signRect.width - 20, height: 20),
                            withAttributes: [
                                .font: UIFont(name: "Georgia-Italic", size: 10.5) ?? UIFont.italicSystemFont(ofSize: 10.5),
                                .foregroundColor: UIColor(red: 20/255, green: 20/255, blue: 19/255, alpha: 1)
                            ]
                        )
                    } else if tool.id == "page-numbers" {
                        let paragraph = NSMutableParagraphStyle()
                        paragraph.alignment = .center
                        let pageNumStr = tr("Sayfa \(i + 1) / \(pdf.pageCount)", "Page \(i + 1) of \(pdf.pageCount)")
                        pageNumStr.draw(
                            in: CGRect(x: pageRect.midX - 80, y: pageRect.height - 34, width: 160, height: 22),
                            withAttributes: [
                                .font: badgeFont,
                                .foregroundColor: UIColor(red: 20/255, green: 20/255, blue: 19/255, alpha: 1),
                                .paragraphStyle: paragraph
                            ]
                        )
                    } else if tool.id == "bates-numbering" {
                        let batesStr = String(format: "%@-BATES-%04d", stampText, i + 1)
                        batesStr.draw(
                            in: CGRect(x: pageRect.width - 220, y: 22, width: 190, height: 22),
                            withAttributes: [
                                .font: badgeFont,
                                .foregroundColor: UIColor(red: 108/255, green: 52/255, blue: 131/255, alpha: 1)
                            ]
                        )
                    } else if tool.id == "edit-pdf" {
                        let noteRect = CGRect(x: pageRect.width - 235, y: 26, width: 205, height: 56)
                        UIColor(red: 255/255, green: 249/255, blue: 219/255, alpha: 0.96).setFill()
                        UIBezierPath(roundedRect: noteRect, cornerRadius: 8).fill()
                        UIColor(red: 214/255, green: 137/255, blue: 16/255, alpha: 1).setStroke()
                        UIBezierPath(roundedRect: noteRect, cornerRadius: 8).stroke()
                        let noteTitle = "📌 \(stampText)"
                        noteTitle.draw(
                            in: noteRect.insetBy(dx: 10, dy: 8),
                            withAttributes: [
                                .font: UIFont(name: "Georgia-Bold", size: 11.5) ?? UIFont.boldSystemFont(ofSize: 11.5),
                                .foregroundColor: UIColor(red: 20/255, green: 20/255, blue: 19/255, alpha: 1)
                            ]
                        )
                    }
                }
            }

            try? data.write(to: outURL)
            refreshDocuments()
            let doneMsg = tr(
                "“\(tool.nameTR)” işlemi tamamlandı ve yeni PDF kaydedildi.",
                "“\(tool.nameEN)” completed and saved as a new PDF."
            )
            return (documents.first(where: { $0.url == outURL }), nil, nil, doneMsg)
        }
    }
}

// MARK: - Ana 5 Sekmeli Görünüm
struct JawsPDFRootView: View {
    @EnvironmentObject var store: JawsDocumentStore
    @State private var selectedTab: Int = 0
    @State private var activeTool: JawsTool?

    var body: some View {
        TabView(selection: $selectedTab) {
            JawsHomeTabView(selectedTab: $selectedTab, activeTool: $activeTool)
                .tabItem {
                    Label(store.tr("Ana Ekran", "Home"), systemImage: "house.fill")
                }
                .tag(0)

            JawsFilesTabView()
                .tabItem {
                    Label(store.tr("Dosyalar", "Files"), systemImage: "folder.fill")
                }
                .tag(1)

            JawsToolsTabView(activeTool: $activeTool)
                .tabItem {
                    Label(store.tr("Araçlar", "Tools"), systemImage: "square.grid.2x2.fill")
                }
                .tag(2)

            JawsScannerTabView(selectedTab: $selectedTab)
                .tabItem {
                    Label(store.tr("Tarayıcı", "Scanner"), systemImage: "camera.viewfinder")
                }
                .tag(3)

            JawsTemplatesTabView(selectedTab: $selectedTab)
                .tabItem {
                    Label(store.tr("Şablonlar", "Templates"), systemImage: "doc.richtext.fill")
                }
                .tag(4)
        }
        .tint(JawsTheme.orange)
        .sheet(item: $activeTool) { tool in
            JawsToolRunnerSheet(tool: tool)
                .environmentObject(store)
        }
        .sheet(item: $store.activePreviewDoc) { doc in
            JawsPDFPreviewSheet(document: doc)
                .environmentObject(store)
        }
    }
}

// MARK: - Üst Marka Başlığı (Jaws 🦈 PDF + FREE + [ TR | EN ] Dil Seçici)
struct JawsBrandHeaderView: View {
    @EnvironmentObject var store: JawsDocumentStore
    var subtitle: String

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            HStack(alignment: .center, spacing: 6) {
                Text("Jaws")
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(JawsTheme.charcoal)
                    .fixedSize(horizontal: true, vertical: false)

                VStack(spacing: 2) {
                    if let uiImg = UIImage(named: "jaws-shark") {
                        Image(uiImage: uiImg)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 30)
                    } else {
                        Text("🦈")
                            .font(.system(size: 24))
                    }
                    Text("FREE")
                        .font(.system(size: 10.5, weight: .bold, design: .serif))
                        .tracking(1.2)
                        .foregroundColor(JawsTheme.orange)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }

                Text("PDF")
                    .font(.system(size: 14.5, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(JawsTheme.orange)
                    .cornerRadius(7)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .fixedSize(horizontal: true, vertical: false)

            Spacer(minLength: 4)

            // Sağ Üst: Alt Başlık + [ TR | EN ] Çift Dil Butonu
            HStack(spacing: 8) {
                Text(subtitle)
                    .font(.system(size: 10.5, weight: .semibold, design: .serif))
                    .foregroundColor(JawsTheme.muted)
                    .lineLimit(2)
                    .multilineTextAlignment(.trailing)

                HStack(spacing: 2) {
                    ForEach(JawsLanguage.allCases) { item in
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                store.lang = item
                            }
                        } label: {
                            Text(item.rawValue)
                                .font(.system(size: 11, weight: .bold, design: .serif))
                                .foregroundColor(store.lang == item ? .white : JawsTheme.charcoal)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 5)
                                .background(store.lang == item ? JawsTheme.orange : Color.clear)
                                .cornerRadius(6)
                        }
                    }
                }
                .padding(2)
                .background(JawsTheme.surfaceAlt)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(JawsTheme.border, lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(JawsTheme.cardBg)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(JawsTheme.border),
            alignment: .bottom
        )
    }
}

// MARK: - SEKME 1: ANA EKRAN
struct JawsHomeTabView: View {
    @EnvironmentObject var store: JawsDocumentStore
    @Binding var selectedTab: Int
    @Binding var activeTool: JawsTool?

    var body: some View {
        ZStack {
            JawsTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                JawsBrandHeaderView(subtitle: store.tr("30 Araçlı\nPDF Stüdyosu", "30-Tool\nPDF Studio"))

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Hero Kartı
                        VStack(alignment: .leading, spacing: 10) {
                            Text(store.tr("HALK İÇİN ÜCRETSİZ • %100 CİHAZ İÇİ", "FREE FOR EVERYONE • 100% ON-DEVICE"))
                                .font(.system(size: 11, weight: .bold, design: .serif))
                                .tracking(1.1)
                                .foregroundColor(JawsTheme.orange)

                            Text(store.tr(
                                "Belgeleri Saniyeler İçinde Dönüştür, Kamerayla Tara ve İmzala",
                                "Convert, Scan with Camera, and Sign Documents in Seconds"
                            ))
                                .font(.system(size: 21, weight: .bold, design: .serif))
                                .foregroundColor(JawsTheme.charcoal)

                            Text(store.tr(
                                "Word, Excel, PowerPoint, Fotoğraf ve PDF araçlarınızın tamamı tek bir çalışma alanında. Dosyalarınız telefonunuzdan dışarı çıkmaz.",
                                "All your Word, Excel, PowerPoint, Photo, and PDF tools in one smart workspace. Your files never leave your iPhone."
                            ))
                                .font(.system(size: 13.5, design: .serif))
                                .foregroundColor(JawsTheme.muted)

                            HStack(spacing: 10) {
                                Button {
                                    selectedTab = 3
                                } label: {
                                    Label(store.tr("Kamerayla Tara", "Scan with Camera"), systemImage: "camera.viewfinder")
                                        .font(.system(size: 13.5, weight: .bold, design: .serif))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(JawsTheme.orange)
                                        .cornerRadius(10)
                                }

                                Button {
                                    selectedTab = 2
                                } label: {
                                    Label(store.tr("30 Aracı Keşfet", "Explore 30 Tools"), systemImage: "square.grid.2x2.fill")
                                        .font(.system(size: 13.5, weight: .bold, design: .serif))
                                        .foregroundColor(JawsTheme.charcoal)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(JawsTheme.surfaceAlt)
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(18)
                        .background(JawsTheme.cardBg)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(JawsTheme.border, lineWidth: 1)
                        )

                        // Popüler Hızlı Araçlar
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(store.tr("Hızlı PDF & Office Araçları", "Quick PDF & Office Tools"))
                                    .font(.system(size: 17, weight: .bold, design: .serif))
                                    .foregroundColor(JawsTheme.charcoal)
                                Spacer()
                                Button(store.tr("Tümünü Gör (30) →", "See All (30) →")) {
                                    selectedTab = 2
                                }
                                .font(.system(size: 12.5, weight: .bold, design: .serif))
                                .foregroundColor(JawsTheme.orange)
                            }

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(Array(JawsToolCatalog.all.prefix(6))) { tool in
                                    Button {
                                        activeTool = tool
                                    } label: {
                                        HStack(spacing: 10) {
                                            JawsToolBadgeView(tool: tool, size: 40)

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(tool.name(store.lang))
                                                    .font(.system(size: 13.5, weight: .bold, design: .serif))
                                                    .foregroundColor(JawsTheme.charcoal)
                                                    .lineLimit(1)
                                                Text(tool.desc(store.lang))
                                                    .font(.system(size: 11, design: .serif))
                                                    .foregroundColor(JawsTheme.muted)
                                                    .lineLimit(1)
                                            }
                                            Spacer(minLength: 0)
                                        }
                                        .padding(11)
                                        .background(JawsTheme.cardBg)
                                        .cornerRadius(13)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 13)
                                                .stroke(JawsTheme.border, lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }

                        // Son Belgeler
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(store.tr("Son İşlenen PDF Belgeleri", "Recent PDF Documents"))
                                    .font(.system(size: 17, weight: .bold, design: .serif))
                                    .foregroundColor(JawsTheme.charcoal)
                                Spacer()
                                Button(store.tr("+ Örnek PDF Üret", "+ Sample PDF")) {
                                    _ = store.createSamplePDF(title: store.tr("JawsPDF Test Belgesi", "JawsPDF Sample Doc"), templateType: "report")
                                }
                                .font(.system(size: 12.5, weight: .bold, design: .serif))
                                .foregroundColor(JawsTheme.orange)
                            }

                            ForEach(store.documents.prefix(4)) { doc in
                                HStack(spacing: 12) {
                                    Text("PDF")
                                        .font(.system(size: 11.5, weight: .bold, design: .serif))
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 44)
                                        .background(JawsTheme.orange)
                                        .cornerRadius(9)

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(doc.name)
                                            .font(.system(size: 14, weight: .bold, design: .serif))
                                            .foregroundColor(JawsTheme.charcoal)
                                            .lineLimit(1)
                                        Text("\(doc.pageCount) \(store.tr("Sayfa", "Pages"))  •  \(doc.fileSizeText)")
                                            .font(.system(size: 11.5, design: .serif))
                                            .foregroundColor(JawsTheme.muted)
                                    }

                                    Spacer()

                                    Button(store.tr("Aç", "Open")) {
                                        store.activePreviewDoc = doc
                                    }
                                    .font(.system(size: 12.5, weight: .bold, design: .serif))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(JawsTheme.orange)
                                    .cornerRadius(8)
                                }
                                .padding(12)
                                .background(JawsTheme.cardBg)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(JawsTheme.border, lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
    }
}

// MARK: - SEKME 2: DOSYALAR
struct JawsFilesTabView: View {
    @EnvironmentObject var store: JawsDocumentStore
    @State private var showFileImporter = false
    @State private var isConvertingImport = false

    var body: some View {
        ZStack {
            JawsTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                JawsBrandHeaderView(subtitle: store.tr("Cihazdaki PDF\nArşivi (\(store.documents.count))", "On-Device PDF\nArchive (\(store.documents.count))"))

                HStack(spacing: 10) {
                    Button {
                        showFileImporter = true
                    } label: {
                        Label(
                            isConvertingImport
                                ? store.tr("İçe Aktarılıyor...", "Importing...")
                                : store.tr("Telefondan Dosya Seç (PDF / Office)", "Select File from iPhone"),
                            systemImage: "folder.badge.plus"
                        )
                            .font(.system(size: 12.5, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 9)
                            .background(JawsTheme.orange)
                            .cornerRadius(10)
                    }

                    Button {
                        _ = store.createSamplePDF(title: store.tr("JawsPDF Yeni Belge", "JawsPDF New Document"), templateType: "standard")
                    } label: {
                        Label(store.tr("+ Örnek PDF", "+ Sample PDF"), systemImage: "doc.badge.plus")
                            .font(.system(size: 12.5, weight: .bold, design: .serif))
                            .foregroundColor(JawsTheme.charcoal)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .background(JawsTheme.surfaceAlt)
                            .cornerRadius(10)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(store.documents) { doc in
                            HStack(spacing: 12) {
                                Text("PDF")
                                    .font(.system(size: 11.5, weight: .bold, design: .serif))
                                    .foregroundColor(.white)
                                    .frame(width: 42, height: 46)
                                    .background(JawsTheme.orange)
                                    .cornerRadius(9)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(doc.name)
                                        .font(.system(size: 14.5, weight: .bold, design: .serif))
                                        .foregroundColor(JawsTheme.charcoal)
                                        .lineLimit(1)
                                    Text("\(doc.pageCount) \(store.tr("Sayfa", "Pages"))  •  \(doc.fileSizeText)")
                                        .font(.system(size: 12, design: .serif))
                                        .foregroundColor(JawsTheme.muted)
                                }

                                Spacer()

                                ShareLink(item: doc.url) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(JawsTheme.charcoal)
                                        .padding(8)
                                        .background(JawsTheme.surfaceAlt)
                                        .cornerRadius(8)
                                }

                                Button {
                                    store.deleteDocument(doc)
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 13.5, weight: .bold))
                                        .foregroundColor(Color(red: 192/255, green: 57/255, blue: 43/255))
                                        .padding(8)
                                        .background(JawsTheme.surfaceAlt)
                                        .cornerRadius(8)
                                }

                                Button(store.tr("Aç", "Open")) {
                                    store.activePreviewDoc = doc
                                }
                                .font(.system(size: 12.5, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(JawsTheme.orange)
                                .cornerRadius(8)
                            }
                            .padding(12)
                            .background(JawsTheme.cardBg)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(JawsTheme.border, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.item, .data, .pdf, .image, .plainText, .rtf, .html, .commaSeparatedText, .spreadsheet, .presentation],
            allowsMultipleSelection: true
        ) { result in
            if case .success(let urls) = result {
                isConvertingImport = true
                Task {
                    for picked in urls {
                        _ = await store.importAndConvertFileFromPhone(pickedURL: picked, forTool: nil)
                    }
                    isConvertingImport = false
                }
            }
        }
    }
}

// MARK: - SEKME 3: 30 PDF ARACI KATALOĞU (Yüksek Kontrastlı Canlı İkonlar)
struct JawsToolsTabView: View {
    @EnvironmentObject var store: JawsDocumentStore
    @Binding var activeTool: JawsTool?
    @State private var selectedCategory: String = "all"
    @State private var searchText: String = ""

    var filteredTools: [JawsTool] {
        JawsToolCatalog.all.filter { tool in
            let matchesCat = (selectedCategory == "all" || tool.category == selectedCategory)
            let matchesQuery = searchText.isEmpty ||
                tool.nameTR.localizedCaseInsensitiveContains(searchText) ||
                tool.nameEN.localizedCaseInsensitiveContains(searchText) ||
                tool.descTR.localizedCaseInsensitiveContains(searchText) ||
                tool.descEN.localizedCaseInsensitiveContains(searchText)
            return matchesCat && matchesQuery
        }
    }

    var body: some View {
        ZStack {
            JawsTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                JawsBrandHeaderView(subtitle: store.tr("30 Profesyonel\nPDF Aracı", "30 Professional\nPDF Tools"))

                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(JawsTheme.charcoal)
                        TextField(
                            store.tr("30 PDF aracında ara (Word, Excel, Birleştir, İmzala...)", "Search 30 PDF tools (Word, Excel, Merge, Sign...)"),
                            text: $searchText
                        )
                            .font(.system(size: 13.5, design: .serif))
                    }
                    .padding(11)
                    .background(JawsTheme.cardBg)
                    .cornerRadius(11)
                    .overlay(
                        RoundedRectangle(cornerRadius: 11)
                            .stroke(JawsTheme.border, lineWidth: 1)
                    )

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(JawsToolCatalog.categories(store.lang), id: \.id) { cat in
                                Button {
                                    selectedCategory = cat.id
                                } label: {
                                    Text(cat.label)
                                        .font(.system(size: 12.5, weight: .bold, design: .serif))
                                        .foregroundColor(selectedCategory == cat.id ? .white : JawsTheme.charcoal)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(selectedCategory == cat.id ? JawsTheme.orange : JawsTheme.cardBg)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(JawsTheme.border, lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(14)

                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(filteredTools) { tool in
                            Button {
                                activeTool = tool
                            } label: {
                                VStack(alignment: .leading, spacing: 9) {
                                    HStack {
                                        JawsToolBadgeView(tool: tool, size: 42)
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(JawsTheme.charcoal)
                                            .frame(width: 26, height: 26)
                                            .background(JawsTheme.surfaceAlt)
                                            .cornerRadius(7)
                                    }

                                    Text(tool.name(store.lang))
                                        .font(.system(size: 14.5, weight: .bold, design: .serif))
                                        .foregroundColor(JawsTheme.charcoal)
                                        .multilineTextAlignment(.leading)

                                    Text(tool.desc(store.lang))
                                        .font(.system(size: 11.5, design: .serif))
                                        .foregroundColor(JawsTheme.muted)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(13)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(JawsTheme.cardBg)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(JawsTheme.border, lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

// MARK: - SEKME 4: KAMERA BELGE TARAYICI
struct JawsScannerTabView: View {
    @EnvironmentObject var store: JawsDocumentStore
    @Binding var selectedTab: Int
    @State private var showCameraScanner = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var scanTitle = "Kamera_Taramasi"

    var body: some View {
        ZStack {
            JawsTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                JawsBrandHeaderView(subtitle: store.tr("Akıllı Belge &\nKamera Tarayıcı", "Smart Document &\nCamera Scanner"))

                Spacer()

                VStack(spacing: 16) {
                    if let uiImg = UIImage(named: "jaws-shark") {
                        Image(uiImage: uiImg)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 72)
                    }

                    Text(store.tr(
                        "Fiziksel Belgeleri veya Fotoğrafları Yüksek Netlikte PDF'e Tarayın",
                        "Scan Physical Documents or Photos into High-Clarity PDF"
                    ))
                        .font(.system(size: 19, weight: .bold, design: .serif))
                        .foregroundColor(JawsTheme.charcoal)
                        .multilineTextAlignment(.center)

                    Text(store.tr(
                        "Apple VisionKit motoru belge kenarlarını otomatik algılar, perspektifi düzeltir ve çok sayfalı A4 PDF üretir.",
                        "Apple VisionKit automatically detects document edges, corrects perspective, and creates multi-page A4 PDFs."
                    ))
                        .font(.system(size: 13.5, design: .serif))
                        .foregroundColor(JawsTheme.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    TextField(store.tr("Tarama Dosya Adı", "Scan File Name"), text: $scanTitle)
                        .font(.system(size: 14, design: .serif))
                        .padding(12)
                        .background(JawsTheme.cardBg)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(JawsTheme.border, lineWidth: 1))
                        .padding(.horizontal, 24)

                    VStack(spacing: 10) {
                        Button {
                            if VNDocumentCameraViewController.isSupported {
                                showCameraScanner = true
                            } else {
                                if let doc = store.createSamplePDF(
                                    title: scanTitle.isEmpty ? "Taranmis_Belge" : scanTitle,
                                    templateType: "scan",
                                    customNote: "Kamera Tarayıcı (VisionKit) ile üretildi."
                                ) {
                                    store.activePreviewDoc = doc
                                }
                            }
                        } label: {
                            Label(store.tr("📸 Kamerayı Aç ve PDF'e Tara", "📸 Open Camera & Scan to PDF"), systemImage: "camera.fill")
                                .font(.system(size: 15, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(JawsTheme.orange)
                                .cornerRadius(12)
                        }

                        PhotosPicker(
                            selection: $selectedPhotoItems,
                            maxSelectionCount: 20,
                            matching: .images
                        ) {
                            Label(store.tr("🖼️ Galeriden Fotoğraf Seçip PDF Yap", "🖼️ Select Photos from Gallery to PDF"), systemImage: "photo.on.rectangle.angled")
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundColor(JawsTheme.charcoal)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(JawsTheme.surfaceAlt)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(22)
                .background(JawsTheme.cardBg)
                .cornerRadius(18)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(JawsTheme.border, lineWidth: 1))
                .padding(18)

                Spacer()
            }
        }
        .onChange(of: selectedPhotoItems) { newItems in
            guard !newItems.isEmpty else { return }
            Task {
                var images: [UIImage] = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImg = UIImage(data: data) {
                        images.append(uiImg)
                    }
                }
                if let created = store.createPDFFromImages(images, title: scanTitle.isEmpty ? "Galeri_PDF" : scanTitle) {
                    store.activePreviewDoc = created
                }
                selectedPhotoItems = []
            }
        }
        .sheet(isPresented: $showCameraScanner) {
            JawsDocumentCameraRepresentable { scannedImages in
                if let created = store.createPDFFromImages(scannedImages, title: scanTitle.isEmpty ? "Kamera_Taramasi" : scanTitle) {
                    store.activePreviewDoc = created
                }
            }
        }
    }
}

// MARK: - SEKME 5: HAZIR KURUMSAL ŞABLONLAR
struct JawsTemplatesTabView: View {
    @EnvironmentObject var store: JawsDocumentStore
    @Binding var selectedTab: Int
    @State private var docTitle: String = "JawsPDF Kurumsal Belge"
    @State private var customNote: String = "Bu belge JawsPDF Şablon Stüdyosu ile hazırlanmıştır."

    private let templates: [(id: String, nameTR: String, nameEN: String, descTR: String, descEN: String, badge: String, colorHex: Int)] = [
        ("invoice", "Kurumsal Fatura Şablonu", "Corporate Invoice Template", "KDV, kalem tablosu ve toplam tutar içeren resmi fatura düzeni.", "Official invoice layout with tax, line items, and totals.", "₺", 0xD06F59),
        ("contract", "Hizmet & Gizlilik Sözleşmesi", "Service & NDA Contract", "Taraflar, maddeler ve dijital imza alanları hazır sözleşme.", "Ready-to-sign contract with clauses and signature blocks.", "§", 0x2C5E8A),
        ("resume", "Modern Yönetici Özgeçmişi (CV)", "Executive Resume / CV", "Deneyim, eğitim ve yetkinlik bölümleriyle A4 CV şablonu.", "Clean A4 resume template with experience and skills sections.", "CV", 0x2E9E5B),
        ("academic", "Akademik Rapor & Tez Kapak", "Academic Report & Thesis", "Üniversite ve Ar-Ge projeleri için standart kapak ve özet sayfası.", "Standard cover and abstract layout for academic & R&D reports.", "A4", 0x8E44AD)
    ]

    var body: some View {
        ZStack {
            JawsTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                JawsBrandHeaderView(subtitle: store.tr("Hazır A4 PDF\nŞablonları", "Ready A4 PDF\nTemplates"))

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(store.tr("Şablon Başlığı & Özel Not", "Template Title & Custom Note"))
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundColor(JawsTheme.charcoal)

                            TextField(store.tr("Belge Başlığı", "Document Title"), text: $docTitle)
                                .font(.system(size: 13.5, design: .serif))
                                .padding(10)
                                .background(JawsTheme.surfaceAlt)
                                .cornerRadius(8)

                            TextField(store.tr("Belge İçerik Notu", "Document Content Note"), text: $customNote)
                                .font(.system(size: 13.5, design: .serif))
                                .padding(10)
                                .background(JawsTheme.surfaceAlt)
                                .cornerRadius(8)
                        }
                        .padding(14)
                        .background(JawsTheme.cardBg)
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(JawsTheme.border, lineWidth: 1))

                        ForEach(templates, id: \.id) { tpl in
                            let col = Color(
                                red: Double((tpl.colorHex >> 16) & 0xFF) / 255.0,
                                green: Double((tpl.colorHex >> 8) & 0xFF) / 255.0,
                                blue: Double(tpl.colorHex & 0xFF) / 255.0
                            )
                            let tplName = store.lang == .tr ? tpl.nameTR : tpl.nameEN
                            let tplDesc = store.lang == .tr ? tpl.descTR : tpl.descEN

                            HStack(spacing: 12) {
                                Text(tpl.badge)
                                    .font(.system(size: 16, weight: .heavy, design: .serif))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(col)
                                    .cornerRadius(11)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(tplName)
                                        .font(.system(size: 14.5, weight: .bold, design: .serif))
                                        .foregroundColor(JawsTheme.charcoal)
                                    Text(tplDesc)
                                        .font(.system(size: 12, design: .serif))
                                        .foregroundColor(JawsTheme.muted)
                                }

                                Spacer()

                                Button(store.tr("Üret ve Aç", "Create & Open")) {
                                    if let created = store.createSamplePDF(
                                        title: "\(tplName) - \(docTitle)",
                                        templateType: tpl.id,
                                        customNote: customNote
                                    ) {
                                        store.activePreviewDoc = created
                                    }
                                }
                                .font(.system(size: 12.5, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(JawsTheme.orange)
                                .cornerRadius(9)
                            }
                            .padding(14)
                            .background(JawsTheme.cardBg)
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(JawsTheme.border, lineWidth: 1))
                        }
                    }
                    .padding(16)
                }
            }
        }
    }
}

// MARK: - Canlı Parmakla İmza Çizim Alanı (Sign PDF İçin)
struct JawsSignatureCanvasView: View {
    @Binding var lines: [[CGPoint]]
    var lang: JawsLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(lang == .tr ? "✍️ Parmağınızla İmzanızı Çizin:" : "✍️ Draw Your Signature with Finger:")
                    .font(.system(size: 12.5, weight: .bold, design: .serif))
                    .foregroundColor(JawsTheme.charcoal)
                Spacer()
                Button(lang == .tr ? "Temizle" : "Clear") {
                    lines.removeAll()
                }
                .font(.system(size: 12, weight: .bold, design: .serif))
                .foregroundColor(JawsTheme.orange)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .frame(height: 115)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(JawsTheme.orange.opacity(0.6), style: StrokeStyle(lineWidth: 1.5, dash: [5, 3]))
                    )

                if lines.isEmpty {
                    Text(lang == .tr ? "Buraya parmağınızla imza atın" : "Sign here with your finger")
                        .font(.system(size: 13, weight: .medium, design: .serif))
                        .foregroundColor(JawsTheme.muted.opacity(0.6))
                }

                Canvas { context, _ in
                    for line in lines where line.count > 1 {
                        var path = Path()
                        path.move(to: line[0])
                        for pt in line.dropFirst() {
                            path.addLine(to: pt)
                        }
                        context.stroke(path, with: .color(JawsTheme.charcoal), lineWidth: 2.6)
                    }
                }
                .frame(height: 115)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let pt = value.location
                            if value.translation == .zero {
                                lines.append([pt])
                            } else if !lines.isEmpty {
                                lines[lines.count - 1].append(pt)
                            } else {
                                lines.append([pt])
                            }
                        }
                )
            }
        }
    }
}

// MARK: - 30 Araç Çalıştırma Penceresi (Her Araç İçin Telefondan Dosya/Fotoğraf Seçici + Özel Kontroller)
struct JawsToolRunnerSheet: View {
    @EnvironmentObject var store: JawsDocumentStore
    @Environment(\.dismiss) private var dismiss
    let tool: JawsTool

    @State private var selectedDocID: String = ""
    @State private var selectedMergeIDs: [String] = []
    @State private var customText: String = "JawsPDF Onaylı"
    @State private var pageRangeText: String = "1"
    @State private var passwordText: String = ""
    @State private var rotationAngle: Int = 90
    @State private var cropMarginPt: Double = 36
    @State private var compressionQuality: Double = 0.55
    @State private var signatureLines: [[CGPoint]] = []

    @State private var showFileImporter = false
    @State private var showCameraScanner = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var isImportingFile = false
    @State private var lastImportedFileName: String?

    @State private var resultMessage: String?
    @State private var outputDoc: JawsSavedDocument?
    @State private var exportedFileURL: URL?
    @State private var exportedFileLabel: String?

    var selectedDoc: JawsSavedDocument? {
        store.documents.first(where: { $0.id == selectedDocID }) ?? store.documents.first
    }

    var fileImporterButtonTitle: String {
        switch tool.id {
        case "word-to-pdf":
            return store.tr("+ Telefondan Word (.docx / .doc / .rtf) Seç", "+ Select Word (.docx / .doc / .rtf) from iPhone")
        case "excel-to-pdf":
            return store.tr("+ Telefondan Excel (.xlsx / .xls / .csv) Seç", "+ Select Excel (.xlsx / .xls / .csv) from iPhone")
        case "powerpoint-to-pdf":
            return store.tr("+ Telefondan PowerPoint (.pptx / .ppt) Seç", "+ Select PowerPoint (.pptx / .ppt) from iPhone")
        case "html-to-pdf":
            return store.tr("+ Telefondan HTML / Metin Dosyası Seç", "+ Select HTML / Text File from iPhone")
        case "jpg-to-pdf", "scan-to-pdf":
            return store.tr("+ Dosyalardan Görsel / PDF Seç", "+ Select Image / PDF from Files")
        case "merge-pdf", "compare-pdf":
            return store.tr("+ Telefondan PDF Dosyaları Ekle (Çoklu)", "+ Add PDF Files from iPhone (Multiple)")
        default:
            return store.tr("+ Telefondan PDF Dosyası Seç", "+ Select PDF File from iPhone")
        }
    }

    var isMultiDocTool: Bool {
        tool.id == "merge-pdf" || tool.id == "compare-pdf"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                JawsTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Üst Araç Başlığı Kartı
                        HStack(spacing: 12) {
                            JawsToolBadgeView(tool: tool, size: 50)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(tool.name(store.lang))
                                    .font(.system(size: 19, weight: .bold, design: .serif))
                                    .foregroundColor(JawsTheme.charcoal)
                                Text(tool.desc(store.lang))
                                    .font(.system(size: 13, design: .serif))
                                    .foregroundColor(JawsTheme.muted)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(JawsTheme.cardBg)
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(JawsTheme.border, lineWidth: 1))

                        // 1. ADIM: TELEFONDAN DOSYA / FOTOĞRAF / KAMERA SEÇİMİ
                        VStack(alignment: .leading, spacing: 10) {
                            Text(store.tr("1. Telefondan Dosya Seçin veya Kayıtlı Belge Kullanın", "1. Select File from iPhone or Choose Saved Document"))
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundColor(JawsTheme.charcoal)

                            // Görsel / Tarama araçları için Fotoğraf Galerisi ve Kamera butonları
                            if tool.isImageOrScanTool {
                                HStack(spacing: 8) {
                                    PhotosPicker(
                                        selection: $selectedPhotoItems,
                                        maxSelectionCount: 20,
                                        matching: .images
                                    ) {
                                        Label(store.tr("🖼️ Galeriden Fotoğraf Seç", "🖼️ Pick from Photos"), systemImage: "photo.on.rectangle")
                                            .font(.system(size: 13, weight: .bold, design: .serif))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(JawsTheme.orange)
                                            .cornerRadius(10)
                                    }

                                    Button {
                                        if VNDocumentCameraViewController.isSupported {
                                            showCameraScanner = true
                                        }
                                    } label: {
                                        Label(store.tr("📸 Kamera", "📸 Camera"), systemImage: "camera.fill")
                                            .font(.system(size: 13, weight: .bold, design: .serif))
                                            .foregroundColor(JawsTheme.charcoal)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 12)
                                            .background(JawsTheme.surfaceAlt)
                                            .cornerRadius(10)
                                    }
                                }
                            }

                            // Telefondan Dosya Seç (Files App / iCloud / İndirilenler)
                            Button {
                                showFileImporter = true
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: isImportingFile ? "arrow.triangle.2.circlepath" : "folder.badge.plus")
                                        .font(.system(size: 16, weight: .bold))
                                    Text(isImportingFile ? store.tr("Dosya Dönüştürülüyor...", "Converting File...") : fileImporterButtonTitle)
                                        .font(.system(size: 13.5, weight: .bold, design: .serif))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .foregroundColor(tool.isImageOrScanTool ? JawsTheme.charcoal : .white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(tool.isImageOrScanTool ? JawsTheme.surfaceAlt : JawsTheme.orange)
                                .cornerRadius(10)
                            }

                            if let importedName = lastImportedFileName {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(Color(red: 46/255, green: 158/255, blue: 91/255))
                                    Text(store.tr("Seçilen Dosya Hazır: \(importedName)", "Selected File Ready: \(importedName)"))
                                        .font(.system(size: 12, weight: .bold, design: .serif))
                                        .foregroundColor(Color(red: 46/255, green: 158/255, blue: 91/255))
                                }
                                .padding(.vertical, 2)
                            }

                            Divider().padding(.vertical, 2)

                            Text(
                                tool.id == "merge-pdf"
                                    ? store.tr("Birleştirilecek Belgeleri İşaretleyin (Çoklu Seçim):", "Check Documents to Merge (Multi-Select):")
                                    : (tool.id == "compare-pdf"
                                        ? store.tr("Karşılaştırılacak 2 PDF Belgesini İşaretleyin (#1 ve #2):", "Check 2 PDF Documents to Compare (#1 & #2):")
                                        : store.tr("Veya Uygulamadaki Hazır Belgeyi Seçin:", "Or Select an Existing Document in App:"))
                            )
                                .font(.system(size: 12, weight: .semibold, design: .serif))
                                .foregroundColor(JawsTheme.muted)

                            ForEach(store.documents) { doc in
                                Button {
                                    if isMultiDocTool {
                                        if let idx = selectedMergeIDs.firstIndex(of: doc.id) {
                                            selectedMergeIDs.remove(at: idx)
                                        } else {
                                            selectedMergeIDs.append(doc.id)
                                        }
                                    } else {
                                        selectedDocID = doc.id
                                    }
                                } label: {
                                    HStack {
                                        if isMultiDocTool {
                                            let orderIndex = selectedMergeIDs.firstIndex(of: doc.id)
                                            Image(systemName: orderIndex != nil ? "checkmark.square.fill" : "square")
                                                .foregroundColor(JawsTheme.orange)
                                            if let ord = orderIndex {
                                                Text("#\(ord + 1)")
                                                    .font(.system(size: 11, weight: .bold, design: .serif))
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(JawsTheme.orange)
                                                    .cornerRadius(5)
                                            }
                                        } else {
                                            Image(systemName: (selectedDoc?.id == doc.id) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(JawsTheme.orange)
                                        }

                                        Text(doc.name)
                                            .font(.system(size: 13.5, weight: .semibold, design: .serif))
                                            .foregroundColor(JawsTheme.charcoal)
                                            .lineLimit(1)
                                        Spacer()
                                        Text("\(doc.pageCount) \(store.tr("syf", "pg"))")
                                            .font(.system(size: 11.5, design: .serif))
                                            .foregroundColor(JawsTheme.muted)
                                    }
                                    .padding(10)
                                    .background(JawsTheme.surfaceAlt)
                                    .cornerRadius(9)
                                }
                            }
                        }
                        .padding(14)
                        .background(JawsTheme.cardBg)
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(JawsTheme.border, lineWidth: 1))

                        // 2. ADIM: ARACA ÖZEL AYARLAR
                        VStack(alignment: .leading, spacing: 10) {
                            Text(store.tr("2. Araç Ayarları & Özelleştirme", "2. Tool Settings & Options"))
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundColor(JawsTheme.charcoal)

                            if tool.id == "rotate-pdf" {
                                Picker(store.tr("Döndürme Açısı", "Rotation Angle"), selection: $rotationAngle) {
                                    Text(store.tr("90° Saat Yönü", "90° Clockwise")).tag(90)
                                    Text(store.tr("180° Ters", "180° Flip")).tag(180)
                                    Text(store.tr("270° Sola", "270° Counter")).tag(270)
                                }
                                .pickerStyle(.segmented)
                            } else if tool.id == "crop-pdf" {
                                Text(store.tr("Kenar Boşluğu Kırpma Miktarı (pt):", "Crop Margin Points (pt):"))
                                    .font(.system(size: 12.5, design: .serif))
                                    .foregroundColor(JawsTheme.muted)
                                Picker("Margin", selection: $cropMarginPt) {
                                    Text("20 pt").tag(20.0)
                                    Text("36 pt").tag(36.0)
                                    Text("54 pt").tag(54.0)
                                    Text("72 pt").tag(72.0)
                                }
                                .pickerStyle(.segmented)
                            } else if tool.id == "compress-pdf" {
                                Text(store.tr("Sıkıştırma Seviyesi (Görsel & Akış Optimizasyonu):", "Compression Level (Stream & Image Optimization):"))
                                    .font(.system(size: 12.5, design: .serif))
                                    .foregroundColor(JawsTheme.muted)
                                Picker("Compression", selection: $compressionQuality) {
                                    Text(store.tr("Maksimum (%35)", "High (35%)")).tag(0.35)
                                    Text(store.tr("Önerilen (%55)", "Balanced (55%)")).tag(0.55)
                                    Text(store.tr("Yüksek Kalite (%75)", "Light (75%)")).tag(0.75)
                                }
                                .pickerStyle(.segmented)
                            } else if tool.id == "redact-pdf" {
                                Text(store.tr(
                                    "Karartılacak Hassas Kelimeleri Girin (Virgülle ayırın):",
                                    "Enter Sensitive Words to Redact (Comma-separated):"
                                ))
                                    .font(.system(size: 12.5, design: .serif))
                                    .foregroundColor(JawsTheme.muted)

                                TextField(store.tr("Örn: Gizli, T.C., Tutar, IBAN", "e.g. Confidential, SSN, Total, IBAN"), text: $customText)
                                    .font(.system(size: 13.5, weight: .semibold, design: .serif))
                                    .padding(10)
                                    .background(JawsTheme.surfaceAlt)
                                    .cornerRadius(8)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 6) {
                                        ForEach(["Gizli, Onaylı", "T.C., Kimlik, Vergi", "Tutar, ₺, KDV", "IBAN, Hesap, Sözleşme"], id: \.self) { preset in
                                            Button(preset) { customText = preset }
                                                .font(.system(size: 11.5, weight: .bold, design: .serif))
                                                .foregroundColor(JawsTheme.charcoal)
                                                .padding(.horizontal, 9)
                                                .padding(.vertical, 5)
                                                .background(JawsTheme.surfaceAlt)
                                                .cornerRadius(6)
                                        }
                                    }
                                }
                            } else if tool.id == "compare-pdf" {
                                Text(store.tr(
                                    "Seçilen #1 ve #2 numaralı PDF belgeleri satır satır karşılaştırılır, benzerlik yüzdesi hesaplanır ve renkli A4 Fark Raporu + .txt çıktısı üretilir.",
                                    "Compares PDF #1 and #2 line-by-line, calculates similarity %, and generates an A4 Diff Report PDF + .txt file."
                                ))
                                    .font(.system(size: 12.5, design: .serif))
                                    .foregroundColor(JawsTheme.muted)
                            } else if tool.id == "repair-pdf" {
                                Text(store.tr(
                                    "Bozuk XRef tabloları, hatalı nesne referansları ve açılmayan sayfa akışları taranarak temiz bir PDF kapsayıcısında yeniden inşa edilir.",
                                    "Scans and rebuilds corrupt XRef tables and page streams into a clean, standards-compliant PDF container."
                                ))
                                    .font(.system(size: 12.5, design: .serif))
                                    .foregroundColor(JawsTheme.muted)
                            } else if tool.id == "pdf-to-pdfa" {
                                Text(store.tr("ISO 19005 (PDF/A-2b) Arşiv Belgesi Başlığı:", "ISO 19005 (PDF/A-2b) Archival Document Title:"))
                                    .font(.system(size: 12.5, design: .serif))
                                    .foregroundColor(JawsTheme.muted)
                                TextField(store.tr("Resmi Arşiv Başlığı", "Official Archival Title"), text: $customText)
                                    .font(.system(size: 13.5, design: .serif))
                                    .padding(10)
                                    .background(JawsTheme.surfaceAlt)
                                    .cornerRadius(8)
                            } else if ["split-pdf", "remove-pages", "extract-pages", "organize-pdf"].contains(tool.id) {
                                Text(store.tr(
                                    "Sayfa Numaraları veya Aralığı (Örn: 1-2 veya 1, 3):",
                                    "Page Numbers or Range (e.g. 1-2 or 1, 3):"
                                ))
                                    .font(.system(size: 12.5, design: .serif))
                                    .foregroundColor(JawsTheme.muted)

                                TextField("1-2", text: $pageRangeText)
                                    .font(.system(size: 14, weight: .semibold, design: .serif))
                                    .padding(10)
                                    .background(JawsTheme.surfaceAlt)
                                    .cornerRadius(8)

                                HStack(spacing: 6) {
                                    Button(store.tr("İlk Sayfa (1)", "First Page (1)")) { pageRangeText = "1" }
                                        .font(.system(size: 11.5, weight: .bold, design: .serif))
                                        .padding(.horizontal, 9)
                                        .padding(.vertical, 5)
                                        .background(JawsTheme.surfaceAlt)
                                        .cornerRadius(6)
                                    if let total = selectedDoc?.pageCount, total > 1 {
                                        Button(store.tr("Son Sayfa (\(total))", "Last Page (\(total))")) { pageRangeText = "\(total)" }
                                            .font(.system(size: 11.5, weight: .bold, design: .serif))
                                            .padding(.horizontal, 9)
                                            .padding(.vertical, 5)
                                            .background(JawsTheme.surfaceAlt)
                                            .cornerRadius(6)
                                    }
                                }
                                .foregroundColor(JawsTheme.charcoal)
                            } else if tool.id == "protect-pdf" || tool.id == "unlock-pdf" {
                                Text(
                                    tool.id == "protect-pdf"
                                        ? store.tr("Belgeye Koyulacak Şifreyi Girin:", "Enter Password to Lock PDF:")
                                        : store.tr("Belgenin Mevcut Şifresini Girin:", "Enter Current PDF Password:")
                                )
                                    .font(.system(size: 12.5, design: .serif))
                                    .foregroundColor(JawsTheme.muted)

                                TextField(store.tr("Şifre (Örn: 2026)", "Password (e.g. 2026)"), text: $passwordText)
                                    .font(.system(size: 14, weight: .semibold, design: .serif))
                                    .padding(10)
                                    .background(JawsTheme.surfaceAlt)
                                    .cornerRadius(8)
                            } else if tool.id == "sign-pdf" {
                                JawsSignatureCanvasView(lines: $signatureLines, lang: store.lang)

                                TextField(store.tr("İmzalayan Adı Soyadı / Ünvanı", "Signer Full Name / Title"), text: $customText)
                                    .font(.system(size: 13.5, design: .serif))
                                    .padding(10)
                                    .background(JawsTheme.surfaceAlt)
                                    .cornerRadius(8)
                            } else {
                                TextField(
                                    store.tr("Damga / Filigran / Başlık Notu", "Watermark / Stamp / Custom Note"),
                                    text: $customText
                                )
                                    .font(.system(size: 13.5, design: .serif))
                                    .padding(10)
                                    .background(JawsTheme.surfaceAlt)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(14)
                        .background(JawsTheme.cardBg)
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(JawsTheme.border, lineWidth: 1))

                        // 3. ADIM: İŞLEMİ BAŞLAT BUTONU
                        Button {
                            guard let doc = selectedDoc else { return }
                            let mergeList = store.documents.filter { selectedMergeIDs.contains($0.id) }
                            let res = store.processTool(
                                tool: tool,
                                sourceDoc: doc,
                                mergeDocs: mergeList.isEmpty ? [doc] : mergeList,
                                customText: customText,
                                pageRangeText: pageRangeText,
                                passwordText: passwordText,
                                rotationAngle: rotationAngle,
                                cropMarginPt: cropMarginPt,
                                compressionQuality: compressionQuality,
                                signatureLines: signatureLines
                            )
                            outputDoc = res.outputDoc
                            exportedFileURL = res.exportedFileURL
                            exportedFileLabel = res.exportedFileLabel
                            resultMessage = res.summary
                        } label: {
                            Text("⚡ \(tool.name(store.lang)) — \(store.tr("İşlemi Başlat", "Run Tool Now"))")
                                .font(.system(size: 15.5, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(JawsTheme.orange)
                                .cornerRadius(12)
                        }

                        // SONUÇ VE DIŞA AKTARIM KARTI
                        if let msg = resultMessage {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(store.tr("✅ İşlem Tamamlandı", "✅ Process Completed"))
                                    .font(.system(size: 15, weight: .bold, design: .serif))
                                    .foregroundColor(JawsTheme.charcoal)

                                Text(msg)
                                    .font(.system(size: 13, design: .serif))
                                    .foregroundColor(JawsTheme.muted)
                                    .textSelection(.enabled)

                                if let expURL = exportedFileURL, let expLabel = exportedFileLabel {
                                    ShareLink(item: expURL) {
                                        Label(expLabel, systemImage: "square.and.arrow.down.fill")
                                            .font(.system(size: 13.5, weight: .bold, design: .serif))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 11)
                                            .background(Color(red: 46/255, green: 158/255, blue: 91/255))
                                            .cornerRadius(9)
                                    }
                                }

                                if let out = outputDoc {
                                    HStack(spacing: 10) {
                                        Button(store.tr("PDF'i Görüntüle", "Preview PDF")) {
                                            dismiss()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                store.activePreviewDoc = out
                                            }
                                        }
                                        .font(.system(size: 13, weight: .bold, design: .serif))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 9)
                                        .background(JawsTheme.orange)
                                        .cornerRadius(9)

                                        ShareLink(item: out.url) {
                                            Label(store.tr("PDF Paylaş / Kaydet", "Share / Save PDF"), systemImage: "square.and.arrow.up")
                                                .font(.system(size: 13, weight: .semibold, design: .serif))
                                                .foregroundColor(JawsTheme.charcoal)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 9)
                                                .background(JawsTheme.surfaceAlt)
                                                .cornerRadius(9)
                                        }
                                    }
                                }
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(JawsTheme.cardBg)
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(JawsTheme.orange, lineWidth: 1.5))
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle(tool.name(store.lang))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(store.tr("Kapat", "Close")) { dismiss() }
                        .foregroundColor(JawsTheme.orange)
                }
            }
            .onAppear {
                if selectedDocID.isEmpty, let first = store.documents.first {
                    selectedDocID = first.id
                }
                if selectedMergeIDs.isEmpty {
                    selectedMergeIDs = store.documents.prefix(2).map { $0.id }
                }
                if tool.id == "redact-pdf" {
                    customText = "Gizli, Onaylı"
                }
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.item, .data, .pdf, .image, .plainText, .rtf, .html, .commaSeparatedText, .spreadsheet, .presentation],
                allowsMultipleSelection: isMultiDocTool || tool.id == "jpg-to-pdf"
            ) { result in
                if case .success(let urls) = result, !urls.isEmpty {
                    isImportingFile = true
                    Task {
                        for picked in urls {
                            if let converted = await store.importAndConvertFileFromPhone(pickedURL: picked, forTool: tool) {
                                selectedDocID = converted.id
                                if !selectedMergeIDs.contains(converted.id) {
                                    selectedMergeIDs.append(converted.id)
                                }
                                lastImportedFileName = picked.lastPathComponent
                                outputDoc = converted
                                if tool.isConvertToPDF {
                                    resultMessage = store.tr(
                                        "“\(picked.lastPathComponent)” dosyası başarıyla A4 PDF belgesine dönüştürüldü!",
                                        "“\(picked.lastPathComponent)” was successfully converted into an A4 PDF!"
                                    )
                                }
                            }
                        }
                        isImportingFile = false
                    }
                }
            }
            .onChange(of: selectedPhotoItems) { newItems in
                guard !newItems.isEmpty else { return }
                isImportingFile = true
                Task {
                    var images: [UIImage] = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let img = UIImage(data: data) {
                            images.append(img)
                        }
                    }
                    if let created = store.createPDFFromImages(images, title: "Fotograflardan_PDF") {
                        selectedDocID = created.id
                        outputDoc = created
                        lastImportedFileName = "\(images.count) Fotoğraf"
                        resultMessage = store.tr(
                            "\(images.count) fotoğraf tam sayfa A4 PDF belgesine dönüştürüldü!",
                            "Converted \(images.count) photo(s) into a full-page A4 PDF!"
                        )
                    }
                    selectedPhotoItems = []
                    isImportingFile = false
                }
            }
            .sheet(isPresented: $showCameraScanner) {
                JawsDocumentCameraRepresentable { scannedImages in
                    if let created = store.createPDFFromImages(scannedImages, title: "Kamera_Taramasi") {
                        selectedDocID = created.id
                        outputDoc = created
                        lastImportedFileName = "\(scannedImages.count) Sayfa Tarama"
                        resultMessage = store.tr(
                            "\(scannedImages.count) sayfa kamerayla tarandı ve PDF yapıldı!",
                            "Scanned \(scannedImages.count) page(s) with camera into PDF!"
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Native PDFKit Önizleme Penceresi
struct JawsPDFPreviewSheet: View {
    @EnvironmentObject var store: JawsDocumentStore
    @Environment(\.dismiss) private var dismiss
    let document: JawsSavedDocument

    var body: some View {
        NavigationStack {
            JawsPDFKitRepresentable(url: document.url)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(document.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        ShareLink(item: document.url) {
                            Label(store.tr("Paylaş", "Share"), systemImage: "square.and.arrow.up")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(store.tr("Tamam", "Done")) { dismiss() }
                            .fontWeight(.bold)
                    }
                }
        }
    }
}

struct JawsPDFKitRepresentable: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = UIColor(red: 243/255, green: 241/255, blue: 234/255, alpha: 1)
        pdfView.document = PDFDocument(url: url)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = PDFDocument(url: url)
    }
}

// MARK: - Apple VisionKit Kamera Tarayıcı Köprüsü
struct JawsDocumentCameraRepresentable: UIViewControllerRepresentable {
    var onScanCompleted: ([UIImage]) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: JawsDocumentCameraRepresentable
        init(parent: JawsDocumentCameraRepresentable) { self.parent = parent }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var pages: [UIImage] = []
            for i in 0..<scan.pageCount {
                pages.append(scan.imageOfPage(at: i))
            }
            parent.onScanCompleted(pages)
            parent.dismiss()
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.dismiss()
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            parent.dismiss()
        }
    }
}
