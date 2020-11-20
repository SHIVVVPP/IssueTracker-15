//
//  MilestoneListDataSource.swift
//  IssueTracker
//
//  Created by 김신우 on 2020/11/20.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import UIKit

class MilestoneListDataSource: NSObject, UICollectionViewDataSource {
    private(set) var datas: [MilestoneItemViewModel] = []

    func load(milestones: [MilestoneItemViewModel]) {
        datas = milestones
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return datas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell: MilestoneCellView = collectionView.dequeueCell(at: indexPath),
            let cellViewModel = datas[safe: indexPath.row]
        else {
            return UICollectionViewCell()
        }
        cell.configure(with: cellViewModel)
        return cell
    }
}
