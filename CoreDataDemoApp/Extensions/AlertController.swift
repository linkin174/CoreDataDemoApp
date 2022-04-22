//
//  AlertController.swift
//  CoreDataDemoApp
//
//  Created by Aleksandr Kretov on 22.04.2022.
//

import UIKit

extension UIAlertController {
    
    //Create new UIAlertController with title
    
    static func createAlertController(withTitle title: String) -> UIAlertController {
        UIAlertController(title: title, message: "What do you want to do?", preferredStyle: .alert)
    }
    
    //Method to create UIAlertAction with desired task and title
    func action(task: ToDoTask?, actionTitle: String, completion: @escaping (String) -> Void) {
        let saveAction = UIAlertAction(title: actionTitle, style: .default) { _ in
            guard let newValue = self.textFields?.first?.text else { return }
            guard !newValue.isEmpty else { return }
            completion(newValue)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        addTextField { textField in
            textField.placeholder = "Task"
            textField.text = task?.title
        }
    }
}
