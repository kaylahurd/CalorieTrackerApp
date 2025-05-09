//
//  MealDetailView.swift
//  CalorieTracker
//
//  Created by Kayla Hurd on 2/23/25.
//
import SwiftUI

struct MealDetailView: View {
    @Binding var meal: ContentView.Meal
    var onSave: () -> Void

    @State private var isEditing: Bool = false

    var body: some View {
        VStack {
            if isEditing {
                TextField("Enter meal name", text: $meal.name, onCommit: {
                    isEditing = false
                    onSave()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            } else {
                Text(meal.name)
                    .font(.largeTitle)
                    .padding()
                    .onTapGesture {
                        isEditing = true
                    }
            }

            // ✅ Show meal date
            Text("Date: \(formattedDate(meal.date))")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom)

            Text("Total Calories: \(meal.calories, specifier: "%.1f") cal")
                .font(.title2)
                .padding(.bottom)

            List(meal.ingredients) { ingredient in
                VStack(alignment: .leading) {
                    Text(ingredient.name).font(.headline)
                    Text("\(ingredient.caloriesPerServing, specifier: "%.1f") cal per \(ingredient.servingSizeAmount, specifier: "%.1f") \(ingredient.servingUnit)")
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("Meal Details")
    }

    // Format the date
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

