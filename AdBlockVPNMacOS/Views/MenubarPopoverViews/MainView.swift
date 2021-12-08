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

struct MainView: View {
    @EnvironmentObject var state: AppState
    private(set) var vpnManager: VPNManager
    private(set) var authManager: AuthManager
    private(set) var logManager: LogManager
    private(set) var errorManager: ErrorManager
    private(set) var updateManager: UpdateManager
    private(set) var dockIconManager: DockIconManager
    @ObservedObject var viewModel: MainViewModel
    private(set) var connectionViewModel: ConnectionViewModel
    private(set) var loginViewModel: LoginViewModel
    private(set) var connectionInfoViewModel: ConnectionInfoViewModel
    var body: some View {
        VStack {
            Spacer().frame(width: 0, height: 16)
            TopBarView()
            VStack {
                Spacer().frame(width: 0, height: 16)
                getViewToShow()
                    .frame(width: 272, height: state.showConnectionInfo ? 460 : 352)
                    .onAppear {
                        self.state.checkViewToShow(loggedIn: self.authManager.isLoggedIn, isError: errorManager.isMainError, updateRequired: updateManager.updateIsRequired)
                    }
            }
            .if(state.showOverlay) {
                $0.overlay(
                    UpdateOverlayView(text: Text("Update Complete!", comment: "Notification that an update has been completed"),
                                      icon: "CheckIcon",
                                      background: .abUpToDateAccent,
                                      foreground: .abWhiteText)
                        .shadow(color: .abShadow, radius: 20, x: 0, y: 5),
                    alignment: .top
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        state.showOverlay = false
                    }
                }
            }
        }
        .frame(width: 320, height: state.showConnectionInfo ? 548 : 440)
        .background([.updates, .updateError, .updateRequired].contains(state.viewToShow) ? Color.abAccentBackground : Color.abBackground)
        .foregroundColor(.abLightText)
        .onReceive(authManager.$token, perform: { newVal in
            self.state.checkViewToShow(loggedIn: self.authManager.willBeLoggedIn(newToken: newVal),
                                       isError: errorManager.isMainError,
                                       updateRequired: updateManager.updateIsRequired)
        })
        .onReceive(viewModel.$vpnAllowed, perform: { newVal in
            if let allowed = newVal, allowed {
                self.state.vpnProfileActive = allowed
            }
        })
        .onReceive(state.$sysExtensionActive, perform: { newVal in
            if newVal {
                viewModel.checkState()
            }
        })
        .onReceive(errorManager.$isError, perform: { newVal in
            if newVal {
                if errorManager.isAuthError {
                    self.authManager.logOut()
                } else if errorManager.isRetryError {
                    self.state.restartConnection = true
                }
            }
            self.state.checkViewToShow(loggedIn: self.authManager.isLoggedIn, isError: errorManager.isMainError, updateRequired: updateManager.updateIsRequired)
            if errorManager.newError {
                viewModel.showErrorNotification()
            }
        })
        .onReceive(errorManager.$checkError, perform: { newVal in
            if newVal, newVal != errorManager.checkError {
                viewModel.checkForError()
            }
        })
        .onReceive(viewModel.$restartConnection, perform: { newVal in
            if newVal {
                state.restartConnection = newVal
            }
        })
        .onReceive(viewModel.$providerAuthChecked, perform: { newVal in
            state.providerAuthChecked = newVal
        })
        .onReceive(updateManager.$updateFailed, perform: { newVal in
            if newVal {
                state.viewToShow = .updateError
            }
        })
        .onReceive(updateManager.$updateIsRequired, perform: { newVal in
            if newVal {
                state.viewToShow = .updateRequired
            } else if updateManager.updateIsRequired {
                state.viewToShow = .connection
            }
        })
    }
    
    @ViewBuilder
    func getViewToShow() -> some View {
        if state.viewToShow == .acceptance {
            AcceptanceView()
        } else if state.viewToShow == .setUpExtension {
            SetUpExtensionView()
        } else if state.viewToShow == .landing {
            LandingView()
        } else if state.viewToShow == .error {
            ErrorView(viewModel: ErrorViewModel(errorManager: errorManager))
        } else if state.viewToShow == .login {
            LoginFlowView(viewModel: loginViewModel)
        } else if state.viewToShow == .connection {
            ConnectionView(viewModel: connectionViewModel, connectionInfoViewModel: connectionInfoViewModel)
        } else if state.viewToShow == .setUpVPN {
            SetUpVPNView(viewModel: connectionViewModel)
        } else if state.viewToShow == .locations {
            RegionSelectionView(viewModel: connectionViewModel)
        } else if state.viewToShow == .preferences {
            PreferencesView(viewModel: PreferencesViewModel(vpnManager: vpnManager, authManager: authManager))
        } else if state.viewToShow == .account {
            AccountView(viewModel: AccountViewModel(vpnManager: vpnManager, authManager: authManager))
        } else if state.viewToShow == .help {
            HelpView(viewModel: HelpViewModel())
        } else if state.viewToShow == .appSettings {
            AppSettingsView(viewModel: AppSettingsViewModel(updateManager: updateManager, dockIconManager: dockIconManager))
        } else if state.viewToShow == .updates {
            UpdatesView(viewModel: UpdatesViewModel(updateManager: updateManager))
        } else if state.viewToShow == .updateError {
            UpdatesErrorView(viewModel: UpdatesViewModel(updateManager: updateManager))
        } else if state.viewToShow == .updateRequired {
            UpdateRequiredView(viewModel: UpdatesViewModel(updateManager: updateManager))
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(vpnManager: VPNManager(),
                 authManager: AuthManager(),
                 logManager: LogManager(),
                 errorManager: ErrorManager(),
                 updateManager: UpdateManager(logManager: LogManager()),
                 dockIconManager: DockIconManager(),
                 viewModel: MainViewModel(authManager: AuthManager(),
                                          vpnManager: VPNManager(), errorManager: ErrorManager(),
                                          notificationManager: NotificationManager()),
                 connectionViewModel: ConnectionViewModel(vpnManager: VPNManager(),
                                                          authManager: AuthManager(),
                                                          logManager: LogManager(),
                                                          notificationManager: NotificationManager(),
                                                          errorManager: ErrorManager()),
                 loginViewModel: LoginViewModel(authManager: AuthManager(),
                                                logManager: LogManager(),
                                                errorManager: ErrorManager()),
                 connectionInfoViewModel: ConnectionInfoViewModel(vpnManager: VPNManager()))
            .environmentObject(AppState())
    }
}
