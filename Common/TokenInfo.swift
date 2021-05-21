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
import KeychainAccess
import SwiftyBeaver

struct TokenInfo: Decodable {
    var access_token: String
    var token_type: String
    var expires_in: Int
    var refresh_token: String
    private(set) var creationDate = Date()
    var isActive: Bool {
        return creationDate + TimeInterval(expires_in) > Date() && !access_token.isEmpty
    }
    
    private enum CodingKeys: String, CodingKey {
        case access_token, token_type, expires_in, refresh_token
    }
    
    init() {
        access_token = ""
        token_type = ""
        expires_in = 0
        refresh_token = ""
    }
    
    init(accessToken: String, tokenType: String, expiresIn: Int, refreshToken: String) {
        access_token = accessToken
        token_type = tokenType
        expires_in = expiresIn
        refresh_token = refreshToken
    }
    
    init(accessToken: String, tokenType: String, expiresIn: Int, refreshToken: String, creationDate: Date) {
        self.init(accessToken: accessToken, tokenType: tokenType, expiresIn: expiresIn, refreshToken: refreshToken)
        self.creationDate = creationDate
    }
    
    private mutating func reset() {
        access_token = ""
        token_type = ""
        expires_in = 0
        refresh_token = ""
    }
    
    func save() {
        let appKeychain = Keychain(service: Constants.keychainID)
        let encoder = JSONEncoder()
        do {
            if !refresh_token.isEmpty {
                let tokenData = try encoder.encode(TokenDatePair(token: refresh_token, date: creationDate))
                try appKeychain.set(tokenData, key: Constants.refreshToken_key)
            } else {
                try appKeychain.remove(Constants.refreshToken_key)
            }
        } catch {
            // Handle error
            SwiftyBeaver.warning("error in saving refresh token")
        }
    }
    
    mutating func clear() {
        reset()
        let appKeychain = Keychain(service: Constants.keychainID)
        do {
            try appKeychain.remove(Constants.refreshToken_key)
        } catch let error {
            SwiftyBeaver.warning("error: \(error)")
        }
    }
    
    static func newFromStored() -> TokenInfo {
        let appKeychain = Keychain(service: Constants.keychainID)
        var storedToken = TokenDatePair()
        do {
            if let tokenInfo = try appKeychain.getData(Constants.refreshToken_key) {
                let decoder = JSONDecoder()
                do {
                    storedToken = try decoder.decode(TokenDatePair.self, from: tokenInfo)
                } catch {
                    SwiftyBeaver.warning("error in retrieving saved token")
                }
            }
        } catch {
            // Handle error
            SwiftyBeaver.warning("error in retrieving refresh token")
        }
        let token = TokenInfo(accessToken: "", tokenType: "", expiresIn: 0, refreshToken: storedToken.token, creationDate: storedToken.date)
        return token
    }
}

struct TokenDatePair: Codable {
    var token: String = ""
    var date: Date = Date()
}
