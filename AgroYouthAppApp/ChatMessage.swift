//
//  ChatMessage.swift
//  AgroYouthAppApp
//
//  Created by Ezequiel Peña on 13/05/25.
//

import SwiftUI

// Estructura para los mensajes en el chat
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    var text: String
    let isUser: Bool // True si el mensaje es del usuario, false si es de la IA
}
