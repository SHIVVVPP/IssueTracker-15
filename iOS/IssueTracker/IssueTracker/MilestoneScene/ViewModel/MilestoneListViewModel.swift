//
//  MilestoneListViewModel.swift
//  IssueTracker
//
//  Created by sihyung you on 2020/10/29.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import Foundation

protocol MilestoneListViewModelProtocol {
    var didFetch: (() -> Void)? { get set }
    func needFetchItems()
    func cellForItemAt(path: IndexPath) -> MilestoneItemViewModel
    func numberOfItem() -> Int
}

class MilestoneListViewModel: MilestoneListViewModelProtocol {
    var didFetch: (() -> Void)?
    private var milestones = [Milestone]()
    
    func needFetchItems() {
        milestones = [Milestone(id: 0, title: "스프린트2", description: "이번 배포를 위한 스프린트", dueDate: "2020-06-19 12:34:55"),
                      Milestone(id: 1, title: "스프린트 15", description: "다음 배포를 위한 스프린트", dueDate: "2020-06-26 11:20:33"),
                      Milestone(id: 1, title: "스프린트", description: "다음 배포를 위한 스프린트", dueDate: "2020-06-26 11:20:33"),
                      Milestone(id: 1, title: "스프린트 1", description: "다음 배포를 위한 스프린트", dueDate: "2020-06-26 11:20:33"),
                      Milestone(id: 1, title: "스프린트1", description: "다음 배포를 위한 스프린트", dueDate: "2020-06-26 11:20:33"),
                      Milestone(id: 1, title: "스프린", description: "다음 배포를 위한 스프린트", dueDate: "2020-06-26 11:20:33"),
                      Milestone(id: 1, title: "스프", description: "다음 배포를 위한 스프린트", dueDate: "2020-06-26 11:20:33"),
                      Milestone(id: 1, title: "스", description: "다음 배포를 위한 스프린트", dueDate: "2020-06-26 11:20:33"),
                      Milestone(id: 1, title: "스프린트3", description: "다음 배포를 위한 스프린트", dueDate: "2020-06-26 11:20:33"),
                      Milestone(id: 1, title: "스프린트3", description: "다음 배포를 위한 스프린트", dueDate: "2020-06-26 11:20:33")]
        
        didFetch?()
    }
    
    func cellForItemAt(path: IndexPath) -> MilestoneItemViewModel {
        return MilestoneItemViewModel(milestone: milestones[path.row])
    }
    
    func numberOfItem() -> Int {
        milestones.count
    }
}
