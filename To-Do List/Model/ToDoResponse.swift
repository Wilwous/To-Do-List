//
//  ToDoResponse.swift
//  To-Do List
//
//  Created by Антон Павлов on 23.08.2024.
//

import Foundation

struct ToDoResponse: Decodable {
    let todos: [ToDoItem]
}
