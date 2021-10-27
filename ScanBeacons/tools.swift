//
//  tools.swift
//  ScanBeacons
//
//  Created by Wei-Cheng Ling on 2021/10/25.
//

import Foundation


// MARK: - JSON

func JsonString(from object: Any) -> String? {
    guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
        return nil
    }
    guard let string = String(data: data, encoding: String.Encoding.utf8) else {
        return nil
    }
    return "'\(string)'"
}

func CurrentTimeString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter.string(from: Date())
}
