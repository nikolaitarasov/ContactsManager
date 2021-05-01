//
//  SqliteDbManager+Crud.swift
//  ContactsManager
//
//  Created by Mykola Tarasov on 4/28/21.
//

import Foundation
import SQLite3

extension SqliteDbManager {

    func create(contact: Contact) {
        guard self.prepareInsertEntryStmt() == SQLITE_OK else { return }
        
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.insertEntryStmt)
        }
        
        //Inserting firstName in insertEntryStmt prepared statement
        if sqlite3_bind_text(self.insertEntryStmt, 1, (contact.firstName as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertEntryStmt)")
            return
        }
        
        //Inserting lastName in insertEntryStmt prepared statement
        if sqlite3_bind_text(self.insertEntryStmt, 2, (contact.lastName as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertEntryStmt)")
            return
        }
        
        //Inserting picture in insertEntryStmt prepared statement
        if sqlite3_bind_text(self.insertEntryStmt, 3, (contact.picture as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertEntryStmt)")
            return
        }

        //Inserting email in insertEntryStmt prepared statement
        if sqlite3_bind_text(self.insertEntryStmt, 4, (contact.email as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(insertEntryStmt)")
            return
        }
        
        //executing the query to insert values
        let r = sqlite3_step(self.insertEntryStmt)
        if r != SQLITE_DONE {
            logDbErr("sqlite3_step(insertEntryStmt) \(r)")
            return
        }
    }
    
    func readAllContacts() throws -> [Contact] {
        // ensure statements are created on first usage if nil
        guard self.prepareReadAllEntriesStmt() == SQLITE_OK else { throw SqliteError(message: "Error in prepareReadEntryStmt") }
        
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.readEntryStmt)
        }
        
        var contacts = [Contact]()
        //traversing through all the contacts
        while(sqlite3_step(readEntryStmt) == SQLITE_ROW){
            let firstName = String(cString: sqlite3_column_text(readEntryStmt, 1))
            let lastName = String(cString: sqlite3_column_text(readEntryStmt, 2))
            let picture = String(cString: sqlite3_column_text(readEntryStmt, 3))
            let email = String(cString: sqlite3_column_text(readEntryStmt, 4))
 
            contacts.append(Contact(firstName: firstName, lastName: lastName, picture: picture, email: email))
        }
        
        return contacts
    }

    func update(contact: Contact) {
        // ensure statements are created on first usage if nil
        guard self.prepareUpdateEntryStmt() == SQLITE_OK else { return }
        
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.updateEntryStmt)
        }
        
        //Inserting firstName in updateEntryStmt prepared statement
        if sqlite3_bind_text(self.updateEntryStmt, 1, (contact.firstName as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateEntryStmt)")
            return
        }
        
        //Inserting lastName in updateEntryStmt prepared statement
        if sqlite3_bind_text(self.updateEntryStmt, 2, (contact.lastName as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateEntryStmt)")
            return
        }

        //Inserting email in updateEntryStmt prepared statement
        if sqlite3_bind_text(self.updateEntryStmt, 3, (contact.email as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateEntryStmt)")
            return
        }

        //Inserting picture in updateEntryStmt prepared statement
        if sqlite3_bind_text(self.updateEntryStmt, 4, (contact.picture as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(updateEntryStmt)")
            return
        }
        
        //executing the query to update values
        let r = sqlite3_step(self.updateEntryStmt)
        if r != SQLITE_DONE {
            logDbErr("sqlite3_step(updateEntryStmt) \(r)")
            return
        }
    }
    
    func delete(contact: Contact) {
        guard self.prepareDeleteEntryStmt() == SQLITE_OK else { return }
        
        defer {
            sqlite3_reset(self.deleteEntryStmt)
        }

        //Inserting email in deleteEntryStmt prepared statement
        if sqlite3_bind_text(self.deleteEntryStmt, 1, (contact.email as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(deleteEntryStmt)")
            return
        }
        
        //executing the query to delete row
        let r = sqlite3_step(self.deleteEntryStmt)
        if r != SQLITE_DONE {
            logDbErr("sqlite3_step(deleteEntryStmt) \(r)")
            return
        }
    }
    
    func prepareInsertEntryStmt() -> Int32 {
        guard insertEntryStmt == nil else { return SQLITE_OK }
        let sql = "INSERT INTO Contacts (FirstName, LastName, Picture, Email) VALUES (?,?,?,?)"
        //preparing the query
        let r = sqlite3_prepare(db, sql, -1, &insertEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare insertEntryStmt")
        }
        return r
    }
    
    func prepareReadAllEntriesStmt() -> Int32 {
        guard readEntryStmt == nil else { return SQLITE_OK }
        let sql = "SELECT * FROM Contacts"
        //preparing the query
        let r = sqlite3_prepare(db, sql, -1, &readEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare readEntryStmt")
        }
        return r
    }
    
    func prepareUpdateEntryStmt() -> Int32 {
        guard updateEntryStmt == nil else { return SQLITE_OK }
        let sql = "UPDATE Contacts SET FirstName = ?, LastName = ?, Email = ? WHERE Picture = ?"
        //preparing the query
        let r = sqlite3_prepare(db, sql, -1, &updateEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare updateEntryStmt")
        }
        return r
    }
    
    func prepareDeleteEntryStmt() -> Int32 {
        guard deleteEntryStmt == nil else { return SQLITE_OK }
        let sql = "DELETE FROM Contacts WHERE Email = ?"
        //preparing the query
        let r = sqlite3_prepare(db, sql, -1, &deleteEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare deleteEntryStmt")
        }
        return r
    }
}
