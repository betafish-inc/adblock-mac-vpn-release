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

struct ListItemButtonStyle: ButtonStyle {
    @State private var isHover = false
    var animationSpeed: Double = 0.15
    var selected: Bool = false
    var buttonWidth: CGFloat = 272

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: buttonWidth, height: 40, alignment: .center)
            .offset(x: 0, y: configuration.isPressed ? 0 : isHover ? -1 : 0)
            .background(selected ? Color.abPrimaryAccent : configuration.isPressed ? Color.abListItemClicked : Color.white)
            .foregroundColor(selected ? .white : .abDarkText)
            .cornerRadius(6)
            .shadow(color: selected ? .clear : configuration.isPressed ? .clear : isHover ? .abShadow : .clear,
                    radius: isHover ? 4 : 0,
                    x: 0,
                    y: isHover ? 3 : 0)
            .blendMode(.plusDarker)
            .onHover { inside in
                withAnimation(.easeInOut(duration: animationSpeed)) {
                    isHover = inside
                }
            }
    }
}

struct RegionButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {}, label: {
                Text(verbatim: "List Item Button")
            }).buttonStyle(ListItemButtonStyle())
            Button(action: {}, label: {
                Text(verbatim: "Reduced Width Button")
            }).buttonStyle(ListItemButtonStyle(buttonWidth: 240))
            Button(action: {}, label: {
                Text(verbatim: "Selected Button")
            }).buttonStyle(ListItemButtonStyle(selected: true))
            Button(action: {}, label: {
                Text(verbatim: "Selected Reduced Width Button")
            }).buttonStyle(ListItemButtonStyle(selected: true, buttonWidth: 240))
        }
        .padding()
    }
}
