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

struct OnboardingCompleteView: View {
    @EnvironmentObject var model: OnboardingViewModel

    var body: some View {
        VStack {
            OnboardingBodyView(headerImage: "OnboardingComplete",
                               bodyTitle: "You're ready to start using AdBlock VPN!")
            Spacer().frame(height: 48)
            HStack(spacing: 32) {
                Button(action: {
                    NSApplication.shared.keyWindow?.close()
                    model.completeOnboarding(showPopover: false)
                }, label: { Text("Close") })
                .buttonStyle(SecondaryButtonStyle())
                Button(action: {
                        NSApplication.shared.keyWindow?.close()
                        model.completeOnboarding()
                }, label: { Text("Open AdBlock VPN") })
                .buttonStyle(PrimaryButtonStyle())
            }
            .fixedSize(horizontal: false, vertical: true)
            Spacer().frame(height: 32)
        }
        .onAppear {
            UserDefaults.standard.set(true, forKey: Constants.onboardingCompleted_key)
        }
    }
}

struct OnboardingCompleteView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingCompleteView()
            .frame(width: 576)
    }
}
