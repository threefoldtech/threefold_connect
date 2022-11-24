import { Module } from '@nestjs/common';
import { DigitalTwinService } from './digitaltwin.service';
import { DigitalTwinController } from './digitaltwin.controller';
import { UserService } from '../user/user.service';
import { PrismaService } from 'nestjs-prisma';

@Module({
    providers: [DigitalTwinService, UserService, PrismaService],
    exports: [DigitalTwinService],
    controllers: [DigitalTwinController],
})
export class DigitalTwinModule {}
