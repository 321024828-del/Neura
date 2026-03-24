//
//  ContentView.swift
//  NEURA
//
//  Created by DEVELOP15 on 24/03/26.
//

import SwiftUI
import AVFoundation
import Speech
import Charts // <-- NUEVO: Importamos el framework de gráficas nativas

// MARK: - Models
struct StudentProfile: Codable, Identifiable {
    var id: String { accountNumber }
    var name: String
    var degree: String
    var accountNumber: String
    var email: String
    var password: String
    var phone: String
    var avatar: AvatarChoice? = nil
}

enum AvatarChoice: String, CaseIterable, Codable, Identifiable {
    case dog, cat
    var id: String { rawValue }
    var title: String { self == .dog ? "Perrito" : "Gatito" }
    var systemImage: String { self == .dog ? "pawprint.fill" : "pawprint" }
}

struct SleepEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    var sleptWell: Bool
    var hours: Int
}

enum Mood: String, CaseIterable, Codable, Identifiable {
    case anxious, sad, angry, calm, happy
    var id: String { rawValue }
    var emoji: String {
        switch self {
        case .anxious: return "😟"
        case .sad: return "😢"
        case .angry: return "😠"
        case .calm: return "😌"
        case .happy: return "😄"
        }
    }
    var title: String {
        switch self {
        case .anxious: return "Ansioso"
        case .sad: return "Triste"
        case .angry: return "Enojado"
        case .calm: return "Tranquilo"
        case .happy: return "Feliz"
        }
    }
}

// MARK: - Persistence Helpers
extension AppStorage where Value == String {
    init(_ key: String) { self.init(wrappedValue: "", key) }
}

// MARK: - Design Components
struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct AnimatedBackground: View {
    @State private var start = UnitPoint(x: 0, y: -2)
    @State private var end = UnitPoint(x: 4, y: 0)
    
    var body: some View {
        LinearGradient(colors: [Color.indigo.opacity(0.8), Color.teal.opacity(0.6), Color.purple.opacity(0.8)], startPoint: start, endPoint: end)
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 8).repeatForever(autoreverses: true)) {
                    start = UnitPoint(x: 1, y: -1)
                    end = UnitPoint(x: 0, y: 2)
                }
            }
    }
}

// MARK: - 1. Root View
struct ContentView: View {
    @AppStorage("profile_json") private var profileJSON: String = ""
    @State private var profile: StudentProfile? = nil

    var body: some View {
        Group {
            if let p = profile {
                if p.avatar == nil {
                    AvatarSelectionView(profile: p) { choice in
                        var updated = p
                        updated.avatar = choice
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            self.profile = updated
                            saveProfile(updated)
                        }
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
                } else {
                    HomeAfterProfileView(profile: p, onUpdate: { updatedProfile in
                        self.profile = updatedProfile
                        saveProfile(updatedProfile)
                    })
                    .transition(.opacity)
                }
            } else {
                NavigationStack {
                    OnboardingFlowView(onFinished: { p in
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            self.profile = p
                            saveProfile(p)
                        }
                    })
                }
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
            }
        }
        .animation(.default, value: profile?.accountNumber)
        .animation(.default, value: profile?.avatar)
        .onAppear { loadProfile() }
        .tint(.indigo)
    }

    private func saveProfile(_ p: StudentProfile) {
        if let data = try? JSONEncoder().encode(p) {
            profileJSON = String(data: data, encoding: .utf8) ?? ""
        }
    }
    private func loadProfile() {
        guard !profileJSON.isEmpty, let data = profileJSON.data(using: .utf8), let p = try? JSONDecoder().decode(StudentProfile.self, from: data) else { return }
        self.profile = p
    }
}

// MARK: - 2. Onboarding
struct OnboardingFlowView: View {
    var onFinished: (StudentProfile) -> Void
    @State private var isFloating = false

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 30) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 180, height: 180)
                        .blur(radius: 15)
                    
                    Image(systemName: "brain.head.profile")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(.white)
                        .offset(y: isFloating ? -15 : 15)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isFloating)
                }
                
                VStack(spacing: 12) {
                    Text("NEURA")
                        .font(.system(size: 54, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    Text("Cuidando tu Salud Mental")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.9))
                }
                
                Spacer()
                
                NavigationLink(destination: RegistrationView(onComplete: onFinished)) {
                    Text("Comenzar")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.white)
                        .foregroundStyle(.indigo)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
                .buttonStyle(BounceButtonStyle())
            }
        }
        .onAppear { isFloating = true }
    }
}

// MARK: - 3. Registro
struct RegistrationView: View {
    var onComplete: (StudentProfile) -> Void
    @State private var name = ""
    @State private var degree = ""
    @State private var account = ""
    @State private var email = ""
    @State private var password = ""
    @State private var phone = ""

    var body: some View {
        Form {
            Section {
                TextField("Nombre completo", text: $name)
                TextField("Carrera", text: $degree)
                TextField("Número de cuenta", text: $account).keyboardType(.numberPad)
            } header: {
                Text("Datos Universitarios").font(.subheadline)
            }
            
            Section {
                TextField("Correo institucional", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                SecureField("Contraseña", text: $password)
                TextField("Celular", text: $phone).keyboardType(.phonePad)
            } header: {
                Text("Contacto y Seguridad").font(.subheadline)
            }
        }
        .navigationTitle("Crea tu cuenta")
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                let profile = StudentProfile(name: name, degree: degree, accountNumber: account, email: email, password: password, phone: phone)
                onComplete(profile)
            }) {
                Text("Siguiente")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValid ? Color.indigo : Color.gray.opacity(0.3))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: isValid ? 5 : 0)
                    .padding()
            }
            .disabled(!isValid)
            .buttonStyle(BounceButtonStyle())
        }
    }

    private var isValid: Bool {
        !name.isEmpty && !degree.isEmpty && !account.isEmpty && !email.isEmpty && !password.isEmpty && !phone.isEmpty
    }
}

// MARK: - 5. Elección de avatar
struct AvatarSelectionView: View {
    var profile: StudentProfile
    var onSelect: (AvatarChoice) -> Void
    @State private var appearAnimation = false

    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                Text("¡Hola, \(profile.name.components(separatedBy: " ").first ?? "")!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.indigo)
                
                Text("Elige al compañero que te guiará en tu proceso de bienestar mental.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 60)
            .offset(y: appearAnimation ? 0 : 20)
            .opacity(appearAnimation ? 1 : 0)
            
            HStack(spacing: 24) {
                ForEach(AvatarChoice.allCases) { choice in
                    Button(action: { onSelect(choice) }) {
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(choice == .dog ? Color.orange.opacity(0.15) : Color.teal.opacity(0.15))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: choice.systemImage)
                                    .font(.system(size: 60))
                                    .foregroundStyle(choice == .dog ? .orange : .teal)
                            }
                            
                            Text(choice.title)
                                .font(.title2.bold())
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                        .background(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
                        )
                    }
                    .buttonStyle(BounceButtonStyle())
                }
            }
            .padding(.horizontal, 24)
            .offset(y: appearAnimation ? 0 : 40)
            .opacity(appearAnimation ? 1 : 0)
            
            Spacer()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.1)) {
                appearAnimation = true
            }
        }
    }
}

// MARK: - Home After Profile
struct HomeAfterProfileView: View {
    @State var profile: StudentProfile
    var onUpdate: (StudentProfile) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Tu espacio seguro,")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Text(profile.name.components(separatedBy: " ").first ?? "")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                        }
                        Spacer()
                        
                        if let avatar = profile.avatar {
                            NavigationLink(destination: PetCareView()) {
                                Image(systemName: avatar.systemImage)
                                    .font(.system(size: 28))
                                    .foregroundStyle(.white)
                                    .padding(16)
                                    .background(Circle().fill(LinearGradient(colors: [.indigo, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)))
                                    .shadow(color: .indigo.opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(BounceButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        HomeCard(title: "Sueño", icon: "moon.zzz.fill", color: .indigo, destination: AnyView(SleepTrackerView()))
                        HomeCard(title: "Emociones", icon: "face.smiling.fill", color: .orange, destination: AnyView(MoodCalendarView()))
                        HomeCard(title: "Afirmación", icon: "sparkles", color: .yellow, destination: AnyView(DailyAffirmationView()))
                        HomeCard(title: "Asistente", icon: "waveform.circle.fill", color: .purple, destination: AnyView(AssistantJournalView()))
                    }
                    .padding(.horizontal)

                    NavigationLink(destination: HelpActionsView()) {
                        HStack {
                            Image(systemName: "lifepreserver.fill").foregroundStyle(.white)
                            Text("Centro de Ayuda y Emergencias")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(.white.opacity(0.7))
                        }
                        .padding()
                        .background(Color.red.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                    }
                    .buttonStyle(BounceButtonStyle())
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        withAnimation { UserDefaults.standard.removeObject(forKey: "profile_json") }
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }
}

struct HomeCard: View {
    let title: String
    let icon: String
    let color: Color
    let destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 34))
                    .foregroundStyle(color)
                    .padding(12)
                    .background(color.opacity(0.15))
                    .clipShape(Circle())
                
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 15, x: 0, y: 8)
            )
        }
        .buttonStyle(BounceButtonStyle())
    }
}

// MARK: - 6. Seguimiento de sueño (CON GRÁFICAS DE BARRAS Y ALERTAS)
struct SleepTrackerView: View {
    @State private var sleptWell: Bool = true
    @State private var hours: Int = 8
    @AppStorage("sleep_entries_json") private var entriesJSON: String = ""
    @State private var entries: [SleepEntry] = []
    
    @State private var showFeedbackAlert = false
    @State private var feedbackTitle = ""
    @State private var feedbackMessage = ""

    var body: some View {
        Form {
            // GRÁFICO VISUAL (Sólo se muestra si hay datos)
            if !entries.isEmpty {
                Section("Tendencia (Últimos 7 días)") {
                    Chart {
                        // Tomamos los 7 más recientes, y les hacemos reverse para que
                        // cronológicamente el más antiguo salga a la izquierda.
                        ForEach(entries.prefix(7).reversed()) { entry in
                            BarMark(
                                x: .value("Fecha", entry.date, unit: .day),
                                y: .value("Horas", entry.hours)
                            )
                            // Color dinámico: verde si cumple la meta, naranja/rojo si no.
                            .foregroundStyle(entry.hours >= 7 ? Color.green.gradient : (entry.hours >= 5 ? Color.orange.gradient : Color.red.gradient))
                            .cornerRadius(6)
                        }
                        
                        // Línea meta punteada
                        RuleMark(y: .value("Meta", 7))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                            .foregroundStyle(.indigo)
                            .annotation(position: .top, alignment: .leading) {
                                Text("Meta: 7h")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.indigo)
                            }
                    }
                    .frame(height: 200)
                    .padding(.vertical, 8)
                    // Hacemos que el eje X muestre el nombre corto del día o fecha
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { _ in
                            AxisValueLabel(format: .dateTime.weekday(), centered: true)
                        }
                    }
                }
            }
            
            Section {
                Picker("Calidad", selection: $sleptWell) {
                    Text("Muy bien").tag(true)
                    Text("No pude dormir").tag(false)
                }.pickerStyle(.segmented)
                
                Stepper(value: $hours, in: 0...14) {
                    HStack {
                        Image(systemName: "clock.fill").foregroundStyle(.indigo)
                        Text("Horas dormidas: **\(hours)**")
                    }
                }
                
                HStack {
                    Image(systemName: sleepStatus.icon)
                    Text(sleepStatus.text).font(.caption)
                }
                .foregroundStyle(sleepStatus.color)
                .padding(.vertical, 4)
                
                Button(action: saveToday) {
                    Text("Guardar registro de hoy")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                        .padding(.vertical, 4)
                }
                .listRowBackground(Color.indigo)
                .buttonStyle(BounceButtonStyle())
                
            } header: {
                Text("Registro de Hoy").font(.subheadline)
            }
            
            if !entries.isEmpty {
                Section("Historial Completo") {
                    ForEach(entries) { e in
                        HStack {
                            Text(e.date, style: .date).foregroundStyle(.secondary)
                            Spacer()
                            Text("\(e.hours)h").bold()
                            Text(e.sleptWell ? "🌙" : "⚠️")
                        }
                    }
                }
            }
        }
        .navigationTitle("Sueño")
        .onAppear { load() }
        .alert(isPresented: $showFeedbackAlert) {
            Alert(
                title: Text(feedbackTitle),
                message: Text(feedbackMessage),
                dismissButton: .default(Text("Entendido"))
            )
        }
    }
    
    private var sleepStatus: (text: String, color: Color, icon: String) {
        if hours >= 7 {
            return ("Excelente tiempo de descanso.", .green, "checkmark.circle.fill")
        } else if hours >= 5 {
            return ("Cuidado, es menos de lo recomendado.", .orange, "exclamationmark.triangle.fill")
        } else {
            return ("Alerta: Riesgo de agotamiento severo.", .red, "exclamationmark.octagon.fill")
        }
    }
    
    private func saveToday() {
        let today = Calendar.current.startOfDay(for: Date())
        var list = entries.filter { Calendar.current.startOfDay(for: $0.date) != today }
        list.append(SleepEntry(id: UUID(), date: Date(), sleptWell: sleptWell, hours: hours))
        entries = list.sorted { $0.date > $1.date }
        if let data = try? JSONEncoder().encode(entries) { entriesJSON = String(data: data, encoding: .utf8) ?? "" }
        
        if hours >= 7 {
            feedbackTitle = "¡Felicidades!"
            feedbackMessage = "Has dormido lo suficiente. ¡Sigue así, tu cuerpo y tu cerebro te lo agradecerán durante el día!"
        } else if hours >= 5 {
            feedbackTitle = "Advertencia"
            feedbackMessage = "Dormiste menos de lo ideal. Intenta no desvelarte tanto hoy para recuperar esa energía vital."
        } else {
            feedbackTitle = "¡Alerta Crítica!"
            feedbackMessage = "Estás durmiendo muy poco. El descanso deficiente afecta directamente tu salud, estrés y aprendizaje. ¡Por favor, intenta tomar una siesta o dormir temprano hoy!"
        }
        
        showFeedbackAlert = true
    }
    
    private func load() {
        guard let data = entriesJSON.data(using: .utf8), let list = try? JSONDecoder().decode([SleepEntry].self, from: data) else { return }
        withAnimation { entries = list }
    }
}

// MARK: - 7. Calendario de emociones
struct MoodCalendarView: View {
    @AppStorage("mood_by_day_json") private var moodJSON: String = ""
    @State private var moodByDay: [String: Mood] = [:]

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                Text("¿Cómo te sientes hoy?").font(.title2).bold()
                
                HStack(spacing: 16) {
                    ForEach(Mood.allCases) { m in
                        Button(action: { select(m) }) {
                            Text(m.emoji)
                                .font(.system(size: 44))
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                )
                        }
                        .buttonStyle(BounceButtonStyle())
                    }
                }
            }
            .padding(.vertical)
            
            List(daysForCurrentMonth(), id: \.self) { key in
                HStack {
                    Text(key).font(.subheadline)
                    Spacer()
                    if let mood = moodByDay[key] {
                        Text(mood.emoji).font(.title3)
                            .transition(.scale)
                    } else {
                        Text("—").foregroundStyle(.tertiary)
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Emociones")
        .background(Color(.systemGroupedBackground))
        .onAppear { load() }
    }

    private func select(_ mood: Mood) {
        let key = dayKey(Date())
        withAnimation(.spring) { moodByDay[key] = mood }
        save()
    }
    private func dayKey(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: date)
    }
    private func daysForCurrentMonth() -> [String] {
        let cal = Calendar.current
        let now = Date()
        let range = cal.range(of: .day, in: .month, for: now) ?? 1..<31
        let comps = cal.dateComponents([.year, .month], from: now)
        return range.compactMap { day -> String? in
            var c = comps; c.day = day; guard let d = cal.date(from: c) else { return nil }
            return dayKey(d)
        }
    }
    private func save() {
        if let data = try? JSONEncoder().encode(moodByDay.mapValues { $0.rawValue }) { moodJSON = String(data: data, encoding: .utf8) ?? "" }
    }
    private func load() {
        guard let data = moodJSON.data(using: .utf8), let dict = try? JSONDecoder().decode([String:String].self, from: data) else { return }
        moodByDay = dict.compactMapValues { Mood(rawValue: $0) }
    }
}

// MARK: - 8. Afirmación diaria
struct DailyAffirmationView: View {
    @State private var isPulsing = false
    private let affirmations = [
        "Soy capaz y valioso.",
        "Merezco descansar y cuidar de mí.",
        "Hoy doy un paso a la vez.",
        "Mi bienestar es una prioridad.",
        "Respiro, me calmo y continúo."
    ]
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: 30) {
                Image(systemName: "sparkles")
                    .font(.system(size: 80))
                    .foregroundStyle(.yellow)
                    .scaleEffect(isPulsing ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing)
                
                Text("Afirmación del día")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                
                Text("\"\(affirmations.randomElement() ?? "Confío en mí.")\"")
                    .font(.system(size: 30, weight: .medium, design: .serif))
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(30)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, 20)
            }
        }
        .onAppear { isPulsing = true }
        .navigationTitle("Afirmación")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 9. Asistente
struct AssistantJournalView: View {
    @State private var inputText: String = ""
    @State private var messages: [String] = []
    @State private var isSpeaking: Bool = false
    @State private var isRecording: Bool = false
    @State private var lastAssistantResponse: String = ""
    @State private var goToHelp: Bool = false
    
    @State private var currentContext: ConversationContext = .neutral
    enum ConversationContext {
        case neutral, offeredBreathing, offeredStudyTip, offeredCrisisHelp
    }

    private let tts = AVSpeechSynthesizer()
    var body: some View {
        VStack {
            NavigationLink("", destination: HelpActionsView(), isActive: $goToHelp).hidden()
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(messages.enumerated()), id: \.offset) { index, msg in
                            let isUser = msg.hasPrefix("Tú:")
                            HStack {
                                if isUser { Spacer() }
                                Text(msg.replacingOccurrences(of: "Tú: ", with: "").replacingOccurrences(of: "Asistente: ", with: ""))
                                    .padding()
                                    .background(isUser ? Color.indigo : Color(.systemGray5))
                                    .foregroundStyle(isUser ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                                if !isUser { Spacer() }
                            }
                            .id(index)
                            .transition(.scale(scale: 0.8, anchor: isUser ? .bottomTrailing : .bottomLeading).combined(with: .opacity))
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    withAnimation { proxy.scrollTo(messages.count - 1, anchor: .bottom) }
                }
            }
            
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Button(action: { isRecording.toggle() }) {
                        Image(systemName: isRecording ? "mic.fill" : "mic")
                            .font(.system(size: 22))
                            .foregroundStyle(isRecording ? .red : .indigo)
                    }
                    .buttonStyle(BounceButtonStyle())
                    
                    TextField("Escribe cómo te sientes...", text: $inputText)
                        .padding(14)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .onSubmit { send() }
                    
                    Button(action: send) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                            .padding(14)
                            .background(Color.indigo)
                            .clipShape(Circle())
                    }
                    .buttonStyle(BounceButtonStyle())
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .padding(.top, 12)
            .background(Color(.systemBackground).shadow(color: .black.opacity(0.05), radius: 10, y: -5))
        }
        .navigationTitle("Asistente Neura")
        .onDisappear { tts.stopSpeaking(at: .immediate) }
    }

    private func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        withAnimation(.spring) { messages.append("Tú: \(text)") }
        inputText = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            generateResponse(for: text)
        }
    }
    
    private func generateResponse(for text: String) {
        let lower = text.lowercased()
        var response = ""
        
        if currentContext != .neutral {
            let isYes = containsAny(lower, ["sí", "si", "ok", "claro", "por favor", "va", "dale"])
            let isNo = containsAny(lower, ["no", "después", "luego", "ahorita no"])
            
            if isYes {
                switch currentContext {
                case .offeredBreathing:
                    response = "Perfecto. Inhala profundamente por 4 segundos... sostén el aire 4 segundos... y exhala suavemente por 6. Repite esto 3 veces. Cuando termines, cuéntame si te sientes un poco mejor."
                case .offeredStudyTip:
                    response = "Intenta la técnica Pomodoro: 25 minutos de enfoque total y 5 de descanso. Levántate a tomar agua en tus descansos. ¡Tú puedes con esto!"
                case .offeredCrisisHelp:
                    response = "Voy a abrir la sección de ayuda ahora mismo. Por favor, contacta a alguien, no estás solo."
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { goToHelp = true }
                default: break
                }
                currentContext = .neutral
            } else if isNo {
                response = "Entiendo perfectamente, no hay presión. ¿Qué más tienes en mente? Aquí estoy para escucharte."
                currentContext = .neutral
            } else {
                currentContext = .neutral
                response = analyzeIntent(lower)
            }
        } else {
            response = analyzeIntent(lower)
        }
        
        lastAssistantResponse = response
        withAnimation(.spring) { messages.append("Asistente: \(response)") }
        speak(response)
    }
    
    private func analyzeIntent(_ lower: String) -> String {
        if containsAny(lower, ["matarm", "suicid", "ya no quiero vivir", "hacerme daño", "morir"]) {
            currentContext = .offeredCrisisHelp
            return "Siento muchísimo que estés pasando por esto. Tu vida es invaluable y hay personas capacitadas listas para apoyarte. ¿Te abro la pantalla de emergencias para contactar ayuda inmediatamente?"
        }
        if containsAny(lower, ["ansiedad", "ansios", "nervios", "pánico", "miedo", "angustia"]) {
            currentContext = .offeredBreathing
            return "La ansiedad puede sentirse muy pesada, pero es una ola que pasará. ¿Te gustaría que te guíe con un ejercicio rápido de respiración para calmar el sistema nervioso?"
        }
        if containsAny(lower, ["estrés", "estresad", "examen", "tarea", "universidad", "proyecto", "agotad", "presión"]) {
            currentContext = .offeredStudyTip
            return "La carga académica y diaria a veces es abrumadora. Tomar pausas estratégicas ayuda a que tu cerebro retenga mejor la información. ¿Te comparto un tip rápido de estudio y descanso?"
        }
        if containsAny(lower, ["depresión", "triste", "llorar", "solo", "sola", "vacío", "desánimo"]) {
            return "Lamento que te sientas así hoy. Está bien no estar bien todo el tiempo. Permítete sentirlo, pero recuerda que es temporal. Un pequeño logro como tomar un vaso con agua o salir al sol cuenta muchísimo hoy."
        }
        if containsAny(lower, ["dormir", "insomnio", "cansad", "sueño", "desvelo", "no descanso"]) {
            return "El descanso es la base de todo. Intenta dejar las pantallas una hora antes de dormir y escucha ruido blanco. ¿Ya registraste tus horas de sueño en la sección principal hoy?"
        }
        if containsAny(lower, ["bien", "feliz", "genial", "alegre", "tranquil", "mejor"]) {
            return "¡Qué gusto leer eso! Celebrar los días buenos y reconocer tu progreso es súper importante. ¿Qué hizo que tu día fuera tan positivo?"
        }
        
        let fallbacks = [
            "Te entiendo. Cuéntame un poco más sobre eso.",
            "Es muy válido lo que mencionas. ¿Cómo te hace sentir eso físicamente?",
            "Aquí estoy para apoyarte. ¿Hay algo específico en lo que te gustaría enfocarte hoy?",
            "Gracias por compartir esto conmigo. A veces, simplemente escribirlo es un gran primer paso para procesarlo."
        ]
        return fallbacks.randomElement() ?? "Te escucho."
    }

    private func containsAny(_ text: String, _ keywords: [String]) -> Bool {
        keywords.contains { text.contains($0) }
    }

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-MX") ?? AVSpeechSynthesisVoice(language: "es-ES")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        tts.speak(utterance)
    }
}

// MARK: - 10. Acciones de ayuda
struct HelpActionsView: View {
    @Environment(\.openURL) private var openURL
    var body: some View {
        List {
            Section("Contactos de emergencia") {
                Button(action: { call("5550000000") }) {
                    HStack {
                        Image(systemName: "phone.circle.fill").foregroundStyle(.red).font(.title2)
                        Text("Psicólogo Universitario").bold()
                    }
                }
                Button(action: { call("911") }) {
                    HStack {
                        Image(systemName: "cross.circle.fill").foregroundStyle(.red).font(.title2)
                        Text("Emergencias (911)").bold()
                    }
                }
            }
            Section("Tu Compañero") {
                NavigationLink(destination: PetCareView()) {
                    Label("Ir a cuidar a tu avatar", systemImage: "heart.fill").foregroundStyle(.pink)
                }
            }
        }
        .navigationTitle("Centro de Ayuda")
    }
    private func call(_ number: String) {
        guard let url = URL(string: "tel://\(number)") else { return }
        openURL(url)
    }
}

// MARK: - 11. Cuidado del Avatar
struct PetCareView: View {
    @AppStorage("pet_care_points") private var carePoints: Int = 0
    @AppStorage("pet_accessories") private var accessories: Int = 0
    @State private var petScale = 1.0

    var body: some View {
        VStack(spacing: 30) {
            Text("Mimos y Cuidado")
                .font(.largeTitle).bold()
            
            ZStack {
                Circle()
                    .fill(Color.teal.opacity(0.15))
                    .frame(width: 240, height: 240)
                
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 120))
                    .foregroundStyle(.teal)
                    .scaleEffect(petScale)
                
                if accessories > 0 {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.yellow)
                        .offset(x: 50, y: -70)
                        .scaleEffect(petScale)
                }
            }
            .padding(.vertical, 40)
            
            HStack(spacing: 50) {
                VStack {
                    Text("\(carePoints)").font(.system(size: 40, weight: .bold, design: .rounded)).foregroundStyle(.indigo)
                    Text("Cuidado").font(.callout).foregroundStyle(.secondary)
                }
                VStack {
                    Text("\(accessories)").font(.system(size: 40, weight: .bold, design: .rounded)).foregroundStyle(.orange)
                    Text("Regalos").font(.callout).foregroundStyle(.secondary)
                }
            }
            
            HStack(spacing: 20) {
                Button(action: { feedPet() }) {
                    Label("Alimentar", systemImage: "heart.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pink)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(BounceButtonStyle())
                
                Button(action: { giveGift() }) {
                    Label("Regalo", systemImage: "gift.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(BounceButtonStyle())
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func feedPet() {
        carePoints += 1
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { petScale = 1.3 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring()) { petScale = 1.0 }
        }
    }
    
    private func giveGift() {
        accessories += 1
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { petScale = 1.3 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring()) { petScale = 1.0 }
        }
    }
}

#Preview {
    ContentView()
}

