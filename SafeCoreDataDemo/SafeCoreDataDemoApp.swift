//
//  SafeCoreDataDemoApp.swift
//  SafeCoreDataDemo
//
//  Created by Ujin Vel on 25.09.2021.
//

import SwiftUI

@main
struct SafeCoreDataDemoApp: App {
    //let persistenceController = PersistenceController.shared
    var body: some Scene {
        let database = Database.shared
        database.load { error in print(error?.localizedDescription ?? "") }
        
        let viewModel = ViewModel(database: database)
        
        return WindowGroup {
            ContentView().environmentObject(viewModel)
        }
    }
}
