//
//  DemoTabView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI
import Combine

class DemoTabView: UICollectionView {
    var didScrollToTab: ((_ tab: Int) -> Void)?

    private(set) var currentSelection: Int = 0

    private var tabViews: [UIView]

    init(tabViews: [UIView], bounces: Bool = true) {
        self.tabViews = tabViews
        if tabViews.isEmpty {
            self.tabViews = [UIView()]
        }

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        super.init(frame: .zero, collectionViewLayout: layout)

        delegate = self
        dataSource = self
        showsHorizontalScrollIndicator = false
        isPagingEnabled = true
        self.bounces = bounces
        backgroundColor = .clear
        register(DemoTabCell.self, forCellWithReuseIdentifier: "DemoTabCell")
    }

    convenience init<Content: View>(tabViews: [Content], bounces: Bool = false) {
        let tabViews = tabViews.compactMap { UIHostingController(rootView: $0).view }
        self.init(tabViews: tabViews, bounces: bounces)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func scrollToTab(_ tab: Int, animated: Bool) {
        let indexPah = IndexPath(item: tab, section: 0)
        guard tab < tabViews.count else { return }
        if !animated {
            currentSelection = tab
        }
        scrollToItem(at: indexPah, at: .centeredHorizontally, animated: animated)
    }

    func resetLayout() {
        collectionViewLayout.invalidateLayout()
    }

    func rebindViews(_ tabViews: [UIView]) {
        guard !tabViews.isEmpty else { return }
        self.tabViews = tabViews
        reloadData()
    }
}

extension DemoTabView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tabViews.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "DemoTabCell",
            for: indexPath
        ) as? DemoTabCell else { return .init() }

        let cellView = tabViews[indexPath.item]
        cell.bindView(cellView)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.bounds.size
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        guard currentSelection != index else { return }
        currentSelection = index
        didScrollToTab?(index)
        notifySelectionChanged()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        guard currentSelection != index else { return }
        currentSelection = index
        notifySelectionChanged()
    }

    private func notifySelectionChanged() {
        NotificationCenter.default.post(name: Self.tabDidChange, object: nil, userInfo: [
            "currentSelection": currentSelection
        ])
    }
}

extension DemoTabView {
    private class DemoTabCell: UICollectionViewCell {
        override func prepareForReuse() {
            super.prepareForReuse()
            contentView.subviews.forEach { $0.removeFromSuperview() }
        }

        fileprivate func bindView(_ view: UIView) {
            contentView.backgroundColor = .clear
            view.backgroundColor = .clear
            contentView.addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}

extension DemoTabView {
    static let tabDidChange = Notification.Name("demoTabViewDidScrollToTab")
}
