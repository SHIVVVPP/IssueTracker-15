//
//  IssueCellWithScroll.swift
//  IssueTracker
//
//  Created by 김신우 on 2020/11/01.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import Combine
import UIKit

protocol IssucCellViewDelegate: AnyObject {
    func closeIssueButtonTapped(_ issueCellView: IssueCellView, at id: Int)
    func deleteIssueButtonTapped(_ issueCellView: IssueCellView, at id: Int)
    func issueCellViewBeginDragging(_ issueCellView: IssueCellView, at id: Int)
}

class IssueCellView: UICollectionViewCell {
    enum Section {
        case labels
    }

    typealias DataSource = UICollectionViewDiffableDataSource<Section, LabelItemViewModel>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, LabelItemViewModel>

    weak var delegate: IssucCellViewDelegate?

    @IBOutlet var cellHorizontalScrollView: UIScrollView!

    @IBOutlet var checkBoxGuideView: UIView!
    @IBOutlet var mainContentGuideView: UIView!
    @IBOutlet var closeBoxGuideView: UIView!
    @IBOutlet var deleteBoxGuideView: UIView!

    @IBOutlet var statusImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var milestoneBadge: BadgeLabelView!
    @IBOutlet var checkBoxButton: UIButton!
    @IBOutlet var closeBoxButton: UIButton!
    @IBOutlet var labelCollectionView: UICollectionView!

    private lazy var dataSource: DataSource = {
        DataSource(collectionView: labelCollectionView) { (collectionView, indexPath, labelItem) -> UICollectionViewCell? in
            guard let cell: LabelBadgeCellView = collectionView.dequeueCell(at: indexPath) else { return nil }
            cell.configure(labelViewModel: labelItem)
            return cell
        }
    }()

    private var issueItemViewModel: IssueItemViewModelTypes?
    private var cancellables = Set<AnyCancellable>()

    private lazy var checkBoxGuideWidthConstraint = checkBoxGuideView.widthAnchor.constraint(equalToConstant: 0)

    override func awakeFromNib() {
        super.awakeFromNib()
        cellHorizontalScrollView.delegate = self
        cellHorizontalScrollView.decelerationRate = .init(rawValue: 0.99999)
        checkBoxGuideWidthConstraint.isActive = true
        checkBoxGuideView.isHidden = false

        milestoneBadge.setBorder(width: 1, color: #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1))
        milestoneBadge.cornerRadiusRatio = 0.5
        milestoneBadge.setPadding(top: 5, left: 5, bottom: 5, right: 5)

        let layout = LeftAlignedBadgeFlowLayout()
        layout.leftSpacing = 10
        layout.estimatedItemSize = CGSize(width: bounds.width / 3, height: 30)
        layout.minimumLineSpacing = 10
        labelCollectionView.setCollectionViewLayout(layout, animated: false)

        labelCollectionView.registerCell(type: LabelBadgeCellView.self)
        NSLayoutConstraint.activate([
            cellHorizontalScrollView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
        ])
    }

    func configure(issueItemViewModel: IssueItemViewModelTypes) {
        self.issueItemViewModel = issueItemViewModel

        titleLabel.text = issueItemViewModel.outputs.title
        titleLabel.invalidateIntrinsicContentSize()

        issueItemViewModel.outputs.milestoneTitlePublisher
            .receive(on: DispatchQueue.main)
            .sink { milestoneTitle in
                self.setMilestone(title: milestoneTitle)
            }
            .store(in: &cancellables)

        issueItemViewModel.outputs.labelItemViewModelPublisher
            .receive(on: DispatchQueue.main)
            .sink { labels in
                self.setLabels(labelViewModels: labels)
            }
            .store(in: &cancellables)

        issueItemViewModel.outputs.isOpenedPublisher
            .receive(on: DispatchQueue.main)
            .sink { isOpen in
                self.setStatus(isOpened: isOpen)
            }
            .store(in: &cancellables)

        issueItemViewModel.outputs.checkedPublisher
            .receive(on: DispatchQueue.main)
            .sink { checked in
                self.setCheck(checked)
            }
            .store(in: &cancellables)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
        issueItemViewModel = nil
        milestoneBadge.text = ""
        titleLabel.text = ""
        cellHorizontalScrollView.contentOffset = CGPoint.zero
        labelCollectionView.isHidden = true
        setCheck(false)
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        super.preferredLayoutAttributesFitting(layoutAttributes)
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame
        frame.size.height = ceil(size.height + labelCollectionView.collectionViewLayout.collectionViewContentSize.height)
        layoutAttributes.frame = frame
        return layoutAttributes
    }

    private func setMilestone(title: String) {
        if title.isEmpty {
            milestoneBadge.text = ""
            milestoneBadge.isHidden = true
        } else {
            milestoneBadge.isHidden = false
            milestoneBadge.text = title
        }
    }

    private func setLabels(labelViewModels: [LabelItemViewModel]) {
        labelCollectionView.isHidden = false
        var snapShot = SnapShot()
        snapShot.appendSections([.labels])
        snapShot.appendItems(labelViewModels, toSection: .labels)
        dataSource.apply(snapShot, animatingDifferences: true)
    }

    private func setStatus(isOpened: Bool) {
        guard let color = isOpened ? Constant.openColor : Constant.closeColor else { return }
        statusImage.tintColor = color
        closeBoxButton.setTitle(isOpened ? "Close" : "Open", for: .normal)
        closeBoxButton.backgroundColor = isOpened ? .link : Constant.openColor
    }

    func resetScrollOffset() {
        cellHorizontalScrollView.contentOffset = CGPoint.zero
    }

    func setCheck(_ check: Bool) {
        checkBoxButton.setImage(check ? Constant.checkedImage : Constant.uncheckedImage, for: .normal)
    }
}

// MARK: - Action

extension IssueCellView {
    @IBAction func checkBoxButtonTapped(_: Any) {
        checkBoxButton.isSelected.toggle()
    }

    @IBAction func closeButtonTapped(_: Any) {
        guard let id = issueItemViewModel?.outputs.id else { return }
        delegate?.closeIssueButtonTapped(self, at: id)
        cellHorizontalScrollView.setContentOffset(CGPoint.zero, animated: true)
    }

    @IBAction func deleteButtonTapped(_: Any) {
        guard let id = issueItemViewModel?.outputs.id else { return }
        delegate?.deleteIssueButtonTapped(self, at: id)
    }

    func showCheckBox(show: Bool, animation: Bool) {
        cellHorizontalScrollView.contentOffset = CGPoint.zero
        cellHorizontalScrollView.isScrollEnabled = !show

        checkBoxGuideWidthConstraint.constant = show ? mainContentGuideView.bounds.width * 0.1 : 0
        if animation {
            UIView.animate(withDuration: 0.5) {
                self.layoutIfNeeded()
            }
        }
    }
}

// MARK: - UIScrollViewDelegate Implementation

extension IssueCellView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_: UIScrollView) {
        guard let id = issueItemViewModel?.outputs.id else { return }
        delegate?.issueCellViewBeginDragging(self, at: id)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity _: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = pagingTargetOffset(contentOffset: scrollView.contentOffset)
    }

    private func pagingTargetOffset(contentOffset: CGPoint) -> CGPoint {
        if contentOffset.x >= 0, contentOffset.x < closeBoxGuideView.bounds.width / 2 {
            return CGPoint.zero
        }

        if
            contentOffset.x >= closeBoxGuideView.bounds.width / 2,
            contentOffset.x < closeBoxGuideView.bounds.width + deleteBoxGuideView.bounds.width / 2
        {
            return CGPoint(x: closeBoxGuideView.bounds.width, y: 0)
        }

        return CGPoint(x: closeBoxGuideView.bounds.width + deleteBoxGuideView.bounds.width, y: 0)
    }
}

// MARK: - UICollectionViewRegisterable Implementation

extension IssueCellView: UICollectionViewRegisterable {
    static var cellIdentifier: String {
        "IssueCellView"
    }

    static var cellNib: UINib {
        UINib(nibName: cellIdentifier, bundle: nil)
    }
}

// MARK: - Constant

extension IssueCellView {
    enum Constant {
        static let uncheckedImage = UIImage(systemName: "circle")
        static let checkedImage = UIImage(systemName: "checkmark.circle.fill")
        static let openColor = UIColor(named: "OpenIssueBackgroundColor")
        static let closeColor = UIColor(named: "ClosedIssueBackgroundColor")
    }
}
