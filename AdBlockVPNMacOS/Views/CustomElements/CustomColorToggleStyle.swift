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

import Foundation
import SwiftUI

struct CustomColorToggleStyle: ToggleStyle {
    private var onColor = Color.abToggleOn
    private var offColor = Color.abToggleOff
    private var circleColor = Color.abToggleCircle
    
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            Button(action: {
                withAccessibilityFriendlyAnimation(Animation.easeInOut(duration: 0.1), {
                    configuration.isOn.toggle()
                })
            }, label: {
                HStack {
                    configuration.label
                        .latoFont()
                        .foregroundColor(.abDarkText)
                        .lineSpacing(4)
                    Spacer()
                    RoundedRectangle(cornerRadius: 100, style: .circular)
                        .fill(configuration.isOn ? onColor : offColor)
                        .frame(width: 48, height: 24)
                        .overlay(
                            Circle()
                                .fill(circleColor)
                                .padding(2)
                                .offset(x: configuration.isOn ? 12 : -12))
                }
            })
                .buttonStyle(PlainButtonStyle())
        }
        .frame(width: 240)
        .padding(.horizontal, 16)
    }
}
