//
//  PlanTrackingView.swift
//  AgroYouthAppApp
//
//  Created by Ezequiel Peña on 13/05/25.
//

import SwiftUI

struct PlanTrackingView: View {
    let cultivoName: String
    // Para el seguimiento, es probable que las tareas vengan de un @ObservedObject
    // que represente el Terreno, pero para este ejemplo lo pasamos con @Binding.
    // En la integración final, esto podría ser `let tasks: [TaskItem]` si la vista es de solo lectura
    // o si los cambios se guardan directamente en el modelo del terreno.
    @Binding var tasks: [TaskItem]
    
    // Callback para cuando se actualiza el estado de una tarea (para guardar en el modelo del terreno)
    var onTaskUpdate: (TaskItem) -> Void

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView { // Para tener barra de título
            VStack {
                if tasks.isEmpty {
                    Text("Este plan aún no tiene tareas asignadas.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        Section(header: Text("Seguimiento del Plan para \(cultivoName)").font(.title2).padding(.vertical)) {
                            ForEach($tasks) { $task in
                                HStack {
                                    Text(task.text)
                                    Spacer()
                                    Image(systemName: task.isCompleted ? "checkmark.square.fill" : "square")
                                        .resizable()
                                        .frame(width: 22, height: 22)
                                        .foregroundColor(task.isCompleted ? .green : .gray)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    task.isCompleted.toggle()
                                    onTaskUpdate(task) // Notificar que una tarea se actualizó
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Seguimiento de Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PlanTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        @State var sampleTasks = [
            TaskItem(text: "Tarea guardada 1", isCompleted: false),
            TaskItem(text: "Tarea guardada 2", isCompleted: true)
        ]
        PlanTrackingView(cultivoName: "Maíz Guardado", tasks: $sampleTasks, onTaskUpdate: { updatedTask in
            print("Tarea actualizada: \(updatedTask.text), completada: \(updatedTask.isCompleted)")
        })
    }
}
