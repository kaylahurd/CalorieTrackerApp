//
//  SavedMealsView.swift
//  CalorieTracker
//
//  Created by Kayla Hurd on 2/23/25.
//
import SwiftUI

struct SavedMealsView: View {
    @Binding var meals: [ContentView.Meal] // Access saved meals from ContentView

    var body: some View {
        NavigationStack {
            VStack {
                Text("Saved Meals")
                    .font(.largeTitle)
                    .padding()

                // Group meals by date
                let groupedMeals = Dictionary(grouping: meals) { meal in
                    formattedDate(meal.date) // Format the date for grouping
                }

                List {
                    ForEach(groupedMeals.keys.sorted(by: { $0 > $1 }), id: \.self) { date in
                        Section(header: Text(date).font(.headline)) { // Show date as section header
                            let mealsForDate = groupedMeals[date] ?? []
                            let totalCaloriesForDate = mealsForDate.reduce(0) { $0 + $1.calories } // ✅ Calculate total calories per day

                            // ✅ Show total calories for that date
                            Text("Total Calories: \(totalCaloriesForDate, specifier: "%.1f") cal")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            ForEach(mealsForDate.indices, id: \.self) { index in
                                NavigationLink(destination: MealDetailView(meal: $meals[index], onSave: saveMeals)) {
                                    HStack {
                                        Text(mealsForDate[index].name) // ✅ Show meal name
                                            .font(.headline)
                                        Spacer()
                                        Text("\(mealsForDate[index].calories, specifier: "%.1f") cal")
                                    }
                                }
                            }
                            .onDelete { offsets in deleteMeal(at: offsets, for: mealsForDate) } // ✅ Delete meals
                        }
                    }
                }
            }
            .navigationTitle("Saved Meals")
        }
    }

    // Function to delete a meal
    private func deleteMeal(at offsets: IndexSet, for mealsForDate: [ContentView.Meal]) {
        for index in offsets {
            if let mealIndex = meals.firstIndex(where: { $0.id == mealsForDate[index].id }) {
                meals.remove(at: mealIndex)
            }
        }
        saveMeals()
    }

    // Save meals after renaming or deleting
    private func saveMeals() {
        if let encoded = try? JSONEncoder().encode(meals) {
            UserDefaults.standard.set(encoded, forKey: "meals")
        }
    }

    // Format the date for grouping meals
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
