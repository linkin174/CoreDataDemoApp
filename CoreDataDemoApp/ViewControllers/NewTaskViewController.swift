//
//  NewTaskViewController.swift
//  CoreDataDemoApp
//
//  Created by Aleksandr Kretov on 19.04.2022.
//

import UIKit



class NewTaskViewController: UIViewController {
    
    var delegate: TasksListViewControllerDelegate!
    
    private lazy var taskTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "New task"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var saveButton: UIButton = createButton(
        buttonTitle: "Save Task",
        buttonColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),
        UIAction { _ in
            self.saveTask()
        })
    
    private lazy var cancelButton: UIButton = createButton(
        buttonTitle: "Cancel",
        buttonColor: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1),
        UIAction { _ in
            self.dismiss(animated: true)
        })

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        add(subwiews: taskTextField, saveButton, cancelButton)
        setupConstraints()
    }
    
    private func setupConstraints() {
        taskTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            taskTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 64),
            taskTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            taskTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: taskTextField.bottomAnchor, constant: 64),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 32),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
    
    private func add(subwiews: UIView...) {
        subwiews.forEach { subview in
            view.addSubview(subview)
        }
    }
    
    private func createButton(buttonTitle title: String, buttonColor color: _ColorLiteralType, _ action: UIAction) -> UIButton {
        var attributes = AttributeContainer()
        attributes.font = UIFont.boldSystemFont(ofSize: 20)
        
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.baseBackgroundColor = color
        buttonConfig.attributedTitle = AttributedString(title, attributes: attributes)
        
        return UIButton(configuration: buttonConfig, primaryAction: action)
    }
    
    private func saveTask() {
        let viewContext = StorageManager.shared.persistentContainer.viewContext
        let task = ToDoTask(context: viewContext)
        task.title = taskTextField.text
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
        delegate.reloadData()
        dismiss(animated: true)
    }
}

