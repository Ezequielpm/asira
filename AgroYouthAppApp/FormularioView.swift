//
//  FormularioView.swift
//  Asira (o AgroYouthAppApp)
//
//  Created by Mario Moreno on 5/13/25.
//

import SwiftUI

struct FormularioView: View {
    // Inyectar el TerrenoManager. Si lo vas a usar en muchas vistas,
    // considera hacerlo un @EnvironmentObject desde tu App struct.
    @ObservedObject var terrenoManager: TerrenoManager // <<--- AÑADIDO

    // Estado local del formulario
    @State private var nombre       = ""
    @State private var tipoCultivo  = "" // Este será el `cultivoActual` del Terreno
    @State private var tipoSuelo    = ""
    @State private var dimension    = ""
    
    // Estado para la navegación
    @State private var navigateToDetail = false
    @State private var createdTerrenoId: UUID? = nil // Para pasar el ID del terreno creado

    var body: some View {
        NavigationStack {
            ZStack {
                Color(#colorLiteral(red: 0.02146766335, green: 0.5795219541, blue: 0.4361915588, alpha: 1))
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer().frame(height: 70)
                    Text("Ingresa los datos\nde tu terreno aquí")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 24)
                    
                    Image("terreno-vacio")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .scaledToFit()
                    Spacer()

                    VStack(spacing: 16) {
                        TextField(
                            "",
                            text: $nombre,
                            prompt: Text("Nombre del terreno, ej. “Huerta Principal”") // Cambiado para claridad
                                .foregroundColor(.black.opacity(0.5))
                        )
                        .foregroundColor(.black)
                        .textFieldStyle(FormFieldStyle())
                        
                        TextField(
                            "",
                            text: $tipoCultivo, // Este es el 'cultivoActual'
                            prompt: Text("Cultivo principal, ej. “Jitomate Saladette”")
                                .foregroundColor(.black.opacity(0.5))
                        )
                        .foregroundColor(.black)
                        .textFieldStyle(FormFieldStyle())

                        TextField(
                            "",
                            text: $tipoSuelo,
                            prompt: Text("Tipo de suelo, ej. “Tierra fértil y arenosa”")
                                .foregroundColor(.black.opacity(0.5))
                        )
                        .foregroundColor(.black)
                        .textFieldStyle(FormFieldStyle())

                        TextField(
                            "",
                            text: $dimension,
                            prompt: Text("Dimensiones, ej. “500 m²” o “1 hectárea”")
                                .foregroundColor(.black.opacity(0.5))
                        )
                        .foregroundColor(.black)
                        .textFieldStyle(FormFieldStyle())

                        Button {
                            // Validar campos si es necesario
                            if !nombre.isEmpty && !tipoCultivo.isEmpty {
                                // Usar el TerrenoManager para añadir el nuevo terreno
                                let nuevoTerreno = terrenoManager.addTerreno(
                                    nombre: nombre,
                                    tipoCultivo: tipoCultivo, // Este es el cultivo principal
                                    tipoSuelo: tipoSuelo,
                                    dimension: dimension
                                )
                                self.createdTerrenoId = nuevoTerreno.id // Guardamos el ID del terreno creado
                                self.navigateToDetail = true // Activamos la navegación
                            } else {
                                // Mostrar alguna alerta de campos vacíos
                                print("Por favor, completa todos los campos.")
                            }
                        } label: {
                            Text("CREAR TERRENO") // Cambiado para claridad
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background( Color(#colorLiteral(red: 0.02146766335, green: 0.5795219541, blue: 0.4361915588, alpha: 1)))
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                        
                        // Navegación hacia TerrenoDetailView
                        // Se activa cuando navigateToDetail es true y createdTerrenoId tiene un valor
                        NavigationLink(
                            destination: Group { // Usamos Group para poder tener el if let
                                if let terrenoId = createdTerrenoId {
                                    TerrenoDetailView(terrenoManager: terrenoManager, terrenoId: terrenoId)
                                } else {
                                    // Vista de fallback o error si no hay ID (no debería pasar si la lógica es correcta)
                                    Text("Error: No se pudo cargar el detalle del terreno.")
                                }
                            },
                            isActive: $navigateToDetail
                        ) {
                            EmptyView()
                        }
                        
                    } // Fin VStack del formulario
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(Color.white)
                            .ignoresSafeArea(edges: .bottom)
                    )
                } // Fin VStack principal de la pantalla
            } // Fin ZStack
            .navigationBarHidden(true) // Si quieres ocultar la barra de navegación de este NavigationStack
        } // Fin NavigationStack
        
        
    } // Fin body
}

// Estilo para los TextField (sin cambios)
private struct FormFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
    }
}

// Preview (ahora necesita un TerrenoManager)
struct FormularioView_Previews: PreviewProvider {
    static var previews: some View {
        // Creamos una instancia de TerrenoManager para el preview
        FormularioView(terrenoManager: TerrenoManager())
            .previewDevice("iPhone 14 Pro")
    }
}

// El #Preview también necesita el manager
#Preview {
    FormularioView(terrenoManager: TerrenoManager())
}
