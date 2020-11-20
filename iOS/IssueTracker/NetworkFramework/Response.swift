//
//  Response.swift
//  NetworkFramework
//
//  Created by 김신우 on 2020/11/07.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import Foundation

public class Response {
    public let statusCode: Int
    public let data: Data
    public let request: URLRequest?
    public let response: HTTPURLResponse?

    public init(statusCode: Int, data: Data, request: URLRequest? = nil, response: HTTPURLResponse? = nil) {
        self.statusCode = statusCode
        self.data = data
        self.request = request
        self.response = response
    }
}

public extension Response {
    func mapEncodable<T: Decodable>(_ type: T.Type) -> T? {
        return try? JSONDecoder().decode(type, from: data)
    }

    func mapJsonObject() -> [String: Any]? {
        return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    }

    func mapJsonArr() -> [[String: Any]]? {
        return try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
    }
}

public extension Response {
    static func convertToResponse(
        response: URLResponse?,
        request: URLRequest,
        data: Data?,
        error: Error?
    ) -> Result<Response, NetworkError> {
        let response = response as? HTTPURLResponse
        switch (response, data, error) {
        case let (.some(response), data, .none):
            let response = Response(statusCode: response.statusCode, data: data ?? Data(), request: request, response: response)
            return .success(response)
        case let (.some(response), _, .some(error)):
            let response = Response(statusCode: response.statusCode, data: data ?? Data(), request: request, response: response)
            let error = NetworkError.underlying(error, response)
            return .failure(error)
        case let (_, _, .some(error)):
            let error = NetworkError.underlying(error, nil)
            return .failure(error)
        default:
            let error = NetworkError.underlying(NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil), nil)
            return .failure(error)
        }
    }
}

extension Response: CustomDebugStringConvertible {
    public var debugDescription: String {
        return """
        [Request]   URL         :   \(String(describing: request?.url?.absoluteString ?? ""))
        [Request]   Method      :   \(String(describing: request?.httpMethod ?? ""))
        [Request]   httpBody    :   \(String(describing: prettyJson(data: request?.httpBody)))
        [Response]  statusCode  :   \(String(describing: response?.statusCode ?? 0))
        [Response]  httpBody    :   \(String(describing: prettyJson(data: data)))
        """
    }

    private func prettyJson(data: Data?) -> String {
        guard let data = data,
              let jsonAny = try? JSONSerialization.jsonObject(with: data, options: [])
        else { return "{No Body}" }

        let prettyJsonData: Data?
        if let jsonObject = jsonAny as? [String: Any] {
            prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        } else if let jsonArr = jsonAny as? [[String: Any]] {
            prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonArr, options: .prettyPrinted)
        } else {
            prettyJsonData = nil
        }
        let prettyJsonStr = String(data: prettyJsonData ?? Data(), encoding: .utf8) ?? ""

        return prettyJsonStr.isEmpty ? "{No Body}" : prettyJsonStr
    }
}
