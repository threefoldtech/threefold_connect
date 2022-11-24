import { Module } from '@nestjs/common';
import { LoginService } from './login.service';
import { LoginController } from './login.controller';
import { UserModule } from '../user/user.module';

@Module({
    providers: [LoginService],
    exports: [LoginService],
    controllers: [LoginController],
    imports: [UserModule],
})
export class LoginModule {}
