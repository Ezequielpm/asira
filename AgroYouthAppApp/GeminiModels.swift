//
//  GeminiModels.swift
//  AgroYouthAppApp
//
//  Created by Ezequiel Peña on 13/05/25.
//

import Foundation

// Estructura para la solicitud a la API de Gemini
struct GeminiRequest: Codable {
    let contents: [Content]
    // Opcional: Puedes añadir GenerationConfig aquí si necesitas más control
    // let generationConfig: GenerationConfig?
}

struct Content: Codable {
    let parts: [Part]
}

struct Part: Codable {
    let text: String
}

// Estructura para la respuesta de la API de Gemini (simplificada)
struct GeminiResponse: Codable {
    struct Candidate: Codable {
        struct Content: Codable {
            struct Part: Codable {
                let text: String
            }
            let parts: [Part]
        }
        let content: Content
    }
    let candidates: [Candidate]?

    struct PromptFeedback: Codable {
        struct SafetyRating: Codable {
            let category: String
            let probability: String
        }
        let safetyRatings: [SafetyRating]?
    }
    let promptFeedback: PromptFeedback? // Puede ser nil si no hay problemas
}
