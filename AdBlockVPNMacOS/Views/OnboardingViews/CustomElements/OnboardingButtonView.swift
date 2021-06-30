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

struct OnboardingButtonView: View {
    var action: () -> Void
    var text: String
    var isPrimary: Bool

    var body: some View {
        Button(action: action) {
            Text(text)
                .multilineTextAlignment(.center)
                .padding(8)
                .frame(maxWidth: 272, minHeight: 40, maxHeight: .infinity)
                .background(isPrimary ? Color.abPrimaryAccent : Color.white)
        }
        .foregroundColor(isPrimary ? .white : .black)
        .cornerRadius(6)
        .if(isPrimary) { $0.shadow(color: .abShadow, radius: 10, x: 0, y: 5) }
        .if(!isPrimary) { $0.overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.abBorder, lineWidth: 1)) }
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

struct OnboardingPrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingButtonView(action: {}, text: "Primary CTA", isPrimary: true)
            .padding()
            .frame(width: 150, height: 40)
        OnboardingButtonView(action: {}, text: "Secondry CTA Secondry CTA Secondry CTA Secondry CTA", isPrimary: false)
            .padding()
            .frame(width: 300, height: 100)
    }
}
