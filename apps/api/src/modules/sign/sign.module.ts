import { Module } from '@nestjs/common';
import { SignService } from './sign.service';
import { SignController } from './sign.controller';
import { UserService } from '../user/user.service';
import { UserModule } from '../user/user.module';

@Module({
    providers: [SignService],
    exports: [SignService],
    controllers: [SignController],
    imports: [UserModule],
})
export class SignModule {}
