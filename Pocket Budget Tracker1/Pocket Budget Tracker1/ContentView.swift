
//  ContentView.swift

//  Handles transition from onboarding to main app and manages tab selection state.

import SwiftUI
import CoreData
import Combine

// Custom notification for signaling when a transaction has been successfully saved
private extension Notification.Name {
    static let transactionSaved = Notification.Name("TransactionSaved")
}

// Displays onboarding flow on first launch, then shows tab-based navigation.
struct ContentView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var context
    
    // MARK: - State
    @State private var showOnboarding = true

    // Defines available tabs in the main application
    enum Tab { case dashboard, transactions, add, analytics }
    @State private var selectedTab: Tab = .dashboard

    // MARK: - Body
    var body: some View {
        if showOnboarding {
            // Show onboarding flow on first launch
            OnboardingView(showOnboarding: $showOnboarding)
        } else {
            // Main app with tab-based navigation
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem { Label("Dashboard", systemImage: "gauge") }
                    .tag(Tab.dashboard)

                TransactionsListView()
                    .tabItem { Label("Transactions", systemImage: "list.bullet") }
                    .tag(Tab.transactions)

                AddEditTransactionView(onSaved: { withAnimation { selectedTab = .transactions } })
                    .tabItem { Label("Add", systemImage: "plus.circle") }
                    .tag(Tab.add)

                AnalyticsView()
                    .tabItem { Label("Analytics", systemImage: "chart.xyaxis.line") }
                    .tag(Tab.analytics)
            }
            // Listen for transaction save notifications and switch to transactions tab
            .onReceive(NotificationCenter.default.publisher(for: .transactionSaved)) { _ in
                withAnimation(.easeInOut) { selectedTab = .transactions }
            }
        }
    }
}

#Preview {
    ContentView()
}
