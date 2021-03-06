//
//  CommentService.swift
//  IssueTracker
//
//  Created by 김신우 on 2020/11/08.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import Foundation
import NetworkFramework

enum CommentService {
    // addComment ( userId, issueId, comment )
    // [POST] /api/comment
    case addComment(Int, Int, String)

    // editComment ( issueId, comment )
    // [PATCH] /api/comment/:id
    case editComment(Int, String)

    // deleteComment ( issueId)
    // [DELETE] /api/comment/:id
    case deleteComment(Int)
}

extension CommentService: IssueTrackerService {
    var path: String {
        switch self {
        case .addComment:
            return "/api/comment"
        case let .editComment(id, _):
            return "/api/comment/\(id)"
        case let .deleteComment(id):
            return "/api/comment/\(id)"
        }
    }

    var queryItems: [String: String]? {
        return nil
    }

    var method: HTTPMethod {
        switch self {
        case .addComment:
            return .post
        case .editComment:
            return .patch
        case .deleteComment:
            return .delete
        }
    }

    var task: Task {
        switch self {
        case let .addComment(userId, issueId, comment):
            var jsonObject = [String: Any]()
            jsonObject["userId"] = userId
            jsonObject["issueId"] = issueId
            jsonObject["content"] = comment
            return .requestJsonObject(jsonObject)
        case let .editComment(id, comment):
            var jsonObject = [String: Any]()
            jsonObject["issueID"] = id
            jsonObject["content"] = comment
            return .requestJsonObject(jsonObject)
        case .deleteComment:
            return .requestPlain
        }
    }

    var validationType: ValidationType {
        switch self {
        case .addComment:
            return .successCode
        case .editComment:
            return .successCode
        case .deleteComment:
            return .successCode
        }
    }

    var headers: [String: String]? {
        return nil
    }
}
