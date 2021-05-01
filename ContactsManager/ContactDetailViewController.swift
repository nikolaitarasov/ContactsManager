//
//  ContactDetailViewController.swift
//  ContactsManager
//
//  Created by Mykola Tarasov on 4/29/21.
//

import UIKit

class ContactDetailViewController: UIViewController, UITextFieldDelegate {
    var contact: Contact!
    var saveButton: UIBarButtonItem!
    let segueId = "backToTableView"
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self

        if let url = URL(string: contact.picture),
           let data = try? Data(contentsOf: url) {
            picture.image = UIImage(data: data)
        }

        firstNameTextField.text = contact.firstName
        lastNameTextField.text = contact.lastName
        emailTextField.text = contact.email

        saveButton = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.saveContact))
        saveButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = saveButton
    }

    @objc func saveContact() {
        saveButton.isEnabled = false
        if let firstName = firstNameTextField.text,
           let lastName = lastNameTextField.text,
           let email = emailTextField.text {
            contact.firstName = firstName
            contact.lastName = lastName
            contact.email = email
        }
        let sqliteDB = SqliteDbManager()
        sqliteDB.update(contact: self.contact)
        self.performSegue(withIdentifier: segueId, sender: self)
    }

    @IBAction func deleteButtonPressed() {
        let sqliteDb = SqliteDbManager()
        sqliteDb.delete(contact: contact)
        self.performSegue(withIdentifier: segueId, sender: self)
    }
    
    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
        guard let updatedText = textField.text else {
            return
        }
        if textField.placeholder == "FirstName" {
            contact.firstName = updatedText
        } else if textField.placeholder == "LastName" {
            contact.lastName = updatedText
        } else if textField.placeholder == "EmailAddress" {
            contact.email = updatedText
        }
        let sqliteDB = SqliteDbManager()
        sqliteDB.update(contact: contact)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            //string is used here as the value of the textField.
            //This will be called after every user input in the textField
        return true
    }
}
