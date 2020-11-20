//
//  AssigneeCellView.swift
//  IssueTracker
//
//  Created by 김신우 on 2020/11/09.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import UIKit

class BottomSheetLabelCollectionView: UITableViewCell {
    @IBOutlet var labelCollectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()

        labelCollectionView.dataSource = self
        let layout = LeftAlignedBadgeFlowLayout()
        layout.leftSpacing = 10
        layout.estimatedItemSize = CGSize(width: bounds.width / 3, height: 30)
        layout.minimumLineSpacing = 10
        labelCollectionView.setCollectionViewLayout(layout, animated: false)
        labelCollectionView.registerCell(type: LabelBadgeCellView.self)
    }

    private var labelItemViewModels = [LabelItemViewModel]()

    func configure(labelItemViewModels: [LabelItemViewModel]) {
        self.labelItemViewModels = labelItemViewModels
        labelCollectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource Implementation

extension BottomSheetLabelCollectionView: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return labelItemViewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: LabelBadgeCellView = collectionView.dequeueCell(at: indexPath) else { return UICollectionViewCell() }
        cell.configure(labelViewModel: labelItemViewModels[indexPath.row])
        cell.setFontSize(20)
        return cell
    }
}

// MARK: - loadNIB extension

extension BottomSheetLabelCollectionView {
    static let identifier = "BottomSheetLabelCollectionView"

    static func createView() -> BottomSheetLabelCollectionView? {
        return Bundle.main.loadNibNamed(BottomSheetLabelCollectionView.identifier, owner: self, options: nil)?.last as? BottomSheetLabelCollectionView
    }
}
