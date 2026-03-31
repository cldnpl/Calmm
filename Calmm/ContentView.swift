//
//  ContentView.swift
//  Calmm
//
//  Created by Claudia Napolitano on 30/03/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 2

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0: Text("Games")
                case 1: Text("Shop")
                case 2: HomeView()
                case 3: Text("Style")
                case 4: Text("Profile")
                default: HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    let tabs: [(icon: String, label: String)] = [
        ("gamecontroller.fill", "games"),
        ("bag.fill", "shop"),
        ("house.fill", "kennel"),
        ("tshirt.fill", "style"),
        ("star.fill", "profile")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<5) { index in
                let isCenter = index == 2
                let isSelected = selectedTab == index

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tabs[index].icon)
                            .font(isCenter ? .title2 : .system(size: 20))
                            .scaleEffect(isSelected && !isCenter ? 1.15 : 1.0)
                            .offset(y: isSelected && !isCenter ? -2 : 0)

                        if !isCenter {
                            Text(tabs[index].label)
                                .font(.system(size: 10, weight: .medium))
                                .opacity(isSelected ? 1 : 0.4)
                        }
                    }
                    .foregroundStyle(
                        isCenter
                            ? .white
                            : (isSelected ? Color(hex: "D85A30") : Color.gray.opacity(0.6))
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, isCenter ? 12 : 8)
                    .padding(.horizontal, isCenter ? 14 : 0)
                    .background(
                        isCenter
                            ? Color(hex: isSelected ? "C9623E" : "F0997B")
                            : (isSelected ? Color(hex: "F0997B").opacity(0.12) : Color.clear)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: isCenter ? 22 : 16))
                    .offset(y: isCenter ? -16 : 0)
                    .shadow(color: isCenter ? Color(hex: "F0997B").opacity(0.35) : .clear,
                            radius: 8, y: 4)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
        .padding(.top, 10)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.white.opacity(0.92))
                .shadow(color: .black.opacity(0.08), radius: 20, y: -4)
        )
        .padding(.horizontal, 16)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    ContentView()
}
