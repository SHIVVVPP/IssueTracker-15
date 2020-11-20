//
//  EndPoin.swift
//  NetworkFramework
//
//  Created by 김신우 on 2020/11/07.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import Foundation

public class EndPoint {
    public let url: String
    public let method: HTTPMethod
    public let task: Task
    public let httpHeaderFields: [String: String]?

    public init(url: String, method: HTTPMethod, task: Task, httpHeaderFields: [String: String]?) {
        self.url = url
        self.method = method
        self.task = task
        self.httpHeaderFields = httpHeaderFields
    }

    func urlRequest() -> Result<URLRequest, NetworkError> {
        guard let requestURL = Foundation.URL(string: url) else {
            return .failure(NetworkError.urlMappingError("URL을 생성할 수 없습니다."))
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = httpHeaderFields
        do {
            switch task {
            case .requestPlain:
                return .success(request)
            case let .requestJsonObject(jsonObject):
                return .success(try request.encoding(jsonObject: jsonObject))
            case let .requestJsonCodable(codableObject):
                return .success(try request.encoding(encodable: codableObject))
            }
        } catch let NetworkError.encodingData(error) {
            return .failure(NetworkError.encodingData(error))
        } catch {
            return .failure(NetworkError.urlMappingError("httpBody 매핑에 실패했습니다."))
        }
    }
}

extension EndPoint {
    static func endPointMapping(_ target: Target) throws -> EndPoint {
        return try EndPoint(url: URL(target: target).absoluteString,
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
    }
}
