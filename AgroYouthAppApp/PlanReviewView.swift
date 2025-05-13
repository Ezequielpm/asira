//
//  PlanReviewView.swift
//  AgroYouthAppApp
//
//  Created by Ezequiel Peña on 13/05/25.
//

import SwiftUI

struct PlanReviewView: View {
    let cultivoName: String
    @Binding var tasks: [TaskItem] // Tareas generadas, se pueden revisar aquí
    
    // Estado para la fecha de inicio del plan seleccionada por el usuario
    @State private var fechaInicioSeleccionada: Date = Date() // Por defecto hoy

    // Callback modificado para pasar la fecha de inicio cuando se guarda
    var onSaveWithStartDate: (Date) -> Void
    var onCancel: () -> Void      // Callback para cuando se cancela
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView { // Para tener barra de título y botones de la sheet
            VStack(spacing: 0) { // Ajustado el spacing general del VStack
                
                // Sección para SELECCIONAR FECHA DE INICIO del plan
                Section { // Usamos Section para agrupar visualmente
                    DatePicker(
                        "Fecha de Inicio del Plan:",
                        selection: $fechaInicioSeleccionada,
                        in: Date()..., // Opcional: Solo permitir fechas desde hoy en adelante
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical) // O .compact si prefieres menos espacio
                    .padding(.horizontal) // Padding para el DatePicker
                    .padding(.vertical, 10) // Espacio vertical
                } header: { // Encabezado para la sección del DatePicker
                    Text("Establecer Inicio del Plan")
                        .font(.headline)
                        .padding(.top) // Espacio arriba del encabezado
                        .frame(maxWidth: .infinity, alignment: .leading) // Alineación
                        .padding(.horizontal) // Padding horizontal para el encabezado
                }
                
                // Lista de Tareas para Revisión
                List {
                    Section(header: Text("Tareas Propuestas para \(cultivoName)").font(.title3).padding(.top)) {
                        if tasks.isEmpty {
                            Text("No se generaron tareas para este plan. Puedes intentar de nuevo o añadir manualmente.")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach($tasks) { $task in // Usamos $task para poder modificar isCompleted si quisiéramos
                                VStack(alignment: .leading) {
                                    Text(task.text)
                                        .lineLimit(nil) // Permitir múltiples líneas si el texto es largo
                                    
                                    // Mostrar los días relativos si existen
                                    if let dias = task.diasDesdeInicio {
                                        Text("Estimado para: Día \(dias) del plan")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 4) // Pequeño padding vertical para cada tarea
                                // En esta vista de "revisión", no permitimos marcar como completada.
                                // Eso se hará en la vista de "seguimiento".
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle()) // Estilo de lista

                // Botones de Acción
                HStack(spacing: 20) {
                    Button("Cancelar") {
                        onCancel()
                        dismiss()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                    .shadow(radius: 2, y: 1)

                    Button("Guardar Plan y Agendar") { // Texto del botón actualizado
                        onSaveWithStartDate(fechaInicioSeleccionada) // Pasa la fecha seleccionada
                        dismiss()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .cornerRadius(10)
                    .shadow(radius: 2, y: 1)
                }
                .padding() // Padding para el HStack de botones
            }
            .navigationTitle("Revisar y Agendar Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { // Cambiado a trailing para consistencia con "Cerrar"
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PlanReviewView_Previews: PreviewProvider {
    static var previews: some View {
        // Datos de ejemplo para el preview
        @State var sampleTasks = [
            TaskItem(text: "Preparar el semillero con sustrato de buena calidad y asegurar un buen drenaje.", diasDesdeInicio: 0),
            TaskItem(text: "Sembrar las semillas de fresa a una profundidad de 0.5 cm, cubriéndolas ligeramente.", diasDesdeInicio: 1),
            TaskItem(text: "Mantener el sustrato húmedo pero no encharcado hasta la germinación (aprox. 2-3 semanas).", diasDesdeInicio: 1),
            TaskItem(text: "Trasplantar las plántulas a macetas individuales o al lugar definitivo cuando tengan 3-4 hojas verdaderas.", diasDesdeInicio: 21)
        ]
        
        PlanReviewView(
            cultivoName: "Fresa Ejemplo",
            tasks: $sampleTasks,
            onSaveWithStartDate: { startDate in
                print("Preview: Plan Guardado con fecha de inicio: \(startDate)")
                // Simular la asignación de dueDates para el preview si se quisiera
                for i in sampleTasks.indices {
                    if let dias = sampleTasks[i].diasDesdeInicio {
                        sampleTasks[i].dueDate = Calendar.current.date(byAdding: .day, value: dias, to: startDate)
                    }
                }
            },
            onCancel: {
                print("Preview: Plan Cancelado")
            }
        )
    }
}
