/**
 * Calculate the calories burned based on the number of steps
 * Formula: Calories = Steps * 0.04 (assuming 0.04 calories burned per step)
 * @param {Object} activity - The activity object containing the number of steps
 * @param {number} activity.steps - The number of steps taken
 * @return {number} - The calculated calories burned
 */
const calculateCalories = (activity) => {
  // Assuming 0.04 calories burned per step
  const caloriesPerStep = 0.04

  // Extract the number of steps from the activity object and calculate calories
  const { steps } = activity
  return steps * caloriesPerStep
}

export default calculateCalories