import { Body, Controller, Param, Post } from '@nestjs/common';
import { SignService } from './sign.service';
import { UserGateway } from '../user/user.gateway';
import { UsernameDto } from 'shared-types';

@Controller('sign')
export class SignController {
    constructor(private readonly signService: SignService, private readonly userGateway: UserGateway) {}

    @Post(':username/cancel')
    async cancel(@Param('') username: UsernameDto): Promise<void> {
        return this.userGateway.emitCancelSignAttempt(username.username);
    }

    @Post('signed-attempt')
    async signedLoginAttemptHandler(@Body() data: string): Promise<void> {
        return this.signService.handleSignedSignAttempt(data);
    }
}
