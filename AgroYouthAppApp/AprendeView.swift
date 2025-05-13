//
//  AprendeView.swift
//  Asira
//
//  Created by Mario Moreno on 5/13/25.
//

//
//  InicioView.swift
//  AppHack
//
//  Created by Dilhan Mora on 12/05/25.
//

import SwiftUI

public struct AprendeView: View {
    
    @Namespace private var namespace
    @State private var showDetail: Bool = false
    @State private var currentData: ListData? = nil
    
    @State private var  datas = [ListData]()
    
    public init() {}
    public var body: some View {
        ZStack {
            List(datas) { data in
                ListRow(namespace: namespace, data: data)
#if os(iOS)
                    .listRowSeparator(.hidden)
#endif
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 8)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 6)
                    .onTapGesture {
                        DispatchQueue.main.async {
                            withAnimation(.transitionSpring) {
                                currentData = data
                                showDetail = true
                            }
                        }
                    }
            }
            .listStyle(.plain)
            .opacity(showDetail ? 0.0 : 1.0)
            if showDetail {
                if let data = currentData {
                    DetailView(namespace: namespace, data: data, show: $showDetail)
                }
            }
        }
        .animation(.transitionSpring, value: showDetail)
        .onAppear {
            DispatchQueue.main.async {
                datas = [
                    ListData(
                        title: "🌱 Siembra",
                        name: "Inicio de ciclo",
                        description: "Aprende cuándo y cómo sembrar.",
                        imageName: "siembra",
                        detalle: "La siembra es el punto de partida del ciclo agrícola. En las comunidades rurales mexicanas, este proceso suele hacerse de forma manual usando herramientas como el bastón sembrador o la coa. Antes de sembrar, el productor limpia y prepara el terreno, eliminando restos del cultivo anterior, maleza y piedras. A veces se utiliza el arado animal o mecánico si se cuenta con los recursos.La siembra puede hacerse a golpe (abriendo un hoyo con el bastón y dejando caer la semilla) o por surcos. En algunos casos, se mezcla la semilla con ceniza, ajo o chile molido para evitar que la coman los insectos. La época de siembra depende mucho del tipo de cultivo y del inicio de la temporada de lluvias.Sembrar demasiado temprano puede hacer que la semilla se seque antes de germinar, y demasiado tarde reduce el tiempo de crecimiento. Es importante respetar la profundidad y el espaciamiento correcto para asegurar que cada planta tenga suficiente luz, agua y nutrientes. Muchas decisiones durante esta etapa se toman por experiencia heredada, aunque una guía técnica puede mejorar notablemente los resultados."
                    ),
                    ListData(
                        title: "💧 Riego",
                        name: "Uso del agua",
                        description: "Evita el desperdicio en tu parcela.",
                        imageName: "riego",
                        detalle: "El riego es una práctica crítica para el éxito del cultivo, especialmente en regiones donde las lluvias son escasas o irregulares. La mayoría de pequeños productores en México dependen del temporal, pero cuando tienen acceso a agua, utilizan riego por gravedad, canales o simplemente cubetas.Estos métodos tradicionales suelen desperdiciar mucha agua. Métodos más eficientes como el riego por goteo o microaspersión reducen el consumo, pero requieren inversión y capacitación. Existen versiones económicas que pueden hacerse con mangueras perforadas y garrafones colocados en alto para generar presión por gravedad.También se puede conservar la humedad del suelo aplicando mulching (acolchado), es decir, cubriendo la base de las plantas con paja, hojas secas o plástico negro. Esto reduce la evaporación y mejora la temperatura del suelo. Capacitar al agricultor sobre el manejo del riego puede marcar una gran diferencia, ya que regar de más también es dañino: puede pudrir las raíces o favorecer plagas."
                    ),
                    ListData(
                        title: "🌿 Mantenimiento",
                        name: "Cuidados del cultivo",
                        description: "Deshierba y fertiliza bien.",
                        imageName: "deshierbe",
                        detalle: "Después de la siembra, el cultivo necesita atención constante. El deshierbe es una práctica fundamental que consiste en quitar la maleza que compite con el cultivo por agua, luz y nutrientes. Se realiza con machete, azadón o a mano, dependiendo del tipo de cultivo.La fertilización también es esencial. Algunos agricultores utilizan abonos orgánicos como estiércol, compost o bocashi, mientras que otros usan fertilizantes químicos. Sin asesoría, la dosificación puede ser incorrecta. Además, algunas prácticas como el aporque (juntar tierra en la base de la planta) ayudan a fortalecer el tallo y proteger las raíces.El monitoreo constante permite detectar problemas temprano, como plantas amarillas, presencia de plagas o deficiencias de nutrientes. Muchas veces el conocimiento de estas prácticas se transmite oralmente, lo que puede limitar el acceso a nuevas técnicas. Un apoyo visual o tutorial puede marcar la diferencia."
                    ),
                    ListData(
                        title: "🐛 Plagas",
                        name: "Protección",
                        description: "Identifica y controla plagas comunes.",
                        imageName: "plagas",
                        detalle: "Las plagas son uno de los mayores enemigos del productor. Gusano cogollero, pulgones, trips, hongos y bacterias son comunes en muchas regiones. Detectarlas a tiempo es crucial, pero muchos agricultores no saben identificar sus síntomas o no tienen acceso a productos para tratarlas.Existen métodos tradicionales efectivos: trampas de feromonas, repelentes hechos con ajo, chile, cebolla, jabón potásico o infusiones de plantas. Sin embargo, su efectividad depende del momento de aplicación. También es importante la rotación de cultivos y el uso de plantas repelentes como la caléndula o la albahaca.Un gran problema es la automedicación del cultivo: se aplican productos vencidos, mal diluidos o en dosis equivocadas, lo cual daña el ambiente y la salud. Educar sobre el manejo integrado de plagas (MIP) puede reducir costos y riesgos."
                    ),
                    ListData(
                        title: "🌽 Cosecha",
                        name: "Recolección",
                        description: "Elige el momento correcto para cosechar.",
                        imageName: "cosecha",
                        detalle: "La cosecha se realiza cuando el fruto, grano o hortaliza ha alcanzado su punto óptimo de maduración. En maíz, por ejemplo, se espera a que las hojas y mazorcas estén secas. En frijol, cuando las vainas están crujientes. Una cosecha prematura puede reducir el rendimiento y una tardía aumenta el riesgo de enfermedades o pérdidas por lluvia.Se realiza manualmente en la mayoría de los casos. El trabajo lo hace la familia o vecinos que se ayudan entre sí. El transporte hasta la casa o al punto de venta puede ser una barrera importante, sobre todo en comunidades sin acceso vehicular. El uso de costales, animales de carga o carretillas improvisadas es común.Después de la cosecha, se realiza una selección del grano o producto, descartando el que esté dañado, con hongos o mordido. Este proceso es fundamental para obtener buen precio y evitar problemas en el almacenaje."
                    ),
                    ListData(
                        title: "🏠 Almacenaje",
                        name: "Postcosecha",
                        description: "Conserva lo que sembraste.",
                        imageName: "almacenaje",
                        detalle: "Una vez cosechado, el grano debe secarse completamente al sol para evitar que se enmohezca. Luego se almacena en costales, tambos, trojes o bolsas selladas. Muchas familias guardan su cosecha en la cocina, el patio o una bodega improvisada.Para evitar plagas como el gorgojo, se usan prácticas como mezclar el grano con ceniza, chile seco, ajo o usar hojas de aguacate. También existen bolsas herméticas y silos metálicos familiares que conservan el grano por varios meses sin necesidad de químicos.La humedad es el principal enemigo: un grano mal seco se fermenta y se pierde. Además, la mala ventilación favorece la aparición de hongos. Capacitar al productor sobre técnicas de secado, manejo postcosecha y conservación natural puede ayudarle a conservar mejor su esfuerzo."
                    ),
                    ListData(
                        title: "🛒 Venta",
                        name: "Comercialización",
                        description: "Vende sin intermediarios.",
                        imageName: "venta",
                        detalle: "Vender la cosecha es uno de los momentos más difíciles para el pequeño agricultor. Muchos venden a intermediarios que llegan directo al campo, pagan en efectivo pero a precios bajos. No hay contrato, garantía ni certeza del pago justo. Otros llevan su producto al mercado local o a la plaza, donde deben competir con revendedores.La mayoría desconoce el precio real del producto en otras ciudades, no sabe calcular su costo de producción, ni cómo empacar o presentar su producto para que sea más atractivo. Algunos ni siquiera tienen transporte para llevarlo a vender.Existen programas como el de “Pequeño Productor Cuentas Conmigo” de Walmart que buscan dar acceso directo al mercado, pero requieren cumplir ciertos estándares. Una herramienta que conecte directamente al productor con compradores, que enseñe a calcular su ganancia y evitar pérdidas, puede ser un cambio enorme en su economía familiar."
                    )
                ]
            }
        }
    }
}

fileprivate
extension Animation {
    static var transitionSpring: Animation {
       self.spring(response: 0.48, dampingFraction: 0.82, blendDuration: 0.7)
    }
}

fileprivate
struct ListData: Identifiable {
    var id = UUID()
    var title: String
    var name: String
    var description: String
    var imageName: String
    var detalle: String // ← esto es lo nuevo
}

fileprivate
struct ListRow: View {
    
    let namespace: Namespace.ID
    let data: ListData
    
    var body: some View {
        NamespaceView(namespace: namespace, data: data)
            .frame(height: 280)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        
        
    }
}

fileprivate
struct DetailView: View {
    
    let namespace: Namespace.ID
    let data: ListData
    @Binding var show: Bool
    @State private var showText: Bool = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack {
                    NamespaceView(namespace: namespace, data: data)
                        .frame(height: 460)
                    
                    ZStack {
                        if showText {
                            Text(data.detalle)
                                .lineLimit(nil)
                                .padding(12)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .animation(.transitionSpring, value: showText)
                    .opacity(0.5)
                    .onAppear {
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut) {
                                showText = true
                            }
                        }
                    }
                }
            }
            Image(systemName: "xmark")
                .padding(8)
                .background(Color.white)
                .foregroundColor(Color.black)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.16), radius: 3, x: 0, y: 0)
                .padding()
                .onTapGesture {
                    withAnimation(.transitionSpring) {
                        show = false
                    }
                }
        }
    }
}

fileprivate
struct NamespaceView: View {
    
    
    
    let namespace: Namespace.ID
    let data: ListData
    
    func iconFor(_ title: String) -> String {
        if title.contains("Siembra") { return "leaf.circle.fill" }
        if title.contains("Riego") { return "drop.circle.fill" }
        if title.contains("Deshierbe") || title.contains("Mantenimiento") { return "scissors" }
        if title.contains("Plagas") { return "ant.circle.fill" }
        if title.contains("Cosecha") { return "basket.fill" }
        if title.contains("Almacenaje") { return "archivebox.fill" }
        if title.contains("Venta") { return "cart.fill" }
        return "square.grid.2x2" // ícono por defecto
    }
    
    var imageTitleView: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { proxy in
                ZStack {
                    Image(data.imageName)
                        .resizable()
                        .scaledToFill()
                }
            }
            .clipShape(Rectangle())
            .matchedGeometryEffect(id: "image\(data.id)", in: namespace)
            
            VStack(alignment: .leading, spacing: -6) {
                let arrText = data.title.split(separator: "\n")
                ForEach(arrText, id: \.self) { text in
                    Text(text)
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(Color.white)
                }
            }
            .shadow(color: Color.black.opacity(0.16), radius: 3, x: 0, y: 0)
            .padding()
            .padding(.bottom, 56)
            .matchedGeometryEffect(id: "title\(data.id)", in: namespace)
        }
    }
    
    var bottomInfoView: some View {
        ZStack(alignment: .leading) {
            if #available(macOS 12.0, *) {
                Rectangle()
                    .fill(.thinMaterial)
            } else {
                Rectangle()
                    .fill(Color.black.opacity(0.5))
            }
            HStack(spacing: 0) {
                Image(systemName: iconFor(data.title))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .padding(6)
                VStack(alignment: .leading) {
                    Text(data.name)
                        .bold()
                    Text(data.description)
                        .font(.caption)
                        .opacity(0.8)
                }.offset(y: -2)
                Spacer()
                Capsule()
                    .fill(Color(#colorLiteral(red: 0.033477135, green: 0.5796292424, blue: 0.4401996732, alpha: 1)))
                    .overlay(
                        Text("ver")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                    )
                    .frame(width: 70, height: 28)
                    .padding(.trailing)
            }
            .padding(.leading, 6)
        }
        .frame(maxHeight: 61)
        .matchedGeometryEffect(id: "botttom\(data.id)", in: namespace)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            imageTitleView
            bottomInfoView
        }
    }
}

#Preview {
    AprendeView()
}
