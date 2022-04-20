//
//  ViewController.swift
//  CoreDataDemoApp
//
//  Created by Aleksandr Kretov on 19.04.2022.
//

import UIKit

class TasksListViewController: UITableViewController {
    // MARK: - Private properties

    private let storage = StorageManager.shared

    private var tasksList: [ToDoTask] {
        storage.fetchData()
    }

    private let cellID = "cell"

    // MARK: - Override Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavBar()
    }

    // MARK: - Private methods

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
        alert(title: "New Task", message: "Enter new task name", atIndex: nil)
    }

    // MARK: - Alert Controller setup

    private func alert(title: String, message: String, atIndex: Int?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.placeholder = "Enter new task name"
        }
        if let index = atIndex {
            let updateAction = UIAlertAction(title: "Update", style: .default) { _ in
                guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
                self.update(taskName: taskName, at: index)
            }
            alert.textFields?.first?.text = tasksList[index].title
            alert.addAction(updateAction)
        } else {
            let addAction = UIAlertAction(title: "Save", style: .default) { _ in
                guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
                self.save(taskName: taskName)
            }
            alert.addAction(addAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    private func save(taskName: String) {
        let task = ToDoTask(context: storage.persistentContainer.viewContext)
        task.title = taskName
        storage.save(task: task)
        let cellIndex = IndexPath(row: tasksList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
    }

    private func update(taskName: String, at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        tasksList[index].title = taskName
        tableView.reloadRows(at: [indexPath], with: .automatic)
        storage.saveContext()
    }
}

// MARK: - Extensions

extension TasksListViewController {
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

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            let task = self.tasksList[indexPath.row]
            self.storage.delete(task: task)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Edit") { _, _, _ in
            guard let title = self.tasksList[indexPath.row].title else { return }
            self.alert(title: title, message: "Edit your task name", atIndex: indexPath.row)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}
