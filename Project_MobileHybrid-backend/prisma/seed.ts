import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seeding...');

  // Clear existing data
  await prisma.postLike.deleteMany({});
  await prisma.postSave.deleteMany({});
  await prisma.comment.deleteMany({});
  await prisma.post.deleteMany({});
  await prisma.calorieEntry.deleteMany({});
  await prisma.workout.deleteMany({});
  await prisma.workoutPlan.deleteMany({});
  await prisma.dailyCalorieTarget.deleteMany({});
  await prisma.user.deleteMany({});

  // Create realistic users
  const password = await bcrypt.hash('password123', 10);

  const user1 = await prisma.user.create({
    data: {
      email: 'alex.fitness@example.com',
      passwordHash: password,
      name: 'Alex Rivera',
      bio: '🏋️ Fitness enthusiast | Strength training | 6 months into fitness journey',
      avatar: 'https://i.pravatar.cc/150?img=12',
      emailVerified: true,
      isActive: true,
    },
  });

  const user2 = await prisma.user.create({
    data: {
      email: 'sarah.health@example.com',
      passwordHash: password,
      name: 'Sarah Johnson',
      bio: '🧘‍♀️ Yoga instructor | Wellness coach | Holistic health',
      avatar: 'https://i.pravatar.cc/150?img=47',
      emailVerified: true,
      isActive: true,
    },
  });

  const user3 = await prisma.user.create({
    data: {
      email: 'mike.gains@example.com',
      passwordHash: password,
      name: 'Mike Thompson',
      bio: '💪 Personal trainer | Bodybuilding | Nutrition expert',
      avatar: 'https://i.pravatar.cc/150?img=33',
      emailVerified: true,
      isActive: true,
    },
  });

  const user4 = await prisma.user.create({
    data: {
      email: 'emma.wellness@example.com',
      passwordHash: password,
      name: 'Emma Davis',
      bio: '🏃‍♀️ Marathon runner | Trail enthusiast | Coffee lover',
      avatar: 'https://i.pravatar.cc/150?img=21',
      emailVerified: true,
      isActive: true,
    },
  });

  console.log('✓ Created 4 realistic users');

  // Create daily calorie targets
  await prisma.dailyCalorieTarget.createMany({
    data: [
      { userId: user1.id, target: 2200 },
      { userId: user2.id, target: 1800 },
      { userId: user3.id, target: 2800 },
      { userId: user4.id, target: 2000 },
    ],
  });

  console.log('✓ Created daily calorie targets');

  // Create pre-made workout plans
  const workoutPlans = await Promise.all([
    prisma.workoutPlan.create({
      data: {
        name: 'Full Body Strength',
        duration: 45,
        difficulty: 'Intermediate',
        description: 'Complete full body workout targeting all major muscle groups. Perfect for gaining strength.',
        caloriesBurned: 350,
        isCustom: false,
        exercises: [
          { name: 'Warm-up Cardio', sets: 1, duration: 5, caloriesBurned: 50 },
          { name: 'Squats', sets: 4, reps: 10, caloriesBurned: 80 },
          { name: 'Bench Press', sets: 4, reps: 8, caloriesBurned: 75 },
          { name: 'Deadlifts', sets: 3, reps: 5, caloriesBurned: 90 },
          { name: 'Rows', sets: 3, reps: 8, caloriesBurned: 60 },
        ],
      },
    }),
    prisma.workoutPlan.create({
      data: {
        name: 'Morning Cardio Blast',
        duration: 30,
        difficulty: 'Beginner',
        description: 'Start your day with energizing cardio exercises. Great for cardiovascular health.',
        caloriesBurned: 280,
        isCustom: false,
        exercises: [
          { name: 'Jumping Jacks', sets: 2, reps: 30, caloriesBurned: 40 },
          { name: 'Running/Jogging', sets: 1, duration: 15, caloriesBurned: 180 },
          { name: 'Burpees', sets: 3, reps: 12, caloriesBurned: 60 },
        ],
      },
    }),
    prisma.workoutPlan.create({
      data: {
        name: 'Yoga & Flexibility',
        duration: 20,
        difficulty: 'All Levels',
        description: 'Improve flexibility and mental clarity with gentle yoga. Perfect for recovery days.',
        caloriesBurned: 80,
        isCustom: false,
        exercises: [
          { name: 'Sun Salutation', sets: 5, reps: 1, caloriesBurned: 40 },
          { name: 'Warrior Poses', sets: 1, duration: 7, caloriesBurned: 25 },
          { name: 'Meditation', sets: 1, duration: 8, caloriesBurned: 15 },
        ],
      },
    }),
    prisma.workoutPlan.create({
      data: {
        name: 'HIIT Sprint Training',
        duration: 25,
        difficulty: 'Advanced',
        description: 'High intensity interval training for maximum calorie burn and cardiovascular improvement.',
        caloriesBurned: 350,
        isCustom: false,
        exercises: [
          { name: 'Sprint Intervals', sets: 8, duration: 1, caloriesBurned: 200 },
          { name: 'Mountain Climbers', sets: 3, reps: 20, caloriesBurned: 90 },
          { name: 'Jump Squats', sets: 3, reps: 15, caloriesBurned: 60 },
        ],
      },
    }),
  ]);

  console.log('✓ Created 4 pre-made workout plans');

  // Create custom workout plans for users
  await prisma.workoutPlan.createMany({
    data: [
      {
        name: "Alex's Upper Body Focus",
        duration: 50,
        difficulty: 'Intermediate',
        description: 'Custom plan focusing on chest, back, and arms',
        caloriesBurned: 320,
        isCustom: true,
        userId: user1.id,
        exercises: [
          { name: 'Pull-ups', sets: 5, reps: 8, caloriesBurned: 80 },
          { name: 'Chest Dips', sets: 4, reps: 10, caloriesBurned: 70 },
        ],
      },
      {
        name: "Sarah's Pilates Routine",
        duration: 35,
        difficulty: 'Beginner',
        description: 'Core strengthening pilates routine',
        caloriesBurned: 150,
        isCustom: true,
        userId: user2.id,
        exercises: [
          { name: 'Pilates 100s', sets: 1, duration: 5, caloriesBurned: 40 },
          { name: 'Leg Circles', sets: 2, reps: 10, caloriesBurned: 50 },
        ],
      },
    ],
  });

  console.log('✓ Created custom workout plans');

  // Create realistic workout history
  const today = new Date();
  const dates = Array.from({ length: 7 }, (_, i) => {
    const date = new Date(today);
    date.setDate(date.getDate() - i);
    return date.toISOString().split('T')[0];
  });

  await prisma.workout.createMany({
    data: [
      {
        userId: user1.id,
        name: 'Full Body Strength',
        duration: 45,
        difficulty: 'Intermediate',
        caloriesBurned: 380,
        date: dates[0],
        notes: 'Felt strong today. New squat PR!',
      },
      {
        userId: user1.id,
        name: 'Morning Cardio',
        duration: 30,
        difficulty: 'Beginner',
        caloriesBurned: 260,
        date: dates[1],
        notes: 'Great pace and energy',
      },
      {
        userId: user2.id,
        name: 'Yoga & Flexibility',
        duration: 20,
        difficulty: 'All Levels',
        caloriesBurned: 85,
        date: dates[1],
        notes: 'Very relaxing session',
      },
      {
        userId: user3.id,
        name: 'HIIT Sprint Training',
        duration: 25,
        difficulty: 'Advanced',
        caloriesBurned: 380,
        date: dates[0],
        notes: 'Intense but rewarding!',
      },
      {
        userId: user4.id,
        name: 'Morning Run',
        duration: 40,
        difficulty: 'Intermediate',
        caloriesBurned: 420,
        date: dates[2],
        notes: '5K run in 28 minutes',
      },
      {
        userId: user3.id,
        name: 'Full Body Strength',
        duration: 50,
        difficulty: 'Intermediate',
        caloriesBurned: 400,
        date: dates[2],
        notes: 'Crushed my workout today',
      },
    ],
  });

  console.log('✓ Created realistic workout history');

  // Create detailed calorie entries with real foods
  await prisma.calorieEntry.createMany({
    data: [
      // User 1 - Alex
      {
        userId: user1.id,
        mealType: 'Breakfast',
        foodName: 'Oatmeal with granola and berries',
        calories: 380,
        protein: 14,
        carbs: 62,
        fat: 9,
        date: dates[0],
      },
      {
        userId: user1.id,
        mealType: 'Snack',
        foodName: 'Protein shake with banana',
        calories: 220,
        protein: 25,
        carbs: 28,
        fat: 3,
        date: dates[0],
      },
      {
        userId: user1.id,
        mealType: 'Lunch',
        foodName: 'Grilled chicken breast with brown rice',
        calories: 520,
        protein: 42,
        carbs: 58,
        fat: 8,
        date: dates[0],
      },
      {
        userId: user1.id,
        mealType: 'Dinner',
        foodName: 'Salmon fillet with sweet potato and broccoli',
        calories: 580,
        protein: 38,
        carbs: 45,
        fat: 22,
        date: dates[0],
      },
      // User 2 - Sarah
      {
        userId: user2.id,
        mealType: 'Breakfast',
        foodName: 'Greek yogurt with honey and almonds',
        calories: 320,
        protein: 15,
        carbs: 35,
        fat: 12,
        date: dates[0],
      },
      {
        userId: user2.id,
        mealType: 'Lunch',
        foodName: 'Quinoa salad with vegetables and chickpeas',
        calories: 420,
        protein: 14,
        carbs: 52,
        fat: 16,
        date: dates[0],
      },
      {
        userId: user2.id,
        mealType: 'Dinner',
        foodName: 'Tofu stir-fry with brown rice',
        calories: 450,
        protein: 20,
        carbs: 58,
        fat: 12,
        date: dates[0],
      },
      // User 3 - Mike
      {
        userId: user3.id,
        mealType: 'Breakfast',
        foodName: 'Eggs and toast with whole wheat',
        calories: 420,
        protein: 28,
        carbs: 32,
        fat: 18,
        date: dates[0],
      },
      {
        userId: user3.id,
        mealType: 'Snack',
        foodName: 'Protein bar',
        calories: 250,
        protein: 20,
        carbs: 28,
        fat: 7,
        date: dates[0],
      },
      {
        userId: user3.id,
        mealType: 'Lunch',
        foodName: 'Turkey sandwich with vegetables',
        calories: 480,
        protein: 38,
        carbs: 45,
        fat: 14,
        date: dates[0],
      },
      {
        userId: user3.id,
        mealType: 'Dinner',
        foodName: 'Lean ground beef with pasta',
        calories: 620,
        protein: 42,
        carbs: 68,
        fat: 16,
        date: dates[0],
      },
      // User 4 - Emma
      {
        userId: user4.id,
        mealType: 'Breakfast',
        foodName: 'Smoothie bowl with granola',
        calories: 380,
        protein: 12,
        carbs: 58,
        fat: 10,
        date: dates[2],
      },
      {
        userId: user4.id,
        mealType: 'Lunch',
        foodName: 'Tuna salad with whole wheat crackers',
        calories: 390,
        protein: 32,
        carbs: 42,
        fat: 10,
        date: dates[2],
      },
      {
        userId: user4.id,
        mealType: 'Dinner',
        foodName: 'Chicken fajitas with whole wheat tortillas',
        calories: 520,
        protein: 35,
        carbs: 55,
        fat: 16,
        date: dates[2],
      },
    ],
  });

  console.log('✓ Created detailed calorie entries');

  // Create organic social posts with real images
  const post1 = await prisma.post.create({
    data: {
      userId: user1.id,
      content: '💪 Just crushed a new personal record on squats! 315 lbs for 5 reps. All the hard work is paying off! Feeling grateful for my fitness journey. #NoGainzWithoutPains #SquatGoals',
      imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25ddfcbf042?w=600&h=600&fit=crop',
    },
  });

  const post2 = await prisma.post.create({
    data: {
      userId: user2.id,
      content: '🧘‍♀️ Beautiful morning yoga session. Starting my day with mindfulness and gratitude. Join me for virtual classes! #YogaLife #Wellness #MindBodySpirit',
    },
  });

  const post3 = await prisma.post.create({
    data: {
      userId: user3.id,
      content: '🥇 Another successful HIIT session completed! 30 minutes of pure intensity. Recovery smoothie next 🥤 #HIIT #Fitness #NoPainNoGain',
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600&h=600&fit=crop',
    },
  });

  const post4 = await prisma.post.create({
    data: {
      userId: user4.id,
      content: '🏃‍♀️ Completed my 10K run this morning! Beautiful weather and great energy. Loving this fitness lifestyle. Who else is a morning runner? #Running #MorningMotivation #10K',
      imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=600&h=600&fit=crop',
    },
  });

  const post5 = await prisma.post.create({
    data: {
      userId: user1.id,
      content: '🥗 Meal prep Sundays! Planning out my nutrition for the week. Consistency is key to achieving fitness goals. What\'s your go-to meal prep? #MealPrep #Nutrition #FitnessGoals',
      imageUrl: 'https://images.unsplash.com/photo-1505576399279-565b52ce32aa?w=600&h=600&fit=crop',
    },
  });

  console.log('✓ Created 5 organic posts with images');

  // Create comments
  await prisma.comment.createMany({
    data: [
      {
        postId: post1.id,
        userId: user3.id,
        content: 'That\'s incredible, Alex! Keep grinding! 💪',
      },
      {
        postId: post1.id,
        userId: user4.id,
        content: 'Amazing progress! Inspiring to see people working towards their goals',
      },
      {
        postId: post2.id,
        userId: user1.id,
        content: 'I need to start practicing yoga more. Your content always motivates me!',
      },
      {
        postId: post3.id,
        userId: user2.id,
        content: 'HIIT is intense but so rewarding! Great job, Mike!',
      },
      {
        postId: post3.id,
        userId: user4.id,
        content: 'How do you manage the recovery after such intense workouts?',
      },
      {
        postId: post4.id,
        userId: user1.id,
        content: 'That\'s an awesome 10K time! Keep it up Emma! 🏃‍♀️',
      },
      {
        postId: post5.id,
        userId: user3.id,
        content: 'Meal prep is everything! This looks delicious!',
      },
    ],
  });

  console.log('✓ Created organic comments');

  // Create likes and saves
  await prisma.postLike.createMany({
    data: [
      { userId: user2.id, postId: post1.id },
      { userId: user3.id, postId: post1.id },
      { userId: user4.id, postId: post1.id },
      { userId: user1.id, postId: post2.id },
      { userId: user3.id, postId: post2.id },
      { userId: user4.id, postId: post2.id },
      { userId: user1.id, postId: post3.id },
      { userId: user2.id, postId: post3.id },
      { userId: user4.id, postId: post3.id },
      { userId: user1.id, postId: post4.id },
      { userId: user2.id, postId: post4.id },
      { userId: user3.id, postId: post4.id },
      { userId: user2.id, postId: post5.id },
      { userId: user3.id, postId: post5.id },
      { userId: user4.id, postId: post5.id },
    ],
  });

  await prisma.postSave.createMany({
    data: [
      { userId: user2.id, postId: post1.id },
      { userId: user4.id, postId: post2.id },
      { userId: user1.id, postId: post3.id },
      { userId: user2.id, postId: post4.id },
      { userId: user3.id, postId: post5.id },
    ],
  });

  console.log('✓ Created likes and saves');

  console.log('\n✅ Database seeding completed successfully!');
  console.log('\n📊 Summary:');
  console.log('- 4 realistic users created');
  console.log('- 6 workout plans (4 pre-made + 2 custom)');
  console.log('- 6 workout history entries');
  console.log('- 14 calorie entries with real foods');
  console.log('- 5 social posts with real images');
  console.log('- 7 comments');
  console.log('- 15 likes and 5 saves');
}

main()
  .catch((e) => {
    console.error('❌ Error during seeding:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
