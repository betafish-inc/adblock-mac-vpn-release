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

struct OnboardingBodyView: View {
    let headerImage: String
    let headerImageLabel: Text?
    let bodyTitle: Text

    var body: some View {
        VStack {
            Spacer().frame(height: 32)
            if headerImageLabel != nil {
                // swiftlint:disable:next force_unwrapping
                Image(headerImage, label: headerImageLabel!)
            } else {
                Image(decorative: headerImage)
            }
            Divider()
                .opacity(0)
                .background(Color.abBorder)
                .padding(.vertical, 32)
            HStack {
                bodyTitle
                    .latoFont(weight: .bold)
                    .foregroundColor(.abDarkText)
                Spacer()
            }
            Spacer().frame(height: 24)
        }
    }
}

struct OnboardingSubviewTemplate_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingBodyView(headerImage: "OnboardingIntro", headerImageLabel: nil,
                           bodyTitle: Text(verbatim: "Thanks for installing AdBlockVPN"))
            .background(Color.abBackground)
    }
}
