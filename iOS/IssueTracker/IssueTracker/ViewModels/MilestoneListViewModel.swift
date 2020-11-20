//
//  MilestoneListViewModel.swift
//  IssueTracker
//
//  Created by sihyung you on 2020/10/29.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import Combine
import Foundation

protocol MilestoneListViewModelTypes {
    var inputs: MilestoneListViewModelInputs { get }
    var outputs: MilestoneListViewModelOutputs { get }
}

protocol MilestoneListViewModelInputs {
    func viewDidLoad()
    func addNewMileStone(title: String, dueDate: String, description: String)
    func editMileStone(at indexPath: IndexPath, title: String, description: String, dueDate: String)
}

protocol MilestoneListViewModelOutputs {
    var milestonePublisher: Published<[MilestoneItemViewModel]>.Publisher { get }
}

class MilestoneListViewModel {
    private var milestoneProvider: MilestoneProvidable?

    @Published private var milestones = [MilestoneItemViewModel]()

    init(with milestoneProvider: MilestoneProvidable = MilestoneProvider.shared) {
        self.milestoneProvider = milestoneProvider
    }
}

// MARK: - MilestoneListViewModelInputs Implementaion

extension MilestoneListViewModel: MilestoneListViewModelInputs {
    func viewDidLoad() {
        milestoneProvider?.fetchMilestones { [weak self] milestones in
            guard let `self` = self,
                  let milestones = milestones
            else { return }
            milestones.forEach { self.milestones.append(MilestoneItemViewModel(milestone: $0, from: .fromServer)) }
        }
    }

    func addNewMileStone(title: String, dueDate: String, description: String) {
        milestoneProvider?.addMilestone(title: title, dueDate: dueDate, description: description, completion: { [weak self] milestone in
            guard let `self` = self,
                  let milestone = milestone
            else { return }
            self.milestones.insert(MilestoneItemViewModel(milestone: milestone, from: .fromServer), at: 0)
        })
    }

    func editMileStone(at indexPath: IndexPath, title: String, description: String, dueDate: String) {
        let currentMilestone: MilestoneItemViewModel = milestones[indexPath.row]

        milestoneProvider?.editMilestone(id: currentMilestone.id, title: title, dueDate: dueDate, description: description, openIssuesLength: currentMilestone.openIssue, closeIssueLength: currentMilestone.closedIssue) { [weak self] milestone in
            guard let `self` = self,
                  let milestone = milestone
            else { return }
            self.milestones[indexPath.row] = MilestoneItemViewModel(milestone: milestone, from: .fromSubmitView)
        }
    }
}

// MARK: - MilestoneListViewModelOutputs Implementation

extension MilestoneListViewModel: MilestoneListViewModelOutputs {
    var milestonePublisher: Published<[MilestoneItemViewModel]>.Publisher { $milestones }
}

// MARK: - MilestoneListViewModelType Implementation

extension MilestoneListViewModel: MilestoneListViewModelTypes {
    var inputs: MilestoneListViewModelInputs { self }
    var outputs: MilestoneListViewModelOutputs { self }
}
