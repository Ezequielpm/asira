//
//  PlanDetailView.swift
//  AgroYouthAppApp
//
//  Created by Ezequiel Peña on 13/05/25.
//

import SwiftUI

struct PlanDetailView: View {
    let cultivoName: String
    @Binding var tasks: [TaskItem] // Usamos @Binding para que los cambios aquí se reflejen en ChatViewWithTasks

    @Environment(\.dismiss) var dismiss // Para poder cerrar esta vista

    var body: some View {
        NavigationView { // O NavigationStack si prefieres y tu min OS target lo permite
            List {
                Section(header: Text("Plan de Actividades para \(cultivoName)").font(.title2).padding(.vertical)) {
                    if tasks.isEmpty {
                        Text("No hay tareas en este plan todavía.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach($tasks) { $task in // $ para binding
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
                                // Aquí puedes añadir lógica para guardar el estado si es necesario
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            // .navigationTitle("Detalle del Plan") // Título alternativo
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

// Preview para PlanDetailView (opcional pero útil)
struct PlanDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Creamos datos de ejemplo para el preview
        @State var sampleTasks = [
            TaskItem(text: "Arar la tierra profundamente.", isCompleted: false),
            TaskItem(text: "Realizar análisis de suelo.", isCompleted: true),
            TaskItem(text: "Aplicar composta orgánica.", isCompleted: false)
        ]
        
        PlanDetailView(cultivoName: "Tomate Ejemplo", tasks: $sampleTasks)
    }
}
