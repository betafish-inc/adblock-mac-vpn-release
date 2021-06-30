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

struct HTMLStringView: NSViewRepresentable {
    let htmlContent: String
    let fontSize: CGFloat
    let centered: Bool
    let backgroundColor: NSColor
    
    init(htmlContent: String, fontSize: CGFloat, centered: Bool, backgroundColor: NSColor) {
        self.htmlContent = htmlContent
        self.fontSize = fontSize
        self.centered = centered
        self.backgroundColor = backgroundColor
    }
    
    init(htmlContent: String, fontSize: CGFloat, centered: Bool) {
        self.htmlContent = htmlContent
        self.fontSize = fontSize
        self.centered = centered
        self.backgroundColor = .white
    }

    func makeNSView(context: Context) -> HyperlinkTextField {
        let text = HyperlinkTextField()
        formatText(text: text)
        return text
    }
    
    func updateNSView(_ text: HyperlinkTextField, context: Context) {
        formatText(text: text)
    }
    
    func formatText(text: HyperlinkTextField) {
        let font = NSFont.latoFont(size: fontSize)
        let fullString =
            """
<style>body{font-family: '\(font.familyName ?? "Lato")';
font-size: \(fontSize)px;
text-align: \(centered ? "center" : "left" );
color: #333333}</style>\(htmlContent)
"""
        text.isBezeled = false
        text.backgroundColor = backgroundColor
        text.textColor = .abLightText
        text.lineBreakMode = .byWordWrapping
        text.preferredMaxLayoutWidth = 250
        text.isEditable = false
        text.usesSingleLineMode = false
        text.isSelectable = true
        text.allowsEditingTextAttributes = true
        text.alignment = .center
        text.maximumNumberOfLines = 0
        text.translatesAutoresizingMaskIntoConstraints = false
        text.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        text.setContentCompressionResistancePriority(.required, for: .vertical)
        DispatchQueue.main.async {
            let data = Data(fullString.utf8)
            if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                text.attributedStringValue = attributedString
                text.sizeToFit()
            }
        }
    }
    
    class HyperlinkTextField: NSTextField {
        override func resetCursorRects() {
            discardCursorRects()
            addCursorRect(self.bounds, cursor: NSCursor.pointingHand)
        }
    }
}
