import SwiftUI
// import UIKit // No es estrictamente necesario si calificamos los tipos de UIKit

@available(iOS 16.0, *)
struct CalendarViewRepresentable: UIViewRepresentable {
    let interval: DateInterval // El mes que queremos mostrar (usaremos interval.start)
    @Binding var selectedDate: Date?
    let tasks: [TaskItem] // Tareas actualizadas para el mes

    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        view.calendar = Calendar(identifier: .gregorian)
        view.locale = Locale(identifier: "es_MX")
        
        // Configurar el mes visible
        let components = Calendar.current.dateComponents([.year, .month], from: interval.start)
        view.visibleDateComponents = components
        view.availableDateRange = DateInterval(start: .distantPast, end: .distantFuture) // Permitir scroll si es necesario, o restringir
        
        view.delegate = context.coordinator
        
        let dateSelection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        view.selectionBehavior = dateSelection
        
        return view
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        // 1. Actualizar el mes visible si `interval.start` (que representa nuestro displayMonth) cambia
        let newComponents = Calendar.current.dateComponents([.year, .month], from: interval.start)
        if uiView.visibleDateComponents != newComponents {
            uiView.visibleDateComponents = newComponents
            // Cuando cambia el mes, el delegado `calendarView(_:decorationFor:)` será llamado
            // para las nuevas fechas visibles, por lo que las decoraciones se actualizarán.
        }

        // 2. Actualizar las tareas en el coordinador si han cambiado
        // Esto es para que el coordinador use las tareas más recientes para las decoraciones.
        if context.coordinator.tasksForDecorations.count != tasks.count || !context.coordinator.tasksForDecorations.elementsEqual(tasks, by: { $0.id == $1.id && $0.isCompleted == $1.isCompleted }) {
            context.coordinator.updateTasks(tasks)
            
            // Forzar recarga de decoraciones para el mes visible
            // Generamos los DateComponents para cada día del mes actual visible
            var datesToReload: [DateComponents] = []
            let calendar = Calendar.current
            guard let monthInterval = calendar.dateInterval(of: .month, for: interval.start) else { return }
            
            calendar.enumerateDates(startingAfter: monthInterval.start, matching: DateComponents(hour:0), matchingPolicy: .nextTime, direction: .forward) { (date, exactMatch, stop) in
                guard let date = date else { return }
                if date >= monthInterval.end { // Detenerse al final del mes
                    stop = true
                    return
                }
                datesToReload.append(calendar.dateComponents([.year, .month, .day], from: date))
            }
             // Añadir el primer día del mes también
            datesToReload.append(calendar.dateComponents([.year, .month, .day], from: monthInterval.start))

            if !datesToReload.isEmpty {
                 uiView.reloadDecorations(forDateComponents: datesToReload, animated: true)
            }
        }


        // 3. Actualizar la selección de fecha si `selectedDate` cambia desde fuera
        if let bindingDate = selectedDate {
            if let selectionBehavior = uiView.selectionBehavior as? UICalendarSelectionSingleDate {
                let bindingDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: bindingDate)
                // Solo actualizar si la selección del calendario es diferente a nuestro binding
                if selectionBehavior.selectedDate != bindingDateComponents {
                    selectionBehavior.setSelected(bindingDateComponents, animated: true)
                }
            }
        } else { // Si selectedDate es nil desde fuera, deseleccionar en el calendario
             if let selectionBehavior = uiView.selectionBehavior as? UICalendarSelectionSingleDate {
                 if selectionBehavior.selectedDate != nil {
                    selectionBehavior.setSelected(nil, animated: true)
                 }
             }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, initialTasks: tasks)
    }

    @available(iOS 16.0, *)
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: CalendarViewRepresentable
        var tasksForDecorations: [TaskItem]

        init(parent: CalendarViewRepresentable, initialTasks: [TaskItem]) {
            self.parent = parent
            self.tasksForDecorations = initialTasks
            super.init()
        }
        
        func updateTasks(_ newTasks: [TaskItem]) {
            self.tasksForDecorations = newTasks
            // La recarga de decoraciones se manejará desde updateUIView ahora
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            DispatchQueue.main.async {
                self.parent.selectedDate = dateComponents?.date
            }
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
            return true
        }

        @MainActor
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard let date = dateComponents.date else { return nil }
            
            let tasksOnThisDay = self.tasksForDecorations.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return Calendar.current.isDate(dueDate, inSameDayAs: date)
            }

            if !tasksOnThisDay.isEmpty {
                // Usar un punto naranja por defecto
                return .default(color: .orange)
                // O si preferías la imagen de círculo:
                // return .image(UIImage(systemName: "circle.fill"), color: .orange, size: .small)
            }
            return nil
        }
    }
}

@available(iOS 16.0, *)
struct PlanCalendarView: View {
    // Propiedades para recibir los datos de ContentView
    @ObservedObject var terrenoManager: TerrenoManager
    var selectedTerreno: Terreno?

    @State private var selectedDate: Date? = Date() // Fecha seleccionada en el calendario
    // Podrías querer controlar el mes que se muestra, por ejemplo, basado en el plan del terreno
    @State private var displayMonth: Date

    // Propiedad computada para obtener las tareas para el calendario
    private var tasksForCalendar: [TaskItem] {
        var tasksToShow: [TaskItem] = []
        if let terreno = selectedTerreno, let plan = terreno.planDeAccion {
            // Mostrar tareas del terreno específico si se ha seleccionado uno y tiene plan
            tasksToShow = plan.filter { $0.dueDate != nil }
        } else {
            // Opcional: Lógica para mostrar tareas de todos los terrenos,
            // o un resumen, si no hay un terreno específico seleccionado.
            // Por ejemplo, mostrar todas las tareas de todos los terrenos con fecha.
            for t in terrenoManager.terrenos {
                if let plan = t.planDeAccion {
                    tasksToShow.append(contentsOf: plan.filter { $0.dueDate != nil })
                }
            }
        }
        return tasksToShow
    }

    // Inicializador para aceptar los parámetros y configurar el mes inicial
    init(terrenoManager: TerrenoManager, selectedTerreno: Terreno?) {
        self.terrenoManager = terrenoManager
        self.selectedTerreno = selectedTerreno
        
        // Determinar el mes inicial a mostrar
        if let terreno = selectedTerreno, let fechaInicio = terreno.fechaInicioPlan {
            self._displayMonth = State(initialValue: fechaInicio)
        } else if let primerTerrenoConPlan = terrenoManager.terrenos.first(where: { $0.planDeAccion != nil && !$0.planDeAccion!.isEmpty && $0.fechaInicioPlan != nil }), let fechaInicio = primerTerrenoConPlan.fechaInicioPlan {
            self._displayMonth = State(initialValue: fechaInicio)
        }
        else {
            self._displayMonth = State(initialValue: Date()) // Mes actual por defecto
        }
    }

    var body: some View {
        VStack {
            // Opcional: Añadir controles para cambiar de mes o seleccionar otro terreno
            // Text("Mes: \(displayMonth, formatter: monthFormatter)")
            // Text("Terreno: \(selectedTerreno?.nombre ?? "General")")

            CalendarViewRepresentable(
                interval: DateInterval(start: displayMonth, duration: 1), // Usa displayMonth para el intervalo
                selectedDate: $selectedDate,
                tasks: tasksForCalendar // Pasa las tareas calculadas
            )
            .frame(height: 400)
            .padding(.bottom,100)

            // Opcional: Mostrar detalles de las tareas para la fecha seleccionada
            if let date = selectedDate {
                Text("Tareas para \(date, style: .date):")
                    .font(.headline)
                let tasksOnDay = tasksForCalendar.filter { task in
                    guard let dueDate = task.dueDate else { return false }
                    return Calendar.current.isDate(dueDate, inSameDayAs: date)
                }
                if tasksOnDay.isEmpty {
                    Text("No hay tareas programadas para esta fecha.")
                        .foregroundColor(.gray)
                } else {
                    List(tasksOnDay) { task in
                        VStack(alignment: .leading) {
                            Text(task.text)
                            if let terrenoNombre = terrenoManager.terrenos.first(where: {$0.planDeAccion?.contains(where: {$0.id == task.id}) ?? false})?.nombre {
                                Text("Terreno: \(terrenoNombre)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            Spacer()
        }
        // Puedes añadir .onChange(of: selectedTerreno) si permites cambiar el terreno
        // para actualizar displayMonth si es necesario.
    }
    
    // Formateador para el mes (ejemplo)
    // private var monthFormatter: DateFormatter {
    //     let formatter = DateFormatter()
    //     formatter.dateFormat = "MMMM yyyy"
    //     formatter.locale = Locale(identifier: "es_MX")
    //     return formatter
    // }
}
