//
//  LabelListDataSource.swift
//  IssueTracker
//
//  Created by 김신우 on 2020/11/20.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import UIKit

class LabelListDataSource: NSObject, UICollectionViewDataSource {
    
    private(set) var datas: [LabelItemViewModel] = []
    
    func load(labels: [LabelItemViewModel]) {
        datas = labels
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell: LabelCellView = collectionView.dequeueCell(at: indexPath),
            let cellViewModel = datas[safe: indexPath.row]
        else {
            return UICollectionViewCell()
        }
        cell.configure(with: cellViewModel)
        return cell
    }
    
}

