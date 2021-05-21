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

import SwiftUI

extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        // swiftlint:disable:next unused_setter_value
        set { }
    }
}

class FocusTextField: NSTextField {
    var onFocusChange: () -> Void = {}
    
    init(onFocusChange: @escaping () -> Void, placeholder: String, alignment: NSTextAlignment) {
        super.init(frame: .zero)
        self.onFocusChange = onFocusChange
        self.textColor = .abDarkText
        self.backgroundColor = .white
        self.isBezeled = false
        let paragraph = NSMutableParagraphStyle()
        if alignment == .center {
            paragraph.alignment = .center
        }
        self.placeholderAttributedString = NSAttributedString(string: placeholder,
                                                              attributes: [.paragraphStyle: paragraph,
                                                                           .font: NSFont.latoFont(),
                                                                           .foregroundColor: NSColor.abLightestText])
        self.font = NSFont.latoFont()
        self.alignment = alignment
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func becomeFirstResponder() -> Bool {
        onFocusChange()
        
        let textView = window?.fieldEditor(true, for: nil) as? NSTextView
        textView?.insertionPointColor = .abDarkText
        
        return super.becomeFirstResponder()
    }
}

struct FocusTextFieldElement: NSViewRepresentable {
    typealias NSViewType = FocusTextField
    
    @Binding var text: String
    @Binding var isFocused: Bool
    var placeholderText: String
    var alignCenter: Bool
    var onCommit: () -> Void

    func makeCoordinator() -> FocusTextFieldElement.Coordinator {
        return Coordinator(text: $text, isFocused: $isFocused, onCommit: onCommit)
    }

    func makeNSView(context: NSViewRepresentableContext<FocusTextFieldElement>) -> FocusTextField {
        let field = FocusTextField(onFocusChange: onFocusChange, placeholder: placeholderText, alignment: alignCenter ? .center : .left)
        field.delegate = context.coordinator
        return field
    }
    
    func updateNSView(_ nsView: FocusTextField, context: Context) {
        nsView.font = NSFont.latoFont()
        nsView.stringValue = text
        let paragraph = NSMutableParagraphStyle()
        if alignCenter {
            paragraph.alignment = .center
        }
        nsView.placeholderAttributedString = NSAttributedString(string: placeholderText,
                                                                attributes: [.paragraphStyle: paragraph,
                                                                             .font: NSFont.latoFont(),
                                                                             .foregroundColor: NSColor.abLightestText])
        nsView.alignment = alignCenter ? .center : .left
    }
    
    func onFocusChange() {
        isFocused = true
    }
    
    class Coordinator: NSObject, NSTextFieldDelegate {
        @Binding var text: String
        @Binding var isFocused: Bool
        var onCommit: () -> Void

        init(text: Binding<String>, isFocused: Binding<Bool>, onCommit: @escaping () -> Void) {
            self._text = text
            self._isFocused = isFocused
            self.onCommit = onCommit
        }

        func controlTextDidChange(_ notification: Notification) {
            guard let textField = notification.object as? NSTextField else { return }
            text = textField.stringValue
            textField.font = NSFont.latoFont()
        }

        func controlTextDidBeginEditing(_ obj: Notification) {
            self.isFocused = true
        }

        func controlTextDidEndEditing(_ obj: Notification) {
            self.isFocused = false
        }

        func textFieldShouldReturn(_ textField: NSTextField) -> Bool {
            textField.resignFirstResponder()
            return false
        }
        
        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                onCommit()
                return true
            }
            return false
        }
    }
}
