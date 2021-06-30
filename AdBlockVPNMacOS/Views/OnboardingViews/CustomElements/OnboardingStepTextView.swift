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

struct OnboardingStepTextView: View {
    var boldText: String
    var normalText: String

    var body: some View {
        Text(boldText)
            .font(.custom("Lato-Bold", size: 16))
            .foregroundColor(.abDarkText)
            + Text(" ")
            + Text(normalText).font(.custom("Lato-Regular", size: 16))
            .foregroundColor(.abDarkText)
    }
}

struct OnboardingStepTextView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingStepTextView(boldText: "Step 1:", normalText: "Do the thing.")
            .padding()
    }
}
