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

struct OnboardingSysExtensionView: View {
    @EnvironmentObject var model: OnboardingViewModel

    var body: some View {
        VStack {
            OnboardingBodyView(headerImage: "OnboardingSysExtension",
                               bodyTitle: Text("Allow AdBlock VPN in your security preferences", comment: "Title for system extensions permissions page in onboarding flow"))
            VStack(alignment: .leading, spacing: 12) {
                OnboardingStepTextView(boldText: Text("Step 1:", comment: "Prefix for step 1 of intructions"),
                                       normalText: Text("Click “Open System Dialog” below. Click ”Open Security Preferences” in the next window.",
                                                        comment: "First step in instructions to enable system extension"))
                OnboardingStepTextView(boldText: Text("Step 2:", comment: "Prefix for step 2 of instructions"),
                                       normalText: Text("At the bottom of the page, click the lock icon and enter your password.",
                                                        comment: "Second step in instruction to enable system extension"))
                OnboardingStepTextView(boldText: Text("Step 3:", comment: "Prefix for step 3 of instructions"),
                                       // swiftlint:disable:next line_length
                                       normalText: Text("Click the “Allow” button to give AdBlock VPN permission to run on your device. Close the preferences window and click “Next Steps” below to continue the setup process.",
                                                        comment: "Third step in instructions to enable the system extension"))
            }
                .fixedSize(horizontal: false, vertical: true)
            Spacer().frame(height: 48)
            HStack(spacing: 32) {
                Button(action: { model.openSecurityPreferences() }, label: { Text("Open System Dialog", comment: "Label for button that opens the system dialog") })
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(model.sysExtensionActive)
                Button(action: { model.sysExtensionActive ? model.checkViewToShow() : (model.viewToShow = .sysExtensionError) },
                       label: { Text("Next Steps", comment: "Label for button that takes the user to the next step in the onboarding flow") })
                    .buttonStyle(PrimaryButtonStyle())
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
