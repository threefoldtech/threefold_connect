import { Injectable } from '@nestjs/common';
import { UserService } from '../user/user.service';
import { UserGateway } from '../user/user.gateway';
import { BadRequestException, NotFoundException } from '../../exceptions';
import { verifyMessage } from '../../utils/crypto.utils';
import { decodeBase64 } from 'tweetnacl-util';
import { SignedSignAttemptDto } from './dtos/sign.dto';

@Injectable()
export class SignService {
    constructor(private readonly userService: UserService, private readonly userGateway: UserGateway) {}

    async handleSignedSignAttempt(data: string): Promise<void> {
        const signedSignAttempt: SignedSignAttemptDto = JSON.parse(JSON.stringify(data));

        const username = signedSignAttempt.doubleName;

        const user = await this.userService.findByUsername(username);
        if (!user) {
            throw new NotFoundException('User not found');
        }

        const signedData = verifyMessage(decodeBase64(signedSignAttempt.signedAttempt), decodeBase64(user.publicKey));
        if (!signedData) {
            throw new BadRequestException('Signature mismatch');
        }

        let room = JSON.parse(signedData)['randomRoom'].toLowerCase();
        if (!room) {
            room = username.toLowerCase();
        }

        await this.userGateway.emitSignedSignAttempt(room, signedSignAttempt);
    }
}
