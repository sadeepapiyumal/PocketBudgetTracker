
//  Pocket_Budget_Tracker1App.swift

//  Initializes the app scene and manages the Core Data stack for transaction storage.

import SwiftUI
import CoreData

// Sets up the Core Data persistence controller and provides it to the view hierarchy.
@main
struct Pocket_Budget_Tracker1App: App {
    let persistenceController = PersistenceController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}


/// Creates and configures NSPersistentContainer with custom data model.
final class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer

    // Initializes the Core Data stack with persistent store.
    // - Parameter inMemory: If true, uses in-memory store for testing; otherwise uses file-based store
    init(inMemory: Bool = false) {
        let model = Self.makeModel()
        container = NSPersistentContainer(name: "PocketBudgetModel", managedObjectModel: model)
        
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        
        // Load persistent stores
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error: \(error), \(error.userInfo)")
            }
        }
        
        // Configure merge policies and automatic synchronization
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // Creates the Core Data model programmatically with Transaction entity.
    // Defines all attributes: id, title, amount, category, type, and date.
    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // Create Transaction entity
        let transaction = NSEntityDescription()
        transaction.name = "Transaction"
        transaction.managedObjectClassName = NSStringFromClass(Transaction.self)

        // Define attributes
        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false

        let title = NSAttributeDescription()
        title.name = "title"
        title.attributeType = .stringAttributeType
        title.isOptional = false

        let amount = NSAttributeDescription()
        amount.name = "amount"
        amount.attributeType = .doubleAttributeType
        amount.isOptional = false

        let category = NSAttributeDescription()
        category.name = "category"
        category.attributeType = .stringAttributeType
        category.isOptional = false

        let type = NSAttributeDescription()
        type.name = "type"
        type.attributeType = .stringAttributeType
        type.isOptional = false

        let date = NSAttributeDescription()
        date.name = "date"
        date.attributeType = .dateAttributeType
        date.isOptional = false

        // Assign attributes to entity
        transaction.properties = [id, title, amount, category, type, date]

        // Add entity to model
        model.entities = [transaction]
        return model
    }
}

// Stores transaction details: unique identifier, title, amount, category, type, and date.
@objc(Transaction)
class Transaction: NSManagedObject {
    /// Unique identifier for the transaction
    @NSManaged var id: UUID
    /// Transaction title or description
    @NSManaged var title: String
    /// Transaction amount in currency
    @NSManaged var amount: Double
    /// Category classification (e.g., Food, Transport, Bills)
    @NSManaged var category: String
    /// Transaction type: "Income" or "Expense"
    @NSManaged var type: String
    /// Date when the transaction occurred
    @NSManaged var date: Date
}
