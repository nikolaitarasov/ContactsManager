//
//  Contact.swift
//  ContactsManager
//
//  Created by Mykola Tarasov on 4/28/21.
//

import Foundation

struct Contact {
    var firstName: String
    var lastName: String
    var picture: String
    var email: String

    init(firstName: String, lastName: String, picture: String, email: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.picture = picture
        self.email = email
    }
}
