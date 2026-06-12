//
//  StreamActionView.swift
//

import UIKit

enum StreamActionBtnType: UInt {
    case record
    case send
    case textInput
}

protocol StreamActionViewDelegate: AnyObject {
    func streamActionViewDidClickPickImage()
    func streamActionViewDidClickRecordButton(_ isStartRecording: Bool)
    func streamActionViewDidClickChatBreak()
    func streamActionViewDidClickSendContent(_ content: String)
    func streamActionViewDidClickSwitchActionType(_ actionType: StreamActionBtnType)
}

/// Chat input bar (ChatGPT-style, built in code)
///
/// Text mode: [+] [(image thumbnail) + text field + mic] [right button]
///   - + presents camera/photo picker; the selected image is inserted inside the input container (one only, with an X to delete)
///   - Mic sits at the right inside the text field; tapping it starts recording immediately
///   - Right button: hidden when empty; up-arrow to send when there is text/image; stop square to interrupt while waiting for the AI reply
/// Recording mode: [stop recording] [amplitude waveform]
///   - Images are not allowed while recording (starting a recording clears the selected image)
///   - Stop sends the recording (not an interrupt); after stopping, return to text mode and the right button becomes the interrupt square
class StreamActionView: UIView {

    // MARK: - Public Properties
    weak var delegate: StreamActionViewDelegate?
    var selectedImage: UIImage?
    private(set) var isRecording: Bool = false
    /// Waiting for the AI reply (right button shows the interrupt square)
    private(set) var isWaitingReply: Bool = false

    /// Text field (exposed so callers can bring up the keyboard)
    let textField = UITextField()

    // MARK: - Private Properties
    private let leftButton = UIButton(type: .system)
    private let middleContainer = UIView()
    private let contentStack = UIStackView()
    private let previewRow = UIView()
    private let previewImageView = UIImageView()
    private let previewDeleteButton = UIButton(type: .system)
    private let micButton = UIButton(type: .system)
    private let waveformView = StreamWaveformView()
    private let rightButton = UIButton(type: .system)

    private let symbolConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
    /// Soft red used for stop-recording / delete-image
    private let softRed = UIColor(red: 0.92, green: 0.34, blue: 0.30, alpha: 1)

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .systemBackground

        let topLine = UIView()
        topLine.backgroundColor = .separator
        topLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topLine)

        setupLeftButton()
        setupMiddleContainer()
        setupRightButton()

        // Align the left/right round buttons to the container bottom (they stay on the bottom row when the image preview makes the container taller)
        let row = UIStackView(arrangedSubviews: [leftButton, middleContainer, rightButton])
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .bottom
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)

        NSLayoutConstraint.activate([
            topLine.topAnchor.constraint(equalTo: topAnchor),
            topLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            topLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            topLine.heightAnchor.constraint(equalToConstant: 0.5),

            row.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            // Pin to the bottom safe area, leaving room for the Home Indicator on notched screens
            row.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -6),

            leftButton.widthAnchor.constraint(equalToConstant: 40),
            leftButton.heightAnchor.constraint(equalToConstant: 40),
            rightButton.widthAnchor.constraint(equalToConstant: 40),
            rightButton.heightAnchor.constraint(equalToConstant: 40),
        ])

        applyState()
    }

    private func setupLeftButton() {
        leftButton.layer.cornerRadius = 20
        leftButton.addTarget(self, action: #selector(clickLeftButton), for: .touchUpInside)
    }

    private func setupRightButton() {
        rightButton.layer.cornerRadius = 20
        rightButton.backgroundColor = .label
        rightButton.tintColor = .systemBackground
        rightButton.addTarget(self, action: #selector(clickRightButton), for: .touchUpInside)
    }

    private func setupMiddleContainer() {
        middleContainer.backgroundColor = .tertiarySystemFill
        middleContainer.layer.cornerRadius = 20

        // Image preview: thumbnail inserted inside the input container, with an X delete button at the top-right
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
        previewImageView.layer.cornerRadius = 10
        previewImageView.translatesAutoresizingMaskIntoConstraints = false

        previewDeleteButton.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)), for: .normal)
        previewDeleteButton.tintColor = .white
        previewDeleteButton.backgroundColor = softRed
        previewDeleteButton.layer.cornerRadius = 11
        previewDeleteButton.translatesAutoresizingMaskIntoConstraints = false
        previewDeleteButton.addTarget(self, action: #selector(clickDeleteImage), for: .touchUpInside)

        previewRow.addSubview(previewImageView)
        previewRow.addSubview(previewDeleteButton)
        NSLayoutConstraint.activate([
            previewImageView.leadingAnchor.constraint(equalTo: previewRow.leadingAnchor, constant: 2),
            previewImageView.topAnchor.constraint(equalTo: previewRow.topAnchor, constant: 6),
            previewImageView.bottomAnchor.constraint(equalTo: previewRow.bottomAnchor, constant: -2),
            previewImageView.widthAnchor.constraint(equalToConstant: 64),
            previewImageView.heightAnchor.constraint(equalToConstant: 64),

            previewDeleteButton.centerXAnchor.constraint(equalTo: previewImageView.trailingAnchor, constant: -4),
            previewDeleteButton.centerYAnchor.constraint(equalTo: previewImageView.topAnchor, constant: 4),
            previewDeleteButton.widthAnchor.constraint(equalToConstant: 22),
            previewDeleteButton.heightAnchor.constraint(equalToConstant: 22),
        ])

        // Input row: text field + mic button at the right inside the field
        textField.placeholder = "Message"
        textField.font = .systemFont(ofSize: 16)
        textField.returnKeyType = .send
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        micButton.setImage(UIImage(systemName: "mic", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)), for: .normal)
        micButton.tintColor = .secondaryLabel
        micButton.addTarget(self, action: #selector(clickMicButton), for: .touchUpInside)

        let textRow = UIStackView(arrangedSubviews: [textField, micButton])
        textRow.axis = .horizontal
        textRow.spacing = 6
        textRow.alignment = .center

        contentStack.axis = .vertical
        contentStack.spacing = 0
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 2, left: 14, bottom: 2, right: 10)
        contentStack.addArrangedSubview(previewRow)
        contentStack.addArrangedSubview(textRow)
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        waveformView.translatesAutoresizingMaskIntoConstraints = false
        waveformView.isHidden = true

        middleContainer.addSubview(contentStack)
        middleContainer.addSubview(waveformView)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: middleContainer.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: middleContainer.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: middleContainer.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: middleContainer.bottomAnchor),

            waveformView.topAnchor.constraint(equalTo: middleContainer.topAnchor, constant: 8),
            waveformView.leadingAnchor.constraint(equalTo: middleContainer.leadingAnchor, constant: 14),
            waveformView.trailingAnchor.constraint(equalTo: middleContainer.trailingAnchor, constant: -14),
            waveformView.bottomAnchor.constraint(equalTo: middleContainer.bottomAnchor, constant: -8),

            middleContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            textRow.heightAnchor.constraint(equalToConstant: 36),
            micButton.widthAnchor.constraint(equalToConstant: 28),
        ])
    }

    // MARK: - Public Methods
    func showSelectedImage(_ image: UIImage?) {
        selectedImage = image
        previewImageView.image = image
        applyState()
    }

    func resetState() {
        // Run synchronously on the main thread to avoid intermediate states from delayed cleanup; dispatch back to main when called from other threads
        if Thread.isMainThread {
            performReset()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.performReset()
            }
        }
    }

    private func performReset() {
        isRecording = false
        textField.isEnabled = true
        textField.text = ""
        selectedImage = nil
        previewImageView.image = nil
        applyState()
    }

    /// Show/hide the waiting-for-reply state (right button shows the interrupt square); callers pass false when the event ends
    func chatBreakShow(_ show: Bool) {
        isWaitingReply = show
        applyState()
    }

    /// Send failed: clear the waiting state and restore the pre-send text/image back into the input bar
    func restoreAfterSendFailure(content: String, image: UIImage?) {
        isWaitingReply = false
        textField.text = content
        showSelectedImage(image)
    }

    /// Recording amplitude array (0~1); redraws the whole waveform in place; must be called on the main thread
    func updateRecordingLevels(_ levels: [CGFloat]) {
        guard isRecording else { return }
        waveformView.update(levels)
    }

    // MARK: - Actions

    /// Left button: + to pick an image in text mode; stop-and-send-recording square in recording mode
    @objc private func clickLeftButton() {
        if isRecording {
            stopRecording()
        } else {
            delegate?.streamActionViewDidClickPickImage()
        }
    }

    /// Right button: interrupt square while waiting for the reply; otherwise up-arrow to send
    @objc private func clickRightButton() {
        if isWaitingReply {
            isWaitingReply = false
            applyState()
            delegate?.streamActionViewDidClickChatBreak()
        } else {
            sendText()
        }
    }

    /// Mic: start recording immediately (must interrupt first while waiting for a reply)
    @objc private func clickMicButton() {
        guard !isRecording, !isWaitingReply else { return }
        // Images are not allowed while recording; clear before starting
        showSelectedImage(nil)
        endEditing(true)
        isRecording = true
        waveformView.reset()
        applyState()
        delegate?.streamActionViewDidClickRecordButton(true)
    }

    private func stopRecording() {
        isRecording = false
        // After stopping and sending the recording, enter the waiting state; right button shows the interrupt square
        isWaitingReply = true
        applyState()
        delegate?.streamActionViewDidClickRecordButton(false)
    }

    private func sendText() {
        let content = textField.text ?? ""
        guard !content.isEmpty || selectedImage != nil else { return }
        endEditing(true)
        isWaitingReply = true
        applyState()
        delegate?.streamActionViewDidClickSendContent(content)
    }

    @objc private func clickDeleteImage() {
        guard !isRecording else { return }
        showSelectedImage(nil)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        applyState()
    }

    // MARK: - State

    private var hasContent: Bool {
        return !(textField.text ?? "").isEmpty || selectedImage != nil
    }

    /// Refresh the whole UI based on isRecording / isWaitingReply / input content
    private func applyState() {
        // Left button: + (text mode) / red stop square (recording mode, stop and send the recording)
        if isRecording {
            leftButton.setImage(UIImage(systemName: "stop.fill", withConfiguration: symbolConfig), for: .normal)
            leftButton.backgroundColor = softRed
            leftButton.tintColor = .white
        } else {
            leftButton.setImage(UIImage(systemName: "plus", withConfiguration: symbolConfig), for: .normal)
            leftButton.backgroundColor = .tertiarySystemFill
            leftButton.tintColor = .label
        }

        // Middle: input content (text mode) / amplitude waveform (recording mode)
        contentStack.isHidden = isRecording
        waveformView.isHidden = !isRecording
        previewRow.isHidden = (selectedImage == nil) || isRecording
        textField.isEnabled = !isRecording

        // Right button: interrupt square (waiting for reply) / up-arrow to send (has content) / hidden
        if isRecording {
            rightButton.isHidden = true
        } else if isWaitingReply {
            rightButton.isHidden = false
            rightButton.setImage(UIImage(systemName: "xmark", withConfiguration: symbolConfig), for: .normal)
        } else if hasContent {
            rightButton.isHidden = false
            rightButton.setImage(UIImage(systemName: "arrow.up", withConfiguration: symbolConfig), for: .normal)
        } else {
            rightButton.isHidden = true
        }
    }
}

// MARK: - UITextFieldDelegate
extension StreamActionView: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Text editing is not allowed while recording
        return !isRecording
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        if hasContent && !isWaitingReply {
            sendText()
        }
        return true
    }
}

// MARK: - Recording amplitude waveform

/// Spectrum bar waveform: each update redraws in place with the full amplitude array (not a scrolling accumulation)
final class StreamWaveformView: UIView {

    private var levels: [CGFloat] = []
    private let barWidth: CGFloat = 3
    private let barGap: CGFloat = 3

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        isOpaque = false
    }

    /// Refresh the whole view with one frame of amplitudes (0~1)
    func update(_ levels: [CGFloat]) {
        self.levels = levels.map { min(max($0, 0), 1) }
        setNeedsDisplay()
    }

    func reset() {
        levels = []
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), !levels.isEmpty else { return }
        context.setFillColor(UIColor.label.cgColor)

        let maxBars = Int(rect.width / (barWidth + barGap))
        guard maxBars > 0 else { return }
        // Bar count is the smaller of the data size and the capacity; slots divide the full width evenly so the bars always fill it regardless of count
        let barCount = min(maxBars, levels.count)
        let slotWidth = rect.width / CGFloat(barCount)
        let midY = rect.midY

        for i in 0..<barCount {
            let level = levels[i * levels.count / barCount]
            let height = max(3, level * (rect.height - 4))
            let bar = CGRect(x: slotWidth * CGFloat(i) + (slotWidth - barWidth) / 2,
                             y: midY - height / 2,
                             width: barWidth,
                             height: height)
            context.addPath(UIBezierPath(roundedRect: bar, cornerRadius: barWidth / 2).cgPath)
        }
        context.fillPath()
    }
}
