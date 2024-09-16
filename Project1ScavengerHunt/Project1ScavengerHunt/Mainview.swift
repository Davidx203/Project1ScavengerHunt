//
//  ContentView.swift
//  Project1ScavengerHunt
//
//  Created by David Perez on 9/14/24.
//
import SwiftUI

import SwiftUI

class TaskModel: ObservableObject, Identifiable {
    let id = UUID()  // Unique identifier for each task
    var name: String
    var completed: Bool
    var description: String
    var photo: UIImage?

    init(name: String, completed: Bool, description: String, photo: UIImage? = nil) {
        self.name = name
        self.completed = completed
        self.description = description
        self.photo = photo
    }
}

struct ContentView: View {
    @State private var selectedTask: TaskModel = TaskModel(name: "", completed: false, description: "")
    @State private var isDetailViewPresented = false
    
    @StateObject private var task1 = TaskModel(name: "Your favorite statue", completed: false, description: "What statue amazed you the most?")
    @StateObject private var task2 = TaskModel(name: "Your favorite bridge", completed: false, description: "Bridges make connection, so show your favorite bridge")
    @StateObject private var task3 = TaskModel(name: "Your favorite building", completed: false, description: "The best architecture building")
    @StateObject private var task4 = TaskModel(name: "Your favorite beach", completed: false, description: "Show where you find the best sand")

    var body: some View {
        NavigationStack {
            VStack {
                Text("Photo Scavenger Hunt")
                    .font(.headline)
                Rectangle()
                    .frame(height: 1)
                    .tint(.gray)
                
                Button(action: {
                    selectedTask = task1
                    isDetailViewPresented = true
                }, label: {
                    HStack {
                        Text("\(task1.name)")
                        Spacer()
                        Image(systemName: "circle")
                    }
                })
                
                Rectangle()
                    .frame(height: 1)
                    .tint(.gray)
                
                Button(action: {
                    selectedTask = task2
                    isDetailViewPresented = true
                }, label: {
                    HStack {
                        Text("\(task2.name)")
                        Spacer()
                        Image(systemName: "circle")
                    }
                })
                
                Rectangle()
                    .frame(height: 1)
                    .tint(.gray)
                
                Button(action: {
                    selectedTask = task3
                    isDetailViewPresented = true
                }, label: {
                    HStack {
                        Text("\(task3.name)")
                        Spacer()
                        Image(systemName: "circle")
                    }
                })
                
                Rectangle()
                    .frame(height: 1)
                    .tint(.gray)
                
                Button(action: {
                    selectedTask = task4
                    isDetailViewPresented = true
                }, label: {
                    HStack {
                        Text("\(task4.name)")
                        Spacer()
                        Image(systemName: "circle")
                    }
                })
                
                Rectangle()
                    .frame(height: 1)
                    .tint(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationDestination(isPresented: $isDetailViewPresented) {
                TaskDetailView(task: $selectedTask)
            }
        }
    }
}


#Preview {
    ContentView()
}
