//
//  IssueEndPoint.swift
//  IssueTracker
//
//  Created by 김신우 on 2020/11/04.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import Foundation
import NetworkFramework

enum IssueService {
    // fetch All (isOpened)
    // [GET] /api/issue?isOpened={boolean}
    case fetchAll(Bool)

    // get issue with (Id)
    // [GET] /api/issue/:id
    case getIssue(Int)

    // createIssue (title, description, milestoneID, authorID)
    // [POST] /api/issue
    case createIssue(String, String?, Int?, Int)

    // editTitle (Id, title)
    // [PATCH] /api/issue/:id/title
    case editTitle(Int, String)

    // editDescription (Id, title, description, isOpened)
    // [PATCH] /api/issue/:id/
    case editIssue(Int, String?, String?, Bool?)

    // delete (Id)
    // [DELETE] /api/issue/:id
    case delete(Int)

    // addLabel( Id, LabelId)
    // [POST] /api/issue/:id/label/:labelId
    case addLabel(Int, Int)

    // deleteLabel ( Id, LabelId)
    // [DELETE] /api/issue/:id/label/:labelId
    case deleteLabel(Int, Int)

    // addMilestone ( Id, milestoneId)
    // [POST] /api/issue/:id/milestone/:milestoneId
    case addMilestone(Int, Int)

    // deleteMilestone ( Id, milestoneId)
    // [DELETE] /api/issue/:id/milestone/:milestoneId
    case deleteMilestone(Int, Int)

    // addAssignee( Id, userId)
    // [POST] /api/issue/:id/assignees/:assigneeId
    case addAssignee(Int, Int)

    // deleteAssignee( Id, userId)
    // [DELETE] /api/issue/:id/assignees/:assigneeId
    case deleteAssignee(Int, Int)
}

extension IssueService: IssueTrackerService {
    var path: String {
        switch self {
        case .fetchAll:
            // /api/issue?isOpened={boolean}
            return "/api/issue"
        case let .getIssue(id):
            // /api/issue/:id
            return "/api/issue/\(id)"
        case .createIssue:
            // /api/issue
            return "/api/issue"
        case let .editTitle(id, title):
            // /api/issue/:id/title
            return "/api/issue/\(id)/\(title)"
        case let .editIssue(id, _, _, _):
            //  /api/issue/:id/
            return "/api/issue/\(id)"
        case let .delete(id):
            // /api/issue/:id
            return "/api/issue/\(id)"
        case let .addLabel(id, labelId):
            // /api/issue/:id/label/:labelId
            return "/api/issue/\(id)/label/\(labelId)"
        case let .deleteLabel(id, labelId):
            // /api/issue/:id/milestone/:milestoneId
            return "/api/issue/\(id)/label/\(labelId)"
        case let .addMilestone(id, milestoneId):
            // /api/issue/:id/milestone/:milestoneId
            return "/api/issue/\(id)/milestone/\(milestoneId)"
        case let .deleteMilestone(id, milestoneId):
            // /api/issue/:id/milestone/:milestoneId
            return "/api/issue/\(id)/milestone/\(milestoneId)"
        case let .addAssignee(id, assigneeId):
            // /api/issue/:id/assignees/:assigneeId
            return "/api/issue/\(id)/assignees/\(assigneeId)"
        case let .deleteAssignee(id, assigneeId):
            // /api/issue/:id/assignees/:assigneeId
            return "/api/issue/\(id)/assignees/\(assigneeId)"
        }
    }

    var queryItems: [String: String]? {
        switch self {
        case let .fetchAll(isOpened):
            return ["isOpened": "\(isOpened)"]
        default:
            return nil
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchAll, .getIssue:
            return .get
        case .createIssue, .addLabel, .addMilestone, .addAssignee:
            return .post
        case .editTitle, .editIssue:
            return .patch
        case .delete, .deleteLabel, .deleteMilestone, .deleteAssignee:
            return .delete
        }
    }

    var task: Task {
        switch self {
        case .fetchAll, .getIssue, .delete, .addLabel,
             .deleteLabel, .addMilestone, .deleteMilestone,
             .addAssignee, .deleteAssignee:
            return .requestPlain
        case let .createIssue(title, description, milestoneId, authorId):
            var jsonObject = [String: Any]()
            jsonObject["title"] = title
            jsonObject["description"] = description
            jsonObject["milestoneId"] = milestoneId // can nil
            jsonObject["authorId"] = authorId
            return .requestJsonObject(jsonObject)
        case let .editTitle(_, title):
            return .requestJsonObject(["title": title])
        case let .editIssue(_, title, description, isOpened):
            var jsonObject = [String: Any]()
            jsonObject["title"] = title
            jsonObject["description"] = description
            jsonObject["isOpened"] = isOpened
            return .requestJsonObject(jsonObject)
        }
    }

    var validationType: ValidationType {
        switch self {
        case .fetchAll:
            return .successCode
        case .getIssue:
            return .successCode
        case .createIssue:
            return .custom([200])
        case .editTitle:
            return .custom([200])
        case .editIssue:
            return .custom([200])
        case .delete:
            return .custom([200])
        case .addLabel:
            return .custom([201])
        case .deleteLabel:
            return .custom([204])
        case .addMilestone:
            return .custom([201])
        case .deleteMilestone:
            return .custom([204])
        case .addAssignee:
            return .custom([201])
        case .deleteAssignee:
            return .custom([204])
        }
    }

    var headers: [String: String]? {
        return nil
    }
}
