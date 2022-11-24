import { Body, Controller, Param, Post } from '@nestjs/common';
import { LoginService } from './login.service';
import { UserGateway } from '../user/user.gateway';
import { DoubleNameDto } from 'shared-types';

@Controller('login')
export class LoginController {
    constructor(private readonly loginService: LoginService, private readonly userGateway: UserGateway) {}

    @Post(':doubleName/cancel')
    async cancel(@Param('') doubleName: DoubleNameDto): Promise<void> {
        return this.userGateway.emitCancelLoginAttempt(doubleName.doubleName);
    }

    @Post(':doubleName')
    async signedLoginAttemptHandler(@Param('doubleName') doubleName: any, @Body() loginAttempt: any): Promise<void> {
        return this.loginService.handleSignedLoginAttempt(doubleName, loginAttempt);
    }
}
