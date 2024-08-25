//
//  TaskTableViewCell.swift
//  To-Do List
//
//  Created by Антон Павлов on 23.08.2024.
//

//
//  TaskTableViewCell.swift
//  To-Do List
//
//  Created by Антон Павлов on 23.08.2024.
//

import UIKit

final class TaskTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 0
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .gray
        
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        
        return label
    }()
    
    private let colorIndicator: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private let statusIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        
        return view
    }()
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        addElements()
        setupLayoutConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configure(with task: TaskModel) {
        titleLabel.text = task.title
        descriptionLabel.text = task.description
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateLabel.text = dateFormatter.string(from: task.creationDate)
        colorIndicator.backgroundColor = task.color
        
        if task.isCompleted {
            statusIcon.image = UIImage(systemName: "checkmark.circle.fill")
            statusIcon.tintColor = .systemGreen
        } else {
            statusIcon.image = UIImage(systemName: "circle")
            statusIcon.tintColor = .systemGray
        }
    }
    
    // MARK: - Setup View
    
    private func addElements() {
        [containerView,
         colorIndicator,
         titleLabel,
         descriptionLabel,
         dateLabel,
         statusIcon
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupLayoutConstraint() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            colorIndicator.topAnchor.constraint(equalTo: containerView.topAnchor),
            colorIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            colorIndicator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            colorIndicator.widthAnchor.constraint(equalToConstant: 8),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: colorIndicator.trailingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: statusIcon.leadingAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: colorIndicator.trailingAnchor, constant: 15),
            descriptionLabel.trailingAnchor.constraint(equalTo: statusIcon.leadingAnchor, constant: -10),
            
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: colorIndicator.trailingAnchor, constant: 15),
            dateLabel.trailingAnchor.constraint(equalTo: statusIcon.leadingAnchor, constant: -10),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            statusIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            statusIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            statusIcon.widthAnchor.constraint(equalToConstant: 24),
            statusIcon.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}
