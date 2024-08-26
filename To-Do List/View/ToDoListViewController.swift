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
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(
            self,
            action: #selector(refreshTasks),
            for: .valueChanged
        )
        
        return refresh
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.estimatedRowHeight = 100
        table.refreshControl = refreshControl
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
        title = "Список задач"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTaskTapped)
        )
        
        let backButton = UIBarButtonItem()
        backButton.title = "Назад"
        navigationItem.backBarButtonItem = backButton
    }
    
    private func addElements() {
        [tableView,
         activityIndicator
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
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Network
    
    private func fetchTasks() {
        activityIndicator.startAnimating()
        NetworkManager.shared.fetchTasks { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.refreshControl.endRefreshing()
                switch result {
                case .success(let tasks):
                    self?.tasks = tasks
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Failed to fetch tasks: \(error)")
                    AlertManager.showAlert(
                        on: self!,
                        title: "Ошибка",
                        message: "Не удалось загрузить задачи. Попробуйте снова."
                    )
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func editTaskTapped(task: TaskModel) {
        let addTaskVC = AddTaskViewController()
        addTaskVC.delegate = self
        addTaskVC.taskToEdit = task
        navigationController?.pushViewController(addTaskVC, animated: true)
    }
    
    // MARK: - Action
    
    @objc private func addTaskTapped() {
        let addTaskVC = AddTaskViewController()
        addTaskVC.delegate = self
        navigationController?.pushViewController(addTaskVC, animated: true)
    }
    
    @objc private func refreshTasks() {
        fetchTasks()
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
        cell.delegate = self
        
        return cell
    }
}

// MARK: - AddTaskViewControllerDelegate

extension ToDoListViewController: AddTaskViewControllerDelegate {
    func didAddTask(_ task: TaskModel) {
        tasks.append(task)
        tableView.reloadData()
    }
    
    func didEditTask(_ task: TaskModel) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            tableView.reloadData()
        }
    }
}

// MARK: - TaskTableViewCellDelegate

extension ToDoListViewController: TaskTableViewCellDelegate {
    func didTapOptionsButton(in cell: TaskTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        var task = tasks[indexPath.row]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(
            UIAlertAction(title: task.isPinned ? "Открепить" : "Закрепить", style: .default, handler: { _ in
                task.isPinned.toggle()
                self.tasks[indexPath.row] = task
                self.tasks.sort {
                    if $0.isPinned == $1.isPinned {
                        return $0.creationDate < $1.creationDate
                    } else {
                        return $0.isPinned && !$1.isPinned
                    }
                }
                self.tableView.reloadData()
            }))
        
        alertController.addAction(UIAlertAction(title: "Редактировать", style: .default, handler: { _ in
            self.editTaskTapped(task: task)
        }))
        
        alertController.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { _ in
            self.tasks.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }))
        
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alertController, animated: true)
    }
}
