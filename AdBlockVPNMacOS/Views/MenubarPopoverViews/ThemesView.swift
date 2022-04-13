//
//  ThemesView.swift
//  AdBlockVPNMacOS
//
//  Created by Dean Murphy on 17/03/2022.
//  Copyright © 2022 Adblock, Inc. All rights reserved.
//

import SwiftUI

struct ThemesView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        VStack {
            ThemesButtonView(text: NSLocalizedString("Use system appearance", comment: "Description of system theme setting."), theme: .system)
            if state.currentTheme == .dark { Divider().background(Color.abBorder).frame(width: 272) } else { Spacer().frame(height: 17) }
            ThemesButtonView(text: NSLocalizedString("Light", comment: "This should mirror what Apple calls the appearance setting in System Preferences > General"),
                             theme: .light)
            if state.currentTheme == .system { Divider().background(Color.abBorder).frame(width: 272) } else { Spacer().frame(height: 17) }
            ThemesButtonView(text: NSLocalizedString("Dark", comment: "This should mirror what Apple calls the appearance setting in System Preferences > General"),
                             theme: .dark)
            Spacer()
        }
        .padding(.top, 8)
        .frame(width: 272, height: state.showConnectionInfo ? 460 : 352)
        .background(Color.abBackground)
        .foregroundColor(.abDarkText)
    }
}

struct ThemesView_Previews: PreviewProvider {
    static var previews: some View {
        ThemesView().environmentObject(AppState())
    }
}

struct ThemesButtonView: View {
    @EnvironmentObject var state: AppState
    var text: String
    var theme: SystemTheme
    var body: some View {
        Button(action: { setTheme() },
               label: {
            HStack {
                Spacer().frame(width: 15)
                Text(text)
                    .latoFont()
                Spacer()
                if state.currentTheme == theme {
                Image(decorative: "CheckIcon")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 24)
                Spacer().frame(width: 15)
                }
            }
        })
        .buttonStyle(ListItemButtonStyle(selected: state.currentTheme == theme, buttonWidth: 272))
        .if(state.currentTheme == theme) {
            $0.customAccessibilityLabel(Text("\(text), selected", comment: "Label for selected theme button"))
        }
    }

    func setTheme() {
        if state.currentTheme != theme {
            state.currentTheme = theme
        }
    }
}
