//
//  ContentView.swift
//  SafeCoreDataDemo
//
//  Created by Ujin Vel on 25.09.2021.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            List {
                Button(action: { viewModel.onNewItem = .init() }) {
                    Label("Add Item", systemImage: "plus")
                }
                
                ForEach(viewModel.items) { item in
                    let itemFormatter: DateFormatter = with(DateFormatter()) {
                        $0.dateStyle = .short
                        $0.timeStyle = .medium
                    }
                    Text("Item at \(item.timestamp, formatter: itemFormatter)")
                }
            }
            .navigationTitle("Items")
            .navigationBarTitleDisplayMode(.automatic)
        }
    }
}
