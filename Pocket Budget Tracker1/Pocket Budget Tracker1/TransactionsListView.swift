//
//  TransactionsListView.swift
//  Pocket Budget Tracker1
//
//  Created by IM Student on 2025-11-11.
//

import SwiftUI
import CoreData
import Combine

private extension Notification.Name {
    static let transactionSaved = Notification.Name("TransactionSaved")
}

struct TransactionsListView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)])
    private var transactions: FetchedResults<Transaction>

    @State private var typeFilter: String = "All"
    @State private var categoryFilter: String = "All"
    @State private var refreshToken: UUID = UUID()

    private var categories: [String] {
        let unique = Set(transactions.map { $0.category })
        return ["All"] + unique.sorted()
    }

    private var filtered: [Transaction] {
        transactions.filter { t in
            let typeOk = (typeFilter == "All") || (t.type == typeFilter)
            let categoryOk = (categoryFilter == "All") || (t.category == categoryFilter)
            return typeOk && categoryOk
        }
    }

    private var groupedByDay: [(Date, [Transaction])] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: filtered) { t in
            calendar.startOfDay(for: t.date)
        }
        return groups.keys.sorted(by: >).map { ($0, groups[$0]!.sorted { $0.date > $1.date }) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Filters")) {
                    Picker("Type", selection: $typeFilter) {
                        Text("All").tag("All")
                        Text("Income").tag("Income")
                        Text("Expense").tag("Expense")
                    }
                    .pickerStyle(.segmented)

                    Menu {
                        ForEach(categories, id: \.self) { cat in
                            Button(action: { categoryFilter = cat }) { Text(cat) }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            Text("Category: \(categoryFilter)")
                            Spacer()
                        }
                    }
                }

                if transactions.isEmpty {
                    Text("No transactions yet. Tap + to add.")
                        .foregroundStyle(.secondary)
                }
                ForEach(groupedByDay, id: \.0) { day, items in
                    Section(header: Text(day, style: .date)) {
                        ForEach(items, id: \.objectID) { t in
                            NavigationLink(destination: AddEditTransactionView(transaction: t)) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(t.title).font(.headline)
                                        Text(t.category).font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text((t.type == "Expense" ? -t.amount : t.amount).formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))
                                        .foregroundStyle(t.type == "Expense" ? .red : .green)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet { context.delete(items[index]) }
                            try? context.save()
                        }
                    }
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddEditTransactionView()) {
                        Image(systemName: "plus")
                    }
                }
            }
            .id(refreshToken)
            .onReceive(NotificationCenter.default.publisher(for: .transactionSaved)) { _ in
                refreshToken = UUID()
            }
        }
    }
}
