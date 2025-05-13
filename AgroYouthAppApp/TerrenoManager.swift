//
//  TerrenoManager.swift
//  AgroYouthAppApp
//
//  Created by Ezequiel Peña on 13/05/25.
//

import Foundation
import SwiftUI

class TerrenoManager: ObservableObject {
    @Published var terrenos: [Terreno] = [
        // Terrenos de ejemplo si quieres
        Terreno(nombre: "Parcela Norte", tipoCultivo: "Maíz", tipoSuelo: "Arcilloso", dimension: "100x50m", planDeAccion: nil),
        Terreno(nombre: "Huerto Casero", tipoCultivo: "Tomate", tipoSuelo: "Franco", dimension: "10x5m", planDeAccion: [TaskItem(text: "Regar tomates", isCompleted: false)])
    ]

    // Modificar addTerreno si quieres añadir fecha de inicio desde el formulario
       func addTerreno(nombre: String, tipoCultivo: String, tipoSuelo: String, dimension: String) -> Terreno {
           let nuevoTerreno = Terreno(nombre: nombre, tipoCultivo: tipoCultivo, tipoSuelo: tipoSuelo, dimension: dimension)
           terrenos.append(nuevoTerreno)
           return nuevoTerreno
       }

    // Modificar updatePlan para usar la fecha de inicio
    // En TerrenoManager.swift
    func updatePlan(forTerrenoID id: UUID, newPlanTasks: [TaskItem], fechaInicio: Date) { // <--- VERIFICA ESTOS NOMBRES
        if let index = terrenos.firstIndex(where: { $0.id == id }) {
            terrenos[index].fechaInicioPlan = fechaInicio
            var tasksConFechasAbsolutas: [TaskItem] = []
            for var task in newPlanTasks {
                if let dias = task.diasDesdeInicio {
                    task.dueDate = Calendar.current.date(byAdding: .day, value: dias, to: fechaInicio)
                }
                tasksConFechasAbsolutas.append(task)
            }
            terrenos[index].planDeAccion = tasksConFechasAbsolutas
        }
    }
    
    func updateTaskInPlan(forTerrenoID terrenoId: UUID, taskToUpdate: TaskItem) {
        guard let terrenoIndex = terrenos.firstIndex(where: { $0.id == terrenoId }),
              var plan = terrenos[terrenoIndex].planDeAccion, // hacerla var para modificar
              let taskIndex = plan.firstIndex(where: { $0.id == taskToUpdate.id }) else {
            return
        }
        plan[taskIndex] = taskToUpdate
        terrenos[terrenoIndex].planDeAccion = plan
    }
    
    
    
    // NUEVA FUNCIÓN: Obtener tareas para un rango de fechas (para el calendario)
        func tasks(for date: Date, in terreno: Terreno?) -> [TaskItem] {
            guard let plan = terreno?.planDeAccion else { return [] }
            return plan.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return Calendar.current.isDate(dueDate, inSameDayAs: date)
            }
        }
        
        // NUEVA FUNCIÓN: Obtener tareas para un mes (para saber qué días resaltar)
        func tasks(forMonthOf date: Date, in terreno: Terreno?) -> [TaskItem] {
            guard let plan = terreno?.planDeAccion else { return [] }
            let calendar = Calendar.current
            guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return [] }
            
            return plan.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return monthInterval.contains(dueDate)
            }
        }
    // Puedes añadir más funciones aquí (eliminar, obtener terreno por ID, etc.)
}
