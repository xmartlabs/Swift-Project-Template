//
//  RealmManager.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2016 'XLOrganizationName'. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics
import RealmSwift

class RealmManager {

    static let sharedInstance = RealmManager()

    fileprivate(set) var defaultRealm: Realm!

    fileprivate var config = Realm.Configuration()

    fileprivate init() {
//        config.schemaVersion = 1
//        config.migrationBlock = { migration, oldSchemaVersion in
//             Perform migrations when needed
//            if oldSchemaVersion == 1 {
//                 ...
//            }
//        }

        do {
            defaultRealm = try Realm(configuration: config)
            DEBUGLog("Realm DB path: \(String(describing: config.fileURL))")
        } catch {
            let nserror = error as NSError
            Crashlytics.sharedInstance().recordError(nserror)
        }
    }

    func eraseAll() {
        do {
            let realm = try createRealm()
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            let nserror = error as NSError
            Crashlytics.sharedInstance().recordError(nserror)
        }
    }

    func createRealm() throws -> Realm {
        return try Realm(configuration: config)
    }

}

extension Object {

    fileprivate func realmInst() -> Realm {
        return self.realm ?? RealmManager.sharedInstance.defaultRealm
    }

    /** Must be called from main thread */
    func save(_ update: Bool = true) throws {
        let realm = self.realmInst()
        try realm.write() {
            realm.add(self, update: update)
        }
    }

    /** Must be called from main thread */
    static func save(_ objects: [Object], update: Bool = true) throws {
        guard let first = objects.first else {
            return
        }
        let realm = first.realmInst()
        try realm.write() {
            objects.forEach() { realm.add($0, update: update) }
        }
    }
    
}
