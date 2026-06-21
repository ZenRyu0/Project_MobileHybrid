class CalorieCalculation {
  double dailyGoal;
  double totalCaloriesConsumed = 0;
  double totalCaloriesBurned = 0;
  CalorieCalculation({required this.dailyGoal});
  void calculateDailyCalories() {}
  void addFood(double foodCalories) {
    totalCaloriesConsumed += foodCalories;
  }
  void logWorkout(double burnedCalories) {
    totalCaloriesBurned += burnedCalories;
  }
}
