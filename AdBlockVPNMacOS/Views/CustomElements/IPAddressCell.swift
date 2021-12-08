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

import Combine
import SwiftUI

struct IPAddressCell: View {
    let IPVersion: String
    let IPAddress: String
    let isIPError: Bool
    let updateIPAddress: () -> Void
    @Binding var isDisabled: Bool
    @Binding var errorTextOpacity: Double
    @Binding var refreshIconRotationAngle: CGFloat

    @State private var IPAddressTextOffset: CGFloat = 0
    @State private var IPAddressTextOpacity: Double = 1
    @State private var copiedTextOffset: CGFloat = 15
    @State private var copiedTextOpacity: Double = 0
    @State private var errorTextOffset: CGFloat = 0
    @State private var retryTextOffset: CGFloat = 15
    @State private var retryTextOpacity: Double = 0
    @State private var isRefreshing: Bool = false

    var body: some View {
        ZStack {
            HStack {
                HStack {
                    Text(IPVersion)
                        .latoFont(weight: .bold, size: 16)
                        .foregroundColor(IPAddress.count == 2 ? .abInactiveAccent : .abDarkText)
                    Spacer(minLength: 24)
                    if isIPError {
                        ZStack(alignment: .trailing) {
                            Text("Error", comment: "Label that is shown when IP Address lookup fails")
                                .latoFont()
                                .offset(y: errorTextOffset)
                                .opacity(errorTextOpacity)
                            Text("Retrying...", comment: "Label that is shown when retrying a network request")
                                .latoFont()
                                .offset(y: retryTextOffset)
                                .opacity(retryTextOpacity)
                                .foregroundColor(.abVPNStateConnected)
                        }
                    } else {
                        ZStack(alignment: .trailing) {
                            Text(IPAddress)
                                .latoFont()
                                .offset(y: IPAddressTextOffset)
                                .opacity(IPAddressTextOpacity)
                                .foregroundColor(IPAddress.count == 2 ? .abInactiveAccent : .abDarkText)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            Text("Copied", comment: "Label that is shown when user copies data to clipboard.")
                                .latoFont()
                                .foregroundColor(.abVPNStateConnected)
                                .offset(y: copiedTextOffset)
                                .opacity(copiedTextOpacity)
                        }
                    }
                }
                .accessibilityElement(children: .combine)
                .customAccessibilityLabel(getIPLabel())
                ZStack {
                    if isIPError {
                        Button(action: refreshIPAddress, label: { Image("RefreshIcon").renderingMode(.template) })
                            .buttonStyle(RefreshButtonStyle())
                            .rotationEffect(Angle(degrees: refreshIconRotationAngle))
                            .foregroundColor(isRefreshing ? .abVPNStateConnected : .abDarkText)
                            .disabled(isDisabled)
                            .customAccessibilityLabel(Text("Refresh", comment: "Label for resfresh icon"))
                    } else {
                        Button(action: copyToPasteboard, label: { Image("CopyIcon") })
                            .buttonStyle(PlainButtonStyle())
                            .disabled(IPAddress.count == 2)
                            .offset(y: IPAddressTextOffset)
                            .opacity(IPAddressTextOpacity)
                            .customAccessibilityLabel(Text("Copy \(IPVersion)", comment: "Label for copy icon, variable holds 'IPV4' or 'IPV6'"))
                        Image(decorative: "CheckIcon")
                            .renderingMode(.template)
                            .foregroundColor(.abVPNStateConnected)
                            .offset(y: copiedTextOffset)
                            .opacity(copiedTextOpacity)
                    }
                }
            }
        }
    }
    
    private func getIPLabel() -> Text {
        var content = IPAddress
        if isIPError {
            if errorTextOpacity != 0 {
                content = NSLocalizedString("Error", comment: "Label that is shown when IP Address lookup fails")
            } else if retryTextOpacity != 0 {
                content = NSLocalizedString("Retrying...", comment: "Label that is shown when retrying a network request")
            }
        }
        
        if content == "--" {
            content = NSLocalizedString("inactive", comment: "Label for empty IP address shown in connection info")
        }
            
        return Text("\(IPVersion): \(content)")
    }

    private func refreshIPAddress() {
        // Trigger IP Address refresh.
        updateIPAddress()

        // Disable refresh button and set to refreshing state.
        isDisabled = true
        isRefreshing = true

        // Rotate the refresh icon.
        withAnimation(isDisabled ? Animation.easeOut(duration: 5.2) : Animation.default) {
            refreshIconRotationAngle += 1800
        }

        // Replace `Error` text with `Retrying...` text.
        withAnimation(Animation.easeInOut(duration: 0.3)) {
            errorTextOffset = -12
            errorTextOpacity = 0
            retryTextOffset = 0
            retryTextOpacity = 1
        }

        // Reset back to pre-animation state.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            isDisabled = false
            isRefreshing = false
            withAnimation(Animation.easeInOut(duration: 0.3)) {
                errorTextOffset = 0
                errorTextOpacity = 1
                retryTextOffset = 15
                retryTextOpacity = 0
            }
        }
    }

    private func copyToPasteboard() {
        // Copy IP Address to Pasteboard.
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(IPAddress, forType: .string)

        // Animate presentation of `Copied` text.
        withAnimation(Animation.easeInOut(duration: 0.3)) {
            IPAddressTextOffset = -12
            IPAddressTextOpacity = 0
            copiedTextOffset = 0
            copiedTextOpacity = 1
        }

        // Reset back to pre-animation state.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(Animation.easeInOut(duration: 0.3)) {
                IPAddressTextOffset = 0
                IPAddressTextOpacity = 1
                copiedTextOffset = 15
                copiedTextOpacity = 0
            }
        }
        
        if NSWorkspace.shared.isVoiceOverEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NSAccessibility.post(
                    element: NSApp as Any,
                    notification: .announcementRequested,
                    userInfo: [
                        NSAccessibility.NotificationUserInfoKey.announcement: NSLocalizedString("Copied", comment: "Voiceover notification when IP address is copied"),
                        .priority: NSAccessibilityPriorityLevel.high.rawValue
                    ])
            }
        }
    }
}

struct IPAddressCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            IPAddressCell(IPVersion: "IPv4",
                          IPAddress: "127.0.0.1",
                          isIPError: false,
                          updateIPAddress: {},
                          isDisabled: .constant(false),
                          errorTextOpacity: .constant(1),
                          refreshIconRotationAngle: .constant(0))
            IPAddressCell(IPVersion: "IPv6",
                          IPAddress: "127.0.0.1",
                          isIPError: true,
                          updateIPAddress: {},
                          isDisabled: .constant(true),
                          errorTextOpacity: .constant(1),
                          refreshIconRotationAngle: .constant(0))
        }
        .frame(width: 240)
        .padding()
    }
}
