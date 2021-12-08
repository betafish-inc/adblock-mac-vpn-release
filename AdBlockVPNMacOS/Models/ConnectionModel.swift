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

import NetworkExtension
import SwiftUI

struct Geo: Identifiable, Decodable {
    var host: String
    var id: String
    var port: Int
}

struct Regions: Decodable {
    let regions: [Geo]
}

struct GeoAssets {
    static let flags = [
        "au_per": "FlagAustralia",
        "au_syd": "FlagAustralia",
        "at": "FlagAustria",
        "be": "FlagBelgium",
        "br": "FlagBrazil",
        "bg": "FlagBulgaria",
        "ca": "FlagCanada",
        "cl": "FlagChile",
        "cz": "FlagCzechRepublic",
        "dk": "FlagDenmark",
        "fi": "FlagFinland",
        "fr": "FlagFrance",
        "de": "FlagGermany",
        "gr": "FlagGreece",
        "hk": "FlagHongKong",
        "hu": "FlagHungary",
        "is": "FlagIceland",
        "in": "FlagIndia",
        "ie": "FlagIreland",
        "im": "FlagIsleOfMan",
        "il": "FlagIsrael",
        "it": "FlagItaly",
        "jp": "FlagJapan",
        "mx": "FlagMexico",
        "md": "FlagMoldova",
        "nl": "FlagNetherlands",
        "nz": "FlagNewZealand",
        "no": "FlagNorway",
        "pl": "FlagPoland",
        "ro": "FlagRomania",
        "ru": "FlagRussia",
        "rs": "FlagSerbia",
        "sg": "FlagSingapore",
        "si": "FlagSlovenia",
        "es": "FlagSpain",
        "se": "FlagSweden",
        "ch": "FlagSwitzerland",
        "gb_lon": "FlagUK",
        "gb_mnc": "FlagUK",
        "us_atl": "FlagUS",
        "us_chi": "FlagUS",
        "us_dal": "FlagUS",
        "us_las": "FlagUS",
        "us_lax": "FlagUS",
        "us_mia": "FlagUS",
        "us_nyc": "FlagUS",
        "us_ewr": "FlagUS",
        "us_phx": "FlagUS",
        "us_sfo": "FlagUS",
        "us_sea": "FlagUS",
        "us_was": "FlagUS"
    ]
    
    static let geoNames = [
        "au_per": NSLocalizedString("Australia - Perth", comment: "Name of 'au_per' region"),
        "au_syd": NSLocalizedString("Australia - Sydney", comment: "Name of 'au_syd' region"),
        "at": NSLocalizedString("Austria", comment: "Name of 'at' region"),
        "be": NSLocalizedString("Belgium", comment: "Name of 'be' region"),
        "br": NSLocalizedString("Brazil", comment: "Name of 'br' region"),
        "bg": NSLocalizedString("Bulgaria", comment: "Name of 'bg' region"),
        "ca": NSLocalizedString("Canada", comment: "Name of 'ca' region"),
        "cl": NSLocalizedString("Chile", comment: "Name of 'cl' region"),
        "cz": NSLocalizedString("Czech Republic", comment: "Name of 'cz' region"),
        "dk": NSLocalizedString("Denmark", comment: "Name of 'dk' region"),
        "fi": NSLocalizedString("Finland", comment: "Name of 'fi' region"),
        "fr": NSLocalizedString("France", comment: "Name of 'fr' region"),
        "de": NSLocalizedString("Germany", comment: "Name of 'de' region"),
        "gr": NSLocalizedString("Greece", comment: "Name of 'gr' region"),
        "hk": NSLocalizedString("Hong Kong", comment: "Name of 'hk' region"),
        "hu": NSLocalizedString("Hungary", comment: "Name of 'hu' region"),
        "is": NSLocalizedString("Iceland", comment: "Name of 'is' region"),
        "in": NSLocalizedString("India", comment: "Name of 'in' region"),
        "ie": NSLocalizedString("Ireland", comment: "Name of 'ie' region"),
        "im": NSLocalizedString("Isle of Man", comment: "Name of 'im' region"),
        "il": NSLocalizedString("Israel", comment: "Name of 'il' region"),
        "it": NSLocalizedString("Italy", comment: "Name of 'it' region"),
        "jp": NSLocalizedString("Japan", comment: "Name of 'jp' region"),
        "mx": NSLocalizedString("Mexico", comment: "Name of 'mx' region"),
        "md": NSLocalizedString("Moldova", comment: "Name of 'md' region"),
        "nl": NSLocalizedString("Netherlands", comment: "Name of 'nl' region"),
        "nz": NSLocalizedString("New Zealand", comment: "Name of 'nz' region"),
        "no": NSLocalizedString("Norway", comment: "Name of 'no' region"),
        "pl": NSLocalizedString("Poland", comment: "Name of 'pl' region"),
        "ro": NSLocalizedString("Romania", comment: "Name of 'ro' region"),
        "ru": NSLocalizedString("Russia", comment: "Name of 'ru' region"),
        "rs": NSLocalizedString("Serbia", comment: "Name of 'rs' region"),
        "sg": NSLocalizedString("Singapore", comment: "Name of 'sg' region"),
        "si": NSLocalizedString("Slovenia", comment: "Name of 'si' region"),
        "es": NSLocalizedString("Spain", comment: "Name of 'es' region"),
        "se": NSLocalizedString("Sweden", comment: "Name of 'se' region"),
        "ch": NSLocalizedString("Switzerland", comment: "Name of 'ch' region"),
        "gb_lon": NSLocalizedString("United Kingdom - London", comment: "Name of 'gb_lon' region"),
        "gb_mnc": NSLocalizedString("United Kingdom - Manchester", comment: "Name of 'gb_mnc' region"),
        "us_atl": NSLocalizedString("US - Atlanta", comment: "Name of 'us_atl' region"),
        "us_chi": NSLocalizedString("US - Chicago", comment: "Name of 'us_chi' region"),
        "us_dal": NSLocalizedString("US - Dallas", comment: "Name of 'us_dal' region"),
        "us_las": NSLocalizedString("US - Las Vegas", comment: "Name of 'us_las' region"),
        "us_lax": NSLocalizedString("US - Los Angeles", comment: "Name of 'us_lax' region"),
        "us_mia": NSLocalizedString("US - Miami", comment: "Name of 'us_mia' region"),
        "us_nyc": NSLocalizedString("US - New York City", comment: "Name of 'us_nyc' region"),
        "us_ewr": NSLocalizedString("US - Newark", comment: "Name of 'us_ewr' region"),
        "us_phx": NSLocalizedString("US - Phoenix", comment: "Name of 'us_phx' region"),
        "us_sfo": NSLocalizedString("US - San Francisco", comment: "Name of 'us_sfo' region"),
        "us_sea": NSLocalizedString("US - Seattle", comment: "Name of 'us_sea' region"),
        "us_was": NSLocalizedString("US - Washington, D.C.", comment: "Name of 'us_was' region"),
        "nearest": NSLocalizedString("Nearest location", comment: "Name of option to use the nearest region")
    ]
    
    static func getGeoName(id: String) -> String {
        return GeoAssets.geoNames[id] ?? NSLocalizedString("Error", comment: "Shown when the location name cannot be found")
    }
}

enum FlagTypes {
    case noFlag
    case greyFlag
    case colorFlag
}

struct ConnectionState {
    var status: NEVPNStatus
    var icon: String
    var action: String
    var flag: FlagTypes
    var greyed: Bool
}

struct ConnectionModel {
    var selectedGeo: String {
        didSet {
            UserDefaults.standard.setValue(selectedGeo, forKey: Constants.geo_key)
        }
    }
    var availableGeos: [Geo] = [Geo(host: "", id: "nearest", port: 0)]
    var connectionAttempted = false
    static let connectionState: [NEVPNStatus: ConnectionState] = [
        .connected: ConnectionState(status: .connected,
                                    icon: "LockConnected",
                                    action: NSLocalizedString("Disconnect", comment: "Label for disconnect button, shown when VPN is connected"),
                                    flag: .colorFlag,
                                    greyed: false),
        .connecting: ConnectionState(status: .connecting,
                                     icon: "LockConnecting",
                                     action: NSLocalizedString("Cancel", comment: "Label for cancel button, shown when VPN is in the process of connecting"),
                                     flag: .greyFlag,
                                     greyed: true),
        .disconnected: ConnectionState(status: .disconnected,
                                       icon: "LockNotConnected",
                                       action: NSLocalizedString("Connect", comment: "Label for connect button, shown when VPN is disconnected"),
                                       flag: .noFlag,
                                       greyed: false),
        .disconnecting: ConnectionState(status: .disconnecting,
                                        icon: "LockConnecting",
                                        action: NSLocalizedString("Reconnect", comment: "Label for reconnect button, shown when VPN is in the process of disconnecting"),
                                        flag: .greyFlag,
                                        greyed: true),
        .invalid: ConnectionState(status: .disconnected,
                                  icon: "LockNotConnected",
                                  action: NSLocalizedString("Connect", comment: "Label for connect button, shown when VPN is in an invalid state"),
                                  flag: .noFlag,
                                  greyed: false),
        .reasserting: ConnectionState(status: .reasserting,
                                      icon: "LockRetry",
                                      action: NSLocalizedString("Cancel", comment: "Label for cancel button, shown when VPN is in the process of reconnecting"),
                                      flag: .noFlag,
                                      greyed: true)
    ]
    
    init() {
        selectedGeo = UserDefaults.standard.string(forKey: Constants.geo_key) ?? "nearest"
    }
    
    func getIcon(status: NEVPNStatus) -> String {
        return ConnectionModel.connectionState[status]?.icon ?? ""
    }

    func getStateText(status: NEVPNStatus) -> String {
        switch status {
        case .connected:
            return String(format:
                            NSLocalizedString("Connected to %@", comment: "VPN state text when connected. Variable holds the name of the location."),
                          getSelectedNameWithoutNearest())
        case .connecting:
            return NSLocalizedString("Securing your connection.", comment: "VPN state text when connecting.")
        case .disconnected, .disconnecting, .invalid:
            return NSLocalizedString("Your connection is not secure", comment: "VPN state text when disconnected, disconnecting, or in an invalid state.")
        case .reasserting:
            return NSLocalizedString("Retrying connection", comment: "VPN state text when reasserting")
        default:
            return NSLocalizedString("Your connection is not secure", comment: "")
        }
    }

    func getStateColor(status: NEVPNStatus) -> Color {
        switch status {
        case .connected:
            return Color.abVPNStateConnected
        case .connecting, .reasserting, .disconnecting:
            return Color.abVPNStateConnecting
        case .disconnected, .invalid:
            return Color.abVPNStateDisconnected
        default:
            return Color.abVPNStateDisconnected
        }
    }
    
    func getNotificationText(status: NEVPNStatus) -> String {
        switch status {
        case .connected:
            return String(format: NSLocalizedString("Connected to\n%@",
                                     comment: "Notification shown when the VPN connects to the given location. Variable holds the name of the location."),
                          getSelectedNameWithoutNearest())
        case .connecting:
            return String(format: NSLocalizedString("Securing your connection...\n%@",
                                     comment: "Notification shown when the VPN is connecting to the given location. Variable holds the name of the location."),
                          getSelectedNameWithoutNearest())
        case .disconnected, .invalid:
            return String(format: NSLocalizedString("Disconnected\n%@",
                                     comment: "Notification shown when the VPN disconnects from the given location. Variable holds the name of the location."),
                          getSelectedNameWithoutNearest())
        case .disconnecting:
            return ""
        case .reasserting:
            return String(format: NSLocalizedString("Retrying connection...\n%@",
                                     comment: "Notification shown when the VPN is reconnecting to the given location. Variable holds the name of the location."),
                          getSelectedNameWithoutNearest())
        default:
            return ""
        }
    }
    
    func getActionText(status: NEVPNStatus) -> String {
        return ConnectionModel.connectionState[status]?.action ?? ""
    }
    
    func getRegionText(status: NEVPNStatus) -> String {
        if status == .connected {
            return NSLocalizedString("Change Location", comment: "Text shown on region selector when the VPN is connected")
        }
        return getSelectedGeoName()
    }
    
    func getFlag(status: NEVPNStatus) -> String {
        let geoToUse = getRegionId()
        switch ConnectionModel.connectionState[status]?.flag {
        case .colorFlag:
            return GeoAssets.flags[geoToUse] ?? "FlagWorld"
        case .greyFlag:
            return "\(GeoAssets.flags[geoToUse] ?? "FlagWorld")Grey"
        default:
            return ""
        }
    }
    
    func getNotificationFlag(status: NEVPNStatus) -> String? {
        let geoToUse = getRegionId()
        switch status {
        case .connected:
            return GeoAssets.flags[geoToUse] ?? "FlagWorld"
        default:
            return "\(GeoAssets.flags[geoToUse] ?? "FlagWorld")Gray"
        }
    }
    
    func getRegionWithoutNearest() -> Geo? {
        var geoToUse = availableGeos.first(where: { $0.id == selectedGeo })
        if selectedGeo == "nearest", let geoNotNearest = availableGeos.last(where: { $0.host == geoToUse?.host && $0.id != "nearest" }) {
            geoToUse = geoNotNearest
        }
        return geoToUse
    }
    
    func getRegionId() -> String {
        return getRegionWithoutNearest()?.id ?? ""
    }
    
    private func getSelectedNameWithoutNearest() -> String {
        return GeoAssets.getGeoName(id: getRegionWithoutNearest()?.id ?? "")
    }
    
    private func getSelectedGeoName() -> String {
        return GeoAssets.getGeoName(id: selectedGeo)
    }
    
    func isGreyed(status: NEVPNStatus) -> Bool {
        return ConnectionModel.connectionState[status]?.greyed ?? false
    }
}
