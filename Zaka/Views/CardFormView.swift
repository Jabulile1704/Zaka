import SwiftUI
import SwiftData

struct CardFormView: View {
    let editing: LoyaltyCard?
    let onFinish: () -> Void

    @Environment(\.modelContext) private var context

    @State private var name = ""
    @State private var number = ""
    @State private var symbology: BarcodeSymbology = .code128
    @State private var tintHex = CardTint.palette[0]
    @State private var symbologyTouched = false
    @State private var scanning = false

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedNumber: String {
        number.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !trimmedName.isEmpty && symbology.accepts(trimmedNumber)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Store") {
                    TextField("Clicks ClubCard", text: $name)
                        .textInputAutocapitalization(.words)
                }

                Section {
                    TextField("Card number", text: $number)
                        .keyboardType(.numbersAndPunctuation)
                        .autocorrectionDisabled()
                        .monospaced()
                        .onChange(of: number) { _, new in
                            if !symbologyTouched {
                                symbology = .detected(for: new.trimmingCharacters(in: .whitespaces))
                            }
                        }

                    Button {
                        scanning = true
                    } label: {
                        Label("Scan the barcode", systemImage: "barcode.viewfinder")
                    }
                } header: {
                    Text("Number")
                } footer: {
                    if !trimmedNumber.isEmpty && !symbology.accepts(trimmedNumber) {
                        Text(symbology == .ean13
                             ? "That is not a valid 13-digit code. Check the digits, or pick Code 128."
                             : "This code cannot be drawn as \(symbology.label).")
                            .foregroundStyle(.red)
                    }
                }

                Section("Barcode type") {
                    Picker("Type", selection: $symbology) {
                        ForEach(BarcodeSymbology.allCases) { option in
                            Text(option.label).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: symbology) { _, _ in symbologyTouched = true }

                    Text(symbology.hint)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Colour") {
                    ColourRow(selection: $tintHex)
                }

                if symbology.accepts(trimmedNumber) {
                    Section("Preview") {
                        BarcodeView(number: trimmedNumber, symbology: symbology)
                            .frame(height: symbology == .qr ? 150 : 90)
                            .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle(editing == nil ? "Add Card" : "Edit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onFinish() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(!canSave)
                        .buttonStyle(.glassProminent)
                }
            }
            .sheet(isPresented: $scanning) {
                ScannerSheet { value in
                    number = value
                    if !symbologyTouched {
                        symbology = .detected(for: value)
                    }
                }
            }
        }
        .onAppear(perform: load)
    }

    private func load() {
        guard let card = editing, name.isEmpty, number.isEmpty else { return }
        name = card.name
        number = card.number
        symbology = card.symbology
        tintHex = card.tintHex
        symbologyTouched = true
    }

    private func save() {
        guard canSave else { return }

        if let card = editing {
            card.name = trimmedName
            card.number = trimmedNumber
            card.symbology = symbology
            card.tintHex = tintHex
        } else {
            context.insert(
                LoyaltyCard(
                    name: trimmedName,
                    number: trimmedNumber,
                    symbology: symbology,
                    tintHex: tintHex
                )
            )
        }
        onFinish()
    }
}

private struct ColourRow: View {
    @Binding var selection: String

    var body: some View {
        HStack(spacing: 12) {
            ForEach(CardTint.palette, id: \.self) { hex in
                Button {
                    selection = hex
                } label: {
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 30, height: 30)
                        .overlay {
                            if hex == selection {
                                Circle().stroke(.primary, lineWidth: 2.5).padding(-4)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }
}
