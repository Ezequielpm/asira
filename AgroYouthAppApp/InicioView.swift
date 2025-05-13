// InicioView.swift
import SwiftUI

// Modelo para una tarjeta de actividad pendiente (puedes expandirlo)
struct ActividadPendienteCardInfo: Identifiable {
    let id: UUID // ID de la tarea original
    let tituloTerreno: String
    let textoTarea: String
    let fechaVencimiento: Date
    // Podrías añadir aquí el ID del terreno para navegar a TerrenoDetailView si es necesario
    let terrenoId: UUID
}

struct InicioView: View {
    @EnvironmentObject var terrenoManager: TerrenoManager
    // Para controlar la pestaña seleccionada en ContentView y navegar a AprendeView
    // Necesitaríamos pasar un @Binding a selectedTab desde ContentView,
    // o usar otra forma de comunicación inter-vistas.
    // Por ahora, lo omitimos para simplificar.
    // @Binding var selectedTab: Int // Asumiendo que 0 es Inicio, 1 MisTerrenos, etc.

    // Estado para las actividades pendientes que se mostrarán
    @State private var actividadesPendientes: [ActividadPendienteCardInfo] = []

    // Datos de 'techniques' (podrían venir de un ViewModel o ser cargados de otra forma si son muchos)
    let techniques: [Technique] = [
        .init(title: "🌱 Siembra", // Coincidir con títulos de AprendeView para futura conexión
              subtitle: "Inicio de ciclo · Aprende cuándo y cómo sembrar",
              imageName: "siembra"),
        .init(title: "💧 Riego",
              subtitle: "Gestión de agua · Ahorra y optimiza tu riego",
              imageName: "riego"),
        .init(title: "🌿 Mantenimiento",
              subtitle: "Cuidados del cultivo · Deshierba y fertiliza bien",
              imageName: "deshierbe"),
        .init(title: "🐛 Plagas",
              subtitle: "Protección del cultivo · Identifica y controla",
              imageName: "plagas")
        // Añade más si es necesario, asegurando que 'imageName' exista en Assets
    ]

    // Para controlar la navegación a TerrenoDetailView desde un banner de actividad
    @State private var terrenoIdParaNavegacionActividad: UUID?
    @State private var navegarADetalleActividad = false

    var body: some View {
        NavigationStack {
            // Header
            HStack {
                Text("Hola, Mario") // Podría ser dinámico con datos de perfil de usuario
                    .font(.largeTitle) // Un poco más grande para jerarquía
                    .fontWeight(.bold) // Más peso
                Spacer()
                Image("profile") // Asegúrate que "profile.png" exista en Assets
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1)) // Borde sutil
            }
            .padding(.horizontal)
            .padding(.top) // Padding superior para el header

            ScrollView {
                VStack(alignment: .leading, spacing: 24) { // Espaciado general
                    
                    // Sección Actividades Pendientes Dinámicas
                    if !actividadesPendientes.isEmpty {
                        Text("Actividades Pendientes")
                            .font(.title2.bold()) // Más jerarquía
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) { // Espacio entre tarjetas de actividad
                                ForEach(actividadesPendientes) { actividad in
                                    ActividadPendienteCardView(actividad: actividad, terrenoManager: terrenoManager)
                                        .onTapGesture {
                                            // Al tocar la tarjeta, preparamos para navegar al detalle del terreno
                                            self.terrenoIdParaNavegacionActividad = actividad.terrenoId
                                            self.navegarADetalleActividad = true
                                        }
                                }
                            }
                            .padding(.horizontal) // Padding para el contenido del ScrollView
                            .padding(.bottom, 5) // Pequeño padding inferior para el scroll
                        }
                        .frame(height: 150) // Altura para las tarjetas de actividad
                    } else {
                        // Mensaje si no hay actividades pendientes
                        VStack(alignment: .leading) {
                           Text("Actividades Pendientes")
                                .font(.title2.bold())
                                .padding(.bottom, 5)
                            Text("¡Estás al día con tus tareas! No hay actividades urgentes.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 20)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding(.horizontal)
                    }

                    // Sección Técnicas de Cultivo
                    Text("Descubre Técnicas de Cultivo")
                        .font(.title2.bold())
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) { // Espacio entre TechniqueCards
                            ForEach(techniques) { tech in
                                TechniqueCard(tech: tech, action: {
                                    // Acción al pulsar "Ver" en TechniqueCard
                                    // Por ahora, solo un print.
                                    // Más adelante, se podría intentar navegar a la pestaña "Aprende"
                                    // y mostrar el detalle de 'tech.title'.
                                    print("Ver técnica: \(tech.title)")
                                    // Ejemplo: selectedTab = indiceDeAprendeView
                                    //          aprendeViewTargetItem = tech.title
                                })
                            }
                        }
                        .padding(.horizontal) // Padding para el contenido del ScrollView
                    }
                    .frame(height: 240) // Altura para las TechniqueCards

                    // Sección Tareas Diarias (como la adaptamos antes)
                    TareasDiarias() // Ya está adaptada para usar @EnvironmentObject terrenoManager
                        .padding(.top) // Espacio arriba de TareasDiarias
                }
                .padding(.bottom) // Padding inferior para el contenido del VStack principal
            }
            .navigationTitle("Inicio") // Título para la barra de navegación
            .navigationBarHidden(true) // Se mantiene si es el diseño deseado
            .background(Color(UIColor.systemGray6).ignoresSafeArea()) // Un fondo sutil para toda la vista
            .onAppear {
                cargarActividadesPendientes()
            }
            // NavigationLink para las actividades pendientes
            .background(
                NavigationLink(
                    destination: Group {
                        if let id = terrenoIdParaNavegacionActividad {
                            TerrenoDetailView(terrenoManager: terrenoManager, terrenoId: id)
                        } else {
                            EmptyView() // No debería llegar aquí si la lógica es correcta
                        }
                    },
                    isActive: $navegarADetalleActividad
                ) { EmptyView() }
            )
        }
    }

    func cargarActividadesPendientes() {
        var tareasFiltradas: [ActividadPendienteCardInfo] = []
        let hoy = Calendar.current.startOfDay(for: Date())
        let limiteDiasFuturo = Calendar.current.date(byAdding: .day, value: 7, to: hoy)! // Mostrar tareas para los próximos 7 días

        for terreno in terrenoManager.terrenos {
            if let plan = terreno.planDeAccion {
                let pendientesDelTerreno = plan.filter { task in
                    !task.isCompleted && task.dueDate != nil && task.dueDate! >= hoy && task.dueDate! <= limiteDiasFuturo
                }
                for tarea in pendientesDelTerreno {
                    tareasFiltradas.append(ActividadPendienteCardInfo(
                        id: tarea.id,
                        tituloTerreno: terreno.nombre,
                        textoTarea: tarea.text,
                        fechaVencimiento: tarea.dueDate!,
                        terrenoId: terreno.id
                    ))
                }
            }
        }
        // Ordenar por fecha de vencimiento y tomar las primeras (e.g., 5)
        actividadesPendientes = Array(tareasFiltradas.sorted(by: { $0.fechaVencimiento < $1.fechaVencimiento }).prefix(5))
    }
}

// Vista para la tarjeta de actividad pendiente
struct ActividadPendienteCardView: View {
    let actividad: ActividadPendienteCardInfo
    @ObservedObject var terrenoManager: TerrenoManager // Para la acción del botón

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(actividad.tituloTerreno)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)

            Text(actividad.textoTarea)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(Color(UIColor.label)) // Color de texto primario
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true) // Para que ocupe el alto necesario

            Spacer() // Empuja el contenido hacia arriba

            HStack {
                Text("Vence: \(actividad.fechaVencimiento, style: .date)")
                    .font(.caption2)
                    .foregroundColor(.orange)
                Spacer()
                // El botón de acción se maneja con el .onTapGesture del card
            }
        }
        .padding()
        .frame(width: 280, height: 130) // Tamaño fijo para las tarjetas
        .background(Color(UIColor.systemBackground)) // Fondo de tarjeta
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}


// El Technique y TechniqueCard (de tu compañero) se quedan como están,
// solo que TechniqueCard ahora puede aceptar una acción.
struct Technique: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
}

struct TechniqueCard: View {
    let tech: Technique
    var action: (() -> Void)? = nil // Callback opcional para la acción del botón "Ver"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(tech.imageName) // Asegúrate que las imágenes existan en Assets
                .resizable()
                .aspectRatio(contentMode: .fill) // Cambiado a fill
                .frame(width: 200, height: 120)
                .clipped()
                .cornerRadius(12)
            
            Text(tech.title)
                .font(.headline)
                .foregroundColor(Color(UIColor.label))

            Text(tech.subtitle)
                .font(.caption)
                .foregroundColor(Color(UIColor.secondaryLabel))
                .lineLimit(2) // Permitir dos líneas para subtítulos más largos
            
            Spacer() // Empuja el botón hacia abajo
            
            HStack {
                Spacer() // Empuja el botón a la derecha
                Button(action: {
                    action?() // Ejecuta la acción si se proveyó
                }) {
                    Text("Ver Más")
                        .font(.caption.weight(.bold))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .frame(width: 200, height: 220) // Altura definida
        .padding() // Padding interno para la tarjeta
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// Preview para InicioView
struct InicioView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = TerrenoManager()
        // Añadir terrenos y tareas de ejemplo al manager para un buen preview
        let hoy = Date()
        let manana = Calendar.current.date(byAdding: .day, value: 1, to: hoy)!
        manager.terrenos = [
            Terreno(nombre: "Huerto Principal", tipoCultivo: "Tomate", tipoSuelo: "Franco", dimension: "10x5m", planDeAccion: [
                TaskItem(text: "Regar tomates", dueDate: hoy),
                TaskItem(text: "Fertilizar tomates", dueDate: manana, diasDesdeInicio: 1)
            ], fechaInicioPlan: hoy),
            Terreno(nombre: "Campo de Maíz", tipoCultivo: "Maíz", tipoSuelo: "Arcilloso", dimension: "1ha", planDeAccion: [
                TaskItem(text: "Revisar crecimiento del maíz", dueDate: manana, diasDesdeInicio: 1)
            ], fechaInicioPlan: hoy)
        ]
        
        return InicioView()
            .environmentObject(manager)
    }
}
