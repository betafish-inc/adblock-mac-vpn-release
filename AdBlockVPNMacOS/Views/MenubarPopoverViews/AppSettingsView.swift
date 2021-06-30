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

import LaunchAtLogin
import SwiftUI

struct AppSettingsView: View {
    @EnvironmentObject var state: AppState
    @ObservedObject var viewModel: AppSettingsViewModel
    @ObservedObject var launchAtLogin = LaunchAtLogin.observable

    var body: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 8)
            VStack {
                Toggle("Show dock icon", isOn: $viewModel.showDockIcon).toggleStyle(CustomColorToggleStyle())
                Divider().customDividerStyle().padding(.vertical, 6)
                Toggle("Launch at Login", isOn: $launchAtLogin.isEnabled).toggleStyle(CustomColorToggleStyle())
                Divider().customDividerStyle().padding(.vertical, 6)
                Toggle("Apply updates" + "\n" + "automatically", isOn: $viewModel.automaticUpdatesOn).toggleStyle(CustomColorToggleStyle())
            }
            Spacer()
            if viewModel.updateAvailable {
                ColorfulButtonView(action: {
                    state.viewToShow = .updates
                }, text: "Update Available", icon: "NextIcon", iconSize: 11, background: .abUpdateAccent, foreground: .abDarkText)
                .shadow(color: .abShadow, radius: 20, x: 0, y: 5)
            } else {
                ColorfulButtonView(action: {}, text: "Up To Date", icon: "CheckIcon", iconSize: 16, background: .abUpToDateAccent, foreground: .white)
            }
            Spacer().frame(height: 8)
            Text(state.getVersionString())
                .latoFont(size: 14)
                .foregroundColor(.abLightText)
                .offset(x: 16, y: 0)
            Spacer().frame(height: 24)
        }
        .frame(width: 272, height: 352)
        .background(Color.white)
        .onAppear {
            viewModel.checkForUpdates()
        }
        // To prevent multiple dock icons appearing when toggle is clicked a lot in short sucession, a debouncer is added before new value is processed.
        .onReceive(viewModel.$showDockIcon.debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)) {
            viewModel.setDockIconVisibility(isVisible: $0)
        }
        // Prevents popover from disapearing when app is in focus while dock icon changes to a hidden state.
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didHideNotification)) { _ in
            guard let appDelegate: AppDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
            appDelegate.showPopover(nil)
        }
    }
}

struct AppSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AppSettingsView(viewModel: AppSettingsViewModel(updateManager: UpdateManager(logManager: LogManager()),
                                                        dockIconManager: DockIconManager())).environmentObject(AppState())
    }
}
