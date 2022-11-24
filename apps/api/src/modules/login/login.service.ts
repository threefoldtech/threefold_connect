import { Injectable } from '@nestjs/common';
import { BadRequestException, NotFoundException } from '../../exceptions';
import { verifyMessage } from '../../utils/crypto.utils';
import { UserService } from '../user/user.service';
import { decodeBase64 } from 'tweetnacl-util';
import { UserGateway } from '../user/user.gateway';
import { LoginAttemptDto, SignedLoginAttemptDto } from 'shared-types';

@Injectable()
export class LoginService {
    constructor(private readonly userService: UserService, private readonly userGateway: UserGateway) {}

    async handleSignedLoginAttempt(username: string, loginAttempt: LoginAttemptDto): Promise<void> {
        const user = await this.userService.findByUsername(username);
        if (!user) {
            console.error(`Signed login attempt received but user ${username} not found`);
            throw new NotFoundException(`Signed login attempt received but user ${username} not found`);
        }

        const signedData = verifyMessage(
            decodeBase64(loginAttempt.signedAttempt.toString()),
            decodeBase64(user.publicKey)
        );
        if (!signedData) {
            console.error(`Signature mismatch for ${user.publicKey} with data ${loginAttempt.signedAttempt}`);
            throw new BadRequestException(
                `Signature mismatch for ${user.publicKey} with data ${loginAttempt.signedAttempt}`
            );
        }

        let verifiedLoginAttempt: SignedLoginAttemptDto = JSON.parse(signedData);

        let room = verifiedLoginAttempt.room.toLowerCase();
        if (!room) {
            room = username.toLowerCase();
        }

        console.log('Sending login attempt to room: ', room);
        await this.userGateway.emitSignedLoginAttempt(room, loginAttempt);
    }
}
