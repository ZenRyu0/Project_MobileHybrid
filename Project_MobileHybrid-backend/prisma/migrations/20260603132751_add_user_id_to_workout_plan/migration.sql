-- AlterTable
ALTER TABLE "WorkoutPlan" ADD COLUMN     "userId" TEXT;

-- CreateIndex
CREATE INDEX "WorkoutPlan_userId_idx" ON "WorkoutPlan"("userId");
