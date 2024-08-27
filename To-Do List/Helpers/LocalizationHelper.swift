//
//  LocalizationHelper.swift
//  To-Do List
//
//  Created by Антон Павлов on 27.08.2024.
//

import Foundation

final class LocalizationHelper {
    static func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}
