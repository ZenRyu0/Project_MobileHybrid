/*
  Warnings:

  - You are about to drop the `PostSave` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "PostSave" DROP CONSTRAINT "PostSave_postId_fkey";

-- DropForeignKey
ALTER TABLE "PostSave" DROP CONSTRAINT "PostSave_userId_fkey";

-- DropTable
DROP TABLE "PostSave";
