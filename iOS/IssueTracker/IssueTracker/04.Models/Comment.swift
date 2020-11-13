//
//  Comment.swift
//  IssueTracker
//
//  Created by 김신우 on 2020/11/11.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import Foundation

struct Comment {
    let content: String
    let createAt: String
    let author: User
    
    init(content: String, user: User) {
        self.content = content
        self.createAt = ""
        self.author = user
    }
    
    init?(json: [String: Any]?) {
        guard let json = json,
            let content = json["content"] as? String,
            let createAt = json["createAt"] as? String,
            let userObject = json["user"] as? [String: Any],
            let user = User(json: userObject)
            else { return nil }
        self.content = content
        self.createAt = createAt
        self.author = user
    }
    
}

// MARK: - For Response Data

extension Comment {
    
    // For AddResponse
    static func addResponse(json: [String: Any]?) -> Comment? {
        guard let json = json,
            let content = json["content"] as? String,
            let createAt = json["createAt"] as? String,
            let authorId = json["userId"] as? Int
            else { return nil }
        
        return Comment(content: content, authorId: authorId, createAt: createAt)
    }
    
    init(content: String, authorId: Int, createAt: String) {
        if let createdDate = createAt.dateForServer {
            self.createAt = DateFormatter.dateForCollectionView.string(from: createdDate)
        } else {
            self.createAt = ""
        }
        self.content = content
        self.author = User(id: authorId)
    }
    
}
