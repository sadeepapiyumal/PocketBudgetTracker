//
//  ContentView.swift
//  Pocket Budget Tracker1
//
//  Created by IM Student on 2025-11-09.
//

import SwiftUI
import CoreData
import Combine

private extension Notification.Name {
    static let transactionSaved = Notification.Name("TransactionSaved")
}

// MARK: - Root
struct ContentView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var showOnboarding = true

    enum Tab { case dashboard, transactions, add, analytics }
    @State private var selectedTab: Tab = .dashboard

    var body: some View {
        if showOnboarding {
            OnboardingView(showOnboarding: $showOnboarding)
        } else {
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
            .onReceive(NotificationCenter.default.publisher(for: .transactionSaved)) { _ in
                withAnimation(.easeInOut) { selectedTab = .transactions }
            }
        }
    }
}

#Preview {
    ContentView()
}
