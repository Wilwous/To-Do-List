//
//  TaskTableViewCell.swift
//  To-Do List
//
//  Created by Антон Павлов on 23.08.2024.
//

import UIKit

// MARK: - Protocol

protocol TaskTableViewCellDelegate: AnyObject {
    func didTapOptionsButton(in cell: TaskTableViewCell)
}

final class TaskTableViewCell: UITableViewCell {
    
    // MARK: - Delegate
    
    weak var delegate: TaskTableViewCellDelegate?
    
    // MARK: - UI Components
    
    private lazy var pinnedIcon: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "pinIcon")?.withRenderingMode(.alwaysTemplate)
        imageView.image = image
        imageView.tintColor = .wBlue
        imageView.isHidden = true
        
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 3
        
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 3
        label.textColor = .gray
        
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        
        return label
    }()
    
    private lazy var colorIndicator: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private lazy var statusButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        
        return button
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        
        return view
    }()
    
    private lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "ellipsis")
        button.setImage(image, for: .normal)
        button.tintColor = .lightGray
        button.addTarget(
            self,
            action: #selector(optionsButtonTapped),
            for: .touchUpInside
        )
        
        return button
    }()
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .wBackground
        containerView.backgroundColor = .wCellBackground
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
        
        titleLabel.textColor = .label
        descriptionLabel.textColor = .secondaryLabel
        dateLabel.textColor = .secondaryLabel
        
        if task.isCompleted {
            statusButton.setTitle(LocalizationHelper.localizedString("done"), for: .normal)
            statusButton.backgroundColor = .wBackgroundDone
            statusButton.setTitleColor(.wTextDone, for: .normal)
        } else {
            statusButton.setTitle(LocalizationHelper.localizedString("undone"), for: .normal)
            statusButton.backgroundColor = .wBackgroundUndone
            statusButton.setTitleColor(.wTextUndone, for: .normal)
        }
        pinnedIcon.isHidden = !task.isPinned
    }

    // MARK: - Setup View
    
    private func addElements() {
        [containerView,
         colorIndicator,
         titleLabel,
         descriptionLabel,
         dateLabel,
         optionsButton,
         statusButton,
         pinnedIcon
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
            titleLabel.trailingAnchor.constraint(equalTo: optionsButton.leadingAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: colorIndicator.trailingAnchor, constant: 15),
            descriptionLabel.trailingAnchor.constraint(equalTo: optionsButton.leadingAnchor, constant: -10),
            
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: colorIndicator.trailingAnchor, constant: 15),
            dateLabel.trailingAnchor.constraint(equalTo: optionsButton.leadingAnchor, constant: -10),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            optionsButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            optionsButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            optionsButton.widthAnchor.constraint(equalToConstant: 24),
            optionsButton.heightAnchor.constraint(equalToConstant: 24),
            
            statusButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            statusButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            statusButton.heightAnchor.constraint(equalToConstant: 20),
            statusButton.widthAnchor.constraint(equalToConstant: 100),
            
            pinnedIcon.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            pinnedIcon.trailingAnchor.constraint(equalTo: optionsButton.leadingAnchor, constant: -10)
        ])
    }
    
    // MARK: - Action
    
    @objc private func optionsButtonTapped() {
        delegate?.didTapOptionsButton(in: self)
    }
}
