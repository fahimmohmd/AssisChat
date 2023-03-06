//
//  ChatSourceConfigView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-06.
//

import SwiftUI

struct ChatSourceConfigView: View {
    @EnvironmentObject private var settingsFeature: SettingsFeature


    var body: some View {
        Content(openAIAPIKey: settingsFeature.configuredOpenAIAPIKey ?? "", openAIDomain: settingsFeature.configuredOpenAIDomain ?? "")
    }
}

private struct Content: View {
    @EnvironmentObject private var essentialFeature: EssentialFeature
    @EnvironmentObject private var settingsFeature: SettingsFeature

    @State var openAIAPIKey: String
    @State var openAIDomain: String

    @State private var validating = false

    var body: some View {
        List {
            Section {
                TextField("sk-XXXXXXX", text: $openAIAPIKey)
            } header: {
                Text("OpenAI API Key")
            } footer: {
                Text("Get an API key from https://platform.openai.com/account/api-keys")
            }

            Section {
                TextField("api.openai.com", text: $openAIDomain)
            } header: {
                Text("OpenAI API domain")
            } footer: {
                Text("Use proxy domain. We recommend leaving it blank to use the default value. Please use a domain that you completely trust, otherwise your API key will be leaked.")
            }

            Section {
                Button {
                    validateAndSave()
                } label: {
                    HStack {
                        if validating {
                            ProgressView()
                        }

                        Text("Validate and Save")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.primary)
                    .colorScheme(.dark)
                }
                .disabled(validating)
                .listRowInsets(EdgeInsets())
            }
        }
    }

    func validateAndSave() -> Void {
        Task {
            if openAIAPIKey.isEmpty {
                essentialFeature.appendAlert(alert: ErrorAlert(message: "Please input API key"))
                return
            }

            let domain = openAIDomain.isEmpty ? nil : openAIDomain

            validating = true

            let saved = await settingsFeature.validateAndConfigOpenAI(apiKey: openAIAPIKey, for: domain)

            validating = false

            if saved {
                essentialFeature.appendAlert(alert: GeneralAlert(title: "Success", message: "Success validated the config and saved."))
            } else {
                essentialFeature.appendAlert(alert: ErrorAlert(message: "Failed to validate"))
            }

        }
    }
}

struct ChatSourceConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ChatSourceConfigView()
    }
}
