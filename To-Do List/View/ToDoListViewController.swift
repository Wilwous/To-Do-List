//
//  ToDoListViewController.swift
//  To-Do List
//
//  Created by Антон Павлов on 23.08.2024.
//

import UIKit

final class ToDoListViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private var tasks: [TaskModel] = []
    
    // MARK: - UI Components
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.estimatedRowHeight = 100
        table.register(
            TaskTableViewCell.self,
            forCellReuseIdentifier: "TaskCell"
        )
        
        return table
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        addElements()
        setupLayoutConstraint()
        fetchTasks()
    }
    
    // MARK: - Setup View
    
    private func setupNavigationBar() {
        title = "To-Do List"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(
                addTaskTapped
            )
        )
    }
    
    private func addElements() {
        [tableView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupLayoutConstraint() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - Network
    
    private func fetchTasks() {
        NetworkManager.shared.fetchTasks { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tasks):
                    self?.tasks = tasks
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Failed to fetch tasks: \(error)")
                }
            }
        }
    }
    
    @objc private func addTaskTapped() {
        // TODO: Логика создания новой задачи
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ToDoListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableViewCell
        let task = tasks[indexPath.row]
        cell.configure(with: task)
        
        return cell
    }
}
