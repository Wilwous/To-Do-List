//
//  ColorUtility.swift
//  To-Do List
//
//  Created by Антон Павлов on 24.08.2024.
//

import UIKit

final class ColorUtility {
    
    static func getRandomColor() -> UIColor {
        let colors = availableColors()
        return colors.randomElement() ?? .gray
    }
    
    static func availableColors() -> [UIColor] {
        return [
            .wRed, .wBeige, .wLightGreen, .wGreen, .wMint,
            .wCyan, .wLightBlue, .wPurple, .wLavender, .wPink
        ]
    }
}
