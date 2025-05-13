//
//  ContentView.swift
//  AgroYouthAppApp
//
//  Created by Ezequiel Peña on 13/05/25.
//

import SwiftUI
import Foundation
struct ContentView: View {
    @StateObject var terrenoManager = TerrenoManager()

    // Ya no necesitas estos estados aquí si TerrenosListView los maneja:
    // @State private var showingFormulario = false
    // @State private var selectedTerrenoIdForDetail: UUID? = nil

    var body: some View {
        TabView {
                    // Pestaña 1: Inicio
                    InicioView()
                        .tabItem {
                            Label("Inicio", systemImage: "house.fill")
                        }

                    // Pestaña 2: Mis Terrenos
                    TerrenosListView(terrenoManager: terrenoManager)
                        .tabItem {
                            Label("Mis Terrenos", systemImage: "leaf.fill")
                        }

                    // Pestaña 3: Calendario de Actividades
                    PlanCalendarView(
                        terrenoManager: terrenoManager,
                        selectedTerreno: primerTerrenoConPlanParaCalendario()
                    )
                    .tabItem {
                        Label("Calendario", systemImage: "calendar")
                    }

                    // Pestaña 4: Aprende <--- NUEVA PESTAÑA
                    AprendeView()
                        .tabItem {
                            Label("Aprende", systemImage: "book.fill") // O "graduationcap.fill" o similar
                        }

                    // Pestaña 5: Marketplace (Placeholder por ahora)
                    Text("Marketplace (Próximamente)")
                        .tabItem {
                            Label("Marketplace", systemImage: "storefront.fill")
                        }

                    // Podrías considerar si "Mapa de Cultivos" sigue siendo una pestaña separada
                    // o se integra en otro lado. Por ahora, la mantenemos si así estaba.
                    Text("Mapa de Cultivos (Próximamente)")
                        .tabItem {
                            Label("Mapa", systemImage: "map.fill")
                        }
                }
                .environmentObject(terrenoManager)// Esto sigue siendo importante si otras vistas lo necesitan
    }
    
    // La función primerTerrenoConPlanParaCalendario() sigue siendo útil para la pestaña Calendario
    private func primerTerrenoConPlanParaCalendario() -> Terreno? {
        return terrenoManager.terrenos.first(where: { $0.planDeAccion != nil && !$0.planDeAccion!.isEmpty && $0.fechaInicioPlan != nil })
    }
    
    // Vista Placeholder para "Inicio"
    struct HomeViewPlaceholder: View {
        var body: some View {
            NavigationView { // O NavigationStack
                VStack {
                    Text("Bienvenido a AgroYouthApp")
                        .font(.largeTitle)
                    Text("Aquí verás tu dashboard y tutorial inicial.")
                        .font(.title3)
                        .foregroundColor(.gray)
                    // Aquí implementarías la lógica del tutorial y el dashboard
                    Spacer()
                }
                .navigationTitle("Inicio")
            }
        }
    }
    
    // Nueva vista para listar los terrenos y navegar a su detalle o al formulario
    struct MisTerrenosListView: View {
        @ObservedObject var terrenoManager: TerrenoManager
        @Binding var showingFormulario: Bool // Para presentar el formulario modalmente
        @Binding var selectedTerrenoIdForNavigation: UUID? // Para la navegación programática al detalle
        
        var body: some View {
            NavigationStack { // Cada pestaña que necesite navegación debe tener su propio NavigationStack
                List {
                    ForEach(terrenoManager.terrenos) { terreno in
                        // NavigationLink para ir al detalle de cada terreno
                        // Usamos el ID para la navegación basada en datos
                        NavigationLink(value: terreno.id) {
                            VStack(alignment: .leading) {
                                Text(terreno.nombre).font(.headline)
                                Text("Cultivo: \(terreno.tipoCultivo)").font(.subheadline)
                            }
                        }
                    }
                    .onDelete(perform: eliminarTerrenos) // Opcional: para permitir borrar terrenos
                }
                .navigationTitle("Mis Terrenos")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingFormulario = true // Activa la presentación modal de FormularioView
                        } label: {
                            Image(systemName: "plus.circle.fill")
                            Text("Añadir Terreno")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton() // Opcional: para habilitar el borrado en la lista
                    }
                }
                // Destino de navegación para cuando se selecciona un Terreno.ID
                .navigationDestination(for: UUID.self) { terrenoId in
                    TerrenoDetailView(terrenoManager: terrenoManager, terrenoId: terrenoId)
                }
                // Para la navegación programática si selectedTerrenoIdForNavigation se establece
                // (por ejemplo, después de crear un nuevo terreno en FormularioView si no se usara sheet)
                // .background(
                //     NavigationLink(
                //         destination: Group {
                //             if let id = selectedTerrenoIdForNavigation {
                //                 TerrenoDetailView(terrenoManager: terrenoManager, terrenoId: id)
                //             }
                //         },
                //         tag: selectedTerrenoIdForNavigation ?? UUID(), // Un tag que coincida cuando no es nil
                //         selection: $selectedTerrenoIdForNavigation,
                //         label: { EmptyView() }
                //     )
                // )
                .onAppear {
                    // Si selectedTerrenoIdForNavigation se usara para activar navegación DESPUÉS de un sheet
                    // if selectedTerrenoIdForNavigation != nil {
                    //    // Lógica para resetearlo o manejar la navegación
                    // }
                }
            }
        }
        
        private func eliminarTerrenos(at offsets: IndexSet) {
            // Encuentra los IDs de los terrenos a eliminar basados en los offsets
            let idsAEliminar = offsets.map { terrenoManager.terrenos[$0].id }
            // Filtra el array de terrenos para remover aquellos con los IDs seleccionados
            terrenoManager.terrenos.removeAll { terreno in
                idsAEliminar.contains(terreno.id)
            }
        }
    }
    
    
    
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            //.environmentObject(TerrenoManager()) // Proveer el manager para el preview
    }
}
