//    AdBlock VPN
//    Copyright © 2020-2021 Betafish Inc. All rights reserved.
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

struct OnboardingSysExtensionView: View {
    @EnvironmentObject var model: OnboardingViewModel

    var body: some View {
        VStack {
            OnboardingBodyView(headerImage: "OnboardingSysExtension",
                               bodyTitle: "Allow AdBlock VPN in your security preferences")
            VStack(alignment: .leading, spacing: 12) {
                OnboardingStepTextView(boldText: "Step 1:",
                                       normalText: "Click “Open System Dialogue” below. Click ”Open Security Preferences” in the next window.")
                OnboardingStepTextView(boldText: "Step 2:",
                                       normalText: "At the bottom of the page, click the lock icon and enter your password.")
                OnboardingStepTextView(boldText: "Step 3:",
                                       // swiftlint:disable:next line_length
                                       normalText: "Click the “Allow” button to give AdBlock VPN permission to run on your device. Close the preferences window and click “Next Steps” below to continue the setup process.")
            }
                .fixedSize(horizontal: false, vertical: true)
            Spacer().frame(height: 48)
            HStack(spacing: 32) {
                OnboardingButtonView(action: { model.openSecurityPreferences() }, text: "Open System Dialog", isPrimary: false)
                    .disabled(model.sysExtensionActive)
                OnboardingButtonView(action: { model.sysExtensionActive ? model.checkViewToShow() : (model.viewToShow = .sysExtensionError) },
                                     text: "Next Steps", isPrimary: true)
            }
            .fixedSize(horizontal: false, vertical: true)
            Spacer().frame(height: 32)
        }
    }
}

struct OnboardingPermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingSysExtensionView()
            .environmentObject(OnboardingViewModel(vpnManager: VPNManager(), notificationManager: NotificationManager()))
            .frame(width: 576)
    }
}
