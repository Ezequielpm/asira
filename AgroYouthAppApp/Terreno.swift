// Terreno.swift
import Foundation

struct Terreno: Identifiable, Codable {
    let id: UUID
    var nombre: String
    var tipoCultivo: String
    var tipoSuelo: String
    var dimension: String
    var planDeAccion: [TaskItem]?
    var fechaInicioPlan: Date? = nil // <--- NUEVO

    init(id: UUID = UUID(), nombre: String, tipoCultivo: String, tipoSuelo: String, dimension: String, planDeAccion: [TaskItem]? = nil, fechaInicioPlan: Date? = nil) {
        self.id = id
        self.nombre = nombre
        self.tipoCultivo = tipoCultivo
        self.tipoSuelo = tipoSuelo
        self.dimension = dimension
        self.planDeAccion = planDeAccion
        self.fechaInicioPlan = fechaInicioPlan // <--- NUEVO
    }
}
