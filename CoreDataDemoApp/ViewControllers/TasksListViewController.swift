//
//  ViewController.swift
//  CoreDataDemoApp
//
//  Created by Aleksandr Kretov on 19.04.2022.
//

import UIKit

protocol TasksListViewControllerDelegate {
    func reloadData()
}

class TasksListViewController: UITableViewController {
    
    private var tasksList: [ToDoTask] = []
    private var cellID = "cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavBar()
        fetchData()
    }

    private func setupNavBar() {
        title = "Actual Tasks"
        navigationController?.navigationBar.prefersLargeTitles =  true
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
        let newTaskVC = NewTaskViewController()
        newTaskVC.delegate = self
        present(newTaskVC, animated: true)
    }
    
    private func fetchData() {
        let viewContext = StorageManager.shared.persistentContainer.viewContext
        let fetchRequest = ToDoTask.fetchRequest()
        do {
            tasksList = try viewContext.fetch(fetchRequest)
            
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension TasksListViewController {

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
}

extension TasksListViewController: TasksListViewControllerDelegate {
    func reloadData() {
        fetchData()
        tableView.reloadData()
    }
}
