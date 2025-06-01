export const formatFoodIngredients = (foods, ingredientsKey) => {
    return foods.map((food) => ({
        ...food,
        ingredients: food[ingredientsKey].map((ingredient) => ingredient.replaceAll(';', ', ').replaceAll('_', ' '))
    }))
}