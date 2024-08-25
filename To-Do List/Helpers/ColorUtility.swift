//
//  ColorUtility.swift
//  To-Do List
//
//  Created by Антон Павлов on 24.08.2024.
//

import UIKit

final class ColorUtility {
    
    static func getRandomColor() -> UIColor {
        let colors: [UIColor] = [
            .wRed, .wBeige, .wLightGreen, .wGreen, .wMint,
            .wCyan, .wLightBlue, .wPurple, .wLavender, .wPink
        ]
        return colors.randomElement() ?? .gray
    }
}
