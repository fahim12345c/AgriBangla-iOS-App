import UIKit

struct PDFGenerator {

    static func generate(data: PDFContent) -> Data {
        let pageW: CGFloat = 595.2
        let pageH: CGFloat = 841.8
        let margin: CGFloat = 36
        let contentW = pageW - 2 * margin
        let footerH: CGFloat = 36
        let brandGreen = UIColor(red: 0.18, green: 0.55, blue: 0.34, alpha: 1)

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageW, height: pageH))

        return renderer.pdfData { ctx in
            let cg = ctx.cgContext
            var pageNum = 1

            func drawFooter() {
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 8),
                    .foregroundColor: UIColor.lightGray
                ]
                let text = "AgriBD — Smart Farming Assistant  •  Page \(pageNum)"
                let size = (text as NSString).size(withAttributes: attrs)
                (text as NSString).draw(at: CGPoint(x: (pageW - size.width) / 2, y: pageH - footerH + 12), withAttributes: attrs)
            }

            func drawHeader() {
                let rect = CGRect(x: 0, y: 0, width: pageW, height: 80)
                cg.setFillColor(brandGreen.cgColor)
                cg.fill(rect)

                let titleAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 20),
                    .foregroundColor: UIColor.white
                ]
                let title = "AgriBD"
                let titleSize = (title as NSString).size(withAttributes: titleAttrs)
                (title as NSString).draw(at: CGPoint(x: (pageW - titleSize.width) / 2, y: 16), withAttributes: titleAttrs)

                let subAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.9)
                ]
                let sub = "🌱 Plant Disease Report"
                let subSize = (sub as NSString).size(withAttributes: subAttrs)
                (sub as NSString).draw(at: CGPoint(x: (pageW - subSize.width) / 2, y: 46), withAttributes: subAttrs)
            }

            func drawMeta(y: inout CGFloat) {
                let name = data.diseaseName.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: "/", with: " & ")
                let nameAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 16),
                    .foregroundColor: brandGreen
                ]
                (name as NSString).draw(at: CGPoint(x: margin, y: y), withAttributes: nameAttrs)
                y += 26

                let infoAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 11),
                    .foregroundColor: UIColor.darkGray
                ]
                let info = "Confidence: \(Int(data.confidence * 100))%  |  \(data.date)"
                (info as NSString).draw(at: CGPoint(x: margin, y: y), withAttributes: infoAttrs)
                y += 20

                if let image = data.image {
                    let maxW: CGFloat = 140
                    let maxH: CGFloat = 140
                    let scale = min(maxW / image.size.width, maxH / image.size.height, 1)
                    let drawRect = CGRect(x: margin, y: y, width: image.size.width * scale, height: image.size.height * scale)
                    image.draw(in: drawRect)
                    y += drawRect.height + 16
                }

                cg.setStrokeColor(brandGreen.withAlphaComponent(0.3).cgColor)
                cg.setLineWidth(1)
                cg.move(to: CGPoint(x: margin, y: y))
                cg.addLine(to: CGPoint(x: pageW - margin, y: y))
                cg.strokePath()
                y += 14
            }

            // --- Page 1 ---
            ctx.beginPage()
            drawHeader()
            var y: CGFloat = 100
            drawMeta(y: &y)

            // Draw report text
            let paraStyle = NSMutableParagraphStyle()
            paraStyle.lineSpacing = 5
            paraStyle.paragraphSpacing = 6

            let textAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paraStyle
            ]

            let attributed = NSAttributedString(string: data.reportText, attributes: textAttrs)
            let framesetter = CTFramesetterCreateWithAttributedString(attributed as CFAttributedString)

            let textRect = CGRect(x: margin, y: y, width: contentW, height: pageH - y - footerH - 8)
            let path = CGPath(rect: textRect, transform: nil)
            let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
            CTFrameDraw(frame, cg)
            let visibleRange = CTFrameGetVisibleStringRange(frame)

            drawFooter()

            // --- Additional pages ---
            var totalDrawn = visibleRange.length
            while totalDrawn < attributed.length {
                pageNum += 1
                ctx.beginPage()
                drawHeader()

                let restRect = CGRect(x: margin, y: 96, width: contentW, height: pageH - 96 - footerH - 8)
                let restPath = CGPath(rect: restRect, transform: nil)
                let restFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(totalDrawn, 0), restPath, nil)
                CTFrameDraw(restFrame, cg)
                let restRange = CTFrameGetVisibleStringRange(restFrame)
                totalDrawn += restRange.length

                drawFooter()
            }
        }
    }
}

struct PDFContent {
    let diseaseName: String
    let confidence: Float
    let reportText: String
    let image: UIImage?
    let date: String

    init(diseaseName: String, confidence: Float, reportText: String, image: UIImage?) {
        self.diseaseName = diseaseName
        self.confidence = confidence
        self.reportText = reportText
        self.image = image
        let fmt = DateFormatter()
        fmt.dateFormat = "dd MMM yyyy, h:mm a"
        fmt.locale = Locale(identifier: "bn_BD")
        self.date = fmt.string(from: Date())
    }
}
