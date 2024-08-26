//
//  TaskModel.swift
//  To-Do List
//
//  Created by Антон Павлов on 23.08.2024.
//

import UIKit

struct TaskModel {
    let id: Int
    var title: String
    var description: String
    var creationDate: Date
    var isCompleted: Bool
    var color: UIColor
    var isPinned: Bool = false
}
