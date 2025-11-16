
//  DashboardView.swift

//  Provides quick overview of income, expenses, balance, and next month expense forecast.

import SwiftUI
import CoreData

// Displays income, expense, balance totals, budget usage percentage, and predicted expenses.
struct DashboardView: View {
    // Fetches all transactions sorted by date in descending order
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)])
    private var transactions: FetchedResults<Transaction>

    // Returns tuple with income and expense amounts.
    private var totals: (income: Double, expense: Double) {
        let income = transactions.filter { $0.type == "Income" }.reduce(0) { $0 + $1.amount }
        let expense = transactions.filter { $0.type == "Expense" }.reduce(0) { $0 + $1.amount }
        return (income, expense)
    }

    // Calculates current balance (income minus expenses).
    private var balance: Double { totals.income - totals.expense }

    // MARK: - Body
    var body: some View {
        let predictor = ExpensePredictor()
        let predicted = predictor.predict(totalIncome: totals.income, totalExpense: totals.expense)
        // Budget usage ratio: expense divided by income, clamped between 0 and 1
        let usage = totals.income > 0 ? min(max(totals.expense / totals.income, 0), 1) : 0

        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Summary cards showing key financial metrics
                    HStack(spacing: 12) {
                        SummaryCard(title: "Income", value: totals.income, color: .green)
                        SummaryCard(title: "Expense", value: totals.expense, color: .red)
                    }
                    SummaryCard(title: "Balance", value: balance, color: .blue)

                    // Budget usage progress indicator
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Budget Usage")
                            .font(.headline)
                        ProgressView(value: usage)
                            .tint(.orange)
                        HStack {
                            Text("")
                            Spacer()
                            Text(String(format: "%.0f%%", usage * 100))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Highlighted AI prediction card for next month expense
                    VStack(alignment: .center, spacing: 12) {"
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .font(.title2)
                                .foregroundStyle(.white)
                            Text("AI Prediction")
                                .font(.subheadline.bold())
                                .foregroundStyle(.white.opacity(0.9))
                            Spacer()
                        }
                        
                        VStack(spacing: 4) {
                            Text("Next Month Expense")
                                .font(.caption.bold())
                                .foregroundStyle(.white.opacity(0.8))
                                .textCase(.uppercase)
                                .tracking(1)
                            Text(predicted.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            colors: [.indigo, .purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .purple.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddEditTransactionView()) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
    }
}

// MARK: - SummaryCard
/// Reusable card component for displaying financial summary metrics.
/// Shows a title and formatted currency value with customizable color.
struct SummaryCard: View {
    // MARK: - Properties
    let title: String
    let value: Double
    let color: Color
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(value.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))
                .font(.title3.bold())
                .foregroundStyle(color)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
