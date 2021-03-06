//
//  IssueDetailHeaderView.swift
//  IssueTracker
//
//  Created by sihyung you on 2020/11/04.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import UIKit

enum IssueBadgeColor: String {
    case open = "OpenIssueBackgroundColor"
    case closed = "ClosedIssueBackgroundColor"
}

class IssueDetailHeaderView: UICollectionReusableView {
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var issueAuthor: UILabel!
    @IBOutlet var issueTitle: UILabel!
    @IBOutlet var issueNumber: UILabel!
    @IBOutlet var issueBadge: UIButton!

    func configure(with headerViewModel: IssueDetailHeaderViewModel) {
        issueAuthor.text = headerViewModel.author.userName
        issueTitle.text = headerViewModel.title
        issueNumber.text = "#" + String(headerViewModel.id)
        configureIssueBadge(isOpened: headerViewModel.isOpened)
        headerViewModel.needImage { [weak self] data in
            self?.setProfileImage(data: data)
        }
    }

    private func configureIssueBadge(isOpened: Bool) {
        var badgeColor: UIColor
        var badgeText: String
        badgeColor = isOpened ? UIColor(named: IssueBadgeColor.open.rawValue) ?? UIColor.green : UIColor(named: IssueBadgeColor.closed.rawValue) ?? UIColor.red
        badgeText = isOpened ? "Open" : "Closed"

        issueBadge.convertToIssueBadge(text: badgeText, backgroundColor: badgeColor)
        issueBadge.contentEdgeInsets = UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10)
    }

    private func setProfileImage(data: Data?) {
        guard let data = data,
              let image = UIImage(data: data)
        else { return }
        profilePicture.image = image
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        profilePicture.setRound(ratio: 1)
    }
}

extension IssueDetailHeaderView: UICollectionViewHeaderRegisterable {
    static var headerIdentifier: String {
        return "IssueDetailHeaderView"
    }

    static var headerNib: UINib {
        return UINib(nibName: "IssueDetailHeaderView", bundle: .main)
    }
}

extension UIButton {
    func convertToIssueBadge(text: String, backgroundColor: UIColor) {
        self.backgroundColor = backgroundColor
        setTitle(text, for: .normal)
    }
}
