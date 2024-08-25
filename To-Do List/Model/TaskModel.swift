//
//  TaskModel.swift
//  To-Do List
//
//  Created by Антон Павлов on 23.08.2024.
//

import UIKit

struct TaskModel {
    let id: Int
    let title: String
    let description: String
    let creationDate: Date
    let isCompleted: Bool
    let color: UIColor
}
