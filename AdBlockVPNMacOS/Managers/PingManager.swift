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
import Alamofire

class PingManager {
    private var logManager: LogManager
    private let ONE_DAY: Double = 86400
    var lastPing: Date = Date(timeIntervalSince1970: 0) {
        didSet {
            UserDefaults.standard.set(lastPing.timeIntervalSince1970, forKey: Constants.pingDate_key)
        }
    }
    
    init(manager: LogManager) {
        let savedPing = UserDefaults.standard.double(forKey: Constants.pingDate_key)
        if savedPing != 0 {
            lastPing = Date(timeIntervalSince1970: TimeInterval(savedPing))
        }
        
        logManager = manager
    }
    
    func start() {
        schedulePing()
    }
    
    private func pingIfNecessary() {
        let pingDate = nextScheduleDate()
        let currentDate = Date()
        if currentDate >= pingDate {
            sendPing()
        }
    }
    
    private func schedulePing() {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: pingDelayTime()) {[weak self] in
            guard let strongSelf = self else { return }
            strongSelf.pingIfNecessary()
            var delay = DispatchTime.now()
            // swiftlint:disable:next shorthand_operator
            delay = delay + DispatchTimeInterval.seconds(5 * 60) // reschedule ourselves in 5 minutes
            DispatchQueue.global(qos: .background).asyncAfter(deadline: delay) {
                self?.schedulePing()
            }
        }
    }
    
    private func sendPing() {
        logManager.sendLogMessage(message: .ping) {[weak self] success in
            guard let strongSelf = self else { return }
            if success {
                strongSelf.lastPing = Date()
            }
        }
    }
    
    private func nextScheduleDate() -> Date {
        return lastPing + TimeInterval(ONE_DAY)
    }
    
    private func pingDelayTime() -> DispatchTime {
        let scheduledDate = nextScheduleDate()
        let delayHours = DispatchTime.now() + scheduledDate.timeIntervalSinceNow
        return delayHours
    }
}
