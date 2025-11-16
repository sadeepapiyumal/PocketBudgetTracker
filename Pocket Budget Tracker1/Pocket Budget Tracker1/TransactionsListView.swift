/
//  TransactionsListView.swift

//  Displays a comprehensive list of all transactions with filtering and grouping capabilities.


import SwiftUI
import CoreData
import Combine

// Custom notification for signaling when a transaction has been successfully saved
private extension Notification.Name {
    static let transactionSaved = Notification.Name("TransactionSaved")
}

// Displays all transactions in a filterable, grouped list format.
struct TransactionsListView: View {
    @Environment(\.managedObjectContext) private var context
    
    // Fetches all transactions sorted by date in descending order
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)])
    private var transactions: FetchedResults<Transaction>

    // MARK: - State
    @State private var typeFilter: String = "All"
    @State private var categoryFilter: String = "All"
    @State private var refreshToken: UUID = UUID()

    // Extracts unique categories from all transactions and prepends "All" option.
    private var categories: [String] {
        let unique = Set(transactions.map { $0.category })
        return ["All"] + unique.sorted()
    }

    // Returns transactions matching both filter criteria.
    private var filtered: [Transaction] {
        transactions.filter { t in
            let typeOk = (typeFilter == "All") || (t.type == typeFilter)
            let categoryOk = (categoryFilter == "All") || (t.category == categoryFilter)
            return typeOk && categoryOk
        }
    }

    // Returns array of tuples: (date, transactions for that day).
    private var groupedByDay: [(Date, [Transaction])] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: filtered) { t in
            calendar.startOfDay(for: t.date)
        }
        return groups.keys.sorted(by: >).map { ($0, groups[$0]!.sorted { $0.date > $1.date }) }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                // Filter section: type and category selectors
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

                // Empty state message
                if transactions.isEmpty {
                    Text("No transactions yet. Tap + to add.")
                        .foregroundStyle(.secondary)
                }
                
                // Transaction list grouped by date
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
                                    // Display amount with sign: negative for expenses, positive for income
                                    Text((t.type == "Expense" ? -t.amount : t.amount).formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))
                                        .foregroundStyle(t.type == "Expense" ? .red : .green)
                                }
                            }
                        }
                        // Swipe to delete functionality
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
            // Refresh list when transaction is saved
            .id(refreshToken)
            .onReceive(NotificationCenter.default.publisher(for: .transactionSaved)) { _ in
                refreshToken = UUID()
            }
        }
    }
}
