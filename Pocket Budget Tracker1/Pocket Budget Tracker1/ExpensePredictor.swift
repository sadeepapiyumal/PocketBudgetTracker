/
//  ExpensePredictor.swift

//  Provides AI-powered expense prediction using CoreML model.

import Foundation
import CoreML

// Predicts future expenses using machine learning model or fallback heuristic.
struct ExpensePredictor {
    // Lazily loads the compiled CoreML model from the app bundle.
    private static let compiledModel: MLModel? = {
        if let url = Bundle.main.url(forResource: "MyTabularRegressor", withExtension: "mlmodelc") {
            return try? MLModel(contentsOf: url)
        }
        if let url = Bundle.main.url(forResource: "MyTabularRegressor", withExtension: "mlmodelc") {
            return try? MLModel(contentsOf: url)
        }
        return nil
    }()

    // Predicts next month's expense based on total income and expense.
    // Uses CoreML model if available, otherwise applies heuristic-based fallback.
  
    func predict(totalIncome: Double, totalExpense: Double) -> Double {
        // Attempt ML model prediction
        if let model = Self.compiledModel {
            let inputsByName = model.modelDescription.inputDescriptionsByName
            var features: [String: MLFeatureValue] = [:]
            
            // Map income input to model
            if let incomeKey = inputsByName.keys.first(where: { $0.lowercased().contains("income") }) {
                features[incomeKey] = .init(double: totalIncome)
            }
            
            // Map expense input to model
            if let expenseKey = inputsByName.keys.first(where: { $0.lowercased().contains("expense") }) {
                features[expenseKey] = .init(double: totalExpense)
            }
            
            // Execute model prediction
            if let provider = try? MLDictionaryFeatureProvider(dictionary: features),
               let output = try? model.prediction(from: provider) {
                let names = Array(output.featureNames)
                // Find output with relevant name (next, predict, expense, or output)
                let preferredName = names.first(where: { name in
                    let n = name.lowercased()
                    return n.contains("next") || n.contains("predict") || n.contains("expense") || n.contains("output")
                }) ?? names.first
                if let preferredName,
                   let value = output.featureValue(for: preferredName)?.doubleValue {
                    return value
                }
            }
        }
        
        // Fallback heuristic-based prediction
        // If no income, return current expense as baseline
        if totalIncome <= 0 { return max(totalExpense, 0) }
        
        // Calculate expense-to-income ratio and apply adjustment
        let ratio = min(max(totalExpense / totalIncome, 0), 2)
        let baseline = totalExpense
        // Apply 5% adjustment, reduced if expense ratio is healthy (< 0.9)
        let adjustment = 0.05 * baseline * (ratio < 0.9 ? 0.5 : 1.0)
        return max(baseline + adjustment, 0)
    }
}
