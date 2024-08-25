//
//  ToDoItem.swift
//  To-Do List
//
//  Created by Антон Павлов on 24.08.2024.
//

import Foundation

struct ToDoItem: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
