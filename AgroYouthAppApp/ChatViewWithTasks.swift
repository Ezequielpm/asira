//
//  ChatViewWithTasks.swift
//  AgroYouthAppApp
//
//  Created by Ezequiel Peña on 13/05/25.
//
import SwiftUI

struct ChatViewWithTasks: View {
    @State private var messages: [ChatMessage]
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false
    
    // Tareas generadas por la IA, antes de ser guardadas o si se genera un nuevo plan
    @State private var generatedTaskItems: [TaskItem] = []
    
    // Estado para controlar la presentación de la sheet (PlanReviewView o PlanTrackingView)
    @State private var showingPlanSheet = false
    
    // Indica si ya existe un plan GUARDADO para el cultivo/terreno actual.
    // Esto vendrá del modelo de datos del Terreno.
    @Binding var hasSavedPlanForCurrentCultivo: Bool
    
    // Tareas del plan guardado. Esto también vendrá del modelo del Terreno.
    @Binding var savedPlanTasks: [TaskItem]

    let selectedCultivo: String
    let apiKey = "AIzaSyDCetBiYFN_l-SDmO8I-RpPV_eUKe8YAjc" // Tu API Key
    let modelName = "gemini-1.5-flash" // Corregido según la sugerencia de AI Studio
    let predefinedQuestions: [String]

    // --- Callbacks para interactuar con el modelo de datos del Terreno ---
    var onSavePlanCallback: ([TaskItem], Date) -> Void // Acepta [TaskItem] y Date
    var onUpdateTaskInSavedPlanCallback: (TaskItem) -> Void

    // Inicializador modificado para aceptar el estado del plan y los callbacks
    init(selectedCultivo: String,
         hasInitialSavedPlan: Binding<Bool>,
         initialSavedTasks: Binding<[TaskItem]>,
         onSavePlan: @escaping ([TaskItem], Date) -> Void, // Firma del callback actualizada
         onUpdateTask: @escaping (TaskItem) -> Void) {
        self.selectedCultivo = selectedCultivo
        self._messages = State(initialValue: [
            ChatMessage(text: "Hola, soy tu asistente AgroYouth. ¿Cómo puedo ayudarte hoy con tu cultivo de \(selectedCultivo)?", isUser: false)
        ])
        self.predefinedQuestions = [
            "Genera un plan de actividades para mi cultivo de \(selectedCultivo).",
            "¿Cuáles son las plagas comunes del \(selectedCultivo) y cómo tratarlas orgánicamente?",
            "¿Cuándo es el mejor momento para cosechar \(selectedCultivo)?"
        ]
        
        self._hasSavedPlanForCurrentCultivo = hasInitialSavedPlan
        self._savedPlanTasks = initialSavedTasks
        self.onSavePlanCallback = onSavePlan // Asignación del callback actualizado
        self.onUpdateTaskInSavedPlanCallback = onUpdateTask
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("Asistente para Cultivo de \(selectedCultivo)")
                    .font(.headline)
                    .padding(.top)

                if !generatedTaskItems.isEmpty || hasSavedPlanForCurrentCultivo {
                    Button(action: {
                        showingPlanSheet = true
                    }) {
                        HStack {
                            Image(systemName: "list.bullet.clipboard.fill")
                            Text(buttonTextForPlan())
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                }
                
                ScrollViewReader { scrollViewProxy in
                    List(messages) { message in
                        HStack {
                            if message.isUser {
                                Spacer()
                                Text(message.text)
                                    .padding(10)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            } else {
                                Text(LocalizedStringKey(message.text))
                                    .padding(10)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                Spacer()
                            }
                        }
                        .id(message.id)
                    }
                    .onChange(of: messages.count) { _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                if isLoading { ProgressView().padding() }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(predefinedQuestions, id: \.self) { question in
                            Button(action: {
                                sendPredefinedQuestion(question)
                            }) {
                                Text(question)
                                    .font(.caption)
                                    .padding(8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(10)
                                    .foregroundColor(.blue)
                            }
                            .padding(.leading, 5)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                }
                .frame(height: 50)

                HStack {
                    TextField("Escribe tu pregunta...", text: $inputText, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(1...5)
                        .onSubmit(sendMessage)

                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                }
                .padding()
            }
            .onAppear {
                if apiKey == "TU_API_KEY_AQUI" {
                    messages.append(ChatMessage(text: "ADVERTENCIA: API Key no configurada.", isUser: false))
                }
            }
            .sheet(isPresented: $showingPlanSheet) {
                if !generatedTaskItems.isEmpty {
                    PlanReviewView( // Esta es la vista que ahora toma 'onSaveWithStartDate'
                        cultivoName: selectedCultivo,
                        tasks: $generatedTaskItems,
                        onSaveWithStartDate: { selectedStartDate in // <--- Callback de PlanReviewView
                            // Llama al callback principal que se pasó en el init
                            self.onSavePlanCallback(generatedTaskItems, selectedStartDate)
                            
                            // Actualizar el estado local para reflejar que el plan se guardó
                            // y las tareas guardadas (con fechas calculadas si es necesario)
                            // Esta lógica de cálculo de dueDate podría estar en TerrenoManager
                            // cuando se llama a onSavePlanCallback.
                            var tasksWithDueDates = generatedTaskItems
                            for i in tasksWithDueDates.indices {
                                if let dias = tasksWithDueDates[i].diasDesdeInicio {
                                    tasksWithDueDates[i].dueDate = Calendar.current.date(byAdding: .day, value: dias, to: selectedStartDate)
                                }
                            }
                            self.savedPlanTasks = tasksWithDueDates // Actualiza el @Binding
                            self.hasSavedPlanForCurrentCultivo = true // Actualiza el @Binding
                            self.generatedTaskItems = [] // Limpia las tareas generadas temporalmente
                            
                            messages.append(ChatMessage(text: "¡Plan guardado y agendado para \(selectedCultivo) a partir del \(selectedStartDate.formatted(date: .long, time: .omitted))!", isUser: false))
                        },
                        onCancel: {
                            messages.append(ChatMessage(text: "Revisión de plan cancelada.", isUser: false))
                        }
                    )
                } else if hasSavedPlanForCurrentCultivo {
                    PlanTrackingView(
                        cultivoName: selectedCultivo,
                        tasks: $savedPlanTasks,
                        onTaskUpdate: { updatedTask in
                            if let index = savedPlanTasks.firstIndex(where: { $0.id == updatedTask.id }) {
                                savedPlanTasks[index] = updatedTask // Actualiza el @Binding localmente
                            }
                            self.onUpdateTaskInSavedPlanCallback(updatedTask) // Notifica al padre
                        }
                    )
                }
            }
        }
    }
    
    private func buttonTextForPlan() -> String {
        if !generatedTaskItems.isEmpty {
            return "Revisar Plan Generado (\(generatedTaskItems.count) tareas)"
        } else if hasSavedPlanForCurrentCultivo {
            return "Ver Seguimiento del Plan (\(savedPlanTasks.count) tareas)"
        }
        return "Ver Plan"
    }

    func sendPredefinedQuestion(_ question: String) {
        inputText = question
        sendMessage()
    }

    func sendMessage() {
        let userMessageText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userMessageText.isEmpty else { return }

        let userMessage = ChatMessage(text: userMessageText, isUser: true)
        messages.append(userMessage)
        inputText = ""
        isLoading = true
        
        let isPlanRequest = userMessageText.lowercased().contains("plan de actividades") ||
                            userMessageText.lowercased().contains("generar tareas") ||
                            userMessageText.lowercased().contains("lista de tareas")

        var promptForGemini = userMessageText
        if isPlanRequest {
            self.generatedTaskItems = [] // Limpiar borradores anteriores
            promptForGemini = """
            Genera una lista de tareas agrícolas detallada para un cultivo de \(selectedCultivo).
            Para cada tarea, indica un número de días estimado desde el inicio del plan para realizarla.
            Formatea cada tarea así:
            [Número de días desde inicio]. [Descripción de la tarea]
            Ejemplo:
            0. Preparar el terreno y arar.
            3. Sembrar las semillas de \(selectedCultivo).
            7. Primer riego ligero.
            No incluyas introducciones, conclusiones, ni texto adicional fuera de la lista de tareas.
            Comienza con el día 0.
            """
        }

        Task {
            do {
                let aiResponseText = try await callGoogleAI(prompt: promptForGemini)
                
                DispatchQueue.main.async {
                    if isPlanRequest {
                        self.generatedTaskItems = parseTasks(from: aiResponseText)
                        if !self.generatedTaskItems.isEmpty {
                            let messageText = "He generado un borrador de plan para \(selectedCultivo). Presiona '\(buttonTextForPlan())' arriba para revisarlo y agendarlo."
                            messages.append(ChatMessage(text: messageText, isUser: false))
                        } else {
                            let noPlanMessage = ChatMessage(text: "No pude generar una lista de tareas específica esta vez. Intenta reformular tu solicitud de plan o pregunta de otra manera.", isUser: false)
                            messages.append(noPlanMessage)
                        }
                    } else {
                        let aiMessage = ChatMessage(text: aiResponseText, isUser: false)
                        messages.append(aiMessage)
                    }
                    isLoading = false
                }
            } catch {
                let errorMessage = "Error al contactar la IA: \(error.localizedDescription)"
                print(errorMessage)
                let aiMessage = ChatMessage(text: "Lo siento, ha ocurrido un error. \(errorMessage)", isUser: false)
                DispatchQueue.main.async {
                    messages.append(aiMessage)
                    isLoading = false
                }
            }
        }
    }

    func parseTasks(from text: String) -> [TaskItem] {
        var parsedTasks: [TaskItem] = []
        let lines = text.split(whereSeparator: \.isNewline)
        for line in lines {
            var taskLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if let dotIndex = taskLine.firstIndex(of: ".") {
                let potentialDaysString = String(taskLine[..<dotIndex]).trimmingCharacters(in: .whitespaces)
                if let days = Int(potentialDaysString) {
                    let taskDescription = String(taskLine[taskLine.index(after: dotIndex)...]).trimmingCharacters(in: .whitespaces)
                    if !taskDescription.isEmpty {
                        parsedTasks.append(TaskItem(text: taskDescription, diasDesdeInicio: days))
                    }
                    continue
                }
            }
            if !taskLine.isEmpty {
                parsedTasks.append(TaskItem(text: taskLine))
            }
        }
        return parsedTasks
    }

    func callGoogleAI(prompt: String) async throws -> String {
        if apiKey == "TU_API_KEY_AQUI" {
             throw NSError(domain: "ConfigurationError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "API Key no configurada."])
        }
        guard !apiKey.isEmpty else {
            throw NSError(domain: "ConfigurationError", code: 1002, userInfo: [NSLocalizedDescriptionKey: "API Key está vacía."])
        }

        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(modelName):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = GeminiRequest(contents: [Content(parts: [Part(text: prompt)])])
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            print("Error al codificar el cuerpo de la solicitud: \(error)")
            throw error
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.cannotParseResponse)
        }
        
        let responseBodyString = String(data: data, encoding: .utf8) ?? "No se pudo decodificar."

        if !(200...299).contains(httpResponse.statusCode) {
            var errorMessage = "Error del servidor con código: \(httpResponse.statusCode)."
            errorMessage += " Detalles: \(responseBodyString)"
            print("Error HTTP Detallado: \(errorMessage)")
            throw NSError(domain: "GoogleAIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        
        do {
            let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)

            if let textResponse = geminiResponse.candidates?.first?.content.parts.first?.text {
                return textResponse
            } else if let promptFeedback = geminiResponse.promptFeedback, let firstRating = promptFeedback.safetyRatings?.first {
                return "Respuesta bloqueada. Razón: \(firstRating.category) (\(firstRating.probability))."
            } else if geminiResponse.candidates == nil || geminiResponse.candidates?.isEmpty == true {
                 return "Respuesta exitosa pero sin contenido (filtros de seguridad?)."
            }
            else {
                return "No se pudo obtener una respuesta válida del modelo."
            }
        } catch {
            print("Error al decodificar la respuesta JSON: \(error)")
            throw error
        }
    }
}

struct ChatViewWithTasks_Previews: PreviewProvider {
    static var previews: some View {
        @State var previewHasSavedPlan = false
        @State var previewSavedTasks: [TaskItem] = []

        ChatViewWithTasks(
            selectedCultivo: "Fresa Preview",
            hasInitialSavedPlan: $previewHasSavedPlan,
            initialSavedTasks: $previewSavedTasks,
            onSavePlan: { tasksToSave, startDate in // Callback de preview actualizado
                var tasksWithDates = tasksToSave
                for i in tasksWithDates.indices {
                    if let dias = tasksWithDates[i].diasDesdeInicio {
                        tasksWithDates[i].dueDate = Calendar.current.date(byAdding: .day, value: dias, to: startDate)
                    }
                }
                previewSavedTasks = tasksWithDates
                previewHasSavedPlan = true
                print("Preview: Plan guardado con \(tasksToSave.count) tareas, iniciando: \(startDate)")
            },
            onUpdateTask: { updatedTask in
                 if let index = previewSavedTasks.firstIndex(where: { $0.id == updatedTask.id }) {
                    previewSavedTasks[index] = updatedTask
                 }
                print("Preview: Tarea actualizada: \(updatedTask.text)")
            }
        )
    }
}
