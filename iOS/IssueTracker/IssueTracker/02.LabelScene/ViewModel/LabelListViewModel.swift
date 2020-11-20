//
//  LabelListViewModel.swift
//  IssueTracker
//
//  Created by 김신우 on 2020/10/28.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import Foundation
import Combine

protocol LabelListViewModelInputs {
    func viewDidLoad()
    func addNewLabel(title: String, desc: String, hexColor: String)
    func editLabel(at indexPath: IndexPath, title: String, desc: String, hexColor: String)
}

protocol LabelListViewModelOutputs {
    var labelPublisher: Published<[LabelItemViewModel]>.Publisher { get }
}

protocol LabelListViewModelType {
    var inputs: LabelListViewModelInputs { get }
    var outputs: LabelListViewModelOutputs { get }
}

class LabelListViewModel: LabelListViewModelType, LabelListViewModelInputs, LabelListViewModelOutputs {
    
    private weak var labelProvider: LabelProvidable?
    
    var labelPublisher: Published<[LabelItemViewModel]>.Publisher { $labels }
    @Published private var labels: [LabelItemViewModel]
    
    init(with labelProvider: LabelProvidable) {
        self.labelProvider = labelProvider
        labels = []
    }
    
    func editLabel(at indexPath: IndexPath, title: String, desc: String, hexColor: String) {
        labelProvider?.editLabel(id: labels[indexPath.row].id, title: title, description: desc, color: hexColor) { [weak self] (label) in
            guard let `self` = self,
                let label = label
                else { return }
            self.labels[indexPath.row] = LabelItemViewModel(label: label)
        }
    }
    
    func addNewLabel(title: String, desc: String, hexColor: String) {
        labelProvider?.addLabel(title: title, description: desc, color: hexColor) { [weak self] (label) in
            guard let `self` = self,
                let label = label
                else { return }
            self.labels.append(LabelItemViewModel(label: label))
        }
    }
    
    func viewDidLoad() {
        labelProvider?.fetchLabels { [weak self] (datas) in
            guard let `self` = self,
                let labels = datas
                else { return }
            labels.forEach { self.labels.append(LabelItemViewModel(label: $0))  }
        }
    }
    
    var inputs: LabelListViewModelInputs { self }
    var outputs: LabelListViewModelOutputs { self }
}
