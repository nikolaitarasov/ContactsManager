//
//  ContactsTableViewController.swift
//  ContactsManager
//
//  Created by Mykola Tarasov on 4/28/21.
//

import UIKit

class ContactsTableViewController: UITableViewController {
    var contacts = [Contact]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.readAllContacts()
        
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        let contact = contacts[indexPath.row]
        // set first and last name
        let fullName = "\(contact.firstName) \(contact.lastName)"
        cell.textLabel?.text = fullName

        // set picture
        if let url = URL(string: contact.picture),
           let data = try? Data(contentsOf: url) {
            cell.imageView?.image = UIImage(data: data)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "ContactDetailViewController") as! ContactDetailViewController
        destination.contact = contacts[indexPath.row]
        navigationController?.pushViewController(destination, animated: true)
    }

    private func readAllContacts() {
        let sqliteDb = SqliteDbManager()
        do {
            contacts = try sqliteDb.readAllContacts()
        } catch let error {
            print(error.localizedDescription)
        }
        if contacts.count == 0 {
            let downloader = ContactsDownloader()
            downloader.contactsData(with: {
                do {
                    self.contacts = try sqliteDb.readAllContacts()
                } catch let error {
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let sqliteDb = SqliteDbManager()
            sqliteDb.delete(contact: contacts[indexPath.row])
            contacts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }

    // MARK: - Navigation

    @IBAction func unwindToTableView(segue: UIStoryboardSegue) {
        readAllContacts()
        self.tableView.reloadData()
    }
}
