import SwiftUI

struct TerrenoDetailView: View {
    // Usamos @ObservedObject porque TerrenoManager es una clase que maneja nuestros datos.
    // Este manager DEBE ser inyectado desde la vista que navega aquí (FormularioView o una lista de terrenos).
    @ObservedObject var terrenoManager: TerrenoManager
    let terrenoId: UUID // El ID del terreno específico que esta vista mostrará

    // Propiedad computada para obtener el terreno actual del manager de forma segura
    var terreno: Terreno? {
        terrenoManager.terrenos.first(where: { $0.id == terrenoId })
    }
    
    // Estado para presentar el chat modalmente
    @State private var showingChatView = false
    
    
    // Función para obtener el nombre de la imagen basado en el tipo de cultivo
        private func imageNameForCultivo(_ tipoCultivo: String) -> String {
            // Normaliza el nombre del cultivo a minúsculas para la comparación
            let cultivoNormalizado = tipoCultivo.lowercased()
            
            // Mapeo simple (puedes expandirlo)
            if cultivoNormalizado.contains("maíz") || cultivoNormalizado.contains("maiz") {
                return "maiz" // Asume que tienes una imagen llamada "maiz" en tus Assets
            } else if cultivoNormalizado.contains("tomate") || cultivoNormalizado.contains("jitomate") {
                return "tomate" // Asume "tomate.jpg" o "tomate.png"
            } else if cultivoNormalizado.contains("fresa") {
                return "fresa" // Asume "fresa.jpg" o "fresa.png"
            }
            // ... añade más casos para otros cultivos ...
            
            return "campo_default" // Imagen por defecto si no hay una específica
        }

    var body: some View {
        // Group nos permite tener lógica condicional en la raíz de la vista
        Group {
            if let currentTerreno = terreno { // Solo mostramos contenido si encontramos el terreno
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) { // Ajusté el spacing
                        // Encabezado con el nombre del terreno
                        Text(currentTerreno.nombre)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.horizontal,70)
                        
                        // --- SECCIÓN DE LA IMAGEN ---
                                                Image(imageNameForCultivo(currentTerreno.tipoCultivo)) // <--- IMAGEN AÑADIDA
                                                    .resizable()
                                                    //.aspectRatio(contentMode: .fill) // O .fit, según prefieras
                                                    .frame(height: 290) // Altura fija para la imagen
                                                    .clipped() // Recorta la imagen si .fill la hace más grande que el frame
                                                    .cornerRadius(12)
                                                    .padding(.bottom, 15) // Espacio debajo de la imagen
                                                // --- FIN SECCIÓN DE LA IMAGEN ---
                        
                        // Sección de Información del Terreno
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(label: "Cultivo Principal:", value: currentTerreno.tipoCultivo)
                            InfoRow(label: "Tipo de Suelo:", value: currentTerreno.tipoSuelo)
                            InfoRow(label: "Dimensiones:", value: currentTerreno.dimension)
                        }
                        .padding(.bottom, 20)
                        
                        // Sección del Plan de Acción
                        Text("Plan de Acción:")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        // Mostramos las tareas si existen, o un mensaje si no.
                        if let plan = currentTerreno.planDeAccion, !plan.isEmpty {
                            // ScrollView por si hay muchas tareas
                            ScrollView {
                                VStack(alignment: .leading) {
                                    ForEach(plan) { tarea in
                                        HStack {
                                            Image(systemName: tarea.isCompleted ? "checkmark.square.fill" : "square")
                                                .foregroundColor(tarea.isCompleted ? .green : .gray)
                                            Text(tarea.text)
                                            Spacer() // Empuja el texto a la izquierda
                                        }
                                        .padding(.vertical, 2)
                                    }
                                }
                            }
                            .frame(maxHeight: 200) // Limitar altura del scroll de tareas
                        } else {
                            Text("Aún no hay un plan de acción para este terreno. ¡Genéralo con la IA!")
                                .foregroundColor(.gray)
                                .padding(.vertical)
                        }
                        
                        // Botón para ir al Chat con IA
                        Button(action: {
                            showingChatView = true
                        }) {
                            HStack {
                                Image(systemName: "sparkles. μπορούμε (message.fill)") // Icono de chat con IA
                                Text(currentTerreno.planDeAccion != nil && !currentTerreno.planDeAccion!.isEmpty ? "Ver/Editar Plan con IA" : "Generar Plan con IA")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                        }
                        .padding(.top) // Espacio antes del botón
                        
                        Spacer() // Empuja todo el contenido hacia arriba
                    }
                    .padding() // Padding general para el VStack principal
                    //.navigationTitle("Detalle del Terreno") // Título para la barra de navegación si FormularioView ya está en un NavStack
                    //.navigationBarTitleDisplayMode(.inline)
                    
                }
            } else {
                // Mensaje si el terreno no se encuentra (esto es un caso de error)
                Text("Terreno no encontrado.")
                    .foregroundColor(.red)
            }
        }
        .sheet(isPresented: $showingChatView) {
            if let unwrappedTerreno = terreno, let terrenoIndex = terrenoManager.terrenos.firstIndex(where: { $0.id == unwrappedTerreno.id }) {
                ChatViewWithTasks(
                    selectedCultivo: unwrappedTerreno.tipoCultivo,
                    hasInitialSavedPlan: Binding(
                        get: { terrenoManager.terrenos[terrenoIndex].planDeAccion != nil && !terrenoManager.terrenos[terrenoIndex].planDeAccion!.isEmpty },
                        set: { _ in }
                    ),
                    initialSavedTasks: Binding(
                        get: { terrenoManager.terrenos[terrenoIndex].planDeAccion ?? [] },
                        set: { newTasks in terrenoManager.terrenos[terrenoIndex].planDeAccion = newTasks }
                    ),
                    onSavePlan: { (nuevasTareasParaGuardar, fechaDeInicio) in // <--- EL CALLBACK RECIBE DOS ARGUMENTOS
                        // Aquí es donde llamas a la función de tu manager
                        terrenoManager.updatePlan(
                            forTerrenoID: unwrappedTerreno.id,
                            newPlanTasks: nuevasTareasParaGuardar, // <--- Nombre correcto del parámetro
                            fechaInicio: fechaDeInicio             // <--- Nombre correcto del parámetro
                        )
                    },
                    onUpdateTask: { tareaActualizada in
                        terrenoManager.updateTaskInPlan(forTerrenoID: unwrappedTerreno.id, taskToUpdate: tareaActualizada)
                    }
                )
            }else {
                // Fallback si `terreno` es nil, aunque no debería llegar aquí si el botón está bien condicionado
                Text("Error al cargar el chat: Terreno no disponible.")
            }
        }
    }
}

// Vista auxiliar para mostrar filas de información (sin cambios)
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .fontWeight(.semibold)
                .frame(width: 140, alignment: .leading) // Ancho fijo para la etiqueta
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading) // El valor toma el resto del espacio
        }
    }
}

// Preview para TerrenoDetailView
struct TerrenoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Crear una instancia de TerrenoManager para el preview
        let manager = TerrenoManager()
        // Tomar el ID del primer terreno de ejemplo, o un UUID vacío si no hay ninguno
        let exampleTerrenoId = manager.terrenos.first?.id ?? UUID()

        // Es buena idea envolver en NavigationStack para ver el título y la barra
        NavigationStack {
            TerrenoDetailView(terrenoManager: manager, terrenoId: exampleTerrenoId)
        }
    }
}
