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

struct OnboardingContactSupportButtonView: View {
    @EnvironmentObject var model: OnboardingViewModel

    var body: some View {
        Button(action: model.openSupportURL) {
            Text("Contact Support")
                .underline()
                .multilineTextAlignment(.center)
                .padding(8)
                .foregroundColor(.abLinkColor)
        }
        .frame(maxWidth: 272, minHeight: 40, maxHeight: .infinity)
        .buttonStyle(PlainButtonStyle())
        .latoFont(weight: .bold)
        .onHover { inside in
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

struct OnboardingSupportButtonView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingContactSupportButtonView()
    }
}
