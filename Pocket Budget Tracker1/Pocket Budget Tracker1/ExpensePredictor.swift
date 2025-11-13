//
//  ExpensePredictor.swift
//  Pocket Budget Tracker1
//
//  Created by IM Student on 2025-11-11.
//

import Foundation
import CoreML

struct ExpensePredictor {
    private static let compiledModel: MLModel? = {
        if let url = Bundle.main.url(forResource: "MyTabularRegressor", withExtension: "mlmodelc") {
            return try? MLModel(contentsOf: url)
        }
        if let url = Bundle.main.url(forResource: "MyTabularRegressor", withExtension: "mlmodelc") {
            return try? MLModel(contentsOf: url)
        }
        return nil
    }()

    func predict(totalIncome: Double, totalExpense: Double) -> Double {
        if let model = Self.compiledModel {
            let inputsByName = model.modelDescription.inputDescriptionsByName
            var features: [String: MLFeatureValue] = [:]
            if let incomeKey = inputsByName.keys.first(where: { $0.lowercased().contains("income") }) {
                features[incomeKey] = .init(double: totalIncome)
            }
            if let expenseKey = inputsByName.keys.first(where: { $0.lowercased().contains("expense") }) {
                features[expenseKey] = .init(double: totalExpense)
            }
            if let provider = try? MLDictionaryFeatureProvider(dictionary: features),
               let output = try? model.prediction(from: provider) {
                let names = Array(output.featureNames)
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
        // Fallback heuristic
        if totalIncome <= 0 { return max(totalExpense, 0) }
        let ratio = min(max(totalExpense / totalIncome, 0), 2)
        let baseline = totalExpense
        let adjustment = 0.05 * baseline * (ratio < 0.9 ? 0.5 : 1.0)
        return max(baseline + adjustment, 0)
    }
}
