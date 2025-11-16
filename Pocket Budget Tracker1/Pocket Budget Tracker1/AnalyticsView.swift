
//  AnalyticsView.swift

//  Displays comprehensive financial analytics including monthly trends, comparisons,

import SwiftUI
import Charts
import CoreData

// Shows monthly income vs expense trends, period comparisons, and predicted next month expenses.
struct AnalyticsView: View {
    // Fetches all transactions sorted by date in ascending order
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: true)])
    private var transactions: FetchedResults<Transaction>

    
    // Returns sorted tuples of (month date, total expense amount).
    private var monthlyTrend: [(Date, Double)] {
        let cal = Calendar.current
        let expenses = transactions.filter { $0.type == "Expense" }
        let groups = Dictionary(grouping: expenses) { t -> Date in
            cal.date(from: cal.dateComponents([.year, .month], from: t.date)) ?? cal.startOfDay(for: t.date)
        }
        return groups.map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }.sorted { $0.0 < $1.0 }
    }

    // Returns sorted tuples of (month date, total income amount).
    private var monthlyIncomeTrend: [(Date, Double)] {
        let cal = Calendar.current
        let incomes = transactions.filter { $0.type == "Income" }
        let groups = Dictionary(grouping: incomes) { t -> Date in
            cal.date(from: cal.dateComponents([.year, .month], from: t.date)) ?? cal.startOfDay(for: t.date)
        }
        return groups.map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }.sorted { $0.0 < $1.0 }
    }

    // Returns sorted tuples of (day date, daily expense total).
    private var currentMonthExpenseTrend: [(Date, Double)] {
        let cal = Calendar.current
        let now = Date()
        let expenses = transactions.filter { t in
            t.type == "Expense" && cal.component(.year, from: t.date) == cal.component(.year, from: now) && cal.component(.month, from: t.date) == cal.component(.month, from: now)
        }
        let groups = Dictionary(grouping: expenses) { t -> Date in
            cal.startOfDay(for: t.date)
        }
        return groups.map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }.sorted { $0.0 < $1.0 }
    }

    // Returns sorted tuples of (day date, daily income total).
    private var currentMonthIncomeTrend: [(Date, Double)] {
        let cal = Calendar.current
        let now = Date()
        let incomes = transactions.filter { t in
            t.type == "Income" && cal.component(.year, from: t.date) == cal.component(.year, from: now) && cal.component(.month, from: t.date) == cal.component(.month, from: now)
        }
        let groups = Dictionary(grouping: incomes) { t -> Date in
            cal.startOfDay(for: t.date)
        }
        return groups.map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }.sorted { $0.0 < $1.0 }
    }

    // Combines current month income and expense trends into a single dataset.
    private var currentMonthCombinedTrend: [(Date, Double, String)] {
        let incomeSeries = currentMonthIncomeTrend.map { ($0.0, $0.1, "Income") }
        let expenseSeries = currentMonthExpenseTrend.map { ($0.0, $0.1, "Expense") }
        return (incomeSeries + expenseSeries).sorted { lhs, rhs in lhs.0 < rhs.0 || (lhs.0 == rhs.0 && lhs.2 < rhs.2) }
    }


    // MARK: - Body
    var body: some View {
        let incomeTotal = transactions.filter { $0.type == "Income" }.reduce(0) { $0 + $1.amount }
        let expenseTotal = transactions.filter { $0.type == "Expense" }.reduce(0) { $0 + $1.amount }
        let predicted = ExpensePredictor().predict(totalIncome: incomeTotal, totalExpense: expenseTotal)
        let cal = Calendar.current
        let now = Date()
        let thisMonthExpense = transactions.filter { t in
            t.type == "Expense" && cal.component(.year, from: t.date) == cal.component(.year, from: now) && cal.component(.month, from: t.date) == cal.component(.month, from: now)
        }.reduce(0) { $0 + $1.amount }
        let currentMonthStart = cal.date(from: cal.dateComponents([.year, .month], from: now)) ?? cal.startOfDay(for: now)
        let nextMonthStart = cal.date(byAdding: DateComponents(month: 1), to: currentMonthStart) ?? currentMonthStart
        let monthEnd = cal.date(byAdding: DateComponents(day: -1), to: nextMonthStart) ?? currentMonthStart
        let prevMonthStart = cal.date(byAdding: DateComponents(month: -1), to: currentMonthStart) ?? currentMonthStart
        let prevMonthEnd = cal.date(byAdding: DateComponents(day: -1), to: currentMonthStart) ?? prevMonthStart
        let nextMonthEnd = cal.date(byAdding: DateComponents(day: -1), to: cal.date(byAdding: DateComponents(month: 2), to: currentMonthStart) ?? nextMonthStart) ?? monthEnd
        let prevMonthExpense = transactions.filter { t in
            t.type == "Expense" && cal.component(.year, from: t.date) == cal.component(.year, from: prevMonthStart) && cal.component(.month, from: t.date) == cal.component(.month, from: prevMonthStart)
        }.reduce(0) { $0 + $1.amount }
        let prevMonthMid = cal.date(byAdding: DateComponents(day: 14), to: prevMonthStart) ?? prevMonthStart
        let currentMonthMid = cal.date(byAdding: DateComponents(day: 14), to: currentMonthStart) ?? currentMonthStart
        let nextMonthMid = cal.date(byAdding: DateComponents(day: 14), to: nextMonthStart) ?? nextMonthStart
        let comparisonSeries: [(Date, Double)] = [
            (currentMonthStart, thisMonthExpense),
            (nextMonthStart, predicted)
        ]
        // Series up to today
        let todayStart = cal.startOfDay(for: now)
        let expenseUptoToday = currentMonthExpenseTrend.filter { cal.startOfDay(for: $0.0) <= todayStart }
        let incomeUptoToday = currentMonthIncomeTrend.filter { cal.startOfDay(for: $0.0) <= todayStart }
        let combinedToday: [(Date, Double, String)] =
            incomeUptoToday.map { ($0.0, $0.1, "Income") } +
            expenseUptoToday.map { ($0.0, $0.1, "Expense") }
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {

                // Chart 1: Daily income and expense trends for current month
                VStack(alignment: .leading) {
                    Text("Monthly Income vs Expense (This Month)").font(.headline)
                    Chart {
                        ForEach(Array(combinedToday.enumerated()), id: \.offset) { _, point in
                            let (date, value, type) = point
                            LineMark(x: .value("Day", date), y: .value("Amount", value))
                                .foregroundStyle(by: .value("Type", type))
                                .symbol(by: .value("Type", type))
                                .interpolationMethod(.monotone)
                            PointMark(x: .value("Day", date), y: .value("Amount", value))
                                .foregroundStyle(by: .value("Type", type))
                        }
                        // Vertical line marking today's date
                        RuleMark(x: .value("Today", todayStart))
                            .foregroundStyle(.gray.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                    }
                    .chartForegroundStyleScale(["Income": .green, "Expense": .red])
                    .chartLegend(position: .bottom)
                    .chartXScale(domain: currentMonthStart...monthEnd)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: 3)) { value in
                            AxisGridLine()
                            AxisValueLabel(format: .dateTime.day())
                        }
                    }
                    .chartYScale(domain: 0...{
                        let maxIncome = incomeUptoToday.map { $0.1 }.max() ?? 0
                        let maxExpense = expenseUptoToday.map { $0.1 }.max() ?? 0
                        let maxY = max(maxIncome, maxExpense)
                        return maxY > 0 ? maxY * 1.1 : 1
                    }())
                    .frame(height: 260)
                }
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                // Chart 2: Bar chart comparing previous, current, and predicted next month expenses
                VStack(alignment: .leading) {
                    Text("Expense: Previous vs Current vs Next (Predicted)").font(.headline)
                    Chart {
                        ForEach([
                            (prevMonthMid, prevMonthExpense, "Previous"),
                            (currentMonthMid, thisMonthExpense, "Current"),
                            (nextMonthMid, predicted, "Next (Predicted)")
                        ], id: \.2) { date, value, label in
                            BarMark(
                                x: .value("Month", date),
                                y: .value("Expense", value)
                            )
                            .foregroundStyle(by: .value("Period", label))
                        }
                    }
                    .chartForegroundStyleScale([
                        "Previous": .gray,
                        "Current": .yellow,
                        "Next (Predicted)": .orange
                    ])
                    .chartLegend(position: .bottom)
                    .chartXScale(domain: prevMonthStart...nextMonthEnd)
                    .frame(height: 220)
                }
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                // Highlighted AI prediction card for next month expense
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
                .padding(.horizontal)
            }
            .padding(.vertical)
            }
            .navigationTitle("Analytics")
        }
    }
}

// MARK: - Preview
#Preview {
    AnalyticsView()
}
