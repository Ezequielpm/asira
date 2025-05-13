import SwiftUI

struct TerrenosListView: View {
    @ObservedObject var terrenoManager: TerrenoManager

    // AÑADE ESTOS ESTADOS para la navegación y el sheet:
    @State private var showingFormulario = false
    @State private var selectedTerrenoIdForDetail: UUID? = nil // Para la navegación
    @State private var navigateToDetailView = false // Para activar el NavigationLink

    private let rowBgColor: Color = .green.opacity(0.1)

    var body: some View {
        // Asegúrate de que esté dentro de un NavigationStack si aún no lo está.
        // Si ContentView ya provee un NavigationStack para esta pestaña, podrías quitar este.
        // Por ahora, lo mantenemos para que la vista sea autónoma.
        NavigationStack { // <--- CAMBIO A NavigationStack (más moderno)
            List {
                Section(header: Text("Mis Cultivos") // Puedes cambiarlo a "Mis Terrenos"
                    .font(.headline)
                    .foregroundColor(.green)
                ) {
                    ForEach(terrenoManager.terrenos) { terreno in
                        // ENVUELVE EL HStack EN UN NavigationLink O USA UN BOTÓN QUE MODIFIQUE selectedTerrenoIdForDetail
                        // Opción 1: NavigationLink directo (más simple si el diseño lo permite)
                        NavigationLink(destination: TerrenoDetailView(terrenoManager: terrenoManager, terrenoId: terreno.id)) {
                            HStack(spacing: 16) {
                                Image(imageNameForCultivo(terreno.tipoCultivo))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.green)
                                
                                Text(terreno.nombre)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            // No necesitas el .contentShape(Rectangle()) y .onTapGesture si usas NavigationLink directo
                        }
                        .listRowBackground(rowBgColor)
                        
                        // Opción 2: Mantener el botón y navegar programáticamente (más control si el diseño es complejo)
                        // Lo dejaremos con NavigationLink por simplicidad por ahora.
                    }
                    .onDelete(perform: deleteTerrenos)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Mis Terrenos") // Título
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    // MODIFICA EL BOTÓN DE AÑADIR:
                    Button(action: {
                        showingFormulario = true // Activa la presentación del sheet
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            // AÑADE EL SHEET PARA EL FORMULARIO:
            .sheet(isPresented: $showingFormulario) {
                // Presenta FormularioView modalmente
                // Asegúrate que tu FormularioView pueda ser inicializado así.
                FormularioView(terrenoManager: terrenoManager)
            }
        }
    }

    // (La función imageNameForCultivo debe estar aquí o ser accesible globalmente)
    private func imageNameForCultivo(_ tipoCultivo: String) -> String {
        let cultivoNormalizado = tipoCultivo.lowercased()
        if cultivoNormalizado.contains("maíz") || cultivoNormalizado.contains("maiz") { return "maiz" }
        if cultivoNormalizado.contains("tomate") || cultivoNormalizado.contains("jitomate") { return "tomate" }
        if cultivoNormalizado.contains("papa") { return "papa" }
        if cultivoNormalizado.contains("fresa") { return "fresa" }
        // Añade aquí más mapeos si los necesitas para las imágenes que usa tu compañero
        if cultivoNormalizado.contains("zanahoria") { return "zanahoria" } // Ejemplo
        return "campo_default"
    }

    private func deleteTerrenos(at offsets: IndexSet) {
        let idsAEliminar = offsets.map { terrenoManager.terrenos[$0].id }
        // Esta es una forma de hacerlo, asegúrate que actualiza la UI correctamente.
        // Podrías necesitar llamar a una función en TerrenoManager si tienes lógica adicional allí.
        terrenoManager.terrenos.removeAll { terreno in
            idsAEliminar.contains(terreno.id)
        }
    }
}

struct TerrenosListView_Previews: PreviewProvider {
    static var previews: some View {
        // Crear una instancia de TerrenoManager para el preview
        let manager = TerrenoManager()
        // Opcional: Añadir algunos terrenos de ejemplo al manager si está vacío por defecto
        // if manager.terrenos.isEmpty {
        // manager.addTerreno(nombre: "Maíz Preview", tipoCultivo: "Maíz", tipoSuelo: "Arenoso", dimension: "1ha")
        // manager.addTerreno(nombre: "Tomate Preview", tipoCultivo: "Tomate", tipoSuelo: "Limoso", dimension: "500m2")
        // }
        TerrenosListView(terrenoManager: manager)
    }
}
