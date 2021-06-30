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
            } else {
                VStack(alignment: .leading) {
                    Spacer().frame(height: 17)
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
                                          onCommit: textEntryButtonClicked)
                        .padding(.horizontal, 16)
                        .frame(width: 272, height: 40)
                        .background(Color.white)
                        .cornerRadius(6)
                        .clipped()
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.abBorder, lineWidth: 1)
                        )
                        .shadow(color: textFieldFocused ? Color.abShadow : .white, radius: 20, x: 0, y: 5)
                    Spacer().frame(height: 17)
                }
                if !inputString.isEmpty || [.noAccountError, .subEndedError, .deviceLimitError].contains(viewModel.currentPage) {
                    AccentButtonView(action: textEntryButtonClicked, text: viewModel.pageStrings.buttonText)
                } else {
                    DisabledButtonView(text: viewModel.pageStrings.buttonText)
                }
                if let linkText = viewModel.pageStrings.linkText {
                    Spacer().frame(height: 8)
                    HTMLStringView(htmlContent: linkText, fontSize: 12, centered: true)
                }
            }
            Spacer()
            if let footerText = viewModel.pageStrings.footerText {
                ZStack(alignment: .center) {
                    Rectangle()
                        .fill(Color.abHeaderBackground)
                    VStack(alignment: .center) {
                        HStack(alignment: .center) {
                            if let tryAgainText = viewModel.pageStrings.footerTryAgainText {
                                MultiLinkTextField(content: footerText,
                                                   fontSize: 14,
                                                   centered: true,
                                                   backgroundColor: .abHeaderBackground,
                                                   textColor: .abLightText,
                                                   accentColorLinks: true,
                                                   localLinks: [tryAgainText: { viewModel.tryAgainClicked() }],
                                                   webLinks: viewModel.pageStrings.footerWebLinks)
                                    .frame(width: 300)
                                    .fixedSize(horizontal: true, vertical: true)
                            } else {
                                MultiLinkTextField(content: footerText,
                                                   fontSize: 14,
                                                   centered: true,
                                                   backgroundColor: .abHeaderBackground,
                                                   textColor: .abLightText,
                                                   accentColorLinks: true,
                                                   localLinks: nil,
                                                   webLinks: viewModel.pageStrings.footerWebLinks)
                                    .frame(width: 300)
                                    .fixedSize(horizontal: true, vertical: true)
                            }
                        }
                    }
                }.frame(width: 320, height: 62)
            }
        }
        .frame(width: 320, height: 352)
        .background(Color.white)
        .foregroundColor(Color.black)
        .latoFont()
        .overlay(
            VStack {
                Spacer().layoutPriority(2)
                if viewModel.isError {
                    ZStack {
                        Rectangle().fill(Color.abErrorAccent)
                        HStack(alignment: .top) {
                            if let tryAgainText = viewModel.errorStrings.errorTryAgainText {
                                MultiLinkTextField(content: viewModel.errorStrings.errorText,
                                                   fontSize: 14,
                                                   centered: false,
                                                   backgroundColor: .abErrorAccent,
                                                   textColor: .white,
                                                   accentColorLinks: false,
                                                   localLinks: [tryAgainText: { viewModel.tryAgainClicked() }],
                                                   webLinks: viewModel.errorStrings.errorWebLinks,
                                                   width: 252)
                                    .frame(width: 252)
                                    .fixedSize(horizontal: true, vertical: true)
                                    .padding(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 0))
                            } else {
                                MultiLinkTextField(content: viewModel.errorStrings.errorText,
                                                   fontSize: 14,
                                                   centered: false,
                                                   backgroundColor: .abErrorAccent,
                                                   textColor: .white,
                                                   accentColorLinks: false,
                                                   localLinks: nil,
                                                   webLinks: viewModel.errorStrings.errorWebLinks,
                                                   width: 252)
                                    .frame(width: 252)
                                    .fixedSize(horizontal: true, vertical: true)
                                    .padding(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 0))
                            }
                            Button {
                                viewModel.dismissError()
                            } label: {
                                Image("CloseIcon")
                                    .resizable()
                                    .scaledToFit()
                                    .onHover { inside in
                                        if inside {
                                            NSCursor.pointingHand.push()
                                        } else {
                                            NSCursor.pop()
                                        }
                                    }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 24))
                        }
                    }.layoutPriority(1)
                }
            }
        )
        .onAppear {
            viewModel.checkError()
        }
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
}

struct LoginFlowView_Previews: PreviewProvider {
    static var previews: some View {
        LoginFlowView(viewModel: LoginViewModel(authManager: AuthManager(), logManager: LogManager(), errorManager: ErrorManager())).environmentObject(AppState())
    }
}
