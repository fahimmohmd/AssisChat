//
//  SettingsFeature.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-06.
//

import Foundation
import SwiftUI

class SettingsFeature: ObservableObject {
    static let colorSchemeKey = "settings:colorScheme"
    static let tintKey = "settings:tint"
    static let openAIDomain = "settings:openAI:domain"
    static let openAIAPIKey = "settings:openAI:apiKey"

    @AppStorage(colorSchemeKey) private(set) var selectedColorScheme: ColorScheme = .automatic
    @AppStorage(tintKey) private(set) var selectedTint: Tint?
    @AppStorage(openAIDomain) private(set) var configuredOpenAIDomain: String?
    @AppStorage(openAIAPIKey) private(set) var configuredOpenAIAPIKey: String?

    let essentialFeature: EssentialFeature

    @Published private(set) var chattingAdapter: ChattingAdapter?

    var adapterReady: Bool {
        return chattingAdapter != nil
    }

    init(essentialFeature: EssentialFeature) {
        self.essentialFeature = essentialFeature

        initiateAdapter()
    }

    func adjustColorScheme(_ colorScheme: ColorScheme) {
        selectedColorScheme = colorScheme
    }

    func adjustTint(_ tint: Tint?) {
        selectedTint = tint
    }

    func initiateAdapter() {
        guard let apiKey = configuredOpenAIAPIKey, !apiKey.isEmpty else {
            return
        }

        chattingAdapter = ChatGPTAdapter(essentialFeature: essentialFeature, config: .init(domain: configuredOpenAIDomain, apiKey: apiKey))
    }

    func validateAndConfigOpenAI(apiKey: String, for domain: String?) async -> Bool {
        let adapter = ChatGPTAdapter(essentialFeature: essentialFeature, config: .init(domain: domain, apiKey: apiKey))

        let validated = await adapter.validateConfig()

        if validated {
            chattingAdapter = adapter
            configuredOpenAIAPIKey = apiKey
            configuredOpenAIDomain = domain
        }

        return validated
    }
}

extension SettingsFeature {
    static let colorSchemes: [ColorScheme] = [
        .automatic,
        .light,
        .dark
    ]

    static let tints: [Tint] = [
        .green,
        .yellow,
        .orange,
        .brown,
        .red,
        .pink,
        .indigo,
        .blue,
    ]

    enum ColorScheme: String, Hashable {
        case automatic = "automatic", light = "light", dark = "dark"

        var systemColorScheme: SwiftUI.ColorScheme? {
            switch self {
            case .automatic: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }

    enum Tint: String, Hashable {
        case green = "green"
        case yellow = "yellow"
        case orange = "orange"
        case brown = "brown"
        case red = "red"
        case pink = "pink"
        case indigo = "indigo"
        case blue = "blue"

        var color: Color {
            switch self {
            case .indigo: return .appIndigo
            case .blue: return .appBlue
            case .green: return .appGreen
            case .yellow: return .appYellow
            case .orange: return .appOrange
            case .brown: return .appBrown
            case .red: return .appRed
            case .pink: return .appPink
            }
        }
    }
}
