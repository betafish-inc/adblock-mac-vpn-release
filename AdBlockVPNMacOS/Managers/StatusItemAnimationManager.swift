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

final class StatusItemAnimationManager {
    // Frame 0 to 3 represent animation frames to be shown when connecting.
    // Frame 4 represents the default static state.
    private var currentFrame = 0
    private var animTimer: Timer
    private var statusBarItem: NSStatusItem?
    private var imageNamePattern: String
    private var imageCount: Int
    
    init(statusBarItem: NSStatusItem?, imageNamePattern: String = "StatusBarIcon_", imageCount: Int = 4) {
        self.animTimer = Timer.init()
        self.statusBarItem = statusBarItem
        self.imageNamePattern = imageNamePattern
        self.imageCount = imageCount
    }
    
    func startAnimating() {
        stopAnimating()
        currentFrame = 0
        animTimer = Timer.scheduledTimer(timeInterval: 5.0 / 30.0, target: self,
                                         selector: #selector(self.updateImage(_:)),
                                         userInfo: nil,
                                         repeats: true)
    }
    
    func stopAnimating() {
        animTimer.invalidate()
        setImage(frameCount: 4)
    }
    
    @objc
    private func updateImage(_ timer: Timer?) {
        setImage(frameCount: currentFrame)
        currentFrame += 1
        if currentFrame % imageCount == 0 {
            currentFrame = 0
        }
    }
    
    private func setImage(frameCount: Int) {
        let image = NSImage(named: NSImage.Name("\(imageNamePattern)\(frameCount)"))
        DispatchQueue.main.async {
            self.statusBarItem?.button?.image = image
        }
    }
}
