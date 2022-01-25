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

import AppKit
import SwiftUI
import SwiftyBeaver
import Zip

class ContactSupportViewModel: ObservableObject {
    @Published var zipWriteComplete = false
    @Published var showError = false

    private var desktopPath: URL?
    private var logFilePaths: [URL]?
    private let readmeText = NSLocalizedString("""
# AdBlockVPNApp.log
This file contains debug and error log entries which are useful for debugging issues with the Adblock VPN Application.

# AdBlockVPNProvider.log
This file contains debug and error log entries which are useful for debugging issues with the Adblock VPN System Extension.

These files can be viewed in a text editor and edited if there is any information you would like to redact from these logs.

For more information about the data we collect and how we use it, visit: \(Constants.logsPrivacyInfoKBArticleURL)
""", comment: "Contents of readme file describing app log files.")

    /// Zip archiving error states
    enum ZipArchiveError: Error {
        case desktopPathInvalid
        case logFilesMissing
        case zipCreationFailed(error: Error)
    }

    func createLogFileArchive() {
        do {
            try saveZipToDesktop()
        } catch ZipArchiveError.zipCreationFailed(let error) {
            SwiftyBeaver.error("Error creating zip archive: \(error.localizedDescription)")
            showError = true
        } catch let error {
            SwiftyBeaver.error("Error occurred while log file zip archive \(error)")
            showError = true
        }
    }

    /// Populates paths to users desktop and logfiles. If error occurs it throws the relevant `ZipArchiveError`.
    /// Intended to be called `.onAppear` of `ContactSupportStepOneView` to skip to `ContactSupportStepTwoView` if error is thrown.
    func populatePaths() throws {
        // Set Path to user desktop folder
        guard let path = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first else { throw ZipArchiveError.desktopPathInvalid }
        desktopPath = path
        // Set Array of URL paths to log files and log file readme
        guard let paths: [URL] = getLogFilePaths() else { throw ZipArchiveError.logFilesMissing }
        logFilePaths = paths
    }

    func openProvideLogsKBArticleURL() {
        if let url = URL(string: Constants.provideLogsKBArticleURL) { NSWorkspace.shared.open(url) }
    }

    func openLogsKBArticleURL() {
        if let url = URL(string: Constants.logsPrivacyInfoKBArticleURL) { NSWorkspace.shared.open(url) }
    }

    /// Validates paths to log files and log file readme, zips this data into an archive and exports to desktop.
    private func saveZipToDesktop() throws {
        // Unwrap Paths
        guard let desktopPath = desktopPath else {
            throw ZipArchiveError.desktopPathInvalid
        }

        guard let logFilePaths = logFilePaths else {
            throw ZipArchiveError.logFilesMissing
        }

        // Zips files in `logFilePaths` and saves archive to `desktopPath`
        do {
            let zipFilePath = desktopPath.appendingPathComponent(Constants.LogFilesArchiveFilename)
            try Zip.zipFiles(paths: logFilePaths,
                             zipFilePath: zipFilePath,
                             password: nil,
                             progress: nil)
        } catch let error {
            throw ZipArchiveError.zipCreationFailed(error: error)
        }
        SwiftyBeaver.verbose("\(Constants.LogFilesArchiveFilename) saved to \(desktopPath)")
        self.zipWriteComplete = true
    }

    /// Populates an array with URLs that link to validated file paths for both cached log files in the user domain, and the log file readme file from main bundle.
    /// - Returns: An array of URLs or nil if no URL paths can be validated.
    private func getLogFilePaths() -> [URL]? {
        var paths = [URL]()
        let fileManager = FileManager.default

        guard let userCacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            SwiftyBeaver.error("Unable to get path to user domain cache directory")
            return nil
        }

        let appLogPath = userCacheDirectory.appendingPathComponent(Constants.appLogFilePath)
        if fileManager.fileExists(atPath: appLogPath.relativePath) {
            paths.append(appLogPath)
        } else {
            SwiftyBeaver.error("Unable to get path to AdBlockVPNApp.log")
        }

        if let providerLogPath = fileManager.urls(for: .cachesDirectory, in: .localDomainMask).first?.appendingPathComponent(Constants.providerLogFilePath),
           fileManager.fileExists(atPath: providerLogPath.relativePath) {
            paths.append(providerLogPath)
        } else {
            SwiftyBeaver.error("Unable to get path to AdBlockVPNProvider.log")
        }

        // Returning nil as no log files are found.
        if paths.isEmpty { return nil }

        // write readme file to the readme path
        let readmePath = userCacheDirectory.appendingPathComponent(Constants.appLogFileReadmePath)
        if fileManager.createFile(atPath: readmePath.relativePath, contents: readmeText.data(using: .utf8), attributes: nil) {
            paths.append(readmePath)
        } else {
            SwiftyBeaver.error("Unable to get write to README.txt")
        }
        return paths
    }
}
