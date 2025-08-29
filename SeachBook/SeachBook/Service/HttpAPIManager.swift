//
//  HttpAPIManager.swift
//  SeachBook
//
//  Created by 이아연 on 8/24/25.
//

import Foundation
import Combine

enum HTTPMethod {
    case get
    case post
    case put
    case patch
    case delete
}

struct HttpAPIManager {
    static var headers: [String: String?] {
        let headers: [String: String?] = [
            "Content-Type": "application/json"
        ]
        return headers
    }

    static func callRequest<T>(api: String,
                               method: HTTPMethod,
                               param: Encodable? = nil,
                               body: Encodable? = nil,
                               responseType: T.Type) -> AnyPublisher<T, APIError>
    where T: Decodable {
        do {
            guard let url = try makeURLWithQueryParams(urlStr: api, param: param) else {
                return Fail(error: APIError.inValidUrl).eraseToAnyPublisher()
            }
            let urlRequest = try URLRequest(url: url, method: method, body: body, headers: headers)
            return callApi(request: urlRequest, responseType: responseType)
        } catch let apiError as APIError {
            return Fail(error: apiError).eraseToAnyPublisher()
        } catch {
            return Fail(error: APIError.unknown(error.localizedDescription)).eraseToAnyPublisher()
        }
    }

    static func makeURLWithQueryParams(urlStr: String, param: Encodable?) throws -> URL? {
        var queryParams: [String: Any] = [:]
        guard let param = param else { return URLComponents(string: urlStr)?.url }

        do {
            let paramData = try JSONEncoder().encode(param)
            if let paramObject = try JSONSerialization.jsonObject(with: paramData, options: .allowFragments) as? [String: Any] {
                queryParams = paramObject
            }

            var urlComponents = URLComponents(string: urlStr)
            var urlQueryItems: [URLQueryItem] = []

            for (key, value) in queryParams {
                urlQueryItems.append(URLQueryItem(name: key, value: String(describing: value)))
            }

            if urlQueryItems.count > 0 {
                urlComponents?.queryItems = urlQueryItems
            }

            guard let url = urlComponents?.url else {
                throw APIError.inValidUrl
            }

            return url
        } catch {
            throw APIError.encodingError(error)
        }
    }

    static func callApi<T>(request: URLRequest, responseType: T.Type) -> AnyPublisher<T, APIError>
    where T: Decodable {

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output -> Data in
                guard let httpResponse = output.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw APIError.unknown("No Server Response")
                }

                let responseData = output.data
                switch httpResponse.statusCode {
                case (200..<300):
                    return responseData

                case (400..<500):
                    let msg = try? extractMessage(from: responseData)
                    throw APIError.client(httpResponse.statusCode, msg)

                default:
                    let msg = try? extractMessage(from: responseData)
                    throw APIError.server(httpResponse.statusCode, msg)
                }
            }
            .decode(type: responseType, decoder: JSONDecoder())
            .mapError { error -> APIError in
                switch error {
                case let api as APIError:
                    return api
                case is DecodingError:
                    return .decodingError(error)
                default:
                    return .unknown(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }

    private static func extractMessage(from data: Data) throws -> String {
        let obj = try JSONSerialization.jsonObject(with: data, options: [])
        if let dict = obj as? [String: Any], let message = dict["message"] as? String {
            return message
        }
        return String(data: data, encoding: .utf8) ?? "UnExpected Error"
    }
}

extension URLRequest {
    init (url: URL, method: HTTPMethod, body: Encodable?, headers: [String: String?]) throws {
        self.init(url: url)
        self.timeoutInterval = TimeInterval(30)

        do {
            let bodyData = try self.makeBody(body: body)

            switch method {
            case .get:
                self.httpMethod = "GET"

            case .post:
                self.httpMethod = "POST"
                self.httpBody = bodyData

            case .put:
                self.httpMethod = "PUT"
                self.httpBody = bodyData

            case .patch:
                self.httpMethod = "PATCH"
                self.httpBody = bodyData

            case .delete:
                self.httpMethod = "DELETE"
                self.httpBody = bodyData
            }

            headers.forEach {
                self.setValue($0.value, forHTTPHeaderField: $0.key)
            }
        } catch {
            throw error
        }
    }

    func makeBody(body: Encodable?) throws -> Data? {
        guard let body = body else { return nil }

        do {
            let jsonEncoder = JSONEncoder()
            let bodyData = try jsonEncoder.encode(body)

            return bodyData
        } catch {
            throw APIError.encodingError(error)
        }
    }
}
