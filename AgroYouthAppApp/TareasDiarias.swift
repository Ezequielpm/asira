// TareasDiarias.swift
import SwiftUI

struct TareasDiarias: View {
    @EnvironmentObject var terrenoManager: TerrenoManager

    // Estado para la tarea actual que se mostrará
    @State private var tareaMostrada: TaskItem? = nil
    @State private var nombreTerrenoDeTarea: String = "Mis Cultivos" // Default o nombre del terreno
    @State private var progresoTarea: CGFloat = 0.0

    var body: some View {
        VStack(alignment: .leading) {
            Text(tareaMostrada == nil ? "Tareas Recientes" : "Próxima Tarea Pendiente")
                .font(.headline)
                .bold()
                .padding(.bottom, 10)
                .padding(.leading, 18)

            if let tarea = tareaMostrada, let terrenoId = findTerrenoId(for: tarea.id) {
                ZStack {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(nombreTerrenoDeTarea)
                            .font(.headline)
                            .foregroundStyle(.white)
                        
                        HStack {
                            Capsule()
                                .fill(Color(#colorLiteral(red: 0.02146766335, green: 0.5795219541, blue: 0.4361915588, alpha: 1)))
                                .frame(width: 70, height: 30) // Ajustado para texto más largo
                                .overlay(
                                    Text("\(Int(progresoTarea * 100))%")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.white)
                                )
                            
                            Text("Progreso Tarea")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        
                        Text(tarea.text)
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true) // Para permitir multilínea
                        
                        if !tarea.isCompleted {
                            Button(action: {
                                marcarTareaComoCompletada(tareaId: tarea.id, terrenoId: terrenoId)
                            }) {
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                                    .foregroundStyle( Color(#colorLiteral(red: 0.02146766335, green: 0.5795219541, blue: 0.4361915588, alpha: 1)))
                                    .overlay(
                                        Text("Marcar como Hecha")
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.white)
                                    )
                            }
                        } else {
                            Text("¡Tarea Completada!")
                                .font(.headline)
                                .padding(.vertical)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(#colorLiteral(red: 0.7215686275, green: 0.8862745098, blue: 0.8039215686, alpha: 1)), Color(#colorLiteral(red: 0.3843137255, green: 0.662745098, blue: 0.5058823529, alpha: 1))]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .padding(.horizontal) // Consistencia
                .overlay(
                    ProgressRingComponent(progress: $progresoTarea, tipoCultivoIcono: obtenerTipoCultivoIcono(for: tarea))
                        .frame(width: 70, height: 70)
                        .padding(.top, 20)
                        .padding(.trailing, 20),
                    alignment: .topTrailing
                )
            } else {
                VStack(alignment: .center) {
                    Text("¡Todo al día!")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding()
                    Text("No hay tareas pendientes por ahora.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 50)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(20)
                .padding(.horizontal)
            }
        }
        .onAppear {
            cargarProximaTarea()
        }
        // Podrías necesitar un .onChange(of: terrenoManager.terrenos) para recargar si los datos cambian externamente,
        // pero @EnvironmentObject ya debería causar actualizaciones.
    }

    private func findTerrenoId(for taskId: UUID) -> UUID? {
        for terreno in terrenoManager.terrenos {
            if terreno.planDeAccion?.contains(where: { $0.id == taskId }) ?? false {
                return terreno.id
            }
        }
        return nil
    }
    
    private func obtenerTipoCultivoIcono(for tarea: TaskItem?) -> String {
        guard let currentTarea = tarea,
              let terreno = terrenoManager.terrenos.first(where: { $0.planDeAccion?.contains(where: { $0.id == currentTarea.id }) ?? false })
        else {
            return "leaf.fill" // Icono por defecto
        }
        
        // Lógica similar a imageNameForCultivo pero para SF Symbols
        let cultivoNormalizado = terreno.tipoCultivo.lowercased()
        if cultivoNormalizado.contains("maíz") || cultivoNormalizado.contains("maiz") { return "corn.fill" } // SF Symbol para maíz (si existe, si no, usa otro)
        if cultivoNormalizado.contains("tomate") { return "carrot.fill" } // Ejemplo, busca un ícono adecuado
        if cultivoNormalizado.contains("papa") { return "potato.fill" } // SF Symbol (si existe)
        if cultivoNormalizado.contains("fresa") { return "strawberry.fill" } // SF Symbol (si existe)
        if cultivoNormalizado.contains("zanahoria") { return "carrot.fill" }
        
        return "leaf.fill" // Icono por defecto
    }


    private func cargarProximaTarea() {
        var todasLasTareasPendientes: [(tarea: TaskItem, terreno: Terreno)] = []

        for terreno in terrenoManager.terrenos {
            if let plan = terreno.planDeAccion {
                let tareasDelTerreno = plan.filter { task in
                    !task.isCompleted && task.dueDate != nil // && task.dueDate! >= Calendar.current.startOfDay(for: Date())
                }
                for tarea in tareasDelTerreno {
                    todasLasTareasPendientes.append((tarea, terreno))
                }
            }
        }

        // Ordenar por fecha de vencimiento (las más próximas primero)
        todasLasTareasPendientes.sort { $0.tarea.dueDate! < $1.tarea.dueDate! }

        if let proxima = todasLasTareasPendientes.first {
            self.tareaMostrada = proxima.tarea
            self.nombreTerrenoDeTarea = proxima.terreno.nombre
            self.progresoTarea = proxima.tarea.isCompleted ? 1.0 : 0.0 // O un cálculo de progreso más fino si lo tienes
        } else {
            self.tareaMostrada = nil
            self.nombreTerrenoDeTarea = "Mis Cultivos"
            self.progresoTarea = 0.0
        }
    }

    private func marcarTareaComoCompletada(tareaId: UUID, terrenoId: UUID) {
        if var tareaActualizada = tareaMostrada, tareaActualizada.id == tareaId {
            tareaActualizada.isCompleted = true
            terrenoManager.updateTaskInPlan(forTerrenoID: terrenoId, taskToUpdate: tareaActualizada)
            // Forzar la recarga para que la UI refleje el cambio y busque la siguiente tarea
            // La actualización de `terrenoManager` debería desencadenar una nueva evaluación.
            // Si `progresoTarea` está directamente vinculado a `tareaMostrada.isCompleted`,
            // la UI del anillo se actualizará.
            self.progresoTarea = 1.0 // Actualiza el anillo inmediatamente
            
            // Opcional: Retrasar la carga de la siguiente tarea para que el usuario vea la animación del anillo
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                 cargarProximaTarea()
            }
        }
    }
}

struct ProgressRingComponent: View {
    @Binding var progress: CGFloat
    var tipoCultivoIcono: String = "leaf.fill" // Icono por defecto

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 8) // Fondo del anillo más sutil

            Circle()
                .trim(from: 0, to: progress)
                .stroke(progressColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)

            Image(systemName: tipoCultivoIcono) // Icono dinámico
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25) // Ajustar tamaño del icono
                .foregroundStyle(progressColor) // Color del icono igual al del progreso
        }
    }

    private var progressColor: Color {
        if progress >= 1.0 {
            return Color.green
        } else if progress > 0.0 { // Cualquier progreso > 0 es "en progreso"
             return Color(#colorLiteral(red: 0.02146766335, green: 0.5795219541, blue: 0.4361915588, alpha: 1)) // Color principal de la app para "en progreso"
        } else {
            return Color.gray.opacity(0.5) // Sin iniciar o sin tarea
        }
    }
}

#Preview {
    // Crear un manager de ejemplo con algunas tareas para el preview
    let manager = TerrenoManager()
    let hoy = Date()
    let manana = Calendar.current.date(byAdding: .day, value: 1, to: hoy)!
    let pasadoManana = Calendar.current.date(byAdding: .day, value: 2, to: hoy)!

    let tarea1 = TaskItem(text: "Regar los tomates urgentemente", dueDate: hoy)
    let tarea2 = TaskItem(text: "Fertilizar el maíz", isCompleted: false, dueDate: manana)
    let tarea3 = TaskItem(text: "Revisar plagas en fresas", dueDate: pasadoManana)
    
    let terreno1 = Terreno(nombre: "Huerto Tomates", tipoCultivo: "Tomate", tipoSuelo: "Franco", dimension: "10m2", planDeAccion: [tarea1], fechaInicioPlan: hoy)
    let terreno2 = Terreno(nombre: "Maizal", tipoCultivo: "Maíz", tipoSuelo: "Arcilloso", dimension: "1ha", planDeAccion: [tarea2, tarea3], fechaInicioPlan: hoy)
    
    manager.terrenos = [terreno1, terreno2]
    
    return TareasDiarias()
        .environmentObject(manager)
        .padding()
        .background(Color.gray.opacity(0.1))
}
