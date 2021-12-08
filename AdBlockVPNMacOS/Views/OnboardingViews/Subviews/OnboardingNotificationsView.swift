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
    private let alertInstructions = Text("For the best app experience from AdBlock VPN, allow notifications. Click “Show Notification“ below. A notification will appear in the top right corner of your screen. Click “Options” then “Allow”. (You can choose “Don’t Allow” if you do not want notifications from AdBlock VPN.) Click “Next” below when you are done.", comment: "Instructions for enabling notifications from the system alert")
    // swiftlint:disable:next line_length
    private let sysPrefInstructions = Text("You will get the best app experience from AdBlock VPN by turning on notifications. Click ”Open Notifications”  then toggle notifications from AdBlock VPN to ”On”. You can also skip this step if you do not want notifications from AdBlock VPN.", comment: "Instructions for enabling notifications from system preferences")

    var body: some View {
        VStack {
            OnboardingBodyView(headerImage: (model.notificationInstructions == .alert) ? "OnboardingNotificationsAlert" : "OnboardingNotificationsSysPrefs",
                               headerImageLabel: nil,
                               bodyTitle: Text("Allow AdBlock VPN Notifications", comment: "Title for notifications page in onboarding flow"))
            if model.notificationInstructions == .alert {
                alertInstructions
            } else {
                sysPrefInstructions
                .latoFont()
                .foregroundColor(.abDarkText)
                .fixedSize(horizontal: false, vertical: true)
            }
            Spacer().frame(height: 48)
            HStack(spacing: 32) {
                Button(action: { model.openNotifications() },
                       label: { (model.notificationInstructions == .alert) ?
                    Text("Show Notification", comment: "Label for button to show the notifications system alert") :
                    Text("Open Notifications", comment: "Label for button to open system preferences to notifications") })
                    .buttonStyle(SecondaryButtonStyle())
                    .if(model.notificationAuthorizationStatus == .authorized) { $0.disabled(true) }
                Button(action: { model.checkViewToShow() }, label: { Text("Next", comment: "Label for button that takes user to the next page of the onboarding flow") })
                    .buttonStyle(PrimaryButtonStyle())
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
