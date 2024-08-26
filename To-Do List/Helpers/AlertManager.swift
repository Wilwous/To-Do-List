//
//  AlertManager.swift
//  To-Do List
//
//  Created by Антон Павлов on 26.08.2024.
//

import UIKit

final class AlertManager {
    
    static func showAlert(on viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}
