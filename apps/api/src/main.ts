import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { PrismaService } from 'nestjs-prisma';
import { AppModule } from './modules/app/app.module';

async function bootstrap() {
    const app = await NestFactory.create(AppModule, { bodyParser: false });

    app.enableCors();
    app.setGlobalPrefix('api');

    const prismaService: PrismaService = app.get(PrismaService);
    await prismaService.enableShutdownHooks(app);

    app.useGlobalPipes(new ValidationPipe());

    const sodium = require('libsodium-wrappers');
    await sodium.ready;

    await app.listen(3001);
}

bootstrap();
