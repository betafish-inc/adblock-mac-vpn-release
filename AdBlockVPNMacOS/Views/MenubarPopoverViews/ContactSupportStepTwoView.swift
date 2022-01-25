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

struct ContactSupportStepTwoView: View {
    @EnvironmentObject var state: AppState
    /// URL to exported log file archive path on desktop or nil.
    private let archiveFileURL: URL?

    init() {
        guard let desktopPath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first else {
            archiveFileURL = nil
            return
        }

        let archiveFilePath = desktopPath.appendingPathComponent(Constants.LogFilesArchiveFilename)
        // assign value to `archiveFileURL` if log file exists on user desktop.
        archiveFileURL = FileManager.default.fileExists(atPath: archiveFilePath.path) ? archiveFilePath : nil
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Step 2", comment: "Subtitle for step 2 of contact support process")
                .latoFont(weight: .bold)
                .padding(.top, 8)
            Divider().background(Color.abBorder).frame(width: 256)
                .padding(.vertical, 8)
            Text("Submit your ticket using the link below. Our support team will respond promptly, typically within 24 hours.",
                 comment: "Label with guidance on the support ticket submission process")
                .latoFont()
            Spacer().frame(height: 24)
            // Show additional dialog if log file exists on desktop.
            if archiveFileURL != nil {
            Text("To speed up the troubleshooting process, please attach AdBlockVPNLogs.zip from your desktop to your ticket.",
                 // swiftlint:disable:next line_length
                 comment: "Label with guidance for adding logs to support tickets. AdBlockVPNLogs.zip is a file name not to be localized. desktop refers to the users desktop folder.")
                .latoFont()
            }
            Spacer()
            Button(action: { openNewTicketURL() },
                   label: { Text("Submit a New Ticket", comment: "Button title for submitting a support ticket") })
            .buttonStyle(PrimaryButtonStyle())
            .customAccessibilityAddTraits(.isLink)
            .padding(.bottom, 24)
        }
        .frame(width: 272, height: state.showConnectionInfo ? 460 : 352)
        .background(Color.abBackground)
        .foregroundColor(.abDarkText)
    }

    /// Opens URL to submit a new ticket, a finder window with log file archive selected (if it exists), and resets view state back to `.previousView`.
    private func openNewTicketURL() {
        if let url = URL(string: Constants.newTicketURL) {
            NSWorkspace.shared.open(url)
        }

        if let archiveFileURL = archiveFileURL,
           FileManager.default.fileExists(atPath: archiveFileURL.path) {
            NSWorkspace.shared.activateFileViewerSelecting([archiveFileURL])
        }

        state.viewToShow = state.previousView
    }
}

struct ContactSupportStepTwoView_Previews: PreviewProvider {
    static var previews: some View {
        ContactSupportStepTwoView().environmentObject(AppState())
    }
}
