//
//  AddEditTransactionView.swift
//  Pocket Budget Tracker1
//
//  Created by IM Student on 2025-11-11.
//
//  MARK: - Purpose
//  Provides a form-based interface for creating new transactions or editing existing ones.
//  Handles validation, Core Data persistence, and user feedback through haptic notifications.

import SwiftUI
import CoreData
import UIKit

// MARK: - Notification Extension
/// Custom notification for signaling when a transaction has been successfully saved
private extension Notification.Name {
    static let transactionSaved = Notification.Name("TransactionSaved")
}

// MARK: - AddEditTransactionView
/// Form view for creating or editing financial transactions.
/// Supports editing existing transactions and creating new ones with validation.
struct AddEditTransactionView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties
    /// The transaction being edited, or nil if creating a new one
    var transaction: Transaction?
    /// Optional callback invoked after successful save
    var onSaved: (() -> Void)? = nil

    // MARK: - State
    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var category: String = "General"
    @State private var type: String = "Expense"
    @State private var date: Date = Date()

    // MARK: - Constants
    /// Available transaction categories for user selection
    private let categories = ["General", "Food", "Transport", "Bills", "Entertainment", "Health", "Salary", "Other"]

    // MARK: - Initialization
    /// Initializes the view with optional transaction for editing.
    /// If a transaction is provided, its values are loaded into the form fields.
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

    // MARK: - Body
    var body: some View {
        Form {
            // Transaction details input section
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

            // Save button - enabled only when form is valid
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
            
            // Delete button - only shown when editing existing transaction
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

    // MARK: - Validation
    /// Validates form input before saving.
    /// Checks: non-empty title, valid positive amount, and valid transaction type.
    private var isValid: Bool {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard let amt = Double(amount), amt > 0 else { return false }
        guard !category.isEmpty, (type == "Income" || type == "Expense") else { return false }
        return true
    }

    // MARK: - Actions
    /// Saves the transaction to Core Data.
    /// Creates a new transaction if editing mode is false, otherwise updates the existing one.
    /// Provides haptic feedback, posts notification, and dismisses the view on success.
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
            
            // Provide haptic feedback to user
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Reset form fields for next entry
            title = ""
            amount = ""
            category = "General"
            type = "Expense"
            date = Date()
            
            // Notify observers and trigger callbacks on main thread
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .transactionSaved, object: nil)
                onSaved?()
                dismiss()
            }
        } catch {
            print("Save error: \(error)")
        }
    }
    
    /// Deletes the current transaction from Core Data and dismisses the view.
    private func deleteCurrent() {
        guard let t = transaction else { return }
        withAnimation {
            context.delete(t)
            try? context.save()
            dismiss()
        }
    }

}
