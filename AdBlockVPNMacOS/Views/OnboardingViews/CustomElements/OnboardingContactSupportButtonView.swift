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

struct OnboardingContactSupportButtonView: View {
    @EnvironmentObject var model: OnboardingViewModel

    var body: some View {
        LinkButtonView(
            action: model.openSupportURL,
            text: Text("Contact Support", comment: "Label for button to contact support from onboarding flow"),
            fontSize: 16)
        .padding(8)
        .frame(maxWidth: 272, minHeight: 40, maxHeight: .infinity)
    }
}

struct OnboardingSupportButtonView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingContactSupportButtonView().environmentObject(OnboardingViewModel(vpnManager: VPNManager(), notificationManager: NotificationManager()))
    }
}
