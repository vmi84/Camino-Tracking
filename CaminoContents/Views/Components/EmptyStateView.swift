import SwiftUI

struct EmptyStateView: View {
    var title: String
    var message: String
    var systemImageName: String
    var actionTitle: String?
    var action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: systemImageName)
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.7))
                .padding(.bottom, 8)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
                .padding(.top, 8)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.primary.opacity(0.03))
    }
}

extension View {
    func emptyState(
        isShowing: Bool,
        title: String,
        message: String,
        systemImageName: String = "exclamationmark.triangle",
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) -> some View {
        ZStack {
            if isShowing {
                EmptyStateView(
                    title: title,
                    message: message,
                    systemImageName: systemImageName,
                    actionTitle: actionTitle,
                    action: action
                )
            } else {
                self
            }
        }
    }
}

#Preview {
    Group {
        EmptyStateView(
            title: "No Items Found",
            message: "Try changing your search criteria or add a new item.",
            systemImageName: "doc.text.magnifyingglass",
            actionTitle: "Add Item") {
                print("Action tapped")
            }
        
        Text("Content View")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .emptyState(
                isShowing: true,
                title: "No Waypoints",
                message: "There are no waypoints available for this route.",
                systemImageName: "mappin.slash",
                actionTitle: "Refresh") {
                    print("Refresh tapped")
                }
    }
} 