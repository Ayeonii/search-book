//
//  Array+Extensions.swift
//  SeachBook
//
//  Created by 이아연 on 8/25/25.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
