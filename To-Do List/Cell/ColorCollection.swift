//
//  ColorCollection.swift
//  To-Do List
//
//  Created by Антон Павлов on 25.08.2024.
//

import UIKit

final class ColorCollection: UICollectionViewCell {
    
    // MARK: - Static
    
    static let idetnifier = "ColorCell"
    
    // MARK: - Private Properties
    
    lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 25
        view.clipsToBounds = true
        
        return view
    }()
    
    private lazy var borderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 35
        view.layer.borderWidth = 6.0
        view.layer.borderColor = UIColor.clear.cgColor
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addElements()
        setupLayoutConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func updateSelectionState(isSelected: Bool) {
        if isSelected {
            borderView.layer.borderColor = colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
        } else {
            borderView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    // MARK: - Setup View
    
    private func addElements() {
        [colorView,
         borderView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupLayoutConstraint() {
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: borderView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: borderView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 50),
            colorView.heightAnchor.constraint(equalTo: colorView.widthAnchor),
            
            borderView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            borderView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            borderView.widthAnchor.constraint(equalToConstant: 70),
            borderView.heightAnchor.constraint(equalTo: borderView.widthAnchor)
        ])
    }
}
