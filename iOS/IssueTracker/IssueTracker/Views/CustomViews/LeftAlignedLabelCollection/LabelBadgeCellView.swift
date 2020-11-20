//
//  LabelBadgeCellView.swift
//  IssueTracker
//
//  Created by 김신우 on 2020/11/09.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import UIKit

class LabelBadgeCellView: UICollectionViewCell {
    @IBOutlet var label: UILabel!

    enum Constant {
        static let cornerRadiusRatio: CGFloat = 0.5
    }

    func configure(labelViewModel: LabelItemViewModel) {
        label.text = labelViewModel.title
        label.textColor = UIColor(cgColor: labelViewModel.hexColor.color).isDarkColor ? UIColor.white : UIColor.black
        layer.backgroundColor = labelViewModel.hexColor.color
    }

    func setFontSize(_ size: CGFloat) {
        label.font = label.font.withSize(size)
        invalidateIntrinsicContentSize()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = bounds.height / 2 * 0.2
    }
}

// MARK: - Load from Nib

extension LabelBadgeCellView {
    static let nibName = "LabelBadgeCellView"

    static func createView() -> LabelBadgeCellView? {
        return Bundle.main.loadNibNamed(nibName, owner: self, options: nil)?.last as? LabelBadgeCellView
    }
}

// MARK: - UICollectionViewRegisterable

extension LabelBadgeCellView: UICollectionViewRegisterable {
    static var cellIdentifier: String {
        "LabelBadgeCellView"
    }

    static var cellNib: UINib {
        return UINib(nibName: cellIdentifier, bundle: Bundle.main)
    }
}
