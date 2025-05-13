//
//  AgroYouthAppAppApp.swift
//  AgroYouthAppApp
//
//  Created by Ezequiel Peña on 13/05/25.
//
//
//  AgroYouthAppAppApp.swift
//  AgroYouthAppApp
//
//  Created by Ezequiel Peña on 13/05/25.
//

// AgroYouthAppApp.swift

import SwiftUI

@main
struct AgroYouthAppAppApp: App {
    // Crear una instancia del TerrenoManager que se compartirá
    @StateObject var terrenoManager = TerrenoManager()

    var body: some Scene {
        WindowGroup {
            // Ejemplo: Si FormularioView es la vista inicial o una pestaña principal
            // Necesitas pasar el terrenoManager.
            // Aquí está cómo lo harías si ContentView es tu TabView principal.
            ContentView()
                .environmentObject(terrenoManager) // Hacerlo disponible para todas las sub-vistas
            
            // Si FormularioView fuera tu vista inicial directa:
            // FormularioView(terrenoManager: terrenoManager)
        }
    }
}
