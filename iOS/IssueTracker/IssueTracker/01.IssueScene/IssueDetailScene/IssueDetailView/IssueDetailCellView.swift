//
//  IssueDetailCellView.swift
//  IssueTracker
//
//  Created by sihyung you on 2020/11/04.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import UIKit

class IssueDetailCellView: UICollectionViewCell {
    @IBOutlet var content: UILabel!
    @IBOutlet var author: UILabel!
    @IBOutlet var createAt: UILabel!
    @IBOutlet var profilePicture: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
        ])
    }

    func configure(with comment: CommentViewModel) {
        content.text = comment.content
        author.text = comment.userName
        createAt.text = comment.createAt
        comment.needImage { [weak self] data in
            self?.setProfile(data: data)
        }
    }

    func setProfile(data: Data?) {
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

extension IssueDetailCellView: UICollectionViewRegisterable {
    static var cellIdentifier: String {
        return "IssueDetailCellView"
    }

    static var cellNib: UINib {
        return UINib(nibName: "IssueDetailCellView", bundle: .main)
    }
}
