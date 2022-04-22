//
//  ViewController.swift
//  CoreDataDemoApp
//
//  Created by Aleksandr Kretov on 19.04.2022.
//

import UIKit

class TasksListViewController: UITableViewController {
    // MARK: - Private properties

    private var tasksList: [ToDoTask] = []

    private let cellID = "cell"

    // MARK: - Override Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavBar()
        fetchTasks()
    }

    // MARK: - Private methods

    private func fetchTasks() {
        StorageManager.shared.fetchData { result in
            switch result {
            case .success(let tasks):
                self.tasksList = tasks
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    private func save(taskName: String) {
        StorageManager.shared.create(taskName) { task in
            self.tasksList.append(task)
            tableView.insertRows(at: [IndexPath(row: self.tasksList.count - 1, section: 0)], with: .automatic)
        }
    }

    private func update(taskName: String, at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        tasksList[index].title = taskName
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension TasksListViewController {
    // MARK: - Alert Controller Setup

    // Alert controller both with task and completion optional nil
    private func showAlert(task: ToDoTask? = nil, completion: (() -> Void)? = nil) {
        let title = task != nil ? "Update Task" : "New Task"
        let actionTitle = task != nil ? "Update" : "Create"
        let alert = UIAlertController.createAlertController(withTitle: title)
        alert.action(task: task, actionTitle: actionTitle) { taskName in
            if let task = task, let completion = completion {
                StorageManager.shared.update(task, newName: taskName)
                completion()
            } else {
                self.save(taskName: taskName)
            }
        }
        present(alert, animated: true)
    }

    // In place implementation
    private func presentAlert(task: ToDoTask? = nil, completion: (() -> Void)? = nil) {
        
        let alertTitle = task != nil ? "Update Task" : "New Task"
        let actionTitile = task != nil ? "Update" : "Create"
        let alertMessage = task != nil ? "Edit your task name" : "What do you want to do?"
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        func createAction(task: ToDoTask?, actionTitle: String, completion: @escaping (String) -> Void) -> UIAlertAction {
            let saveAction = UIAlertAction(title: actionTitle, style: .default) { _ in
                guard let newValue = alert.textFields?.first?.text else { return }
                guard !newValue.isEmpty else { return }
                completion(newValue)
            }
            return saveAction
        }
        
        let saveAction = createAction(task: task, actionTitle: actionTitile) { taskName in
            if let task = task, let completion = completion {
                StorageManager.shared.update(task, newName: taskName)
                completion()
            } else {
                self.save(taskName: taskName)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "Task"
            textField.text = task?.title
        }
        present(alert, animated: true)
    }

    // MARK: - TableView Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasksList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = tasksList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }

    // MARK: - TableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            let task = self.tasksList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            StorageManager.shared.delete(task)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Edit") { _, _, _ in
            let task = self.tasksList[indexPath.row]
            tableView.reloadRows(at: [indexPath], with: .automatic)
            self.presentAlert(task: task) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        action.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        return UISwipeActionsConfiguration(actions: [action])
    }

    // MARK: - NavBar Setup

    private func setupNavBar() {
        title = "Actual Tasks"
        navigationController?.navigationBar.prefersLargeTitles = true
        let navBarAppearence = UINavigationBarAppearance()
        navBarAppearence.configureWithOpaqueBackground()
        navBarAppearence.backgroundColor = .systemTeal
        navBarAppearence.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearence.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = navBarAppearence
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearence
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
        navigationController?.navigationBar.tintColor = .white
    }

    @objc private func addTask() {
        presentAlert()
    }
}
