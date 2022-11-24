import { Module } from '@nestjs/common';
import { UserService } from './user.service';
import { UserController } from './user.controller';
import { UserGateway } from './user.gateway';

@Module({
    providers: [UserService, UserGateway],
    exports: [UserService, UserGateway],
    controllers: [UserController],
})
export class UserModule {}
