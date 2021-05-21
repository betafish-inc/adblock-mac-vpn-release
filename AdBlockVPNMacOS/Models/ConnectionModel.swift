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

import Foundation
import NetworkExtension

struct Geo: Identifiable, Decodable {
    var host: String
    var id: String
    var name: String
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
}

enum FlagTypes {
    case noFlag
    case greyFlag
    case colorFlag
}

struct ConnectionState {
    var status: NEVPNStatus
    var icon: String
    var state: String
    var action: String
    var flag: FlagTypes
    var greyed: Bool
    var notification: String
}

struct ConnectionModel {
    var selectedGeo: String {
        didSet {
            UserDefaults.standard.setValue(selectedGeo, forKey: Constants.geo_key)
        }
    }
    var availableGeos: [Geo] = [Geo(host: "", id: "nearest", name: "Nearest location", port: 0)]
    var connectionAttempted = false
    static let connectionState: [NEVPNStatus: ConnectionState] = [
        .connected: ConnectionState(status: .connected,
                                    icon: "LockConnected",
                                    state: "Connected to",
                                    action: "Disconnect",
                                    flag: .colorFlag,
                                    greyed: false,
                                    notification: "Connected to"),
        .connecting: ConnectionState(status: .connecting,
                                     icon: "LockConnecting",
                                     state: "Securing your connection...",
                                     action: "Cancel",
                                     flag: .greyFlag,
                                     greyed: true,
                                     notification: "Securing your connection..."),
        .disconnected: ConnectionState(status: .disconnected,
                                       icon: "LockNotConnected",
                                       state: "Your connection is not secure",
                                       action: "Connect",
                                       flag: .noFlag,
                                       greyed: false,
                                       notification: "Disconnected"),
        .disconnecting: ConnectionState(status: .disconnecting,
                                        icon: "LockConnecting",
                                        state: "Your connection is not secure",
                                        action: "Reconnect",
                                        flag: .greyFlag,
                                        greyed: true,
                                        notification: ""),
        .invalid: ConnectionState(status: .disconnected,
                                  icon: "LockNotConnected",
                                  state: "Your connection is not secure",
                                  action: "Connect",
                                  flag: .noFlag,
                                  greyed: false,
                                  notification: "Disconnected"),
        .reasserting: ConnectionState(status: .reasserting,
                                      icon: "LockRetry",
                                      state: "Retrying connection...",
                                      action: "Cancel",
                                      flag: .noFlag,
                                      greyed: true,
                                      notification: "Retrying connection...")
    ]
    
    init() {
        selectedGeo = UserDefaults.standard.string(forKey: Constants.geo_key) ?? "nearest"
    }
    
    func getIcon(status: NEVPNStatus) -> String {
        return ConnectionModel.connectionState[status]?.icon ?? ""
    }
    
    func getStateText(status: NEVPNStatus) -> String {
        if status == .connected {
            if selectedGeo == "nearest",
               let connectedGeo = availableGeos.first(where: { $0.id == selectedGeo }),
               let geoNameToUse = availableGeos.first(where: { $0.host == connectedGeo.host && $0.id != "nearest" }) {
                return "\(ConnectionModel.connectionState[status]?.state ?? "") \(geoNameToUse.name)"
            } else if let geoToUse = availableGeos.first(where: { $0.id == selectedGeo }) {
                return "\(ConnectionModel.connectionState[status]?.state ?? "") \(geoToUse.name)"
            }
        }
        return ConnectionModel.connectionState[status]?.state ?? ""
    }
    
    func getNotificationText(status: NEVPNStatus) -> String {
        return "\(ConnectionModel.connectionState[status]?.notification ?? "")\n\(getRegionName())"
    }
    
    func getActionText(status: NEVPNStatus) -> String {
        return ConnectionModel.connectionState[status]?.action ?? ""
    }
    
    func getRegionText(status: NEVPNStatus) -> String {
        if status == .connected {
            return "Change Location"
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
    
    func getRegionName() -> String {
        return getRegionWithoutNearest()?.name ?? ""
    }
    
    func getSelectedGeoName() -> String {
        if let geoToUse = availableGeos.first(where: { $0.id == selectedGeo }) {
            return geoToUse.name
        }
        return "Error"
    }
    
    func isGreyed(status: NEVPNStatus) -> Bool {
        return ConnectionModel.connectionState[status]?.greyed ?? false
    }
}
