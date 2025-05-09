//
//  MealView.swift
//  CalorieTracker
//
//  Created by Kayla Hurd on 2/19/25.
//
import SwiftUI

struct MealView: View {
    var ingredients: [ContentView.Ingredient]
    var onSaveMeal: (ContentView.Meal) -> Void

    @State private var ingredientAmounts: [UUID: String] = [:]
    @State private var selectedInputMode: [UUID: String] = [:]
    @State private var totalCalories: Double?
    @State private var mealName: String = ""

    @Environment(\.presentationMode) var presentationMode // ✅ Allows dismissing the view

    let inputModes = ["Grams/Oz", "Serving"]

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Enter Meal Name", text: $mealName)
                    .font(.title2)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)

                List(ingredients, id: \.id) { ingredient in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(ingredient.name).font(.headline)
                            .foregroundColor(.blue)

                        Text("\(ingredient.caloriesPerServing, specifier: "%.1f") cal per \(ingredient.servingSizeAmount, specifier: "%.1f") \(ingredient.servingUnit)")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Picker("Input Mode", selection: Binding(
                            get: { selectedInputMode[ingredient.id, default: "Grams/Oz"] },
                            set: { selectedInputMode[ingredient.id] = $0 }
                        )) {
                            ForEach(inputModes, id: \.self) { mode in Text(mode).tag(mode) }
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        TextField("Amount", text: Binding(
                            get: { ingredientAmounts[ingredient.id, default: "" ] },
                            set: { ingredientAmounts[ingredient.id] = $0 }
                        ))
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding()
                }

                Button("Calculate Calories") { calculateCalories() }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                if let totalCalories = totalCalories {
                    Text("Total Calories: \(totalCalories, specifier: "%.1f") cal")
                        .font(.title)
                        .padding()

                    Button("Save Meal") { saveMeal() }
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Create Meal")
        }
    }

    // ✅ Function to calculate total meal calories
    private func calculateCalories() {
        totalCalories = ingredients.reduce(0) { total, ingredient in
            let inputMode = selectedInputMode[ingredient.id, default: "Grams/Oz"]
            guard let amountStr = ingredientAmounts[ingredient.id], let amount = Double(amountStr) else { return total }
            return total + (inputMode == "Serving" ? amount * ingredient.caloriesPerServing : (amount / ingredient.servingSizeAmount) * ingredient.caloriesPerServing)
        }
    }

    // ✅ Function to save a meal and go back to ContentView
    private func saveMeal() {
        guard let totalCalories = totalCalories else { return }
        
        let meal = ContentView.Meal(
            id: UUID(),
            name: mealName.isEmpty ? "Untitled Meal" : mealName,
            calories: totalCalories,
            date: Date(),
            ingredients: ingredients
        )
        
        onSaveMeal(meal) // ✅ Save meal
        presentationMode.wrappedValue.dismiss() // ✅ Automatically go back to ContentView
    }
}

