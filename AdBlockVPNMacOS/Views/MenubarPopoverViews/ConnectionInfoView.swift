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

struct ConnectionInfoView: View {
    @ObservedObject var viewModel: ConnectionInfoViewModel
    @State var isRefreshButtonDisabled: Bool = false
    @State var errorTextOpacity: Double = 1
    @State var refreshIconRotationAngle: CGFloat = 0
    
    var body: some View {
        VStack {
            IPAddressCell(IPVersion: NSLocalizedString("IPv4", comment: "Label for IPv4 IP address shown in connection info"),
                          IPAddress: viewModel.ipv4Address,
                          isIPError: viewModel.ipError,
                          updateIPAddress: viewModel.updateIPAddresses,
                          isDisabled: $isRefreshButtonDisabled,
                          errorTextOpacity: $errorTextOpacity,
                          refreshIconRotationAngle: $refreshIconRotationAngle)
            Divider().customDividerStyle()
            IPAddressCell(IPVersion: NSLocalizedString("IPv6", comment: "Label for IPv4 IP address shown in connection info"),
                          IPAddress: viewModel.ipv6Address,
                          isIPError: viewModel.ipError,
                          updateIPAddress: viewModel.updateIPAddresses,
                          isDisabled: $isRefreshButtonDisabled,
                          errorTextOpacity: $errorTextOpacity,
                          refreshIconRotationAngle: $refreshIconRotationAngle)
            Divider().customDividerStyle()
            HStack {
                Image("TimeIcon").renderingMode(.template)
                Spacer()
                Text(viewModel.connectedTime).latoFont()
            }.foregroundColor(viewModel.vpnConnected ? .abDarkText : .abInactiveAccent)
                .accessibilityElement(children: .combine)
                .customAccessibilityLabel(getConnectedTimeLabel())
        }
        .foregroundColor(.abDarkText)
        .frame(width: 240)
    }
    
    private func getConnectedTimeLabel() -> Text {
        var time = viewModel.connectedTime
        if viewModel.connectedTime == "--" {
            time = NSLocalizedString("inactive", comment: "Label for empty time connected section of connection info when the VPN isn't connected")
        }
        
        return Text("Time connected: \(time)", comment: "Label for time connected secion of connection info")
    }
}

struct ConnectionInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionInfoView(viewModel: ConnectionInfoViewModel(vpnManager: VPNManager()))
    }
}
