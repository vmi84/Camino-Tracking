import SwiftUI

extension View {
    /// Conditionally applies a transformation to a view
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Mimics scrollContentBackground for iOS 16+ compatibility
    @ViewBuilder func compatScrollContentBackground(_ visibility: Visibility) -> some View {
        #if os(iOS)
        if #available(iOS 16.0, *) {
            self.scrollContentBackground(visibility)
        } else {
            self
        }
        #else
        self
        #endif
    }
} 