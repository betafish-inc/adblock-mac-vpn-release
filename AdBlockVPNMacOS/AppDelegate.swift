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

import Cocoa
import Combine
import LaunchAtLogin
import NetworkExtension
import Sparkle
import SwiftUI
import SwiftyBeaver
import SystemExtensions

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var userApproval = false
    var popover = NSPopover()
    var onboardingWindow: NSWindow?
    var statusBarItem: NSStatusItem?
    var showPopoverOnActive = true
    private var state = AppState()
    private var dockIconManager = DockIconManager()
    private var vpnManager = VPNManager()
    private var authManager = AuthManager()
    private var logManager = LogManager()
    private var errorManager: ErrorManager
    private var pingManager: PingManager?
    private var notificationManager = NotificationManager()
    private var updateManager: UpdateManager?
    private var notificationCentre = NotificationCenter.default
    private var cancellable: AnyCancellable?
    private var cancellablePopoverWillShow: AnyCancellable?
    private var cancellablePopoverWillClose: AnyCancellable?
    private let defaults = UserDefaults.standard
    private let monitor = NWPathMonitor()
    private let isXcodePreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    private var appIsInApplicationsFolder: Bool
    private var bundlePath = Bundle.main.bundlePath
    private lazy var iconAnimation = StatusItemAnimationManager(statusBarItem: statusBarItem)
    private lazy var onboardingViewModel = OnboardingViewModel(viewToShow: appIsInApplicationsFolder ? .intro : .appMove,
                                                               vpnManager: vpnManager,
                                                               notificationManager: notificationManager)
    private var shouldConnectOnWake = false
    private var isPowerOff = false

    override init() {
        errorManager = ErrorManager()
        errorManager.clearError()
        #if DEBUG
        // Prevents `Move to Application Folder` UI from presenting in debug builds.
        appIsInApplicationsFolder = true
        #else
        appIsInApplicationsFolder = PFIsInApplicationsFolder(bundlePath)
        #endif

        super.init()
    }

    func applicationWillFinishLaunching(_ notification: Notification) {
        dockIconManager.setDockIconVisibilityOnAppLaunch()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Set LaunchAtLogin preference if it has not been set previously
        // This should only run on the apps first launch
        if !defaults.bool(forKey: Constants.launchAtLoginSet_key) {
            LaunchAtLogin.isEnabled = true
            defaults.setValue(true, forKey: Constants.launchAtLoginSet_key)
        }

        let file = FileDestination()
        file.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $L: ($N: $l) $M"
        file.logFileURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(Constants.appLogFilePath)
        file.logFileMaxSize = (1 * 1024 * 1024) // Limit log file size to 1MB.
        file.logFileAmount = 2 // logFileAmount needs to be greater than 1 for logFileMaxSize to be applied.
        let console = ConsoleDestination()
        console.useNSLog = true
        console.format = "ABLOG: $C$L$c: ($N: $l) $M"
        SwiftyBeaver.addDestination(file)
        SwiftyBeaver.addDestination(console)

        checkForUpdateOrReinstall()
        SwiftyBeaver.debug("current app version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "x.x.x")")
        
        updateManager = UpdateManager(logManager: logManager)
        guard let initializedUpdateManager = updateManager else { return }
        SUUpdater.shared()?.delegate = initializedUpdateManager

        // Create the SwiftUI view that provides the window contents.
        let contentView = MainView(vpnManager: vpnManager,
                                   authManager: authManager,
                                   logManager: logManager,
                                   errorManager: errorManager,
                                   updateManager: initializedUpdateManager,
                                   dockIconManager: dockIconManager,
                                   viewModel: MainViewModel(authManager: authManager,
                                                            vpnManager: vpnManager,
                                                            errorManager: errorManager,
                                                            notificationManager: notificationManager),
                                   connectionViewModel: ConnectionViewModel(vpnManager: vpnManager,
                                                                            authManager: authManager,
                                                                            logManager: logManager,
                                                                            notificationManager: notificationManager,
                                                                            errorManager: errorManager),
                                   loginViewModel: LoginViewModel(authManager: authManager,
                                                                  logManager: logManager,
                                                                  errorManager: errorManager),
                                   connectionInfoViewModel: ConnectionInfoViewModel(vpnManager: vpnManager))
            .environmentObject(state)

        popover.contentSize = NSSize(width: 320 * state.guiScaleFactor.scale.app, height: 440)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)

        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = self.statusBarItem?.button {
            self.setStatusBarImage(with: vpnManager.connectionStatus ?? .invalid)
            button.action = #selector(togglePopover(_:))
            button.imageScaling = .scaleProportionallyDown

            // We have to delay showing the popover until after the button is created
            showPopoverOnActive = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showPopover(self)
            }
        }

        registerForInternetChanges()
        registerForSleepEvent()
        registerForWakeEvent()
        registerForPowerOffEvent()
        pingManager = PingManager(manager: logManager)
        pingManager?.start()
        
        if defaults.bool(forKey: Constants.reconnect_key) {
            state.restartConnection = true
            defaults.set(false, forKey: Constants.reconnect_key)
        }

        activateExtension()
        setupVpnStatusSubscriber()
        setupPopoverStatusSubscribers()
        SwiftyBeaver.verbose("App launch path: \(bundlePath)")

        // Conditionally presents either the Move App view, Onboarding view, or the main status bar item.
        if !appIsInApplicationsFolder {
            setStatusBarItemVisibility(isVisible: false)
            showOnboardingWindow()
        } else if !defaults.bool(forKey: Constants.onboardingCompleted_key) {
            setStatusBarItemVisibility(isVisible: false)
            showOnboardingWindow()
        } else {
            // This ensures that status bar item is visible on relaunch if app is force quit during the end of the onboarding steps.
            setStatusBarItemVisibility(isVisible: true)
        }
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        if NSApp.windows.count <= 2 {
            conditionallyShowPopover()
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        conditionallyShowPopover()
        return false
    }
    
    private func conditionallyShowPopover() {
        if showPopoverOnActive {
            showPopover(self)
        } else {
            showPopoverOnActive = true
        }
    }

    private func showOnboardingWindow() {
        let contentView = OnboardingMainView()
            .environmentObject(onboardingViewModel)
            .environmentObject(state)

        onboardingWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 1000),
            styleMask: [.titled, .miniaturizable, .closable, .fullSizeContentView],
            backing: .buffered, defer: false)
        onboardingWindow?.titlebarAppearsTransparent = true
        onboardingWindow?.backgroundColor = getOnboardingTitlebarColor()
        onboardingWindow?.isMovableByWindowBackground = true
        onboardingWindow?.setFrameAutosaveName("AdBlock VPN")
        onboardingWindow?.center()
        onboardingWindow?.contentView = NSHostingView(rootView: contentView)
        onboardingWindow?.makeKeyAndOrderFront(nil)
        onboardingWindow?.isReleasedWhenClosed = false
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem?.button {
            self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            self.popover.contentViewController?.view.window?.makeKey()
        }
    }
    
    func showPopover(_ sender: AnyObject?) {
        if !isXcodePreview {
            togglePopover(sender)
        }
    }

    /// Sets the visibility of the status bar item.
    /// - Parameter isVisible: A Boolean value to indicate if the menu bar should display the status bar item.
    func setStatusBarItemVisibility(isVisible: Bool) {
        self.statusBarItem?.isVisible = isVisible
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        let isPowerOffOrUpdate = defaults.bool(forKey: Constants.willInstallUpdate_key) || isPowerOff
        let shouldBeConnected = [.connected, .connecting].contains(vpnManager.connectionStatus) || shouldConnectOnWake
        let shouldConnectOnStart = isPowerOffOrUpdate && shouldBeConnected
        UserDefaults.standard.set(shouldConnectOnStart, forKey: Constants.reconnect_key)
        
        vpnManager.disconnectVPN {
            sender.reply(toApplicationShouldTerminate: true)
        }
        return .terminateLater
    }

    /// - Returns: The correct NSColor for titlebar styling, based on user theme preference. 
    private func getOnboardingTitlebarColor() -> NSColor {
        switch state.currentTheme {
        case .system:
            return .abBackground
        case .light:
            return .abOnboardingTitlebarLight
        case .dark:
            return .abOnboardingTitlebarDark
        }
    }

    /// Checks if the user has performed an update or fresh reinstall of the VPN, and if update, shows update overlay, if reinstall, resets the users login state.
    private func checkForUpdateOrReinstall() {
        guard let hostAppModifiedDate = (try? FileManager.default.attributesOfItem(atPath: bundlePath))?[.modificationDate] as? Date else { return }

        /// The modified date of the host app
        var currentModificationDate = hostAppModifiedDate.stringValue

        /// A cached instance of the modified date if one exists, otherwise an empty string.
        let storedModificationDate = defaults.string(forKey: Constants.modifiedDate_key) ?? ""

        // If storedModificationDate is empty, we can assume this is a first time install or user has purged their userdefaults.
        // In this case, we set the host app modified date and `currentModificationDate` variable to the current date and time.
        // This is to prevent the host app modified date being set at build time, rather set the first time the app has run.
        // This covers the edgecase where a user may install, delete and reinstall the same version of the app, but not detecting
        // a reinstall is required as the modified date is static.
        if storedModificationDate.isEmpty {
            let date = Date()
            let attributes: [FileAttributeKey: Any] = [FileAttributeKey.modificationDate: date]
            do {
                try FileManager.default.setAttributes(attributes, ofItemAtPath: bundlePath)
                currentModificationDate = date.stringValue
                SwiftyBeaver.debug("Host app modified date set to: \(currentModificationDate))")
            } catch {
                SwiftyBeaver.error("Host app modified date write failed with error: \(error)")
            }
        }

        let hasBeenModified = storedModificationDate != currentModificationDate
        let hasUpdated = defaults.bool(forKey: Constants.willInstallUpdate_key)
        defaults.setValue(false, forKey: Constants.willInstallUpdate_key)

        switch hasBeenModified {
        case false:
            SwiftyBeaver.debug("Host app modified date hasn't changed: \(String(describing: storedModificationDate))")
        case true && hasUpdated:
            state.showOverlay = true
            defaults.setValue(currentModificationDate, forKey: Constants.modifiedDate_key)
            SwiftyBeaver.debug("Update detected - host app modified date changed from \(storedModificationDate) to \(currentModificationDate)")
        case true:
            authManager.logOut()
            defaults.setValue(currentModificationDate, forKey: Constants.modifiedDate_key)
            SwiftyBeaver.debug("Reinstall detected - host app modified date changed from \(storedModificationDate) to \(currentModificationDate)")
        }
    }

    private func activateExtension() {
        // Create an activation request and assign a delegate to
        // receive reports of success or failure.
        let request = OSSystemExtensionRequest.activationRequest(forExtensionWithIdentifier: Constants.tunnelProviderID,
                                                                 queue: DispatchQueue.main)
        request.delegate = self

        // Submit the request to the system.
        let extensionManager = OSSystemExtensionManager.shared
        extensionManager.submitRequest(request)
    }

    private func setupVpnStatusSubscriber() {
        cancellable = self.notificationCentre.publisher(for: .NEVPNStatusDidChange)
            .sink { notification in
                guard let session = notification.object as? NETunnelProviderSession else { return }
                self.setStatusBarImage(with: session.status)
            }
    }

    private func setStatusBarImage(with vpnStatus: NEVPNStatus) {
        guard let button = self.statusBarItem?.button else { return }
        iconAnimation.stopAnimating()
        switch vpnStatus {
        case .connected:
            button.appearsDisabled = false
        case .disconnected, .invalid:
            button.appearsDisabled = true
        case .connecting, .disconnecting, .reasserting:
            button.appearsDisabled = false
            iconAnimation.startAnimating()
        @unknown default:
            button.appearsDisabled = true
        }
    }
    
    private func setupPopoverStatusSubscribers() {
        cancellablePopoverWillShow = self.notificationCentre.publisher(for: NSPopover.willShowNotification)
            .sink { [weak self] _ in
                self?.notificationManager.shouldShow = false
            }
        cancellablePopoverWillClose = self.notificationCentre.publisher(for: NSPopover.willCloseNotification)
            .sink { [weak self] _ in
                self?.notificationManager.shouldShow = true
            }
    }
    
    private func registerForPowerOffEvent() {
        let notificationCenter = NSWorkspace.shared.notificationCenter
        notificationCenter.addObserver(forName: NSWorkspace.willPowerOffNotification, object: nil, queue: nil) { [weak self] _ in
            self?.isPowerOff = true
        }
    }
    
    private func registerForWakeEvent() {
        let notificationCenter = NSWorkspace.shared.notificationCenter
        notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: nil) { [weak self] _ in
            SwiftyBeaver.verbose("wake event received")
            if self?.shouldConnectOnWake ?? false {
                SwiftyBeaver.debug("connecting from wake")
                self?.state.restartConnection = true
                self?.state.viewToShow = .connection
                self?.shouldConnectOnWake = false
            }
            
            // If user has auto updates on
            if self?.updateManager?.applyUpdatesAutomatically ?? false {
                // If the update has been downloaded
                if self?.updateManager?.storedUpdateBlock != nil {
                    SwiftyBeaver.debug("wake apply update")
                    // Apply the update
                    self?.updateManager?.storedUpdateBlock?()
                } else {
                    SwiftyBeaver.debug("wake check for updates in background")
                    // Otherwise, check for an available update and download in background
                    self?.updateManager?.checkForUpdatesInBackground()
                }
            } else {
                SwiftyBeaver.debug("wake check for updates (no auto update)")
                // Otherwise, check if there's an available update, silently
                self?.updateManager?.checkForUpdates()
            }
        }
    }
    
    private func registerForSleepEvent() {
        let notificationCenter = NSWorkspace.shared.notificationCenter
        notificationCenter.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: nil) { [weak self] _ in
            SwiftyBeaver.verbose("sleep event received")
            if [.connected, .connecting].contains(self?.vpnManager.connectionStatus) {
                self?.shouldConnectOnWake = true
                SwiftyBeaver.debug("disconnecting on sleep")
                self?.vpnManager.disconnectVPN()
            }
        }
    }
    
    private func registerForInternetChanges() {
        let pathUpdateHandler = { [weak self] (path: Network.NWPath) in
            guard let strongSelf = self else { return }
            
            SwiftyBeaver.debug("path change: \(path.debugDescription)")
            
            if !path.availableInterfaces.contains(where: { $0.type == .wifi || $0.type == .wiredEthernet }) {
                strongSelf.errorManager.setError(error: ErrorManager.ErrorObj(message: "", type: .noInternet, link: nil))
                SwiftyBeaver.debug("no internet")
            }
            
            if path.status != .unsatisfied && path.availableInterfaces.contains(where: { $0.type == .wifi || $0.type == .wiredEthernet }) && strongSelf.errorManager.isError {
                strongSelf.errorManager.clearError()
                SwiftyBeaver.debug("internet back")
            }
        }
        
        monitor.pathUpdateHandler = pathUpdateHandler
        let queue = DispatchQueue.init(label: "pathMonitorInternetQueue", qos: .userInitiated)
        monitor.start(queue: queue)
        SwiftyBeaver.verbose("start listening for internet connectivity")
    }

    @IBAction func signOutClicked(_ sender: AnyObject) {
        authManager.logOut()
    }
    
    @IBAction func openLinkMenuClicked(_ sender: NSMenuItem) {
        if let senderID = sender.identifier?.rawValue {
            var stringURL = ""
            if senderID == "ManageAccountMenuItem" {
                stringURL = Constants.accountsURL
            } else if senderID == "SendFeedbackMenuItem" {
                stringURL = Constants.feedbackURL
            } else if senderID == "GetHelpMenuItem" {
                stringURL = Constants.helpURL
            }
            if let url = URL(string: stringURL) {
                NSWorkspace.shared.open(url)
            }
        }
    }

    @IBAction func zoomMenuClicked(_ sender: NSMenuItem) {
        guard let senderID = sender.identifier?.rawValue else { return }
        if senderID == "ActualSizeMenuItem" {
            state.guiResetView()
        } else if senderID == "ZoomInMenuItem" {
            state.guiZoomIn()
        } else if senderID == "ZoomOutMenuItem" {
            state.guiZoomOut()
        }
    }
}

// based on code from: https://developer.apple.com/documentation/networkextension/filtering_network_traffic
extension AppDelegate: OSSystemExtensionRequestDelegate {
    func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {
        guard result == .completed else {
            SwiftyBeaver.debug("Unexpected result \(result.rawValue) for system extension request")
            return
        }
        
        if userApproval {
            userApproval = false
            logManager.sendLogMessage(message: .install_success)
            activateExtension()
        } else {
            state.sysExtensionActive = true
            onboardingViewModel.sysExtensionActive = true
        }
    }

    func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {
        logManager.sendLogMessage(message: .install_failure, error: error.localizedDescription)
        SwiftyBeaver.error("System extension request failed: \(error.localizedDescription)")
        state.sysExtensionActive = false
        onboardingViewModel.sysExtensionActive = false
    }

    func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
        logManager.sendLogMessage(message: .install_attempt)
        SwiftyBeaver.debug("Extension \(request.identifier) requires user approval")
        userApproval = true
    }

    func request(_ request: OSSystemExtensionRequest,
                 actionForReplacingExtension existing: OSSystemExtensionProperties,
                 withExtension extension: OSSystemExtensionProperties) -> OSSystemExtensionRequest.ReplacementAction {
        // TODO: check if versions differ
        SwiftyBeaver.debug("Replacing extension \(request.identifier) version \(existing.bundleShortVersion) with version \(`extension`.bundleShortVersion)")
        return .replace
    }
}
