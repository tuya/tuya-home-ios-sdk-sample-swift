//
//  StreamChatMessageCell.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class StreamChatMessage: NSObject {
    var eventId: String = ""
    var sendContent: String = "" // asr | text
    var sendImage: UIImage? // image (single, kept for backward compatibility)
    /// Sent images (multi-image). Empty by default; when non-empty the cell displays these.
    var sendImages: [UIImage] = []
    /// Received images (multi-image). Empty by default.
    var recvImages: [UIImage] = []
    var nlg: NSMutableString = NSMutableString()
    var skill: String = ""
    var isBreak: Bool = false

    override init() {
        super.init()
        nlg = NSMutableString()
    }

    /// Images to render in the sent (ASR) bubble: prefers the multi-image array, falls back to the single image.
    var displaySendImages: [UIImage] {
        if !sendImages.isEmpty { return sendImages }
        if let img = sendImage { return [img] }
        return []
    }
}

class StreamChatMessageCell: UITableViewCell {

    // MARK: - Constants
    private static let kBubbleMaxWidth: CGFloat = 300.0
    private static let kBubblePadding: CGFloat = 12.0
    private static let kBubbleMargin: CGFloat = 16.0 // Top/Bottom margin for the cell, and spacing after last bubble.
    private static let kBubbleSpacing: CGFloat = 10.0 // Spacing between ASR and NLG bubbles if both exist.
    private static let kSkillLabelHeight: CGFloat = 20.0
    private static let kSkillLabelMargin: CGFloat = 5.0

    // New constants
    private static let kSentImageMaxWidth: CGFloat = 150.0
    private static let kAsrContentVerticalSpacing: CGFloat = 5.0 // Spacing between text and image within the ASR bubble

    // Multi-image thumbnail size (used when there is more than one image); single images keep the adaptive size.
    private static let kImageThumbSize: CGFloat = 80.0
    private static let kImageThumbSpacing: CGFloat = 6.0

    // MARK: - Properties
    // ASR (Sent message) related views
    private var asrBubbleView: UIView!
    private var asrLabel: UILabel!
    /// Horizontal scroll container for sent images. Single image keeps the adaptive size and does not scroll.
    private var asrImagesScrollView: UIScrollView!
    private var asrImageViews: [UIImageView] = [] // reused image views inside the scroll view

    // NLG (Received message) related views
    private var nlgLabel: UILabel!
    private var nlgBubbleView: UIView!
    /// Horizontal scroll container for received images (left aligned, independent of the text bubble).
    private var recvImagesScrollView: UIScrollView!
    private var recvImageViews: [UIImageView] = [] // reused image views inside the scroll view

    private var skillLabel: UILabel!

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        selectionStyle = .none
        backgroundColor = .clear
        setupViews()
    }

    // MARK: - Setup
    private func setupViews() {
        // ASR (Sent) Bubble and its content
        asrBubbleView = UIView()
        asrBubbleView.layer.cornerRadius = 16.0
        asrBubbleView.layer.masksToBounds = true // This will be handled by the mask for specific corners
        asrBubbleView.backgroundColor = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        contentView.addSubview(asrBubbleView)

        asrLabel = UILabel()
        asrLabel.font = UIFont.systemFont(ofSize: 16.0)
        asrLabel.numberOfLines = 0
        asrLabel.textColor = .white
        asrBubbleView.addSubview(asrLabel)

        asrImagesScrollView = UIScrollView()
        asrImagesScrollView.showsHorizontalScrollIndicator = false
        asrImagesScrollView.alwaysBounceHorizontal = false
        asrBubbleView.addSubview(asrImagesScrollView)

        // NLG (Received) Bubble and its content
        nlgBubbleView = UIView()
        nlgBubbleView.layer.cornerRadius = 16.0
        nlgBubbleView.layer.masksToBounds = true // This will be handled by the mask
        nlgBubbleView.backgroundColor = UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 234.0/255.0, alpha: 1.0)
        contentView.addSubview(nlgBubbleView)

        nlgLabel = UILabel()
        nlgLabel.font = UIFont.systemFont(ofSize: 16.0)
        nlgLabel.numberOfLines = 0
        nlgLabel.textColor = .black
        nlgBubbleView.addSubview(nlgLabel)

        // Received images container (left aligned, independent of the text bubble)
        recvImagesScrollView = UIScrollView()
        recvImagesScrollView.showsHorizontalScrollIndicator = false
        recvImagesScrollView.alwaysBounceHorizontal = false
        contentView.addSubview(recvImagesScrollView)

        skillLabel = UILabel()
        skillLabel.font = UIFont.systemFont(ofSize: 12.0)
        skillLabel.textColor = .gray
        skillLabel.textAlignment = .left
        contentView.addSubview(skillLabel)
    }

    // MARK: - Configuration
    func configureCellWithMessage(_ message: StreamChatMessage) {
        let contentWidth = contentView.frame.size.width
        var currentY = StreamChatMessageCell.kBubbleMargin // Top margin for the first bubble

        let sentImages = message.displaySendImages
        let recvImages = message.recvImages
        let hasSentText = !message.sendContent.isEmpty
        let hasSentImage = !sentImages.isEmpty
        let hasNlg = message.nlg.length > 0
        let hasRecvImage = !recvImages.isEmpty

        // Reset visibility for reuse
        asrBubbleView.isHidden = true
        asrLabel.isHidden = true
        asrImagesScrollView.isHidden = true
        nlgBubbleView.isHidden = true
        nlgLabel.isHidden = true
        recvImagesScrollView.isHidden = true
        skillLabel.isHidden = true

        // --- Sent Message (ASR Text and/or Image) ---
        if hasSentText || hasSentImage {
            asrBubbleView.isHidden = false
            var yOffsetInAsrBubble = StreamChatMessageCell.kBubblePadding
            var asrContentMaxWidth: CGFloat = 0

            // 1. Layout Text if present
            if hasSentText {
                asrLabel.isHidden = false
                asrLabel.text = message.sendContent
                let maxAsrTextSize = CGSize(width: StreamChatMessageCell.kBubbleMaxWidth - 2 * StreamChatMessageCell.kBubblePadding, height: .greatestFiniteMagnitude)
                let asrTextActualSize = calculateTextSize(with: message.sendContent, maxSize: maxAsrTextSize)

                asrLabel.frame = CGRect(x: StreamChatMessageCell.kBubblePadding, y: yOffsetInAsrBubble, width: asrTextActualSize.width, height: asrTextActualSize.height)
                yOffsetInAsrBubble += asrTextActualSize.height
                asrContentMaxWidth = max(asrContentMaxWidth, asrTextActualSize.width)
            }

            // 2. Layout Image(s) if present
            var imagesAreaSize: CGSize = .zero
            if hasSentImage {
                if hasSentText { // Add spacing if text is above image
                    yOffsetInAsrBubble += StreamChatMessageCell.kAsrContentVerticalSpacing
                }

                let bubbleContentMaxWidth = StreamChatMessageCell.kBubbleMaxWidth - 2 * StreamChatMessageCell.kBubblePadding
                imagesAreaSize = StreamChatMessageCell.imagesAreaSize(for: sentImages, bubbleContentMaxWidth: bubbleContentMaxWidth)
                layoutImages(sentImages,
                             inScrollView: asrImagesScrollView,
                             reusedViews: &asrImageViews,
                             origin: CGPoint(x: StreamChatMessageCell.kBubblePadding, y: yOffsetInAsrBubble),
                             areaSize: imagesAreaSize)
                yOffsetInAsrBubble += imagesAreaSize.height
                asrContentMaxWidth = max(asrContentMaxWidth, imagesAreaSize.width)
            }

            var asrBubbleContentHeight = yOffsetInAsrBubble - StreamChatMessageCell.kBubblePadding // Total height of content inside
            if hasSentText && hasSentImage {
                asrBubbleContentHeight = (asrLabel.frame.size.height + StreamChatMessageCell.kAsrContentVerticalSpacing + imagesAreaSize.height)
            } else if hasSentText {
                asrBubbleContentHeight = asrLabel.frame.size.height
            } else if hasSentImage {
                asrBubbleContentHeight = imagesAreaSize.height
            }

            let asrBubbleWidth = asrContentMaxWidth + 2 * StreamChatMessageCell.kBubblePadding
            let asrBubbleHeight = asrBubbleContentHeight + 2 * StreamChatMessageCell.kBubblePadding

            asrBubbleView.frame = CGRect(x: contentWidth - asrBubbleWidth, // Align to right
                                        y: currentY, width: asrBubbleWidth, height: asrBubbleHeight)

            let asrMaskLayer = CAShapeLayer()
            let asrMaskPath = UIBezierPath(
                roundedRect: asrBubbleView.bounds,
                byRoundingCorners: [.topLeft, .bottomLeft, .bottomRight],
                cornerRadii: CGSize(width: 16.0, height: 16.0)
            )
            asrMaskLayer.path = asrMaskPath.cgPath
            asrBubbleView.layer.mask = asrMaskLayer

            currentY += asrBubbleHeight
            if hasNlg || hasRecvImage { // Add spacing only if a following bubble exists
                currentY += StreamChatMessageCell.kBubbleSpacing
            }
        }

        // --- Received Message (NLG) ---
        if hasNlg {
            nlgBubbleView.isHidden = false
            nlgLabel.isHidden = false
            nlgLabel.text = message.nlg as String

            let maxNlgBubbleSize = CGSize(width: StreamChatMessageCell.kBubbleMaxWidth - 2 * StreamChatMessageCell.kBubblePadding, height: .greatestFiniteMagnitude)
            let nlgTextSize = calculateTextSize(with: message.nlg as String, maxSize: maxNlgBubbleSize)

            let nlgBubbleWidth = nlgTextSize.width + 2 * StreamChatMessageCell.kBubblePadding
            let nlgBubbleHeight = nlgTextSize.height + 2 * StreamChatMessageCell.kBubblePadding

            nlgBubbleView.frame = CGRect(x: 0, y: currentY, width: nlgBubbleWidth, height: nlgBubbleHeight) // Align to left
            nlgLabel.frame = CGRect(x: StreamChatMessageCell.kBubblePadding, y: StreamChatMessageCell.kBubblePadding, width: nlgTextSize.width, height: nlgTextSize.height)

            let nlgMaskLayer = CAShapeLayer()
            let nlgMaskPath = UIBezierPath(
                roundedRect: nlgBubbleView.bounds,
                byRoundingCorners: [.topRight, .bottomLeft, .bottomRight],
                cornerRadii: CGSize(width: 16.0, height: 16.0)
            )
            nlgMaskLayer.path = nlgMaskPath.cgPath
            nlgBubbleView.layer.mask = nlgMaskLayer

            currentY += nlgBubbleHeight

            if !message.skill.isEmpty {
                skillLabel.isHidden = false
                skillLabel.text = "SKILL: \(message.skill)"
                skillLabel.frame = CGRect(
                    x: StreamChatMessageCell.kBubblePadding,
                    y: currentY + StreamChatMessageCell.kSkillLabelMargin, // Add left padding for skill label
                    width: contentWidth - 2 * StreamChatMessageCell.kBubblePadding,
                    height: StreamChatMessageCell.kSkillLabelHeight
                )
                // currentY is already at the bottom of nlgBubble. Skill label is below it.
            }
        }

        // --- Received Images (left aligned) ---
        if hasRecvImage {
            if hasNlg {
                currentY += StreamChatMessageCell.kBubbleSpacing
            }
            let bubbleContentMaxWidth = StreamChatMessageCell.kBubbleMaxWidth - 2 * StreamChatMessageCell.kBubblePadding
            let recvAreaSize = StreamChatMessageCell.imagesAreaSize(for: recvImages, bubbleContentMaxWidth: bubbleContentMaxWidth)
            layoutImages(recvImages,
                         inScrollView: recvImagesScrollView,
                         reusedViews: &recvImageViews,
                         origin: CGPoint(x: 0, y: currentY),
                         areaSize: recvAreaSize)
            currentY += recvAreaSize.height
        }

        // Alpha for break state
        let alpha: CGFloat = message.isBreak ? 0.7 : 1.0
        asrBubbleView.alpha = alpha
        nlgBubbleView.alpha = alpha
        recvImagesScrollView.alpha = alpha
        skillLabel.alpha = alpha
    }

    // MARK: - Height Calculation
    static func heightForMessage(_ message: StreamChatMessage, withWidth width: CGFloat) -> CGFloat {
        var totalHeight = kBubbleMargin // Top margin

        let sentImages = message.displaySendImages
        let recvImages = message.recvImages
        let hasSentText = !message.sendContent.isEmpty
        let hasSentImage = !sentImages.isEmpty
        let hasNlg = message.nlg.length > 0
        let hasRecvImage = !recvImages.isEmpty

        // Calculate height for Sent (ASR) content
        if hasSentText || hasSentImage {
            var asrContentInnerHeight: CGFloat = 0

            if hasSentText {
                let maxAsrTextSize = CGSize(width: kBubbleMaxWidth - 2 * kBubblePadding, height: .greatestFiniteMagnitude)
                let asrTextActualSize = calculateTextSize(with: message.sendContent, maxSize: maxAsrTextSize)
                asrContentInnerHeight += asrTextActualSize.height
            }

            if hasSentImage {
                if hasSentText { // Space between text and image
                    asrContentInnerHeight += kAsrContentVerticalSpacing
                }
                let imagesAreaSize = imagesAreaSize(for: sentImages, bubbleContentMaxWidth: kBubbleMaxWidth - 2 * kBubblePadding)
                asrContentInnerHeight += imagesAreaSize.height
            }

            let asrBubbleHeight = asrContentInnerHeight + 2 * kBubblePadding // Add bubble's top/bottom padding
            totalHeight += asrBubbleHeight

            if hasNlg || hasRecvImage { // If a following bubble exists, add spacing
                totalHeight += kBubbleSpacing
            }
        }

        // Calculate height for Received (NLG) content
        if hasNlg {
            let maxNlgBubbleSize = CGSize(width: kBubbleMaxWidth - 2 * kBubblePadding, height: .greatestFiniteMagnitude)
            let nlgTextSize = calculateTextSize(with: message.nlg as String, maxSize: maxNlgBubbleSize)
            let nlgBubbleHeight = nlgTextSize.height + 2 * kBubblePadding
            totalHeight += nlgBubbleHeight

            if !message.skill.isEmpty {
                totalHeight += kSkillLabelMargin + kSkillLabelHeight
            }
        }

        // Calculate height for Received images
        if hasRecvImage {
            if hasNlg {
                totalHeight += kBubbleSpacing
            }
            let recvAreaSize = imagesAreaSize(for: recvImages, bubbleContentMaxWidth: kBubbleMaxWidth - 2 * kBubblePadding)
            totalHeight += recvAreaSize.height
        }

        totalHeight += kBubbleMargin // Bottom margin for the cell
        return totalHeight
    }

    // MARK: - Multi-image helpers

    /// Overall size of the image area: a single image keeps its adaptive aspect ratio; multiple images use fixed
    /// square thumbnails laid out horizontally (scrollable, no line wrapping).
    static func imagesAreaSize(for images: [UIImage], bubbleContentMaxWidth: CGFloat) -> CGSize {
        guard !images.isEmpty else { return .zero }
        if images.count == 1 {
            return calculateImageDisplaySize(
                for: images[0],
                maxDisplayWidth: kSentImageMaxWidth,
                bubbleContentAreaMaxWidth: bubbleContentMaxWidth
            )
        }
        let count = CGFloat(images.count)
        let width = min(bubbleContentMaxWidth, count * kImageThumbSize + (count - 1) * kImageThumbSpacing)
        return CGSize(width: ceil(width), height: kImageThumbSize)
    }

    /// Lays out images in a horizontal scroll view. The scroll view frame is set to `areaSize` (the visible area);
    /// the content size is the full width of all images so it can scroll horizontally. Single image keeps the adaptive
    /// display size and does not need scrolling.
    private func layoutImages(_ images: [UIImage],
                              inScrollView scrollView: UIScrollView,
                              reusedViews: inout [UIImageView],
                              origin: CGPoint,
                              areaSize: CGSize) {
        guard !images.isEmpty, areaSize.width > 0, areaSize.height > 0 else {
            scrollView.isHidden = true
            return
        }
        scrollView.isHidden = false
        scrollView.frame = CGRect(origin: origin, size: areaSize)

        let isSingle = images.count == 1

        if isSingle {
            // Single image: fill the visible area, no scrolling
            scrollView.contentSize = areaSize
            ensureReusableCount(&reusedViews, in: scrollView, count: 1)
            let iv = reusedViews[0]
            iv.isHidden = false
            iv.image = images[0]
            iv.contentMode = .scaleAspectFit
            iv.frame = CGRect(origin: .zero, size: areaSize)
            hideExtras(reusedViews, from: 1)
            return
        }

        // Multiple images: square thumbnails laid out horizontally; full width can exceed the visible area
        let count = CGFloat(images.count)
        let contentWidth = count * StreamChatMessageCell.kImageThumbSize + (count - 1) * StreamChatMessageCell.kImageThumbSpacing
        scrollView.contentSize = CGSize(width: contentWidth, height: areaSize.height)

        ensureReusableCount(&reusedViews, in: scrollView, count: images.count)
        for i in 0..<images.count {
            let iv = reusedViews[i]
            iv.isHidden = false
            iv.image = images[i]
            iv.contentMode = .scaleAspectFill
            let x = CGFloat(i) * (StreamChatMessageCell.kImageThumbSize + StreamChatMessageCell.kImageThumbSpacing)
            iv.frame = CGRect(x: x, y: 0, width: StreamChatMessageCell.kImageThumbSize, height: StreamChatMessageCell.kImageThumbSize)
        }
        hideExtras(reusedViews, from: images.count)
    }

    private func ensureReusableCount(_ views: inout [UIImageView], in scrollView: UIScrollView, count: Int) {
        while views.count < count {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.layer.cornerRadius = 8.0
            iv.layer.masksToBounds = true
            scrollView.addSubview(iv)
            views.append(iv)
        }
    }

    private func hideExtras(_ views: [UIImageView], from start: Int) {
        for i in start..<views.count {
            views[i].isHidden = true
            views[i].image = nil
        }
    }

    // MARK: - Helper Methods
    // Helper to calculate scaled image display size
    static func calculateImageDisplaySize(for image: UIImage, maxDisplayWidth: CGFloat, bubbleContentAreaMaxWidth: CGFloat) -> CGSize {
        guard image.size.width > 0 && image.size.height > 0 else {
            return .zero
        }

        let originalSize = image.size
        let aspectRatio = originalSize.height / originalSize.width

        var displayWidth = originalSize.width
        var displayHeight = originalSize.height

        // 1. Apply max image display width (e.g., 150pt)
        if displayWidth > maxDisplayWidth {
            displayWidth = maxDisplayWidth
            displayHeight = displayWidth * aspectRatio
        }

        // 2. Ensure it doesn't exceed the bubble's content area max width
        // This might further reduce the size if maxImageDisplayWidth was greater than bubbleContentAreaMaxWidth
        // or if the original image width was between maxImageDisplayWidth and bubbleContentAreaMaxWidth.
        if displayWidth > bubbleContentAreaMaxWidth {
            displayWidth = bubbleContentAreaMaxWidth
            // Re-calculate height based on the original aspect ratio if width changes due to this constraint
            displayHeight = displayWidth * (image.size.height / image.size.width)
        }

        return CGSize(width: ceil(displayWidth), height: ceil(displayHeight))
    }

    static func calculateTextSize(with text: String, maxSize: CGSize) -> CGSize {
        guard !text.isEmpty else {
            return .zero
        }

        let font = UIFont.systemFont(ofSize: 16.0)
        let attributes = [NSAttributedString.Key.font: font]
        let textRect = text.boundingRect(
            with: maxSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        return CGSize(width: ceil(textRect.size.width), height: ceil(textRect.size.height))
    }

    // Instance method forwarding to class method for convenience
    private func calculateTextSize(with text: String, maxSize: CGSize) -> CGSize {
        return StreamChatMessageCell.calculateTextSize(with: text, maxSize: maxSize)
    }

    // MARK: - Prepare for Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        asrLabel.text = nil
        nlgLabel.text = nil
        skillLabel.text = nil

        for iv in asrImageViews { iv.image = nil; iv.isHidden = true }
        for iv in recvImageViews { iv.image = nil; iv.isHidden = true }

        // Reset visibility, important if cells are reused for different message types
        asrBubbleView.isHidden = true
        asrLabel.isHidden = true
        asrImagesScrollView.isHidden = true
        nlgBubbleView.isHidden = true
        nlgLabel.isHidden = true
        recvImagesScrollView.isHidden = true
        skillLabel.isHidden = true

        // Reset alpha
        asrBubbleView.alpha = 1.0
        nlgBubbleView.alpha = 1.0
        recvImagesScrollView.alpha = 1.0
        skillLabel.alpha = 1.0

        // Important: Reset the mask, otherwise it might use old bounds
        asrBubbleView.layer.mask = nil
        nlgBubbleView.layer.mask = nil
    }
}
