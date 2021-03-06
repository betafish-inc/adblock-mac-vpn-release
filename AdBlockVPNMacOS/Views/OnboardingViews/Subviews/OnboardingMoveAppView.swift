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

struct OnboardingMoveAppView: View {
    /// Set to true when app has started it's process to move to Applications folder.
    /// This is to prevent app termination from being called from `NSWindow.willCloseNotification`
    @State var appIsMoving = false

    var body: some View {
        VStack {
            OnboardingBodyView(headerImage: "OnboardingMoveApp",
                               headerImageLabel: nil,
                               bodyTitle: Text("Move AdBlock VPN to the Applications folder", comment: "Title for move app page of onboarding flow"))
            Text("We’ll need to move the AdBlock VPN app into your Applications folder first. Click “Continue” to confirm this change.",
                 comment: "Instructions for move app page of onboarding flow")
                .latoFont()
                .foregroundColor(.abDarkText)
                .fixedSize(horizontal: false, vertical: true)
            Spacer().frame(height: 48)
            HStack(spacing: 32) {
                Button(action: { terminateApp() }, label: {
                    Text("Cancel", comment: "Label for button that cancels out of the onboarding flow")
                }).buttonStyle(SecondaryButtonStyle())
                Button(action: { moveApp() }, label: {
                    Text("Continue", comment: "Label for button that continues the process of moving the app to the correct folder")
                }).buttonStyle(PrimaryButtonStyle())
            }
            .fixedSize(horizontal: false, vertical: true)
            Spacer().frame(height: 32)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { _ in terminateApp() }
    }

    /// Moves the host app to the Applications folder
    fileprivate func moveApp() {
        appIsMoving = true
        PFMoveToApplicationsFolderIfNecessary()
    }

    /// Terminates the app process
    fileprivate func terminateApp() {
        if !appIsMoving { NSApp.terminate(self) }
    }
}

struct OnboardingMoveAppView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingMoveAppView()
            .background(Color.abBackground)
            .frame(width: 576)
    }
}
