//
//  NetworkManager.swift
//  To-Do List
//
//  Created by Антон Павлов on 23.08.2024.
//

import UIKit

final class NetworkManager {
    
    // MARK: - Static
    
    static let shared = NetworkManager()
    
    // MARK: - Public Methods
    
    func fetchTasks(completion: @escaping (Result<[TaskModel], Error>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(ToDoResponse.self, from: data)
                    let tasks = response.todos.map { item -> TaskModel in
                        let randomColor = ColorUtility.getRandomColor()
                        return TaskModel(
                            id: item.id,
                            title: item.todo,
                            description: item.todo,
                            creationDate: Date(),
                            isCompleted: item.completed,
                            color: randomColor
                        )
                    }
                    completion(.success(tasks))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    // MARK: - Initializer
    
    private init() {}
}
