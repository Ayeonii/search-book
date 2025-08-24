//
//  APIError.swift
//  SeachBook
//
//  Created by 이아연 on 8/24/25.
//

import Foundation

enum APIError: Error {
    case decodingError(Error)
    case encodingError(Error)
    case inValidUrl
    case imageFetchFail(String?)
    case convertImageFail
    case server(Int, String?)
    case client(Int, String?)
    case unknowned(String)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .decodingError(error):
            return "description: " + error.localizedDescription
        case let .encodingError(error):
            return "description: " + error.localizedDescription
        case .inValidUrl:
            return "description: Invalid URL"
        case let .imageFetchFail(msg):
            return "description: " + (msg ?? "")
        case .convertImageFail:
            return "description: Converting To Image Fail"
        case let .server(_, msg),
             let .client(_, msg):
            return "description: " + (msg ?? "")
        case let .unknowned(msg):
            return "description: " + msg
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .decodingError:
            return "Check Decoding Type"
        case .encodingError:
            return "Check Encoding Type"
        case .inValidUrl:
            return "Check URL"
        case .imageFetchFail:
            return "Check Image URL"
        case .convertImageFail:
            return "Check Image Data"
        case .server,
             .client:
            return "Retry"
        case .unknowned:
            return ""
        }
    }
}

extension APIError: CustomNSError {
    static var errorDomain: String {
        return "APIError"
    }

    var errorCode: Int {
        switch self {
        case .server(let statusCode, _),
                .client(let statusCode, _):
            return statusCode
        default:
            return -1
        }
    }

    var errorUserInfo: [String: Any] {
        return [
            NSLocalizedDescriptionKey: errorDescription ?? "",
            NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion ?? ""
        ]
    }

    var nsError: NSError {
        return NSError(apiError: self)
    }
}
