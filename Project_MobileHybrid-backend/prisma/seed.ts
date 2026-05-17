import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seeding...');

  // Create test users
  const password = await bcrypt.hash('password123', 10);

  const user1 = await prisma.user.upsert({
    where: { email: 'test@example.com' },
    update: {},
    create: {
      email: 'test@example.com',
      passwordHash: password,
      name: 'Test User',
      bio: 'Fitness enthusiast and gym lover',
      avatar: 'https://i.pravatar.cc/150?img=1',
      emailVerified: true,
      isActive: true,
    },
  });

  const user2 = await prisma.user.upsert({
    where: { email: 'jane@example.com' },
    update: {},
    create: {
      email: 'jane@example.com',
      passwordHash: password,
      name: 'Jane Smith',
      bio: 'Starting my fitness journey',
      avatar: 'https://i.pravatar.cc/150?img=2',
      emailVerified: true,
      isActive: true,
    },
  });

  const user3 = await prisma.user.upsert({
    where: { email: 'mike@example.com' },
    update: {},
    create: {
      email: 'mike@example.com',
      passwordHash: password,
      name: 'Mike Johnson',
      bio: 'Strength training specialist',
      avatar: 'https://i.pravatar.cc/150?img=3',
      emailVerified: true,
      isActive: true,
    },
  });

  console.log('✓ Created users:', { user1: user1.email, user2: user2.email, user3: user3.email });

  // Create daily calorie targets
  await prisma.dailyCalorieTarget.upsert({
    where: { userId: user1.id },
    update: {},
    create: {
      userId: user1.id,
      target: 2000,
    },
  });

  await prisma.dailyCalorieTarget.upsert({
    where: { userId: user2.id },
    update: {},
    create: {
      userId: user2.id,
      target: 1800,
    },
  });

  await prisma.dailyCalorieTarget.upsert({
    where: { userId: user3.id },
    update: {},
    create: {
      userId: user3.id,
      target: 2500,
    },
  });

  console.log('✓ Created daily calorie targets');

  // Create workout plans
  const workoutPlans = await Promise.all([
    prisma.workoutPlan.upsert({
      where: { id: 'plan-1' },
      update: {},
      create: {
        id: 'plan-1',
        name: 'Full Body Strength',
        duration: 45,
        difficulty: 'Intermediate',
        description: 'Complete full body workout targeting all major muscle groups',
        caloriesBurned: 350,
        isCustom: false,
        exercises: [
          { name: 'Warm-up Cardio', sets: 1, reps: 10, duration: 5, caloriesBurned: 50 },
          { name: 'Squats', sets: 4, reps: 10, caloriesBurned: 80 },
          { name: 'Bench Press', sets: 4, reps: 8, caloriesBurned: 75 },
          { name: 'Deadlifts', sets: 3, reps: 5, caloriesBurned: 90 },
          { name: 'Cool-down Stretching', sets: 1, duration: 5, caloriesBurned: 20 },
        ],
      },
    }),
    prisma.workoutPlan.upsert({
      where: { id: 'plan-2' },
      update: {},
      create: {
        id: 'plan-2',
        name: 'Morning Cardio',
        duration: 30,
        difficulty: 'Beginner',
        description: 'Start your day with energizing cardio exercises',
        caloriesBurned: 250,
        isCustom: false,
        exercises: [
          { name: 'Warm-up Jumping Jacks', sets: 1, reps: 30, caloriesBurned: 30 },
          { name: 'Running/Jogging', sets: 1, duration: 15, caloriesBurned: 150 },
          { name: 'Burpees', sets: 3, reps: 15, caloriesBurned: 50 },
          { name: 'Cool-down Walk', sets: 1, duration: 5, caloriesBurned: 20 },
        ],
      },
    }),
    prisma.workoutPlan.upsert({
      where: { id: 'plan-3' },
      update: {},
      create: {
        id: 'plan-3',
        name: 'Yoga & Flexibility',
        duration: 20,
        difficulty: 'All Levels',
        description: 'Improve flexibility and mental clarity with gentle yoga',
        caloriesBurned: 80,
        isCustom: false,
        exercises: [
          { name: 'Breathing & Centering', sets: 1, duration: 3, caloriesBurned: 10 },
          { name: 'Sun Salutation', sets: 5, reps: 1, caloriesBurned: 30 },
          { name: 'Standing Poses', sets: 1, duration: 7, caloriesBurned: 25 },
          { name: 'Relaxation & Meditation', sets: 1, duration: 5, caloriesBurned: 15 },
        ],
      },
    }),
  ]);

  console.log('✓ Created workout plans:', workoutPlans.length);

  // Create workout history
  const today = new Date();
  const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);
  const twoDaysAgo = new Date(today.getTime() - 2 * 24 * 60 * 60 * 1000);

  await prisma.workout.createMany({
    data: [
      {
        userId: user1.id,
        name: 'Morning Cardio',
        duration: 30,
        difficulty: 'Beginner',
        caloriesBurned: 250,
        date: yesterday.toISOString().split('T')[0],
        notes: 'Great cardio session!',
      },
      {
        userId: user1.id,
        name: 'Full Body Strength',
        duration: 45,
        difficulty: 'Intermediate',
        caloriesBurned: 350,
        date: twoDaysAgo.toISOString().split('T')[0],
        notes: 'Personal best on squats!',
      },
      {
        userId: user2.id,
        name: 'Yoga & Flexibility',
        duration: 20,
        difficulty: 'All Levels',
        caloriesBurned: 80,
        date: yesterday.toISOString().split('T')[0],
        notes: 'Felt very relaxed after this',
      },
    ],
  });

  console.log('✓ Created workout history');

  // Create calorie entries
  await prisma.calorieEntry.createMany({
    data: [
      {
        userId: user1.id,
        mealType: 'Breakfast',
        foodName: 'Oatmeal with berries',
        calories: 350,
        protein: 12,
        carbs: 58,
        fat: 8,
        date: today.toISOString().split('T')[0],
      },
      {
        userId: user1.id,
        mealType: 'Lunch',
        foodName: 'Grilled chicken salad',
        calories: 450,
        protein: 35,
        carbs: 25,
        fat: 18,
        date: today.toISOString().split('T')[0],
      },
      {
        userId: user1.id,
        mealType: 'Dinner',
        foodName: 'Salmon with vegetables',
        calories: 550,
        protein: 40,
        carbs: 30,
        fat: 25,
        date: today.toISOString().split('T')[0],
      },
    ],
  });

  console.log('✓ Created calorie entries');

  // Create posts
  const post1 = await prisma.post.create({
    data: {
      userId: user1.id,
      content: 'Just completed a 45-minute full body workout! Feeling amazing! 💪',
      imageUrl: 'https://media.istockphoto.com/id/2027278927/photo/young-athletic-woman-exercising-with-barbell-during-sports-training-in-a-gym.jpg?s=612x612&w=0&k=20&c=ifFL7Mqc8NwTj25PAx4ONy1OOQZvc1S_kVOofsbLgFw=',
    },
  });

  const post2 = await prisma.post.create({
    data: {
      userId: user2.id,
      content: 'Starting my fitness journey today. Who else wants to be accountable partners? 🏃‍♀️',
    },
  });

  const post3 = await prisma.post.create({
    data: {
      userId: user3.id,
      content: 'New personal record on deadlifts! 305 lbs 🎉',
      imageUrl: 'https://media.istockphoto.com/id/2027278927/photo/young-athletic-woman-exercising-with-barbell-during-sports-training-in-a-gym.jpg?s=612x612&w=0&k=20&c=ifFL7Mqc8NwTj25PAx4ONy1OOQZvc1S_kVOofsbLgFw=',
    },
  });

  console.log('✓ Created posts:', [post1.id, post2.id, post3.id]);

  // Create comments
  await prisma.comment.createMany({
    data: [
      {
        postId: post1.id,
        userId: user2.id,
        content: 'Wow, great work! Keep it up! 💪',
      },
      {
        postId: post1.id,
        userId: user3.id,
        content: 'Impressive dedication!',
      },
      {
        postId: post2.id,
        userId: user1.id,
        content: 'I want to be your accountability partner!',
      },
    ],
  });

  console.log('✓ Created comments');

  // Create likes
  await prisma.postLike.createMany({
    data: [
      { userId: user2.id, postId: post1.id },
      { userId: user3.id, postId: post1.id },
      { userId: user1.id, postId: post2.id },
      { userId: user3.id, postId: post2.id },
      { userId: user1.id, postId: post3.id },
      { userId: user2.id, postId: post3.id },
    ],
  });

  console.log('✓ Created likes');

  console.log('✅ Database seeding completed successfully!');
}

main()
  .catch((e) => {
    console.error('❌ Error during seeding:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
