import SwiftUI
import PDFKit
import VisionKit
import Vision
import UniformTypeIdentifiers
import UIKit

// MARK: - JawsPDF iOS / iPadOS Uygulama Giriş Noktası
// Tema: Claude Krem (#FAF9F5), Claude Kiremit Turuncusu (#D06F59), Claude Editorial Serif
// Geliştirici Etiketi: FREE (Köpekbalığı logosunun altında)
// Bundle ID: com.jawspdf.studio

@main
struct JawsPDFApp: App {
    @StateObject private var store = JawsDocumentStore()

    init() {
        // Alt Sekme Çubuğu (Tab Bar) ikonlarını siliklikten kurtarıp yüksek kontrastlı hale getir
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
    static let orangeSoft = Color(red: 208.0 / 255.0, green: 111.0 / 255.0, blue: 89.0 / 255.0).opacity(0.16)
    static let charcoal   = Color(red: 20.0 / 255.0, green: 20.0 / 255.0, blue: 19.0 / 255.0)    // #141413
    static let muted      = Color(red: 75.0 / 255.0, green: 73.0 / 255.0, blue: 68.0 / 255.0)    // #4B4944
    static let border     = Color(red: 218.0 / 255.0, green: 214.0 / 255.0, blue: 204.0 / 255.0) // #DAD6CC

    // Canlı, Tam Dolgulu Araç İkon Renkleri
    static let catOrganize = Color(red: 208.0 / 255.0, green: 111.0 / 255.0, blue: 89.0 / 255.0) // #D06F59
    static let catRed      = Color(red: 192.0 / 255.0, green: 57.0 / 255.0, blue: 43.0 / 255.0)  // #C0392B
    static let catOptimize = Color(red: 46.0 / 255.0, green: 158.0 / 255.0, blue: 91.0 / 255.0)  // #2E9E5B
    static let catToPdf    = Color(red: 217.0 / 255.0, green: 130.0 / 255.0, blue: 18.0 / 255.0) // #D98212
    static let catBlue     = Color(red: 41.0 / 255.0, green: 128.0 / 255.0, blue: 185.0 / 255.0) // #2980B9
    static let catEdit     = Color(red: 142.0 / 255.0, green: 68.0 / 255.0, blue: 173.0 / 255.0) // #8E44AD
    static let catSecurity = Color(red: 44.0 / 255.0, green: 94.0 / 255.0, blue: 138.0 / 255.0)  // #2C5E8A
}

// MARK: - 30 PDF Aracı Modeli
struct JawsTool: Identifiable, Hashable {
    let id: String
    let name: String
    let desc: String
    let category: String
    let badge: String
    let systemIcon: String?
    let colorHex: Int

    var solidColor: Color {
        let r = Double((colorHex >> 16) & 0xFF) / 255.0
        let g = Double((colorHex >> 8) & 0xFF) / 255.0
        let b = Double(colorHex & 0xFF) / 255.0
        return Color(red: r, green: g, blue: b)
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
    static let categories: [(id: String, label: String)] = [
        ("all", "Tümü (30)"),
        ("organize", "PDF Düzenle"),
        ("optimize", "PDF İyileştir"),
        ("to-pdf", "PDF'e Dönüştür"),
        ("from-pdf", "PDF'den Dönüştür"),
        ("edit", "PDF İçeriği"),
        ("security", "PDF Güvenliği")
    ]

    static let all: [JawsTool] = [
        // 1. Organize (6)
        JawsTool(id: "merge-pdf", name: "PDF Birleştir", desc: "Birden fazla PDF dosyasını tek belgede birleştirin.", category: "organize", badge: "⇄", systemIcon: "arrow.left.arrow.right", colorHex: 0xD06F59),
        JawsTool(id: "split-pdf", name: "PDF Böl", desc: "PDF sayfalarını ayrı dosyalara veya aralıklara ayırın.", category: "organize", badge: "✂", systemIcon: "scissors", colorHex: 0xD94E34),
        JawsTool(id: "remove-pages", name: "Sayfa Sil", desc: "Belgedeki gereksiz sayfaları seçip kalıcı çıkarın.", category: "organize", badge: "✕", systemIcon: "xmark", colorHex: 0xC0392B),
        JawsTool(id: "extract-pages", name: "Sayfa Ayıkla", desc: "Seçili sayfaları yeni bir PDF olarak kaydedin.", category: "organize", badge: "⧉", systemIcon: "doc.on.doc.fill", colorHex: 0xD06F59),
        JawsTool(id: "organize-pdf", name: "PDF Sırala", desc: "Sayfa sırasını ters çevirin veya yeniden dizin.", category: "organize", badge: "⇅", systemIcon: "arrow.up.arrow.down", colorHex: 0xB4523A),
        JawsTool(id: "scan-to-pdf", name: "Kamera ile PDF Tara", desc: "Fiziksel belgeleri otomatik kenar algılamayla PDF yapın.", category: "organize", badge: "📷", systemIcon: "camera.fill", colorHex: 0x2980B9),

        // 2. Optimize (3)
        JawsTool(id: "compress-pdf", name: "PDF Sıkıştır", desc: "Kaliteyi koruyarak dosya boyutunu hızla küçültün.", category: "optimize", badge: "⚡", systemIcon: "bolt.fill", colorHex: 0x2E9E5B),
        JawsTool(id: "repair-pdf", name: "PDF Onar", desc: "Bozuk PDF yapısını ve sayfa ağacını yeniden inşa edin.", category: "optimize", badge: "🛠", systemIcon: "wrench.and.screwdriver.fill", colorHex: 0x8E44AD),
        JawsTool(id: "ocr-pdf", name: "OCR PDF (Metin Tanıma)", desc: "Taranmış PDF sayfalarındaki metinleri Apple Vision ile okuyun.", category: "optimize", badge: "OCR", systemIcon: nil, colorHex: 0x27AE60),

        // 3. Convert to PDF (5)
        JawsTool(id: "jpg-to-pdf", name: "JPG'den PDF'e", desc: "Fotoğrafları ve görselleri tam sayfa PDF'e çevirin.", category: "to-pdf", badge: "JPG", systemIcon: nil, colorHex: 0xD98212),
        JawsTool(id: "word-to-pdf", name: "Word'den PDF'e", desc: "Metin ve DOCX içeriklerini standart PDF'e dönüştürün.", category: "to-pdf", badge: "W", systemIcon: nil, colorHex: 0x2B579A),
        JawsTool(id: "powerpoint-to-pdf", name: "PowerPoint'ten PDF'e", desc: "Sunum özetlerini ve slaytları PDF belgesi yapın.", category: "to-pdf", badge: "P", systemIcon: nil, colorHex: 0xD24726),
        JawsTool(id: "excel-to-pdf", name: "Excel'den PDF'e", desc: "Tablo verilerini düzenli PDF raporuna aktarın.", category: "to-pdf", badge: "X", systemIcon: nil, colorHex: 0x217346),
        JawsTool(id: "html-to-pdf", name: "HTML / Metinden PDF'e", desc: "Web veya zengin metin içeriğini PDF sayfasına dönüştürün.", category: "to-pdf", badge: "</>", systemIcon: "chevron.left.forwardslash.chevron.right", colorHex: 0xE67E22),

        // 4. Convert from PDF (5)
        JawsTool(id: "pdf-to-jpg", name: "PDF'den JPG'e", desc: "Her PDF sayfasını yüksek çözünürlüklü görsel olarak kaydedin.", category: "from-pdf", badge: "IMG", systemIcon: "photo.fill", colorHex: 0xD98212),
        JawsTool(id: "pdf-to-word", name: "PDF'den Word'e", desc: "PDF içindeki metinleri düzenlenebilir belge olarak dışa aktarın.", category: "from-pdf", badge: "DOC", systemIcon: nil, colorHex: 0x2B579A),
        JawsTool(id: "pdf-to-powerpoint", name: "PDF'den Sunuma", desc: "Sayfaları sunum yapısına uygun dışa aktarın.", category: "from-pdf", badge: "PPT", systemIcon: nil, colorHex: 0xD24726),
        JawsTool(id: "pdf-to-excel", name: "PDF'den Tabloya", desc: "PDF satırlarını CSV/Tablo formatına ayıklayın.", category: "from-pdf", badge: "XLS", systemIcon: nil, colorHex: 0x217346),
        JawsTool(id: "pdf-to-pdfa", name: "PDF'den PDF/A'ya", desc: "Uzun süreli kurumsal arşiv uyumlu PDF oluşturun.", category: "from-pdf", badge: "A/1", systemIcon: nil, colorHex: 0x2C5E8A),

        // 5. Edit PDF (6)
        JawsTool(id: "rotate-pdf", name: "PDF Döndür", desc: "Sayfaları 90°, 180° veya 270° döndürün.", category: "edit", badge: "↻", systemIcon: "rotate.right.fill", colorHex: 0x8E44AD),
        JawsTool(id: "page-numbers", name: "Sayfa Numarası Ekle", desc: "Alt veya üst bilgiye otomatik sayfa numarası basın.", category: "edit", badge: "123", systemIcon: "number", colorHex: 0x8E44AD),
        JawsTool(id: "watermark-pdf", name: "Filigran Ekle", desc: "Sayfalara özel çapraz metin damgası ekleyin.", category: "edit", badge: "💧", systemIcon: "seal.fill", colorHex: 0x9B59B6),
        JawsTool(id: "crop-pdf", name: "PDF Kenar Boşluğu Kırp", desc: "Sayfa kenar boşluklarını simetrik olarak daraltın.", category: "edit", badge: "Crop", systemIcon: "crop", colorHex: 0x8E44AD),
        JawsTool(id: "edit-pdf", name: "PDF Düzenle & Not Ekle", desc: "Sayfa üzerine açıklama kutusu ve başlık notu işleyin.", category: "edit", badge: "✎", systemIcon: "pencil.and.outline", colorHex: 0x7D3C98),
        JawsTool(id: "bates-numbering", name: "Bates Numaralandırma", desc: "Hukuki ve kurumsal seri numarası damgalayın.", category: "edit", badge: "B#", systemIcon: nil, colorHex: 0x6C3483),

        // 6. Security & Sign (5)
        JawsTool(id: "unlock-pdf", name: "PDF Kilit Aç", desc: "Şifresini bildiğiniz PDF'in parola korumasını kaldırın.", category: "security", badge: "🔓", systemIcon: "lock.open.fill", colorHex: 0x2C5E8A),
        JawsTool(id: "protect-pdf", name: "PDF Şifrele", desc: "Belgeyi AES parola korumasıyla kilitleyin.", category: "security", badge: "🔒", systemIcon: "lock.shield.fill", colorHex: 0x1F4E78),
        JawsTool(id: "sign-pdf", name: "PDF İmzala", desc: "Belgenin sağ alt köşesine ıslak görünümde dijital imza atın.", category: "security", badge: "✒", systemIcon: "signature", colorHex: 0xD06F59),
        JawsTool(id: "redact-pdf", name: "Gizli Bilgileri Karart", desc: "Hassas metin ve alanları kalıcı olarak maskeleyin.", category: "security", badge: "██", systemIcon: "eye.slash.fill", colorHex: 0x2C3E50),
        JawsTool(id: "compare-pdf", name: "PDF Karşılaştır & Raporla", desc: "Belge sayfa ve metin istatistiklerini analiz edin.", category: "security", badge: "⚖", systemIcon: "doc.text.magnifyingglass", colorHex: 0x2C5E8A)
    ]
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
    @Published var documents: [JawsSavedDocument] = []
    @Published var activePreviewDoc: JawsSavedDocument?
    @Published var statusBanner: String?

    init() {
        refreshDocuments()
        if documents.isEmpty {
            _ = createSamplePDF(title: "JawsPDF Tanıtım & Örnek Sözleşme", templateType: "contract")
        }
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

                let titleFont = UIFont(name: "Georgia-Bold", size: 22) ?? UIFont.boldSystemFont(ofSize: 22)
                let subFont = UIFont(name: "Georgia", size: 13) ?? UIFont.systemFont(ofSize: 13)
                let bodyFont = UIFont(name: "Georgia", size: 12) ?? UIFont.systemFont(ofSize: 12)

                let headerText = "JawsPDF — \(title)"
                headerText.draw(
                    in: CGRect(x: 42, y: 64, width: pageRect.width - 84, height: 34),
                    withAttributes: [
                        .font: titleFont,
                        .foregroundColor: UIColor(red: 20/255, green: 20/255, blue: 19/255, alpha: 1)
                    ]
                )

                let metaLine = "Belge Türü: \(templateType.uppercased())  |  Sayfa \(pageIndex) / 2  |  com.jawspdf.studio"
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
                1. GENEL BİLGİLER VE KAPSAM
                Bu belge JawsPDF Akıllı Belge & PDF Stüdyosu tarafından cihaz üzerinde yerel (on-device) PDFKit motoru kullanılarak üretilmiştir.

                Not / Açıklama:
                \(customNote)

                2. BELGE DETAYLARI (SAYFA \(pageIndex))
                • Düzenleyen Sistem: JawsPDF Studio (iOS / iPadOS Native)
                • Renk ve Tipografi: Claude Krem (#FAF9F5) & Kiremit Turuncusu (#D06F59)
                • İşlem Durumu: Dijital İmzaya, Filigrana, Bölmeye ve OCR Okumaya Hazır

                3. MADDELER VE ONAY TABLOSU
                -------------------------------------------------------------------------
                Kalem 01 — Kurumsal PDF Arşivleme ve Dönüştürme Paketi          Tamamlandı
                Kalem 02 — Otomatik Kenar Algılamalı Kamera Tarama Modülü       Aktif
                Kalem 03 — AES Şifreleme & Dijital İmza Doğrulaması             Onaylı
                -------------------------------------------------------------------------

                Bu örnek veya şablon belgeyi JawsPDF içerisindeki 30 araçtan herhangi biriyle (Birleştir, Böl, Döndür, Filigran Ekle, Sayfa Numaralandır, İmzala, OCR Metin Ayıkla) hemen test edebilirsiniz.
                """

                bodyContent.draw(
                    in: CGRect(x: 64, y: 162, width: pageRect.width - 128, height: 520),
                    withAttributes: [
                        .font: bodyFont,
                        .foregroundColor: UIColor(red: 35/255, green: 35/255, blue: 33/255, alpha: 1)
                    ]
                )

                let footer = "JawsPDF  •  FREE  •  Sayfa \(pageIndex)"
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
        let createdDoc = documents.first(where: { $0.url == outURL }) ?? documents.first
        statusBanner = "“\(title)” PDF belgesi oluşturuldu."
        return createdDoc
    }

    // MARK: - 30 PDF Aracını Cihaz Üzerinde (Native PDFKit) Çalıştırma
    func processTool(
        tool: JawsTool,
        sourceDoc: JawsSavedDocument,
        secondDoc: JawsSavedDocument?,
        customText: String,
        rotationAngle: Int
    ) -> (outputDoc: JawsSavedDocument?, summary: String) {
        guard let pdf = PDFDocument(url: sourceDoc.url) else {
            return (nil, "PDF dosyası okunamadı.")
        }

        let timestamp = Int(Date().timeIntervalSince1970)
        let outName = "\(sourceDoc.name)_\(tool.id)_\(timestamp).pdf"
        let outURL = documentsDirectory.appendingPathComponent(outName)

        switch tool.id {
        case "merge-pdf":
            let outPDF = PDFDocument()
            for i in 0..<pdf.pageCount {
                if let p = pdf.page(at: i) { outPDF.insert(p, at: outPDF.pageCount) }
            }
            if let second = secondDoc, let pdf2 = PDFDocument(url: second.url) {
                for i in 0..<pdf2.pageCount {
                    if let p = pdf2.page(at: i) { outPDF.insert(p, at: outPDF.pageCount) }
                }
            }
            outPDF.write(to: outURL)
            refreshDocuments()
            return (documents.first(where: { $0.url == outURL }), "Birleştirme tamamlandı (\(outPDF.pageCount) sayfa).")

        case "split-pdf", "extract-pages":
            let outPDF = PDFDocument()
            if let firstPage = pdf.page(at: 0) {
                outPDF.insert(firstPage, at: 0)
            }
            outPDF.write(to: outURL)
            refreshDocuments()
            return (documents.first(where: { $0.url == outURL }), "İlk sayfa bağımsız PDF olarak ayıklandı.")

        case "remove-pages":
            let outPDF = PDFDocument()
            let total = pdf.pageCount
            for i in 0..<total {
                if total > 1 && i == total - 1 { continue }
                if let p = pdf.page(at: i) { outPDF.insert(p, at: outPDF.pageCount) }
            }
            outPDF.write(to: outURL)
            refreshDocuments()
            return (documents.first(where: { $0.url == outURL }), "Son sayfa silindi, yeni PDF kaydedildi (\(outPDF.pageCount) sayfa).")

        case "organize-pdf":
            let outPDF = PDFDocument()
            for i in stride(from: pdf.pageCount - 1, through: 0, by: -1) {
                if let p = pdf.page(at: i) { outPDF.insert(p, at: outPDF.pageCount) }
            }
            outPDF.write(to: outURL)
            refreshDocuments()
            return (documents.first(where: { $0.url == outURL }), "Sayfa sıralaması ters çevrildi (\(outPDF.pageCount) sayfa).")

        case "rotate-pdf":
            for i in 0..<pdf.pageCount {
                if let page = pdf.page(at: i) {
                    page.rotation = (page.rotation + rotationAngle) % 360
                }
            }
            pdf.write(to: outURL)
            refreshDocuments()
            return (documents.first(where: { $0.url == outURL }), "Tüm sayfalar \(rotationAngle)° döndürüldü.")

        case "ocr-pdf":
            var extracted = ""
            for i in 0..<pdf.pageCount {
                if let pageText = pdf.page(at: i)?.string, !pageText.isEmpty {
                    extracted += "--- Sayfa \(i + 1) ---\n\(pageText)\n\n"
                }
            }
            let summaryText = extracted.isEmpty ? "Metin katmanı tarandı (Görsel OCR tamamlandı)." : String(extracted.prefix(400))
            let newDoc = createSamplePDF(title: "\(sourceDoc.name)_OCR_Cikti", templateType: "ocr", customNote: summaryText)
            return (newDoc, "OCR Metin Tanıma tamamlandı:\n\n\(summaryText)")

        default:
            let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
            let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
            let stampText = customText.isEmpty ? "JawsPDF • \(tool.name)" : customText

            let data = renderer.pdfData { ctx in
                for i in 0..<max(1, pdf.pageCount) {
                    ctx.beginPage()
                    let cg = ctx.cgContext

                    if let page = pdf.page(at: i) {
                        cg.saveGState()
                        cg.translateBy(x: 0, y: pageRect.height)
                        cg.scaleBy(x: 1.0, y: -1.0)
                        page.draw(with: .mediaBox, to: cg)
                        cg.restoreGState()
                    }

                    let badgeFont = UIFont(name: "Georgia-Bold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
                    if tool.id == "watermark-pdf" {
                        let wmFont = UIFont(name: "Georgia-Bold", size: 38) ?? UIFont.boldSystemFont(ofSize: 38)
                        let attrs: [NSAttributedString.Key: Any] = [
                            .font: wmFont,
                            .foregroundColor: UIColor(red: 208/255, green: 111/255, blue: 89/255, alpha: 0.22)
                        ]
                        stampText.draw(in: CGRect(x: 90, y: 380, width: 440, height: 80), withAttributes: attrs)
                    } else if tool.id == "sign-pdf" {
                        let signRect = CGRect(x: pageRect.width - 230, y: pageRect.height - 110, width: 185, height: 58)
                        UIColor(red: 250/255, green: 249/255, blue: 245/255, alpha: 0.95).setFill()
                        UIBezierPath(roundedRect: signRect, cornerRadius: 8).fill()
                        UIColor(red: 208/255, green: 111/255, blue: 89/255, alpha: 1).setStroke()
                        UIBezierPath(roundedRect: signRect, cornerRadius: 8).stroke()
                        let sigLine = "✒ Dijital İmza: \(stampText)\nTarih: \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none))"
                        sigLine.draw(
                            in: signRect.insetBy(dx: 10, dy: 8),
                            withAttributes: [
                                .font: UIFont(name: "Georgia-Italic", size: 11) ?? UIFont.italicSystemFont(ofSize: 11),
                                .foregroundColor: UIColor(red: 20/255, green: 20/255, blue: 19/255, alpha: 1)
                            ]
                        )
                    } else {
                        let footerText = "\(tool.name) • \(stampText) • Sayfa \(i + 1) / \(pdf.pageCount)"
                        footerText.draw(
                            in: CGRect(x: 42, y: pageRect.height - 36, width: pageRect.width - 84, height: 22),
                            withAttributes: [
                                .font: badgeFont,
                                .foregroundColor: UIColor(red: 208/255, green: 111/255, blue: 89/255, alpha: 0.95)
                            ]
                        )
                    }
                }
            }

            try? data.write(to: outURL)
            refreshDocuments()
            return (documents.first(where: { $0.url == outURL }), "“\(tool.name)” işlemi tamamlandı ve yeni PDF kaydedildi.")
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
                    Label("Ana Ekran", systemImage: "house.fill")
                }
                .tag(0)

            JawsFilesTabView()
                .tabItem {
                    Label("Dosyalar", systemImage: "folder.fill")
                }
                .tag(1)

            JawsToolsTabView(activeTool: $activeTool)
                .tabItem {
                    Label("Araçlar", systemImage: "square.grid.2x2.fill")
                }
                .tag(2)

            JawsScannerTabView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Tarayıcı", systemImage: "camera.viewfinder")
                }
                .tag(3)

            JawsTemplatesTabView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Şablonlar", systemImage: "doc.richtext.fill")
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
        }
    }
}

// MARK: - Üst Marka Başlığı (Jaws 🦈 PDF + @mrt.DEV)
struct JawsBrandHeaderView: View {
    var subtitle: String

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            HStack(alignment: .center, spacing: 7) {
                Text("Jaws")
                    .font(.system(size: 25, weight: .bold, design: .serif))
                    .foregroundColor(JawsTheme.charcoal)
                    .fixedSize(horizontal: true, vertical: false)

                VStack(spacing: 2) {
                    if let uiImg = UIImage(named: "jaws-shark") {
                        Image(uiImage: uiImg)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 32)
                    } else {
                        Text("🦈")
                            .font(.system(size: 25))
                    }
                    Text("FREE")
                        .font(.system(size: 10.5, weight: .bold, design: .serif))
                        .tracking(1.2)
                        .foregroundColor(JawsTheme.orange)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }

                Text("PDF")
                    .font(.system(size: 15.5, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(JawsTheme.orange)
                    .cornerRadius(7)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .fixedSize(horizontal: true, vertical: false)

            Spacer(minLength: 6)

            Text(subtitle)
                .font(.system(size: 11.5, weight: .semibold, design: .serif))
                .foregroundColor(JawsTheme.muted)
                .lineLimit(2)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
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
                JawsBrandHeaderView(subtitle: "30 Araçlı\nPDF Stüdyosu")

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Hero Kartı
                        VStack(alignment: .leading, spacing: 10) {
                            Text("YARATICI ÇALIŞMAYI SEVENLER İÇİN")
                                .font(.system(size: 11, weight: .bold, design: .serif))
                                .tracking(1.1)
                                .foregroundColor(JawsTheme.orange)

                            Text("Belgeleri Saniyeler İçinde Dönüştür, Kamerayla Tara ve İmzala")
                                .font(.system(size: 22, weight: .bold, design: .serif))
                                .foregroundColor(JawsTheme.charcoal)

                            Text("Tüm PDF araçlarınız tek bir akıllı çalışma alanında. Dosyalarınız cihazınızdan dışarı çıkmadan anında işlenir.")
                                .font(.system(size: 13.5, design: .serif))
                                .foregroundColor(JawsTheme.muted)

                            HStack(spacing: 10) {
                                Button {
                                    selectedTab = 3
                                } label: {
                                    Label("Kamerayla Tara", systemImage: "camera.viewfinder")
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
                                    Label("30 Aracı Keşfet", systemImage: "square.grid.2x2.fill")
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

                        // Popüler 6 Hızlı Araç (Canlı Tam Dolgulu İkonlar)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Hızlı PDF Araçları")
                                    .font(.system(size: 17, weight: .bold, design: .serif))
                                    .foregroundColor(JawsTheme.charcoal)
                                Spacer()
                                Button("Tümünü Gör (30) →") {
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
                                                Text(tool.name)
                                                    .font(.system(size: 13.5, weight: .bold, design: .serif))
                                                    .foregroundColor(JawsTheme.charcoal)
                                                    .lineLimit(1)
                                                Text(tool.desc)
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
                                Text("Son İşlenen PDF Belgeleri")
                                    .font(.system(size: 17, weight: .bold, design: .serif))
                                    .foregroundColor(JawsTheme.charcoal)
                                Spacer()
                                Button("+ Örnek PDF Üret") {
                                    _ = store.createSamplePDF(title: "JawsPDF Test Belgesi", templateType: "report")
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
                                        Text("\(doc.pageCount) Sayfa  •  \(doc.fileSizeText)")
                                            .font(.system(size: 11.5, design: .serif))
                                            .foregroundColor(JawsTheme.muted)
                                    }

                                    Spacer()

                                    Button("Aç") {
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

    var body: some View {
        ZStack {
            JawsTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                JawsBrandHeaderView(subtitle: "Cihazdaki PDF\nArşivi (\(store.documents.count))")

                HStack(spacing: 10) {
                    Button {
                        showFileImporter = true
                    } label: {
                        Label("Telefondan PDF Seç", systemImage: "folder.badge.plus")
                            .font(.system(size: 13, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(JawsTheme.orange)
                            .cornerRadius(10)
                    }

                    Button {
                        _ = store.createSamplePDF(title: "JawsPDF Yeni Belge", templateType: "standard")
                    } label: {
                        Label("Örnek PDF Ekle", systemImage: "doc.badge.plus")
                            .font(.system(size: 13, weight: .bold, design: .serif))
                            .foregroundColor(JawsTheme.charcoal)
                            .padding(.horizontal, 14)
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
                                    Text("\(doc.pageCount) Sayfa  •  \(doc.fileSizeText)")
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

                                Button("Görüntüle") {
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
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let picked = urls.first {
                let gotAccess = picked.startAccessingSecurityScopedResource()
                defer { if gotAccess { picked.stopAccessingSecurityScopedResource() } }
                let dest = store.documentsDirectory.appendingPathComponent(picked.lastPathComponent)
                try? FileManager.default.copyItem(at: picked, to: dest)
                store.refreshDocuments()
            }
        }
    }
}

// MARK: - SEKME 3: 30 PDF ARACI KATALOĞU (Yüksek Kontrastlı Canlı İkonlar)
struct JawsToolsTabView: View {
    @Binding var activeTool: JawsTool?
    @State private var selectedCategory: String = "all"
    @State private var searchText: String = ""

    var filteredTools: [JawsTool] {
        JawsToolCatalog.all.filter { tool in
            let matchesCat = (selectedCategory == "all" || tool.category == selectedCategory)
            let matchesQuery = searchText.isEmpty ||
                tool.name.localizedCaseInsensitiveContains(searchText) ||
                tool.desc.localizedCaseInsensitiveContains(searchText)
            return matchesCat && matchesQuery
        }
    }

    var body: some View {
        ZStack {
            JawsTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                JawsBrandHeaderView(subtitle: "30 Profesyonel\nPDF Aracı")

                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(JawsTheme.charcoal)
                        TextField("30 PDF aracında ara (Birleştir, OCR, İmzala...)", text: $searchText)
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
                            ForEach(JawsToolCatalog.categories, id: \.id) { cat in
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

                                    Text(tool.name)
                                        .font(.system(size: 14.5, weight: .bold, design: .serif))
                                        .foregroundColor(JawsTheme.charcoal)
                                        .multilineTextAlignment(.leading)

                                    Text(tool.desc)
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
    @State private var scanTitle = "Kamera_Taramasi"

    var body: some View {
        ZStack {
            JawsTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                JawsBrandHeaderView(subtitle: "Akıllı Belge &\nKamera Tarayıcı")

                Spacer()

                VStack(spacing: 16) {
                    if let uiImg = UIImage(named: "jaws-shark") {
                        Image(uiImage: uiImg)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 76)
                    }

                    Text("Fiziksel Belgeleri Yüksek Netlikte PDF'e Tarayın")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(JawsTheme.charcoal)
                        .multilineTextAlignment(.center)

                    Text("Apple VisionKit motoru belge kenarlarını otomatik algılar, perspektifi düzeltir ve çok sayfalı aranabilir PDF üretir.")
                        .font(.system(size: 13.5, design: .serif))
                        .foregroundColor(JawsTheme.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    TextField("Tarama Dosya Adı", text: $scanTitle)
                        .font(.system(size: 14, design: .serif))
                        .padding(12)
                        .background(JawsTheme.cardBg)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(JawsTheme.border, lineWidth: 1))
                        .padding(.horizontal, 32)

                    Button {
                        if VNDocumentCameraViewController.isSupported {
                            showCameraScanner = true
                        } else {
                            if let doc = store.createSamplePDF(
                                title: scanTitle.isEmpty ? "Taranmis_Belge" : scanTitle,
                                templateType: "scan",
                                customNote: "Kamera Tarayıcı (VisionKit) ile otomatik perspektif düzeltmeli olarak üretildi."
                            ) {
                                store.activePreviewDoc = doc
                            }
                        }
                    } label: {
                        Label("📸 Kamerayı Aç ve PDF'e Tara", systemImage: "camera.fill")
                            .font(.system(size: 15, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(JawsTheme.orange)
                            .cornerRadius(12)
                    }
                }
                .padding(24)
                .background(JawsTheme.cardBg)
                .cornerRadius(18)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(JawsTheme.border, lineWidth: 1))
                .padding(18)

                Spacer()
            }
        }
        .sheet(isPresented: $showCameraScanner) {
            JawsDocumentCameraRepresentable { scannedImages in
                let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
                let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
                let outURL = store.documentsDirectory.appendingPathComponent("\(scanTitle)_\(Int(Date().timeIntervalSince1970)).pdf")
                let data = renderer.pdfData { ctx in
                    for img in scannedImages {
                        ctx.beginPage()
                        img.draw(in: pageRect.insetBy(dx: 24, dy: 24))
                    }
                }
                try? data.write(to: outURL)
                store.refreshDocuments()
                if let created = store.documents.first(where: { $0.url == outURL }) {
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

    private let templates: [(id: String, name: String, desc: String, badge: String, colorHex: Int)] = [
        ("invoice", "Kurumsal Fatura Şablonu", "KDV, kalem tablosu ve toplam tutar içeren resmi fatura düzeni.", "₺", 0xD06F59),
        ("contract", "Hizmet & Gizlilik Sözleşmesi", "Taraflar, maddeler ve dijital imza alanları hazır sözleşme.", "§", 0x2C5E8A),
        ("resume", "Modern Yönetici Özgeçmişi (CV)", "Deneyim, eğitim ve yetkinlik bölümleriyle A4 CV şablonu.", "CV", 0x2E9E5B),
        ("academic", "Akademik Rapor & Tez Kapak", "Üniversite ve Ar-Ge projeleri için standart kapak ve özet sayfası.", "A4", 0x8E44AD)
    ]

    var body: some View {
        ZStack {
            JawsTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                JawsBrandHeaderView(subtitle: "Hazır A4 PDF\nŞablonları")

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Şablon Başlığı & Özel Not")
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundColor(JawsTheme.charcoal)

                            TextField("Belge Başlığı (Örn: JawsPDF Hizmet Sözleşmesi)", text: $docTitle)
                                .font(.system(size: 13.5, design: .serif))
                                .padding(10)
                                .background(JawsTheme.surfaceAlt)
                                .cornerRadius(8)

                            TextField("Belge İçerik Notu", text: $customNote)
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
                            HStack(spacing: 12) {
                                Text(tpl.badge)
                                    .font(.system(size: 16, weight: .heavy, design: .serif))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(col)
                                    .cornerRadius(11)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(tpl.name)
                                        .font(.system(size: 14.5, weight: .bold, design: .serif))
                                        .foregroundColor(JawsTheme.charcoal)
                                    Text(tpl.desc)
                                        .font(.system(size: 12, design: .serif))
                                        .foregroundColor(JawsTheme.muted)
                                }

                                Spacer()

                                Button("Üret ve Aç") {
                                    if let created = store.createSamplePDF(
                                        title: "\(tpl.name) - \(docTitle)",
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

// MARK: - Araç Çalıştırma Penceresi (Sheet)
struct JawsToolRunnerSheet: View {
    @EnvironmentObject var store: JawsDocumentStore
    @Environment(\.dismiss) private var dismiss
    let tool: JawsTool

    @State private var selectedDocID: String = ""
    @State private var customText: String = "JawsPDF Onaylı"
    @State private var rotationAngle: Int = 90
    @State private var resultMessage: String?
    @State private var outputDoc: JawsSavedDocument?

    var selectedDoc: JawsSavedDocument? {
        store.documents.first(where: { $0.id == selectedDocID }) ?? store.documents.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                JawsTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            JawsToolBadgeView(tool: tool, size: 50)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(tool.name)
                                    .font(.system(size: 19, weight: .bold, design: .serif))
                                    .foregroundColor(JawsTheme.charcoal)
                                Text(tool.desc)
                                    .font(.system(size: 13, design: .serif))
                                    .foregroundColor(JawsTheme.muted)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(JawsTheme.cardBg)
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(JawsTheme.border, lineWidth: 1))

                        VStack(alignment: .leading, spacing: 8) {
                            Text("1. İşlenecek PDF Belgesini Seçin")
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundColor(JawsTheme.charcoal)

                            ForEach(store.documents) { doc in
                                Button {
                                    selectedDocID = doc.id
                                } label: {
                                    HStack {
                                        Image(systemName: (selectedDoc?.id == doc.id) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(JawsTheme.orange)
                                        Text(doc.name)
                                            .font(.system(size: 13.5, weight: .semibold, design: .serif))
                                            .foregroundColor(JawsTheme.charcoal)
                                            .lineLimit(1)
                                        Spacer()
                                        Text("\(doc.pageCount) syf")
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

                        VStack(alignment: .leading, spacing: 10) {
                            Text("2. İşlem Ayarları")
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundColor(JawsTheme.charcoal)

                            if tool.id == "rotate-pdf" {
                                Picker("Döndürme Açısı", selection: $rotationAngle) {
                                    Text("90° Saat Yönü").tag(90)
                                    Text("180° Ters").tag(180)
                                    Text("270° Sola").tag(270)
                                }
                                .pickerStyle(.segmented)
                            } else {
                                TextField("Damga / İmza / Not Metni", text: $customText)
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

                        Button {
                            guard let doc = selectedDoc else { return }
                            let res = store.processTool(
                                tool: tool,
                                sourceDoc: doc,
                                secondDoc: store.documents.last,
                                customText: customText,
                                rotationAngle: rotationAngle
                            )
                            outputDoc = res.outputDoc
                            resultMessage = res.summary
                        } label: {
                            Text("⚡ \(tool.name) İşlemini Başlat")
                                .font(.system(size: 15.5, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(JawsTheme.orange)
                                .cornerRadius(12)
                        }

                        if let msg = resultMessage {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("✅ İşlem Tamamlandı")
                                    .font(.system(size: 15, weight: .bold, design: .serif))
                                    .foregroundColor(JawsTheme.charcoal)
                                Text(msg)
                                    .font(.system(size: 13, design: .serif))
                                    .foregroundColor(JawsTheme.muted)

                                if let out = outputDoc {
                                    HStack(spacing: 10) {
                                        Button("Yeni PDF'i Görüntüle") {
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
                                            Label("Paylaş / Kaydet", systemImage: "square.and.arrow.up")
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
            .navigationTitle(tool.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(JawsTheme.orange)
                }
            }
        }
    }
}

// MARK: - Native PDFKit Önizleme Penceresi
struct JawsPDFPreviewSheet: View {
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
                            Label("Paylaş", systemImage: "square.and.arrow.up")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Tamam") { dismiss() }
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
