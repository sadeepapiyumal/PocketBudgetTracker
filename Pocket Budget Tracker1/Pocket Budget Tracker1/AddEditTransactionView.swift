//
//  AddEditTransactionView.swift
//  Pocket Budget Tracker1
//
//  Created by IM Student on 2025-11-11.
//

import SwiftUI
import CoreData
import UIKit

private extension Notification.Name {
    static let transactionSaved = Notification.Name("TransactionSaved")
}

struct AddEditTransactionView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    var transaction: Transaction?
    var onSaved: (() -> Void)? = nil

    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var category: String = "General"
    @State private var type: String = "Expense"
    @State private var date: Date = Date()

    private let categories = ["General", "Food", "Transport", "Bills", "Entertainment", "Health", "Salary", "Other"]

    init(transaction: Transaction? = nil, onSaved: (() -> Void)? = nil) {
        self.transaction = transaction
        self.onSaved = onSaved
        if let t = transaction {
            _title = State(initialValue: t.title)
            _amount = State(initialValue: String(format: "%.2f", t.amount))
            _category = State(initialValue: t.category)
            _type = State(initialValue: t.type)
            _date = State(initialValue: t.date)
        }
    }

    var body: some View {
        Form {
            Section(header: Text("Details")) {
                TextField("Title", text: $title)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                Picker("Type", selection: $type) {
                    Text("Income").tag("Income")
                    Text("Expense").tag("Expense")
                }
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { Text($0).tag($0) }
                }
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)
            }

            Section {
                Button(action: save) {
                    HStack {
                        Spacer()
                        Text("Save").bold()
                        Spacer()
                    }
                }
                .disabled(!isValid)
            }
            if transaction != nil {
                Section {
                    Button(role: .destructive) {
                        deleteCurrent()
                    } label: {
                        HStack { Spacer(); Text("Delete"); Spacer() }
                    }
                }
            }
        }
        .navigationTitle(transaction == nil ? "Add Transaction" : "Edit Transaction")
    }

    private var isValid: Bool {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard let amt = Double(amount), amt > 0 else { return false }
        guard !category.isEmpty, (type == "Income" || type == "Expense") else { return false }
        return true
    }

    private func save() {
        let amt = Double(amount) ?? 0
        let t = transaction ?? Transaction(context: context)
        if transaction == nil { t.id = UUID() }
        t.title = title
        t.amount = amt
        t.category = category
        t.type = type
        t.date = date
        do {
            try context.save()
            context.processPendingChanges()
            context.refresh(t, mergeChanges: true)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Clear the form fields
            title = ""
            amount = ""
            category = "General"
            type = "Expense"
            date = Date()
            
            // Notify and trigger callbacks
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .transactionSaved, object: nil)
                onSaved?()
                
                // Always dismiss to go back to the previous screen
                dismiss()
            }
        } catch {
            print("Save error: \(error)")
        }
    }

    private func deleteCurrent() {
        guard let t = transaction else { return }
        withAnimation {
            context.delete(t)
            try? context.save()
            dismiss()
        }
    }
}
