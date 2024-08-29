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
        refresh.backgroundColor = .wBackground
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
        view.backgroundColor = .wBackground
        setupNavigationBar()
        addElements()
        setupLayoutConstraint()
        fetchTasks()
    }
    
    // MARK: - Setup View
    
    private func setupNavigationBar() {
        title = LocalizationHelper.localizedString("listTasks")
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "wBackground")
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTaskTapped)
        )
        
        let backButton = UIBarButtonItem()
        backButton.title = LocalizationHelper.localizedString("back")
        backButton.tintColor = UIColor(named: "wBlue")
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
        
        let coreDataTasks = CoreDataManager.shared.fetchTasks()
        
        if coreDataTasks.isEmpty {
            NetworkManager.shared.fetchTasks { [weak self] result in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.refreshControl.endRefreshing()
                    
                    switch result {
                    case .success(let tasks):
                        tasks.forEach { task in
                            CoreDataManager.shared.saveTask(
                                id: Int64(task.id),
                                title: task.title,
                                descriptionText: task.description,
                                creationDate: task.creationDate,
                                isCompleted: task.isCompleted,
                                color: task.color,
                                isPinned: task.isPinned
                            )
                        }
                        self?.tasks = CoreDataManager.shared.fetchTasks().map { taskEntity in
                            return TaskModel(
                                id: Int(taskEntity.id),
                                title: taskEntity.title ?? "",
                                description: taskEntity.descriptionText ?? "",
                                creationDate: taskEntity.creationDate ?? Date(),
                                isCompleted: taskEntity.isCompleted,
                                color: taskEntity.color as? UIColor ?? UIColor.white,
                                isPinned: taskEntity.isPinned
                            )
                        }
                        self?.tasks.sort {
                            if $0.isPinned == $1.isPinned {
                                return $0.creationDate < $1.creationDate
                            } else {
                                return $0.isPinned && !$1.isPinned
                            }
                        }
                        self?.tableView.reloadData()
                    case .failure(let error):
                        print("Failed to fetch tasks: \(error)")
                        AlertManager.showAlert(
                            on: self!,
                            title: LocalizationHelper.localizedString("error"),
                            message: LocalizationHelper.localizedString("errorText1")
                        )
                    }
                }
            }
        } else {
            self.tasks = coreDataTasks.map { taskEntity in
                return TaskModel(
                    id: Int(taskEntity.id),
                    title: taskEntity.title ?? "",
                    description: taskEntity.descriptionText ?? "",
                    creationDate: taskEntity.creationDate ?? Date(),
                    isCompleted: taskEntity.isCompleted,
                    color: taskEntity.color as? UIColor ?? UIColor.white,
                    isPinned: taskEntity.isPinned
                )
            }
            self.tasks.sort {
                if $0.isPinned == $1.isPinned {
                    return $0.creationDate < $1.creationDate
                } else {
                    return $0.isPinned && !$1.isPinned
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
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
            UIAlertAction(title: task.isPinned ? LocalizationHelper.localizedString("pin") : LocalizationHelper.localizedString("unpin"), style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                task.isPinned.toggle()
                
                if let taskEntityToUpdate = CoreDataManager.shared.fetchTasks().first(where: { $0.id == Int64(task.id) }) {
                    taskEntityToUpdate.isPinned = task.isPinned
                    CoreDataManager.shared.saveContext()
                }
                
                self.tasks[indexPath.row] = task
                self.tasks.sort {
                    if $0.isPinned == $1.isPinned {
                        return $0.creationDate < $1.creationDate
                    } else {
                        return $0.isPinned && !$1.isPinned
                    }
                }
                self.tableView.reloadData()
            })
        )
        
        alertController.addAction(
            UIAlertAction(title: LocalizationHelper.localizedString("edit"), style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                self.editTaskTapped(task: task)
            })
        )
        
        alertController.addAction(
            UIAlertAction(title: LocalizationHelper.localizedString("delete"),
                          style: .destructive,
                          handler: {
                              [weak self] _ in
                              guard let self = self else { return }
                              let taskToRemove = self.tasks[indexPath.row]
                              
                              if let taskEntityToRemove = CoreDataManager.shared.fetchTasks().first(where: {
                                  $0.id == Int64(
                                    taskToRemove.id
                                  )
                              }) {
                                  CoreDataManager.shared.deleteTask(taskEntityToRemove)
                              }
                              
                              self.tasks.remove(at: indexPath.row)
                              self.tableView.deleteRows(at: [indexPath], with: .automatic)
                          })
        )
        
        alertController.addAction(UIAlertAction(title: LocalizationHelper.localizedString("cancel"), style: .cancel))
        
        present(alertController, animated: true)
    }
}
