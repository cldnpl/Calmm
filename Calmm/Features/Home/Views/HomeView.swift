import Combine
import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(CatNeedsViewModel.self) private var needsViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var cats: [CatModel]

    @State private var viewModel = HomeViewModel()
    @State private var isEditingName = false
    @State private var draftName = ""
    @FocusState private var nameFieldFocused: Bool

    private var cat: CatModel? { cats.first }
    private let idleTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .bottom) {
            CatSceneView(
                imageName: viewModel.currentImageName,
                catGesture: catGesture
            )

            // Cat name at the top
            VStack {
                catNameHeader
                    .padding(.top, 56)
                Spacer()
            }

            CatNeedsOverlayView(
                hunger: needsViewModel.hungerPercentage,
                cleanliness: needsViewModel.cleanlinessPercentage
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 122)
        }
        .onReceive(idleTimer) { _ in
            viewModel.handleIdleTick()
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }

    // MARK: - Cat name header

    @ViewBuilder
    private var catNameHeader: some View {
        if isEditingName {
            // Editing mode
            HStack(spacing: 8) {
                TextField("Cat name", text: $draftName)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "3D2C24"))
                    .multilineTextAlignment(.center)
                    .focused($nameFieldFocused)
                    .submitLabel(.done)
                    .onSubmit { saveName() }
                    .onChange(of: draftName) { _, newValue in
                        if newValue.count > 12 {
                            draftName = String(newValue.prefix(12))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.85))
                    )
                    .frame(maxWidth: 180)

                // Confirm button
                Button(action: saveName) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Color(hex: "F0997B"))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
        } else {
            // Display mode
            HStack(spacing: 6) {
                Text(cat?.name ?? "Calmm")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "3D2C24"))
                    .shadow(color: .white.opacity(0.6), radius: 4, y: 1)

                Button(action: startEditing) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color(hex: "F0997B").opacity(0.85))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.6))
            )
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }

    // MARK: - Gesture

    private var catGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if isEditingName { saveName() }
                viewModel.handleDragChanged(translation: value.translation)
            }
            .onEnded { value in
                viewModel.handleDragEnded(translation: value.translation)
            }
    }

    // MARK: - Name editing

    private func startEditing() {
        draftName = cat?.name ?? ""
        isEditingName = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            nameFieldFocused = true
        }
    }

    private func saveName() {
        let trimmed = draftName.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            cat?.name = trimmed
            try? modelContext.save()
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isEditingName = false
        }
        nameFieldFocused = false
    }
}

#Preview {
    let needsViewModel = CatNeedsViewModel()
    needsViewModel.loadPreview(hunger: 76, cleanliness: 88)
    return HomeView()
        .environment(needsViewModel)
        .modelContainer(for: CatModel.self, inMemory: true)
}
