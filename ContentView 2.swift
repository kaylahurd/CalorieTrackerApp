import SwiftUI
import UIKit

struct ContentView: View {
    @State private var ingredientName: String = ""
    @State private var caloriesPerServing: String = ""
    @State private var servingSizeAmount: String = ""
    @State private var servingUnit: String = ""

    @State private var ingredients: [Ingredient] = []
    @State private var meals: [Meal] = []
    @State private var mealViewActive: Bool = false
    @State private var savedMealsViewActive: Bool = false

    struct Ingredient: Identifiable, Hashable, Codable {
        let id: UUID
        let name: String
        let caloriesPerServing: Double
        let servingSizeAmount: Double
        let servingUnit: String
    }

    struct Meal: Identifiable, Codable {
        let id: UUID
        var name: String
        let calories: Double
        let date: Date
        let ingredients: [Ingredient]
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Text("Meal Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                VStack(spacing: 10) {
                    Text("ADD NEW INGREDIENT")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    TextField("Ingredient Name", text: $ingredientName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    TextField("Calories per Serving", text: $caloriesPerServing)
                        .keyboardType(UIKeyboardType.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    TextField("Serving Size Amount", text: $servingSizeAmount)
                        .keyboardType(UIKeyboardType.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    TextField("Serving Unit (e.g., oz, slice, bagel)", text: $servingUnit)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    Button(action: addIngredient) {
                        Text("Add Ingredient")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 3)
                .padding(.horizontal)
                .padding(.bottom, 5)

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        Text("Saved Ingredients")
                            .font(.title2)
                            .padding(.leading)

                        ForEach(ingredients) { ingredient in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(ingredient.name)
                                        .font(.headline)
                                    Text("\(ingredient.caloriesPerServing, specifier: "%.1f") cal per \(ingredient.servingSizeAmount, specifier: "%.1f") \(ingredient.servingUnit)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Button(action: { deleteIngredient(ingredient) }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 10)
                }
                .frame(maxHeight: 300)

                HStack {
                    Button(action: { mealViewActive = true }) {
                        Text("Create Meal")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .navigationDestination(isPresented: $mealViewActive) {
                        MealView(ingredients: ingredients, onSaveMeal: saveMeal)
                    }

                    Button(action: { savedMealsViewActive = true }) {
                        Text("View Saved Meals")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .navigationDestination(isPresented: $savedMealsViewActive) {
                        SavedMealsView(meals: $meals)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 10)
        }
        .onAppear {
            loadIngredients()
            loadMeals()
        }
    }

    private func addIngredient() {
        guard let calories = Double(caloriesPerServing),
              let servingAmount = Double(servingSizeAmount),
              !ingredientName.isEmpty,
              !servingUnit.isEmpty else { return }

        let newIngredient = Ingredient(
            id: UUID(),
            name: ingredientName,
            caloriesPerServing: calories,
            servingSizeAmount: servingAmount,
            servingUnit: servingUnit
        )

        ingredients.append(newIngredient)
        saveIngredients()

        ingredientName = ""
        caloriesPerServing = ""
        servingSizeAmount = ""
        servingUnit = ""
    }

    private func deleteIngredient(_ ingredient: Ingredient) {
        ingredients.removeAll { $0.id == ingredient.id }
        saveIngredients()
    }

    private func saveMeal(_ meal: Meal) {
        meals.append(meal)
        saveMeals()
    }

    private func saveIngredients() {
        if let encoded = try? JSONEncoder().encode(ingredients) {
            UserDefaults.standard.set(encoded, forKey: "ingredients")
        }
    }

    private func loadIngredients() {
        if let savedData = UserDefaults.standard.data(forKey: "ingredients"),
           let decoded = try? JSONDecoder().decode([Ingredient].self, from: savedData) {
            ingredients = decoded
        }
    }

    private func saveMeals() {
        if let encoded = try? JSONEncoder().encode(meals) {
            UserDefaults.standard.set(encoded, forKey: "meals")
        }
    }

    private func loadMeals() {
        if let savedData = UserDefaults.standard.data(forKey: "meals"),
           let decoded = try? JSONDecoder().decode([Meal].self, from: savedData) {
            meals = decoded
        }
    }
}

