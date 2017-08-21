//
//  ViewController.swift
//  FetchResultController
//
//  Created by Chung Sama on 8/21/17.
//  Copyright © 2017 Chung Sama. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    
    var person: Person?
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        if let person = person {
            nameTextField.text = person.name
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide keybroad
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        updatePerson()
    }
    
    // MARK: Update data
    func updatePerson() {
        if let person = person {
            person.name = nameTextField.text ?? ""
            AppDelegate.shared.saveContext()
        }
        navigationController?.popViewController(animated: true)
    }
}
