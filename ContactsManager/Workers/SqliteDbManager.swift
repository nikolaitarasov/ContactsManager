//
//  SqliteDBManager.swift
//  ContactsManager
//
//  Created by Mykola Tarasov on 4/28/21.
//

import Foundation
import SQLite3
import os.log

class SqliteDbManager {
    let dbURL: URL
    var db: OpaquePointer?
    var insertEntryStmt: OpaquePointer?
    var readEntryStmt: OpaquePointer?
    var updateEntryStmt: OpaquePointer?
    var deleteEntryStmt: OpaquePointer?

    init() {
        do {
            do {
                dbURL = try FileManager.default
                    .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    .appendingPathComponent("contacts13.db")
                os_log("URL: %s", dbURL.absoluteString)
            } catch {
                //TODO: Just logging the error and returning empty path URL here. Handle the error gracefully after logging
                os_log("Some error occurred. Returning empty path.")
                dbURL = URL(fileURLWithPath: "")
                return
            }
            
            try openDB()
            try createTables()
            } catch {
                //TODO: Handle the error gracefully after logging
                os_log("Some error occurred. Returning.")
                return
            }
    }
    
    func openDB() throws {
        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            os_log("error opening database at %s", dbURL.absoluteString)
            throw SqliteError(message: "error opening database \(dbURL.absoluteString)")
        }
    }
    
    func createTables() throws {
        let ret =  sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Contacts (id INTEGER UNIQUE PRIMARY KEY AUTOINCREMENT, FirstName TEXT NOT NULL, LastName TEXT NOT NULL, Picture TEXT NOT NULL, Email TEXT NOT NULL)", nil, nil, nil)
        if (ret != SQLITE_OK) {
            logDbErr("Error creating db table - Contacts")
            throw SqliteError(message: "unable to create table Contacts")
        }
        
    }
    
    func logDbErr(_ msg: String) {
        let errmsg = String(cString: sqlite3_errmsg(db)!)
        os_log("ERROR %s : %s", msg, errmsg)
    }
}

struct SqliteError: Error {
    var message = ""
    var error = SQLITE_ERROR

    init(message: String = "") {
        self.message = message
    }

    init(error: Int32) {
        self.error = error
    }
}
