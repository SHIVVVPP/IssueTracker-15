//
//  IssueItemViewModel.swift
//  IssueTracker
//
//  Created by 김신우 on 2020/11/04.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import Combine
import Foundation

protocol IssueItemViewModelTypes {
    var inputs: IssueItemViewModelInputs { get }
    var outputs: IssueItemViewModelOutputs { get }
}

protocol IssueItemViewModelInputs {}

protocol IssueItemViewModelOutputs {
    var id: Int { get }
    var title: String { get }
    var milestoneTitlePublisher: Published<String>.Publisher { get }
    var isOpenedPublisher: Published<Bool>.Publisher { get }
    var labelItemViewModelPublisher: Published<[LabelItemViewModel]>.Publisher { get }
    var checkedPublisher: Published<Bool>.Publisher { get }
}

protocol IssueItemViewModelProtocol: AnyObject {
    var id: Int { get }
    var title: String { get }
    var milestoneTitle: String { get }
    var isOpened: Bool { get }
    var labelItemViewModels: [LabelItemViewModel] { get }

    var didMilestoneChanged: ((String) -> Void)? { get set }
    var didLabelsChanged: (([LabelItemViewModel]) -> Void)? { get set }
    var checked: Bool { get }
}

class IssueItemViewModel: IssueItemViewModelTypes, IssueItemViewModelOutputs, IssueItemViewModelInputs {
    var inputs: IssueItemViewModelInputs { self }
    var outputs: IssueItemViewModelOutputs { self }

    var milestoneTitlePublisher: Published<String>.Publisher { $milestoneTitle }
    var isOpenedPublisher: Published<Bool>.Publisher { $isOpened }
    var labelItemViewModelPublisher: Published<[LabelItemViewModel]>.Publisher { $labelItemViewModels }
    var checkedPublisher: Published<Bool>.Publisher { $checked }

    let id: Int
    let title: String

    @Published var isOpened: Bool
    @Published var checked: Bool = false
    @Published private(set) var milestoneTitle: String = ""
    @Published private(set) var labelItemViewModels = [LabelItemViewModel]()

    init(issue: Issue) {
        id = issue.id
        title = issue.title
        isOpened = issue.isOpened
    }

    func setLabels(labels: [Label]?) {
        guard let labels = labels else { return }
        labelItemViewModels = labels.map { LabelItemViewModel(label: $0) }
    }

    func setMilestone(milestone: Milestone?) {
        guard let milestone = milestone else { return }
        milestoneTitle = milestone.title
    }
}

extension IssueItemViewModel: Hashable {
    static func == (lhs: IssueItemViewModel, rhs: IssueItemViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}
