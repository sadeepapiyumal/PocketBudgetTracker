//
//  DashboardView.swift
//  Pocket Budget Tracker1
//
//  Created by IM Student on 2025-11-11.
//

import SwiftUI
import CoreData

struct DashboardView: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)])
    private var transactions: FetchedResults<Transaction>

    private var totals: (income: Double, expense: Double) {
        let income = transactions.filter { $0.type == "Income" }.reduce(0) { $0 + $1.amount }
        let expense = transactions.filter { $0.type == "Expense" }.reduce(0) { $0 + $1.amount }
        return (income, expense)
    }

    private var balance: Double { totals.income - totals.expense }

    var body: some View {
        let predictor = ExpensePredictor()
        let predicted = predictor.predict(totalIncome: totals.income, totalExpense: totals.expense)
        let usage = totals.income > 0 ? min(max(totals.expense / totals.income, 0), 1) : 0

        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Summary Cards
                    HStack(spacing: 12) {
                        SummaryCard(title: "Income", value: totals.income, color: .green)
                        SummaryCard(title: "Expense", value: totals.expense, color: .red)
                    }
                    SummaryCard(title: "Balance", value: balance, color: .blue)

                    // Budget usage
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

                    // Predicted next month expense - HIGHLIGHTED
                    VStack(alignment: .center, spacing: 12) {
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

struct SummaryCard: View {
    let title: String
    let value: Double
    let color: Color
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
