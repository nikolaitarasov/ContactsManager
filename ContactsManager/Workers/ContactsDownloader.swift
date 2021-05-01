//
//  ContactsDownloader.swift
//  ContactsManager
//
//  Created by Mykola Tarasov on 4/28/21.
//

import Foundation

struct ContactsDownloader {
    let endpoint = "https://randomuser.me/api/?inc=name,email,picture&results=20"

    func contactsData(with completionHandler: @escaping () -> Void) {
        let url = URL(string: endpoint)
        let task = URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
            if let error = error {
                print(error)
                completionHandler()
                return
            }
            if let data = data {
                let contacts = self.parseJsonData(data)
                let sqliteDb = SqliteDbManager()
                for contact in contacts {
                    sqliteDb.create(contact: contact)
                }
            }
            completionHandler()
        })
        task.resume()
    }

    func parseJsonData(_ data: Data) -> [Contact] {
     
        var contacts = [Contact]()
     
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
     
            // Parse JSON data
            let jsonResults = jsonResult?["results"] as! [AnyObject]
            for result in jsonResults {
                let name = result["name"] as! [String: String]
                let firstName = name["first"]!
                let lastName = name["last"]!
                let pictures = result["picture"] as! [String: String]
                let picture = pictures["large"]!
                let email = result["email"] as! String
                contacts.append(Contact(firstName: firstName, lastName: lastName, picture: picture, email: email))
            }
     
        } catch {
            print(error)
        }
     
        return contacts
    }
}

extension Notification.Name {
    static let contactsDidDownload = Notification.Name("contactsDidDownload")
}
