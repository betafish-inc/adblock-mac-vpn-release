//    AdBlock VPN
//    Copyright © 2020-present Adblock, Inc. All rights reserved.
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.

import SwiftUI

struct LoginFlowView: View {
    @EnvironmentObject var state: AppState
    @State private var inputString: String = ""
    @State private var textFieldFocused: Bool = false
    @ObservedObject var viewModel: LoginViewModel
    var body: some View {
        VStack {
            if viewModel.isTransition {
                Spacer().frame(height: 102)
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(Color.abPrimaryAccent, lineWidth: 16)
                    .frame(width: 100, height: 100)
                    .rotationEffect(Angle(degrees: viewModel.isSpinning ? 360 : 0))
                    .animation(Animation.default.repeatForever(autoreverses: false))
                    .onAppear {
                        viewModel.isSpinning = true
                    }
                    .customAccessibilityLabel(Text("Processing", comment: "Label for spinning circle when login flow is waiting for the server response"))
                    .customAccessibilityAddTraits(.isImage)
            } else {
                VStack(alignment: .leading) {
                    Text(viewModel.pageStrings.titleText)
                        .latoFont(weight: .bold)
                        .foregroundColor(.abDarkText)
                    Spacer().frame(height: 5)
                    Text(viewModel.pageStrings.descriptionText)
                        .latoFont()
                        .foregroundColor(.abLightText)
                    Spacer().frame(height: 39)
                }.frame(width: 272)
                if let placeholder = viewModel.pageStrings.placeholderText {
                    FocusTextFieldElement(text: $inputString,
                                          isFocused: $textFieldFocused,
                                          placeholderText: placeholder,
                                          alignCenter: viewModel.currentPage == .codeEntry,
                                          trimWhitespace: true,
                                          onCommit: textEntryButtonClicked)
                        .padding(.horizontal, 16)
                        .frame(width: 272, height: 40)
                        .background(Color.abBackground)
                        .cornerRadius(6)
                        .clipped()
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.abBorder, lineWidth: 1)
                        )
                        .shadow(color: textFieldFocused ? Color.abShadow : .abShadowLight,
                                radius: 20, x: 0, y: 5)
                    Spacer().frame(height: 17)
                }
                if !inputString.isEmpty || [.noAccountError, .subEndedError, .deviceLimitError].contains(viewModel.currentPage) {
                    Button(action: { textEntryButtonClicked() }, label: { Text(viewModel.pageStrings.buttonText) }).buttonStyle(PrimaryButtonStyle())
                } else {
                    Button(action: {}, label: { Text(viewModel.pageStrings.buttonText) }).buttonStyle(DisabledButtonStyle())
                }
                if let linkText = viewModel.pageStrings.linkText {
                    Spacer().frame(height: 8)
                    LinkButtonView(action: {
                        if let url = URL(string: linkText.1) {
                            NSWorkspace.shared.open(url)
                        }
                    }, text: Text(linkText.0))
                }
            }
            Spacer()
            if let footerText = viewModel.pageStrings.footerText {
                FooterBlockView(footerText: footerText, linkAction: {
                    if viewModel.pageStrings.footerTryAgain {
                        tryAgainClicked()
                    } else {
                        if let myURL = viewModel.pageStrings.footerWebLink, let url = URL(string: myURL) {
                            NSWorkspace.shared.open(url)
                        }
                    }
                })
                .frame(width: 320)
                .if(viewModel.isOverlayError) {
                    $0.hidden()
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .contain)
        .frame(width: 320, height: state.showConnectionInfo ? 460 : 352)
        .background(Color.abBackground)
        .latoFont()
        .overlay(
            VStack {
                Spacer().layoutPriority(2)
                if viewModel.isOverlayError {
                    ErrorBlockView(
                        errorText: viewModel.errorStrings.errorText,
                        linkAction: viewModel.errorStrings.errorTryAgain ? tryAgainClicked : nil,
                        dismissError: viewModel.dismissError,
                        showHelp: true)
                        .layoutPriority(1)
                }
            }
        )
        .onAppear {
            viewModel.checkError()
        }
        .onReceive(viewModel.$isOverlayError, perform: { newVal in
            if newVal, newVal != viewModel.isOverlayError {
                if NSWorkspace.shared.isVoiceOverEnabled {
                    // delay until after the last UI element is read (hopefully)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        NSAccessibility.post(
                            element: NSApp as Any,
                            notification: .announcementRequested,
                            userInfo: [
                                NSAccessibility.NotificationUserInfoKey.announcement: viewModel.errorStrings.errorText,
                                .priority: NSAccessibilityPriorityLevel.high.rawValue
                            ])
                    }
                }
            }
        })
    }
    
    func textEntryButtonClicked() {
        if !inputString.isEmpty {
            viewModel.buttonClicked(textInput: inputString) { (success) in
                if success {
                    self.state.viewToShow = .setUpVPN
                }
            }
            inputString = ""
        }
    }
    
    func tryAgainClicked() {
        inputString = ""
        viewModel.tryAgainClicked()
    }
}

struct LoginFlowView_Previews: PreviewProvider {
    static var previews: some View {
        LoginFlowView(viewModel: LoginViewModel(authManager: AuthManager(),
                                                logManager: LogManager(),
                                                errorManager: ErrorManager()))
            .environmentObject(AppState())
    }
}
