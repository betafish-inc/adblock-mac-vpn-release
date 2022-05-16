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

import Combine
import SwiftUI

@available(macOS 11.0, *)
struct AccessibilitySortPriorityViewModifier: ViewModifier {
    var text: Double
    
    func body(content: Content) -> some View {
        content.accessibilitySortPriority(text)
    }
}

struct AccessibilitySortPriorityDeprecatedVM: ViewModifier {
    var text: Double
    
    func body(content: Content) -> some View {
        content.accessibility(sortPriority: text)
    }
}

extension View {
    /// Allows you to use the appropriate version of accessibility sort priorityl based on what version of macOS is available
    /// Example usage: `.customSortPriority(1)`
    @ViewBuilder
    func customSortPriority(_ priority: Double) -> some View {
        if #available(macOS 11.0, *) {
            self.modifier(AccessibilitySortPriorityViewModifier(text: priority))
        } else {
            self.modifier(AccessibilitySortPriorityDeprecatedVM(text: priority))
        }
    }
}

@available(macOS 11.0, *)
struct AccessibilityLabelViewModifier: ViewModifier {
    var text: Text
    
    func body(content: Content) -> some View {
        content.accessibilityLabel(text)
    }
}

struct AccessibilityLabelDeprecatedViewModifier: ViewModifier {
    var text: Text
    
    func body(content: Content) -> some View {
        content.accessibility(label: text)
    }
}

extension View {
    /// Allows you to use the appropriate version of accessibility label based on what version of macOS is available
    /// Example usage: `.customAccessibilityLabel("Link to website")`
    @ViewBuilder
    func customAccessibilityLabel(_ text: Text) -> some View {
        if #available(macOS 11.0, *) {
            self.modifier(AccessibilityLabelViewModifier(text: text))
        } else {
            self.modifier(AccessibilityLabelDeprecatedViewModifier(text: text))
        }
    }
}

@available(macOS 11.0, *)
struct AccessibilityAddTraitsViewModifier: ViewModifier {
    var text: AccessibilityTraits
    
    func body(content: Content) -> some View {
        content.accessibilityAddTraits(text)
    }
}

struct AccessibilityAddTraitsDepViewModifier: ViewModifier {
    var text: AccessibilityTraits
    
    func body(content: Content) -> some View {
        content.accessibility(addTraits: text)
    }
}

extension View {
    /// Allows you to use the appropriate version of adding accessibility traits based on what version of macOS is available
    /// Example usage: `.customAccessibilityAddTraits(.isLink)`
    @ViewBuilder
    func customAccessibilityAddTraits(_ text: AccessibilityTraits) -> some View {
        if #available(macOS 11.0, *) {
            self.modifier(AccessibilityAddTraitsViewModifier(text: text))
        } else {
            self.modifier(AccessibilityAddTraitsDepViewModifier(text: text))
        }
    }
}

extension View {
    @ViewBuilder
    /// A drop in replacment for `.animation` which conditionally animates depending on the systemwide `Reduce Animation` accessibility option.
    func accessibilityFriendlyAnimation(_ animation: Animation? = .default) -> some View {
        if NSWorkspace.shared.accessibilityDisplayShouldReduceMotion {
            self
        } else {
            self.animation(animation)
        }
    }
}

/// A drop in replacment for `withAnimation` which conditionally animates depending on the systemwide `Reduce Animation` accessibility option.
func withAccessibilityFriendlyAnimation<Result>(_ animation: Animation? = .default, _ body: () throws -> Result) rethrows -> Result {
    if NSWorkspace.shared.accessibilityDisplayShouldReduceMotion {
        return try body()
    } else {
        return try withAnimation(animation, body)
    }
}

extension View {
    /// Allows you to conditionally apply a `ViewModifier` to a `View`.
    /// If `condition` equates to true, the view modifier will transformed as per the closure input.
    /// If `condition` equares to false, the view will return unmodified.
    /// Example usage: `.if(foo) { $0.padding() }`
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

extension View {
    /// A wrapper for the `.onChange` ViewModifier to provide backwards compatibility to macOS 10.x
    @ViewBuilder func onChangeWrapper<T: Equatable>(value: T, onChange: @escaping (T) -> Void) -> some View {
        if #available(macOS 11.0, *) {
            self.onChange(of: value, perform: onChange)
        } else {
            self.onReceive(Just(value)) { (value) in
                onChange(value)
            }
        }
    }
}

extension View {
    /// A wrapper for the `.preferredColorScheme` ViewModifier to provide backwards compatibility to macOS 10.x
    @ViewBuilder func preferredColorSchemeWrapper(_ colorScheme: ColorScheme) -> some View {
        if #available(macOS 11.0, *) {
            self.preferredColorScheme(colorScheme)
        } else {
            self.colorScheme(colorScheme)
        }
    }
}
