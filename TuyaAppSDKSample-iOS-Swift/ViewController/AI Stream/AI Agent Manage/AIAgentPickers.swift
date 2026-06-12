//
//  AIAgentPickers.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2026 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import AVFoundation

// MARK: - Avatar picker

/// Avatar picker (m.life.ai.agent.config.list-support-avatars), shown as a grid; tapping invokes the callback with the selected item
class AIAgentAvatarPickerViewController: UICollectionViewController {

    private let devId: String
    private let onSelect: (ThingSmartAIAgentAvatarResult) -> Void
    private let agentRequest = ThingSmartAIAgentRequest()
    private var avatars: [ThingSmartAIAgentAvatarResult] = []

    init(devId: String, onSelect: @escaping (ThingSmartAIAgentAvatarResult) -> Void) {
        self.devId = devId
        self.onSelect = onSelect
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        super.init(collectionViewLayout: layout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Avatar"
        collectionView.backgroundColor = .systemBackground
        collectionView.register(AIAgentAvatarCell.self, forCellWithReuseIdentifier: AIAgentAvatarCell.reuseId)

        SVProgressHUD.show()
        agentRequest.listSupportAvatars(devId: devId) { [weak self] avatars in
            SVProgressHUD.dismiss()
            self?.avatars = avatars
            self?.collectionView.reloadData()
        } failure: { [weak self] error in
            self?.showAIAgentError(error)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return avatars.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AIAgentAvatarCell.reuseId, for: indexPath) as! AIAgentAvatarCell
        cell.imageView.setImageURL(avatars[indexPath.item].url)
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelect(avatars[indexPath.item])
        navigationController?.popViewController(animated: true)
    }
}

extension AIAgentAvatarPickerViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 4 items per row
        let side = (collectionView.bounds.width - 16 * 2 - 12 * 3) / 4
        return CGSize(width: side, height: side)
    }
}

private final class AIAgentAvatarCell: UICollectionViewCell {

    static let reuseId = "AIAgentAvatarCell"
    let imageView = AIAgentRemoteImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.tintColor = .systemGray3
        imageView.frame = contentView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Language picker

/// Language picker (m.life.ai.agent.config.list-support-languages); tapping invokes the callback with the selected item
class AIAgentLanguagePickerViewController: UITableViewController {

    private let devId: String
    private let selectedLangCode: String?
    private let onSelect: (ThingSmartAIAgentLanguageResult) -> Void
    private let agentRequest = ThingSmartAIAgentRequest()
    private var languages: [ThingSmartAIAgentLanguageResult] = []

    init(devId: String, selectedLangCode: String?, onSelect: @escaping (ThingSmartAIAgentLanguageResult) -> Void) {
        self.devId = devId
        self.selectedLangCode = selectedLangCode
        self.onSelect = onSelect
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Language"
        SVProgressHUD.show()
        agentRequest.listSupportLanguages(devId: devId) { [weak self] languages in
            SVProgressHUD.dismiss()
            self?.languages = languages
            self?.tableView.reloadData()
        } failure: { [weak self] error in
            self?.showAIAgentError(error)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let language = languages[indexPath.row]
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        var name = language.langName ?? language.langCode ?? "-"
        if language.hasDefault == true {
            name += " (default)"
        }
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = language.langCode
        cell.accessoryType = (language.langCode != nil && language.langCode == selectedLangCode) ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onSelect(languages[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Voice picker

/// Voice picker (m.life.ai.timbre.page), with paged loading + keyword search + demo playback; tapping invokes the callback with the selected item
class AIAgentTimbrePickerViewController: UITableViewController, UISearchBarDelegate {

    private let devId: String
    private let selectedVoiceId: String?
    private let onSelect: (ThingSmartAITimbreResult) -> Void
    private let agentRequest = ThingSmartAIAgentRequest()

    private var timbres: [ThingSmartAITimbreResult] = []
    private var pageNo = 0
    private var hasMore = true
    private var loading = false
    private var keyword: String?
    private let pageSize = 20

    private let searchBar = UISearchBar()
    private var player: AVPlayer?

    init(devId: String, selectedVoiceId: String?, onSelect: @escaping (ThingSmartAITimbreResult) -> Void) {
        self.devId = devId
        self.selectedVoiceId = selectedVoiceId
        self.onSelect = onSelect
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Voice"
        searchBar.placeholder = "Keyword search (keyWord)"
        searchBar.delegate = self
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
        reload()
    }

    private func reload() {
        pageNo = 0
        hasMore = true
        timbres = []
        tableView.reloadData()
        loadMore()
    }

    private func loadMore() {
        guard hasMore, !loading else { return }
        loading = true
        var req = ThingSmartAITimbrePageReq(devId: devId, pageNo: pageNo + 1, pageSize: pageSize)
        req.keyWord = keyword
        req.preferredVoiceId = selectedVoiceId
        if timbres.isEmpty { SVProgressHUD.show() }
        agentRequest.queryTimbrePage(req) { [weak self] pageResult in
            SVProgressHUD.dismiss()
            guard let self = self else { return }
            self.loading = false
            self.pageNo += 1
            let pageList = pageResult.list ?? []
            self.timbres.append(contentsOf: pageList)
            // Use this page's returned count to decide whether there is a next page; don't rely on the possibly missing totalPage
            self.hasMore = pageList.count >= self.pageSize
            self.tableView.reloadData()
        } failure: { [weak self] error in
            self?.loading = false
            self?.showAIAgentError(error)
        }
    }

    // MARK: - UISearchBarDelegate

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let text = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        keyword = text.isEmpty ? nil : text
        reload()
    }

    // MARK: - Table view

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timbres.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let timbre = timbres[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let isSelected = timbre.voiceId != nil && timbre.voiceId == selectedVoiceId
        cell.textLabel?.text = (timbre.voiceName ?? timbre.voiceId ?? "-") + (isSelected ? " (current)" : "")
        cell.textLabel?.textColor = isSelected ? .systemBlue : .label

        var details: [String] = []
        if let tags = timbre.descTags, !tags.isEmpty { details.append(tags.joined(separator: " / ")) }
        if let langs = timbre.supportLangs, !langs.isEmpty { details.append("Languages: " + langs.joined(separator: ",")) }
        cell.detailTextLabel?.text = details.joined(separator: "  ")
        cell.detailTextLabel?.textColor = .secondaryLabel

        if let demoUrl = timbre.demoUrl, !demoUrl.isEmpty {
            let playButton = UIButton(type: .system)
            playButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
            playButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
            playButton.addAction { [weak self] in
                self?.playDemo(urlString: demoUrl)
            }
            cell.accessoryView = playButton
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onSelect(timbres[indexPath.row])
        navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == timbres.count - 1 {
            loadMore()
        }
    }

    /// Play the voice demo
    private func playDemo(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        player = AVPlayer(url: url)
        player?.play()
    }
}

// MARK: - UIButton closure callback (simple implementation that works on iOS 13)

private final class AIAgentButtonAction {
    let handler: () -> Void
    init(handler: @escaping () -> Void) { self.handler = handler }
    @objc func invoke() { handler() }
}

private var aiAgentButtonActionKey: UInt8 = 0

private extension UIButton {
    func addAction(_ handler: @escaping () -> Void) {
        let action = AIAgentButtonAction(handler: handler)
        objc_setAssociatedObject(self, &aiAgentButtonActionKey, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addTarget(action, action: #selector(AIAgentButtonAction.invoke), for: .touchUpInside)
    }
}
