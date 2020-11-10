//
//  IssueFilter.swift
//  IssueTracker
//
//  Created by 김신우 on 2020/11/05.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import Foundation

protocol IssueFilterable: AnyObject {
    var generalConditions: [Bool] { get set }
    var detailConditions: [Int] { get set }
    
    func filter(datas: [Issue]) -> [Issue]
}

class IssueFilter: IssueFilterable {
    
    var generalConditions = [Bool](repeating: false, count: Condition.allCases.count)
    var detailConditions = [Int](repeating: -1, count: DetailSelectionType.allCases.count)
    
    init() {
        self.generalConditions[0] = true
    }
    
    init(generalCondition: [Bool], detailCondition: [Int]) {
        guard detailCondition.count == DetailSelectionType.allCases.count,
            generalCondition.count == Condition.allCases.count
            else { return }
        self.generalConditions = generalCondition
        self.detailConditions = detailCondition
    }
    
    func filter(datas: [Issue]) -> [Issue] {
        
        var dataSet = Set<Issue>()
        if generalConditions[Condition.issueOpened.rawValue] {
            dataSet = dataSet.union(datas.filter { $0.isOpened })
        }
        
        if generalConditions[Condition.issueClosed.rawValue] {
            dataSet = dataSet.union(datas.filter { !$0.isOpened })
        }
        
        // TODO: Issue AssignedToMe, CommentedByMe, FromMe
        //        if generalConditions[Condition.issueAssignedToMe.rawValue] {
        //
        //        }
        //
        //        if generalConditions[Condition.issueCommentedByMe.rawValue] {
        //
        //        }
        //
        //        if generalConditions[Condition.issueFromMe.rawValue] {
        //
        //        }
        
        // TODO: Detail Condition
        //        if detailConditions[DetailSelectionType.assignee.rawValue] != -1 {
        //
        //        }
        //
        //        if detailConditions[DetailSelectionType.writer.rawValue] != -1 {
        //
        //        }
        
        if let id = detailConditions[safe: DetailSelectionType.label.rawValue],
            id != -1 {
            dataSet = dataSet.intersection(datas.filter { $0.labels.contains(where: { $0 == id })})
        }
        
        if let id = detailConditions[safe: DetailSelectionType.milestone.rawValue],
            id != -1  {
            dataSet = dataSet.intersection(datas.filter { $0.milestone ?? -1 ==  id })
        }
        
        
        return dataSet.map { $0 }
    }
}
