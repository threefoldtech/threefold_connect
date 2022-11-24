-- CreateTable
CREATE TABLE `User` (
    `userId` VARCHAR(191) NOT NULL,
    `username` VARCHAR(191) NOT NULL,
    `mainPublicKey` VARCHAR(191) NOT NULL,
    `email` VARCHAR(191) NOT NULL,

    UNIQUE INDEX `User_userId_key`(`userId`),
    UNIQUE INDEX `User_username_key`(`username`),
    UNIQUE INDEX `User_mainPublicKey_key`(`mainPublicKey`),
    PRIMARY KEY (`userId`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `DigitalTwin` (
    `id` VARCHAR(191) NOT NULL,
    `userId` VARCHAR(191) NOT NULL,
    `derivedPublicKey` VARCHAR(191) NOT NULL,
    `appId` VARCHAR(191) NOT NULL,
    `yggdrasilIp` VARCHAR(191) NULL DEFAULT '',

    UNIQUE INDEX `DigitalTwin_id_key`(`id`),
    UNIQUE INDEX `DigitalTwin_derivedPublicKey_key`(`derivedPublicKey`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `DigitalTwin` ADD CONSTRAINT `DigitalTwin_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `User`(`userId`) ON DELETE RESTRICT ON UPDATE CASCADE;
