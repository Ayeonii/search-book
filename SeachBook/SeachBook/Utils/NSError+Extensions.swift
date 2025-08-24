//
//  NSError+Extensions.swift
//  SeachBook
//
//  Created by 이아연 on 8/24/25.
//

import Foundation

extension NSError {
    convenience init(apiError: APIError) {
        self.init(domain: APIError.errorDomain, code: apiError.errorCode, userInfo: apiError.errorUserInfo)
    }
}
