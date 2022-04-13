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

struct SearchBar: View {
    @EnvironmentObject var state: AppState
    @Binding var searchText: String
    @State private var isFocused: Bool = false
    var body: some View {
        HStack {
            Image(decorative: "SearchIcon")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(height: 24)
            FocusTextFieldElement(text: $searchText,
                                  isFocused: $isFocused,
                                  placeholderText: "Search",
                                  alignCenter: false,
                                  trimWhitespace: false,
                                  fontSize: state.guiScaleFactor.scale.textFieldFontSize,
                                  onCommit: {})
        }
        .accessibilityElement(children: .contain)
        .customAccessibilityLabel(Text("Search regions list", comment: "Alt text for regions search bar"))
        .foregroundColor(.abDarkText)
        .padding(.horizontal, 16)
        .frame(width: 272 * state.guiScaleFactor.scale.app,
               height: 40 * state.guiScaleFactor.scale.app)
        .background(Color.abSearchBarBackground)
        .cornerRadius(6)
        .clipped()
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.abBorder, lineWidth: 1)
        )
        .scaleEffect(state.guiScaleFactor.scale.textField)
        .frame(width: 272 * state.guiScaleFactor.scale.app - 80)
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(searchText: .constant("")).environmentObject(AppState())
    }
}
