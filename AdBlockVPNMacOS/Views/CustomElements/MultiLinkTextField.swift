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

struct MultiLinkTextField: NSViewRepresentable {
    let content: String
    let fontSize: CGFloat
    let centered: Bool
    let backgroundColor: NSColor
    let textColor: NSColor
    let accentColorLinks: Bool
    let localLinks: [String: () -> Void]?
    let webLinks: [String: String]?
    let width: Int
    
    init(content: String, fontSize: CGFloat, centered: Bool, backgroundColor: NSColor, textColor: NSColor, accentColorLinks: Bool, localLinks: [String: () -> Void]?, webLinks: [String: String]?, width: Int = 310) {
        self.content = content
        self.fontSize = fontSize
        self.centered = centered
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.accentColorLinks = accentColorLinks
        self.localLinks = localLinks
        self.webLinks = webLinks
        self.width = width
    }
    
    func makeNSView(context: Context) -> HyperlinkTextField {
        let text = HyperlinkTextField(content: content,
                                      fontSize: fontSize,
                                      centered: centered,
                                      backgroundColor: backgroundColor,
                                      textColor: textColor,
                                      accentColorLinks: accentColorLinks,
                                      localLinks: localLinks,
                                      webLinks: webLinks,
                                      width: width)
        return text
    }
    
    func updateNSView(_ text: HyperlinkTextField, context: Context) {}
    
    class HyperlinkTextField: NSTextView {
        var localLinks: [String: () -> Void]?
        var webLinks: [String: String]?
        
        init(content: String, fontSize: CGFloat, centered: Bool, backgroundColor: NSColor, textColor: NSColor, accentColorLinks: Bool, localLinks: [String: () -> Void]?, webLinks: [String: String]?, width: Int = 310) {
            // use the frame and text container that are created automatically with the convenience initializer and plug
            // them into the required initializer
            let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: width, height: 17))
            super.init(frame: textView.frame, textContainer: textView.textContainer)
            self.localLinks = localLinks
            self.webLinks = webLinks
            
            self.backgroundColor = backgroundColor
            self.textColor = textColor
            isEditable = false
            isSelectable = true
            alignment = centered ? .center : .left
            let linkForeground = accentColorLinks ? .abLinkColor : textColor
            let linkUnderline = accentColorLinks ? 0 : NSUnderlineStyle.single.rawValue
            
            let font = NSFont.latoFont(size: fontSize)
            let attributedString = NSMutableAttributedString(string: content, attributes: [.font: font, .foregroundColor: textColor])
            let plainString: NSString = attributedString.string as NSString
            if let funcLinks = localLinks {
                for link in funcLinks {
                    attributedString.addAttributes([.link: "localLink\(link.key)"], range: plainString.range(of: link.key))
                }
            }
            if let urlLinks = webLinks {
                for link in urlLinks {
                    attributedString.addAttributes([.link: "webLink\(link.key)"], range: plainString.range(of: link.key))
                }
            }
            textStorage?.setAttributedString(attributedString)
            linkTextAttributes = [.foregroundColor: linkForeground, .cursor: NSCursor.pointingHand, .underlineStyle: linkUnderline]
            
            if let layoutManager = self.layoutManager, let textContainer = self.textContainer {
                layoutManager.ensureLayout(for: textContainer)
                self.setFrameSize(layoutManager.usedRect(for: textContainer).size)
                self.sizeToFit()
            }
            
            addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(clickHandler(click:))))
        }
        
        // overridden so that the size of the view is reported to SwiftUI correctly
        override var intrinsicContentSize: NSSize {
            if let layoutManager = self.layoutManager, let textContainer = self.textContainer {
                layoutManager.ensureLayout(for: textContainer)
                return layoutManager.usedRect(for: textContainer).size
            }
            return frame.size
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc func clickHandler(click: NSClickGestureRecognizer) {
            if let layoutManager = self.layoutManager, let textContainer = self.textContainer, let textStorage = self.textStorage {
                let location = click.location(in: self)
                let index = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
                if index < textStorage.length {
                    var range: NSRange = NSRange()
                    if let type = textStorage.attribute(.link, at: index, effectiveRange: &range) as? String {
                        if type.hasPrefix("localLink") {
                            let linkKey = type.replacingOccurrences(of: "localLink", with: "")
                            if let localFunc = localLinks?[linkKey] {
                                localFunc()
                            }
                        } else if type.hasPrefix("webLink") {
                            let linkKey = type.replacingOccurrences(of: "webLink", with: "")
                            if let urlString = webLinks?[linkKey], let url = URL(string: urlString) {
                                NSWorkspace.shared.open(url)                                
                            }
                        }
                    }
                }
            }
        }
        
        override func resetCursorRects() {
            discardCursorRects()
            addCursorRect(self.bounds, cursor: NSCursor.pointingHand)
        }
    }
}
