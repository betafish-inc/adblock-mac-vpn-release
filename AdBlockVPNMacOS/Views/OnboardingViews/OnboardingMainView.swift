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

struct OnboardingMainView: View {
    @EnvironmentObject var model: OnboardingViewModel

    var body: some View {
        VStack {
            OnboardingTopBarView(currentView: model.viewToShow)
            getBodyView()
        }
        .frame(width: 576)
        .padding(.horizontal, 32)
        .padding(.top, 8)
        .padding(.bottom)
        // If onboarding window is closed by the user, the app will either terminate or complete the onboarding process if they are on the final `.complete` page
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { _ in
            if model.viewToShow == .complete {
                model.completeOnboarding()
            } else if model.viewToShow != .appMove {
                NSApp.terminate(self)
            }
        }
    }

    @ViewBuilder
    func getBodyView() -> some View {
        switch model.viewToShow {
        case .intro:
            OnboardingIntroView()
        case .sysExtension:
            OnboardingSysExtensionView()
        case .sysExtensionError:
            OnboardingPermissionsErrorView()
        case .VPNConfig:
            OnboardingVPNConfigView()
        case .VPNConfigError:
            OnboardingVPNConfigErrorView()
        case .notifications:
            OnboardingNotificationsView()
        case .complete:
            OnboardingCompleteView()
        case .appMove:
            OnboardingMoveAppView()
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(OnboardingViews.allCases, id: \.self) { view in
            OnboardingMainView()
                .environmentObject(OnboardingViewModel(viewToShow: view, vpnManager: VPNManager(), notificationManager: NotificationManager()))
                .background(Color.white)
        }
    }
}
