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

import SwiftyBeaver
import SwiftUI

struct ContactSupportStepOneView: View {
    @EnvironmentObject var state: AppState
    @ObservedObject var viewModel = ContactSupportViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            Text("Step 1", comment: "Subtitle for step 1 of contact support process")
                .latoFont(weight: .bold)
                .padding(.top, 8)
            Divider().background(Color.abBorder).frame(width: 256)
                .padding(.vertical, 8)
            Text("Before you submit a new ticket, click “Create App Logs” to save an app log file to your desktop.")
                .latoFont()
                .minimumScaleFactor(0.7) // Scales down Text View size for long localized strings.
                .padding(.bottom, 16)
            LinkButtonView(action: { viewModel.openLogsKBArticleURL() },
                           text: Text("Learn more about the data we collect and how we use it.",
                                      comment: "Label for button that links to privacy policy"),
                           fontSize: 16,
                           center: false)
            Spacer()
            if viewModel.zipWriteComplete {
                ColorfulButtonView(text: Text("App Logs Created",
                                              comment: "Label to confirm log file has been exported."),
                                   icon: "CheckIcon",
                                   iconSize: 22,
                                   updateAvailable: false)
                    .disabled(true)
                    .padding(.bottom, 16)
            } else {
                Button(action: { viewModel.createLogFileArchive() },
                       label: { Text("Create App Logs", comment: "Label for button that exports app log file.") })
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.bottom, 16)
            }
            Button(action: { showNextStep() },
                   label: {Text("Next",
                                comment: "Label for button that progresses to the next step of the customer support flow")})
                .buttonStyle(SecondaryButtonStyle())
                .padding(.bottom, 24)
        }
        .frame(width: 272, height: state.showConnectionInfo ? 460 : 352)
        .background(Color.abBackground)
        .foregroundColor(.abDarkText)
        .if(viewModel.showError) { $0.overlay(
            VStack {
                Spacer().layoutPriority(2)
                ErrorBlockView(errorText: NSLocalizedString("We encountered an error, please manually attach your user logs",
                                                            comment: "Body text for error message shown when exporting app log file fails."),
                               linkAction: { viewModel.openProvideLogsKBArticleURL() },
                               dismissError: { viewModel.showError = false },
                               showHelp: true,
                               helpURL: Constants.provideLogsKBArticleURL)
                    .layoutPriority(1)
                    .frame(width: 320)
            })
        }
        .onAppear(perform: { populatePaths() })
    }

    /// Populates file paths for desktop & log files
    /// Skips to Step Two of the support flow if error thrown.
    private func populatePaths() {
        do {
            try viewModel.populatePaths()
        } catch let error {
            SwiftyBeaver.error("Error occured populating app log paths: \(error)")
            // If previous view was Step 2, return back to .help view, else, skip to step 2.
            state.contactSupportStepOneSkipped = true
            showNextStep()
        }
    }

    private func showNextStep() {
        self.state.viewToShow = .contactSupportStepTwo
    }
}

struct ContactSupportStepOneView_Previews: PreviewProvider {
    static var previews: some View {
        ContactSupportStepOneView()
            .environmentObject(AppState())
    }
}
