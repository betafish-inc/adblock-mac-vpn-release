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

struct ErrorBlockView: View {
    var errorText: String
    var linkAction: (() -> Void)?
    var dismissError: (() -> Void)?
    var showHelp: Bool
    var helpURL = Constants.helpURL
    var body: some View {
        ZStack {
            Rectangle().fill(Color.abErrorAccent)
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    Text("Oops!", comment: "Header for error block")
                        .padding(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 2))
                        .latoFont(weight: .bold, size: 14)
                        .foregroundColor(.abErrorText)
                    Spacer()
                    if showHelp {
                        Button {
                            if let url = URL(string: helpURL) {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
                            Image("HelpIcon", label: Text("Help", comment: "label for help icon"))
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
                        .customSortPriority(-1)
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.abErrorText)
                        .frame(width: 20, height: 20)
                        .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 24))
                    }
                    if let dismissFunc = dismissError {
                        Button {
                            dismissFunc()
                        } label: {
                            Image("CloseIcon", label: Text("Close", comment: "label for close icon"))
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
                        .customSortPriority(-1)
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.abErrorText)
                        .frame(width: 20, height: 20)
                        .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 24))
                    }
                }
                if let linkFunc = linkAction {
                    LinkButtonView(action: linkFunc, text: Text(errorText), fontSize: 14, whiteText: true, center: false)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(EdgeInsets(top: 0, leading: 24, bottom: 16, trailing: 24))
                } else {
                    Text(errorText)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(EdgeInsets(top: 0, leading: 24, bottom: 16, trailing: 16))
                        .latoFont(weight: .bold, size: 14)
                        .foregroundColor(.abErrorText)
                }
            }
            .accessibilityElement(children: .contain)
        }.fixedSize(horizontal: false, vertical: true)
    }
}

struct ErrorBlockView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ErrorBlockView(
                errorText: "We don’t recognize that email address. We don’t recognize that email address.",
                linkAction: {},
                dismissError: {},
                showHelp: true)
                .frame(width: 320, height: 352)
            ErrorBlockView(
                errorText: "We don’t recognize that email address. We don’t recognize that email address.",
                linkAction: nil,
                dismissError: {},
                showHelp: true)
                .frame(width: 320, height: 352)
            ErrorBlockView(
                errorText: "We don’t recognize that email address. We don’t recognize that email address.",
                linkAction: nil,
                dismissError: nil,
                showHelp: true)
                .frame(width: 320, height: 352)
            ErrorBlockView(
                errorText: "We don’t recognize that email address. We don’t recognize that email address.",
                linkAction: nil,
                dismissError: nil,
                showHelp: false)
                .frame(width: 320, height: 352)
        }
    }
}
