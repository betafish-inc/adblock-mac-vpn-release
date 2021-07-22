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

struct OnboardingNotificationsView: View {
    @EnvironmentObject var model: OnboardingViewModel

    // swiftlint:disable:next line_length
    private let alertInstructions = "For the best app experience from AdBlock VPN, allow notifications. Click “Show Notification“ below. A notification will appear in the top right corner of your screen. Click “Options” then “Allow”. (You can choose “Don’t Allow” if you do not want notifications from AdBlock VPN.) Click “Next” below when you are done."
    // swiftlint:disable:next line_length
    private let sysPrefInstructions = "You will get the best app experience from AdBlock VPN by turning on notifications. Click ”Open Notifications”  then toggle notifications from AdBlock VPN to ”On”. You can also skip this step if you do not want notifications from AdBlock VPN."

    var body: some View {
        VStack {
            OnboardingBodyView(headerImage: (model.notificationInstructions == .alert) ? "OnboardingNotificationsAlert" : "OnboardingNotificationsSysPrefs",
                               bodyTitle: "Allow AdBlock VPN Notifications")
            Text((model.notificationInstructions == .alert) ? alertInstructions : sysPrefInstructions)
                .latoFont()
                .foregroundColor(.abDarkText)
                .fixedSize(horizontal: false, vertical: true)
            Spacer().frame(height: 48)
            HStack(spacing: 32) {
                Button(action: { model.openNotifications() },
                       label: { Text((model.notificationInstructions == .alert) ? "Show Notification" : "Open Notifications") })
                    .buttonStyle(SecondaryButtonStyle())
                    .if(model.notificationAuthorizationStatus == .authorized) { $0.disabled(true) }
                Button(action: { model.checkViewToShow() }, label: { Text("Next") }).buttonStyle(PrimaryButtonStyle())
            }
            .fixedSize(horizontal: false, vertical: true)
            Spacer().frame(height: 32)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { _ in
            model.checkUserNotificationsAuthorizationState()
        }
    }
}

struct OnboardingNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingNotificationsView()
            .environmentObject(OnboardingViewModel(vpnManager: VPNManager(), notificationManager: NotificationManager()))
            .frame(width: 576)
    }
}
