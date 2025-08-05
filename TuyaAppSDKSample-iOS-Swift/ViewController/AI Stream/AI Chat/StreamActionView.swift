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

class StreamActionView: UIView {
    
    // MARK: - Properties
    weak var delegate: StreamActionViewDelegate?
    var selectedImage: UIImage?
    private(set) var isRecording: Bool = false
    
    // MARK: - IBOutlets
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var pickImageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var chatBreakBtn: UIButton!
    @IBOutlet weak var switchInputBtn: UIButton!
    
    // MARK: - Private Properties
    private var isShowRecord: Bool = false
    private var btnType: StreamActionBtnType = .record
    private var isShowBreaking: Bool = false
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        // Load from XIB
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "StreamActionView", bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        
        awakeFromNib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        textField.delegate = self
        
        recordBtn.setTitle("🎙️ Start Record", for: .normal)
        recordBtn.setTitle("🛑 Stop & Send", for: .selected)
        
        // Configure text field properties
        textField.placeholder = "Type message here..."
        
        // Add text change listener
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        // Add button click events
        recordBtn.addTarget(self, action: #selector(clickRecordBtn(_:)), for: .touchUpInside)
        chatBreakBtn.addTarget(self, action: #selector(clickChatBreakBtn(_:)), for: .touchUpInside)
        switchInputBtn.addTarget(self, action: #selector(clickSwitchInputBtn(_:)), for: .touchUpInside)
        deleteBtn.addTarget(self, action: #selector(clickDeleteImageBtn(_:)), for: .touchUpInside)
        
        // Add tap gesture to image view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickPickImage(_:)))
        pickImageView.addGestureRecognizer(tapGesture)
        pickImageView.isUserInteractionEnabled = true
        
        chatBreakShow(false)
        resetState()
    }
    
    // MARK: - Public Methods
    func showSelectedImage(_ image: UIImage?) {
        selectedImage = image
        if let image = image {
            pickImageView.image = image
            deleteBtn.isHidden = false
        } else {
            pickImageView.image = nil
            deleteBtn.isHidden = true
        }
    }
    
    func resetState() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isRecording = false
            self.recordBtn.isSelected = false
            self.textField.isEnabled = true
            self.showSelectedImage(nil)
            self.textField.text = ""
            
            self.recordBtn.tintColor = .systemYellow
        }
    }
    
    func chatBreakShow(_ show: Bool) {
        chatBreakBtn.isHidden = !show
    }
    
    // MARK: - Actions
    @IBAction func clickPickImage(_ sender: Any) {
        delegate?.streamActionViewDidClickPickImage()
    }
    
    @IBAction func clickDeleteImageBtn(_ sender: Any) {
        showSelectedImage(nil)
    }
    
    @IBAction func clickRecordBtn(_ sender: Any) {
        changeToRecording(!isRecording)
    }
    
    @IBAction func clickChatBreakBtn(_ sender: Any) {
        delegate?.streamActionViewDidClickChatBreak()
        chatBreakShow(chatBreakBtn.isHidden)
    }
    @IBAction func clickSwitchInputBtn(_ sender: Any) {
        delegate?.streamActionViewDidClickSwitchActionType(btnType)
        
        switch btnType {
        case .record:
            btnType = .textInput
            endEditing(true)
            chatBreakShow(false)
        case .textInput:
            // Switch to recording mode
            btnType = .record
        case .send:
            // Send the message
            delegate?.streamActionViewDidClickSendContent(textField.text ?? "")
            btnType = .record
            endEditing(true)
            chatBreakShow(true)
        }
        updateActionBtnTypeStatus()
    }
    
    // MARK: - Private Methods
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // Add text change handling logic here if needed
        
        if (textField.text?.count ?? 0) > 0 {
            btnType = .send
        } else {
            btnType = .record
        }
        updateActionBtnTypeStatus()
    }
    
    private func updateActionBtnTypeStatus() {
        switch btnType {
        case .record:
            textField.isHidden = false
            recordBtn.isHidden = true
            switchInputBtn.setTitle("🎙️", for: .normal)
        case .send:
            textField.isHidden = false
            recordBtn.isHidden = true
            switchInputBtn.setTitle("🚀", for: .normal)
        case .textInput:
            textField.isHidden = true
            recordBtn.isHidden = false
            switchInputBtn.setTitle("⌨️", for: .normal)
        }
    }
    
    private func changeToRecording(_ recording: Bool) {
        isRecording = recording
        recordBtn.isSelected = recording
        textField.isEnabled = !recording
        
        if recording {
            chatBreakShow(true)
        }
        
        delegate?.streamActionViewDidClickRecordButton(isRecording)
    }
}

// MARK: - UITextFieldDelegate
extension StreamActionView: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Don't allow text editing if recording is in progress
        return !isRecording
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        if !(textField.text?.isEmpty ?? true) {
            clickSwitchInputBtn(switchInputBtn!)
        }
        return true
    }
}
