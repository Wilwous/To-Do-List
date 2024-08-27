//
//  AddTaskViewController.swift
//  To-Do List
//
//  Created by Антон Павлов on 25.08.2024.
//

import UIKit

// MARK: - Protocol

protocol AddTaskViewControllerDelegate: AnyObject {
    func didAddTask(_ task: TaskModel)
    func didEditTask(_ task: TaskModel)
}

final class AddTaskViewController: UIViewController {
    
    // MARK: - Delegate
    
    weak var delegate: AddTaskViewControllerDelegate?
    
    // MARK: - Public Properties
    
    var taskToEdit: TaskModel?
    
    // MARK: - Private Properties
    
    private let colorNames = ColorUtility.availableColors()
    private var selectedColor: UIColor?
    
    // MARK: - UI Components
    
    private lazy var titleTextField: UITextField = {
        let text = UITextField()
        text.placeholder = "Заголовок"
        text.font = .systemFont(ofSize: 17)
        text.textAlignment = .left
        text.borderStyle = .none
        text.textColor = .label
        text.backgroundColor = .wCellStroke
        text.layer.cornerRadius = 10
        text.layer.borderWidth = 1
        text.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: text.frame.height))
        text.leftView = paddingView
        text.leftViewMode = .always
        
        return text
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let text = UITextView()
        text.font = .systemFont(ofSize: 17)
        text.textColor = .label
        text.backgroundColor = .wCellStroke
        text.layer.borderWidth = 1
        text.layer.cornerRadius = 10
        text.layer.borderColor = UIColor.separator.cgColor
        text.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        text.isScrollEnabled = true
        text.delegate = self
        
        return text
    }()
    
    private lazy var descriptionPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Описание"
        label.font = .systemFont(ofSize: 17)
        label.textColor = UIColor.gray.withAlphaComponent(0.5)
        label.isHidden = !descriptionTextView.text.isEmpty
        
        return label
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.allowsMultipleSelection = false
        view.register(
            ColorCollection.self,
            forCellWithReuseIdentifier: ColorCollection.idetnifier
        )
        
        return view
    }()
    
    private lazy var creationButton: UIButton = {
        let button = UIButton()
        button.setTitle(taskToEdit == nil ? "Создать" : "Сохранить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .wBlue
        button.layer.cornerRadius = 16
        button.addTarget(
            self,
            action: #selector(creationButtonTapped),
            for: .touchUpInside
        )
        
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wBackground
        title = taskToEdit == nil ? "Создание задачи" : "Редактирование задачи"
        addElements()
        layoutConstraint()
        configureViewIfEditing()
    }
    
    // MARK: - Setup View
    
    private func addElements() {
        [titleTextField,
         descriptionTextView,
         colorCollectionView,
         creationButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        [descriptionPlaceholderLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            descriptionTextView.addSubview($0)
        }
    }
    
    private func layoutConstraint() {
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            titleTextField.heightAnchor.constraint(equalToConstant: 48),
            
            descriptionTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 350),
            
            descriptionPlaceholderLabel.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 8),
            descriptionPlaceholderLabel.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 15),
            
            colorCollectionView.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 24),
            colorCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            colorCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 140),
            
            creationButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 24),
            creationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            creationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            creationButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func configureViewIfEditing() {
        guard let task = taskToEdit else { return }
        titleTextField.text = task.title
        descriptionTextView.text = task.description
        selectedColor = task.color
        descriptionPlaceholderLabel.isHidden = !task.description.isEmpty
        colorCollectionView.reloadData()
    }
    
    // MARK: - Actions
    
    @objc private func creationButtonTapped() {
        guard let title = titleTextField.text, !title.isEmpty,
              let description = descriptionTextView.text, !description.isEmpty else {
            AlertManager.showAlert(
                on: self,
                title: "Ошибка",
                message: "Пожалуйста, заполните все поля"
            )
            return
        }
        
        let selectedColor = self.selectedColor ?? ColorUtility.getRandomColor()
        
        if var task = taskToEdit {
            
            task.title = title
            task.description = description
            task.color = selectedColor
            
            if let existingTaskEntity = CoreDataManager.shared.fetchTasks().first(where: { $0.id == Int64(task.id) }) {
                existingTaskEntity.title = title
                existingTaskEntity.descriptionText = description
                existingTaskEntity.color = selectedColor
                CoreDataManager.shared.saveContext()
            }
            
            delegate?.didEditTask(task)
        } else {
            let newTask = TaskModel(
                id: Int.random(in: 1...1000),
                title: title,
                description: description,
                creationDate: Date(),
                isCompleted: false,
                color: selectedColor
            )
            
            CoreDataManager.shared.saveTask(
                id: Int64(newTask.id),
                title: newTask.title,
                descriptionText: newTask.description,
                creationDate: newTask.creationDate,
                isCompleted: newTask.isCompleted,
                color: newTask.color,
                isPinned: newTask.isPinned
            )
            
            delegate?.didAddTask(newTask)
        }
        
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextViewDelegate

extension AddTaskViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholderLabel.isHidden = !textView.text.isEmpty
    }
}

// MARK: - UICollectionViewDelegate

extension AddTaskViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return colorNames.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ColorCollection.idetnifier,
            for: indexPath
        ) as? ColorCollection else {
            return UICollectionViewCell()
        }
        
        let color = colorNames[indexPath.item]
        cell.colorView.backgroundColor = color
        cell.updateSelectionState(isSelected: color == selectedColor)
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        selectedColor = colorNames[indexPath.item]
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AddTaskViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 12
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 12
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
}
