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
import SwiftyBeaver

struct ConnectionView: View {
    @EnvironmentObject var state: AppState
    @ObservedObject var viewModel: ConnectionViewModel
    @State private var connectionAnimation = false
    private(set) var connectionInfoViewModel: ConnectionInfoViewModel

    var body: some View {
        VStack {
            Spacer().frame(height: state.showConnectionInfo ? 0 : 24)
            ZStack {
                if !viewModel.flag.isEmpty && viewModel.grey {
                    Image(decorative: "FlagWorldGrey")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .rotationEffect(Angle(degrees: connectionAnimation ? 360 : 0))
                        .accessibilityFriendlyAnimation(Animation
                                                            .linear(duration: 10.0)
                                                            .repeatForever(autoreverses: false))
                        .onAppear { connectionAnimation = true }
                        .onDisappear { connectionAnimation = false }
                } else if !viewModel.flag.isEmpty {
                    Image(decorative: viewModel.flag)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                }
                Image(decorative: viewModel.connectionIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 145)
                    .offset(x: 0, y: -20)
            }
            Spacer().frame(height: state.showConnectionInfo ? 8 : 24)
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Circle()
                    .frame(width: 12, height: 12)
                    .foregroundColor(viewModel.connectionStateColor)
                Text(viewModel.connectionStateText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .latoFont()
                    .foregroundColor(.abDarkText)
            }
            Spacer().frame(height: viewModel.grey ? 33 : CGFloat(24)) // CGFloat() explicitly added to fix bug in SwiftUI Previews
            if viewModel.grey {
                Text(viewModel.regionButtonText)
                    .latoFont(weight: .bold)
                    .foregroundColor(.abLightestText)
            } else {
                Button(action: { state.viewToShow = .locations }, label: { Text(viewModel.regionButtonText) })
                    .buttonStyle(SecondaryButtonStyle(icon: "NextIcon", bold: true))
                    .customAccessibilityLabel(Text("\(viewModel.regionButtonText), next", comment: "Alt text for region selection button"))
            }
            Spacer().frame(height: 16)
            if viewModel.grey {
                Button(action: { viewModel.toggleConnection() }, label: { Text(viewModel.connectionButtonText) })
                    .buttonStyle(SecondaryButtonStyle(bold: true))
            } else {
                Button(action: { viewModel.toggleConnection() }, label: { Text(viewModel.connectionButtonText) }).buttonStyle(PrimaryButtonStyle())
            }
            Spacer().frame(height: 24)
            if state.showConnectionInfo {
                ConnectionInfoView(viewModel: connectionInfoViewModel)
            }
        }
        .frame(width: 272, height: state.showConnectionInfo ? 460 : 352)
        .background(Color.abBackground)
        .onAppear {
            viewModel.updateViewBasedOnCurrentState()
        }
        .onReceive(state.$restartConnection, perform: { newVal in
            if newVal {
                SwiftyBeaver.debug("received restartConnection")
                viewModel.restart()
                state.restartConnection = false
            }
        })
        .onReceive(viewModel.$connectionStateText, perform: { _ in
            if NSWorkspace.shared.isVoiceOverEnabled {
                let notification = viewModel.getVoiceOverNotification()
                if !notification.isEmpty {
                    // delay until after the last UI element is read (hopefully)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        NSAccessibility.post(
                            element: NSApp as Any,
                            notification: .announcementRequested,
                            userInfo: [
                                NSAccessibility.NotificationUserInfoKey.announcement: notification,
                                .priority: NSAccessibilityPriorityLevel.high.rawValue
                            ])
                    }
                }
            }
        })
    }
}

struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView(viewModel: ConnectionViewModel(vpnManager: VPNManager(),
                                                      authManager: AuthManager(),
                                                      logManager: LogManager(),
                                                      notificationManager: NotificationManager(),
                                                      errorManager: ErrorManager()),
                       connectionInfoViewModel: ConnectionInfoViewModel(vpnManager: VPNManager()))
            .environmentObject(AppState())
    }
}
