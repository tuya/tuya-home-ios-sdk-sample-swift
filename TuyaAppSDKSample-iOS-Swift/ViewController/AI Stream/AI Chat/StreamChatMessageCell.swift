//
//  StreamChatMessageCell.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class StreamChatMessage: NSObject {
    var eventId: String = ""
    var sendContent: String = "" // asr | text
    var sendImage: UIImage? // image
    var nlg: NSMutableString = NSMutableString()
    var skill: String = ""
    var isBreak: Bool = false
    
    override init() {
        super.init()
        nlg = NSMutableString()
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
    
    // MARK: - Properties
    // ASR (Sent message) related views
    private var asrBubbleView: UIView!
    private var asrLabel: UILabel!
    private var asrImageView: UIImageView! // For sent images
    
    // NLG (Received message) related views
    private var nlgLabel: UILabel!
    private var nlgBubbleView: UIView!
    
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

        asrImageView = UIImageView()
        asrImageView.contentMode = .scaleAspectFit
        asrImageView.layer.cornerRadius = 8.0 // Optional: slightly round image corners if desired
        asrImageView.layer.masksToBounds = true
        asrBubbleView.addSubview(asrImageView) // Add to ASR bubble
        
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

        let hasSentText = !message.sendContent.isEmpty
        let hasSentImage = message.sendImage != nil
        let hasNlg = message.nlg.length > 0

        // Reset visibility for reuse
        asrBubbleView.isHidden = true
        asrLabel.isHidden = true
        asrImageView.isHidden = true
        nlgBubbleView.isHidden = true
        nlgLabel.isHidden = true
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

            // 2. Layout Image if present
            if hasSentImage {
                asrImageView.isHidden = false
                asrImageView.image = message.sendImage
                
                if hasSentText { // Add spacing if text is above image
                    yOffsetInAsrBubble += StreamChatMessageCell.kAsrContentVerticalSpacing
                }
                
                let imageDisplaySize = StreamChatMessageCell.calculateImageDisplaySize(
                    for: message.sendImage!,
                    maxDisplayWidth: StreamChatMessageCell.kSentImageMaxWidth,
                    bubbleContentAreaMaxWidth: StreamChatMessageCell.kBubbleMaxWidth - 2 * StreamChatMessageCell.kBubblePadding
                )
                
                asrImageView.frame = CGRect(x: StreamChatMessageCell.kBubblePadding, y: yOffsetInAsrBubble, width: imageDisplaySize.width, height: imageDisplaySize.height)
                yOffsetInAsrBubble += imageDisplaySize.height
                asrContentMaxWidth = max(asrContentMaxWidth, imageDisplaySize.width)
            }
            
            var asrBubbleContentHeight = yOffsetInAsrBubble - StreamChatMessageCell.kBubblePadding // Total height of content inside
            if hasSentText && hasSentImage {
                asrBubbleContentHeight = (asrLabel.frame.size.height + StreamChatMessageCell.kAsrContentVerticalSpacing + asrImageView.frame.size.height)
            } else if hasSentText {
                asrBubbleContentHeight = asrLabel.frame.size.height
            } else if hasSentImage {
                asrBubbleContentHeight = asrImageView.frame.size.height
            }

            let asrBubbleWidth = asrContentMaxWidth + 2 * StreamChatMessageCell.kBubblePadding
            let asrBubbleHeight = asrBubbleContentHeight + 2 * StreamChatMessageCell.kBubblePadding
            
            asrBubbleView.frame = CGRect(x: contentWidth - asrBubbleWidth, // Align to right
                                        y: currentY, width: asrBubbleWidth, height: asrBubbleHeight)
            
            // Adjust subview frames if centering or specific alignment within bubble is needed
            // For now, they are top-left aligned within padding.
            // If you want content centered horizontally in the bubble:
            if hasSentText {
                var textFrame = asrLabel.frame
                // textFrame.origin.x = (asrBubbleWidth - textFrame.size.width) / 2.0 // Center
                asrLabel.frame = textFrame
            }
            if hasSentImage {
                var imageFrame = asrImageView.frame
                // imageFrame.origin.x = (asrBubbleWidth - imageFrame.size.width) / 2.0 // Center
                asrImageView.frame = imageFrame
            }

            let asrMaskLayer = CAShapeLayer()
            let asrMaskPath = UIBezierPath(
                roundedRect: asrBubbleView.bounds,
                byRoundingCorners: [.topLeft, .bottomLeft, .bottomRight],
                cornerRadii: CGSize(width: 16.0, height: 16.0)
            )
            asrMaskLayer.path = asrMaskPath.cgPath
            asrBubbleView.layer.mask = asrMaskLayer
            
            currentY += asrBubbleHeight
            if hasNlg { // Add spacing only if NLG bubble follows
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
        
        // Alpha for break state
        let alpha: CGFloat = message.isBreak ? 0.7 : 1.0
        asrBubbleView.alpha = alpha
        nlgBubbleView.alpha = alpha
        skillLabel.alpha = alpha
        // asrImageView's alpha will be covered by asrBubbleView's alpha
    }
    
    // MARK: - Height Calculation
    static func heightForMessage(_ message: StreamChatMessage, withWidth width: CGFloat) -> CGFloat {
        var totalHeight = kBubbleMargin // Top margin

        let hasSentText = !message.sendContent.isEmpty
        let hasSentImage = message.sendImage != nil
        let hasNlg = message.nlg.length > 0

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
                let imageDisplaySize = calculateImageDisplaySize(
                    for: message.sendImage!,
                    maxDisplayWidth: kSentImageMaxWidth,
                    bubbleContentAreaMaxWidth: kBubbleMaxWidth - 2 * kBubblePadding
                )
                asrContentInnerHeight += imageDisplaySize.height
            }
            
            let asrBubbleHeight = asrContentInnerHeight + 2 * kBubblePadding // Add bubble's top/bottom padding
            totalHeight += asrBubbleHeight
            
            if hasNlg { // If NLG follows, add spacing
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
        
        totalHeight += kBubbleMargin // Bottom margin for the cell
        return totalHeight
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
        asrImageView.image = nil // Clear image
        nlgLabel.text = nil
        skillLabel.text = nil

        // Reset visibility, important if cells are reused for different message types
        asrBubbleView.isHidden = true
        asrLabel.isHidden = true
        asrImageView.isHidden = true
        nlgBubbleView.isHidden = true
        nlgLabel.isHidden = true
        skillLabel.isHidden = true
        
        // Reset alpha
        asrBubbleView.alpha = 1.0
        nlgBubbleView.alpha = 1.0
        skillLabel.alpha = 1.0

        // Important: Reset the mask, otherwise it might use old bounds
        asrBubbleView.layer.mask = nil
        nlgBubbleView.layer.mask = nil
    }
}
