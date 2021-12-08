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
                Toggle(isOn: $state.showConnectionInfo) {
                    Text("Show connection info", comment: "Label for toggle to turn the 'show connection info' feature on/off")
                }.toggleStyle(CustomColorToggleStyle())
                Divider().customDividerStyle().padding(.vertical, 6)
                Toggle(isOn: $viewModel.showDockIcon) {
                    Text("Show dock icon", comment: "Label for toggle to turn the 'show dock icon' feature on/off")
                }.toggleStyle(CustomColorToggleStyle())
                Divider().customDividerStyle().padding(.vertical, 6)
                Toggle(isOn: $launchAtLogin.isEnabled) {
                    Text("Launch at login", comment: "Label for toggle to turn the 'launch at login' feature on/off")
                }.toggleStyle(CustomColorToggleStyle())
                Divider().customDividerStyle().padding(.vertical, 6)
                Toggle(isOn: $viewModel.automaticUpdatesOn) {
                    Text("Apply updates automatically", comment: "Label for toggle to turn the 'apply updates automatically' feature on/off")
                }.toggleStyle(CustomColorToggleStyle())
            }
            Spacer()
            ColorfulButtonView(action: viewModel.updateAvailable ? { state.viewToShow = .updates } : {},
                               text: viewModel.updateAvailable ?
                               Text("Update Available", comment: "Label for button to go to updates page") :
                               Text("Up To Date", comment: "Label for disabled button (when no update is available)"),
                               icon: viewModel.updateAvailable ? "NextIcon": "CheckIcon",
                               iconSize: viewModel.updateAvailable ? 11 : 16,
                               updateAvailable: viewModel.updateAvailable)
                .disabled(!viewModel.updateAvailable)
            Spacer().frame(height: 8)
            Text("Version \(state.versionString)", comment: "App version shown on settings page. Variable holds the version number")
                .latoFont(size: 14)
                .foregroundColor(.abLightText)
                .offset(x: 16, y: 0)
            Spacer().frame(height: 24)
        }
        .frame(width: 272, height: state.showConnectionInfo ? 460 : 352)
        .background(Color.abBackground)
        .onAppear {
            viewModel.checkForUpdates()
        }
        // To prevent multiple dock icons appearing when toggle is clicked a lot in short succession, a debouncer is added before new value is processed.
        .onReceive(viewModel.$showDockIcon.debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)) {
            viewModel.setDockIconVisibility(isVisible: $0)
        }
        // Prevents popover from disappearing when app is in focus while dock icon changes to a hidden state.
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
