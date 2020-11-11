//
//  AddCommentMilestoneCellView.swift
//  IssueTracker
//
//  Created by 김신우 on 2020/11/10.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import UIKit

class BottomSheetMilestoneView: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundBar: UIView!
    @IBOutlet weak var frontBar: UIView!
    
    private lazy var frontBarGaugeWidthConstraint: NSLayoutConstraint = {
        return frontBar.widthAnchor.constraint(equalToConstant: 0)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        frontBarGaugeWidthConstraint.isActive  = true
    }
    
    func configure(milestoneViewModel: MilestoneItemViewModel) {
        titleLabel.text = milestoneViewModel.title
        setGaugeBar(close: CGFloat(milestoneViewModel.issueClosed), open: CGFloat(milestoneViewModel.issueOpened))
    }
    
    func setGaugeBar(close: CGFloat, open: CGFloat) {
        layoutIfNeeded()
        if close + open == 0 {
            frontBarGaugeWidthConstraint.constant = 0
            return
        }
        frontBarGaugeWidthConstraint.constant = backgroundBar.bounds.width * close / (open + close)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundBar.layer.cornerRadius = backgroundBar.bounds.height / 2
        layer.cornerRadius = bounds.height / 2 * 0.25
    }
}

// MARK: - Load From Nib

extension BottomSheetMilestoneView {
    static let identifier = "BottomSheetMilestoneView"
    static func createView() -> BottomSheetMilestoneView? {
        return Bundle.main.loadNibNamed(BottomSheetMilestoneView.identifier, owner: self, options: nil)?.last as? BottomSheetMilestoneView
    }
}