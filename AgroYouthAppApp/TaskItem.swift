// TaskItem.swift
import Foundation // Para Date

struct TaskItem: Identifiable, Equatable, Codable {
    let id: UUID
    var text: String
    var isCompleted: Bool = false
    var dueDate: Date? = nil // Fecha de vencimiento específica
    var diasDesdeInicio: Int? = nil // Para calcular dueDate a partir de una fecha de inicio del plan

    // Inicializador para cuando la IA no da fechas, o para parseo
    init(id: UUID = UUID(), text: String, isCompleted: Bool = false, dueDate: Date? = nil, diasDesdeInicio: Int? = nil) {
        self.id = id
        self.text = text
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.diasDesdeInicio = diasDesdeInicio
    }
}
