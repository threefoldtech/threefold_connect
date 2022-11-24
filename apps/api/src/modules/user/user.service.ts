import { Injectable } from '@nestjs/common';
import { PrismaService } from 'nestjs-prisma';
import { AuthorizationHeaders, CreatedUserDto, CreateUserDto, UpdatedUserDto, UserIntentions } from 'shared-types';
import { BadRequestException, ExpectationFailedException, NotFoundException } from '../../exceptions';
import { decodeBase64 } from 'tweetnacl-util';
import { findUserByPublicKeyQuery, findUserByUsernameQuery, updateEmailOfUserQuery } from './queries/user.queries';
import { verifyMessage } from '../../utils/crypto.utils';
import { User as UserModel } from '@prisma/client';
import { isBase64 } from 'class-validator';
import { UserDto } from 'shared-types/src/user/dtos/user.dtos';

@Injectable()
export class UserService {
    constructor(private _prisma: PrismaService) {}

    async findAll(): Promise<UserDto[]> {
        const users = await this._prisma.user.findMany();
        return users.map((user: UserModel) => {
            return {
                doublename: user.username,
                publicKey: user.mainPublicKey,
            };
        });
    }

    async findByUsername(username: string, withException: boolean = false): Promise<UserDto> {
        const user = await this._prisma.user.findUnique(findUserByUsernameQuery(username));
        if (!user && !withException) {
            console.error(`Username ${username} not found`);
            return null;
        }
        if (!user && withException) {
            throw new NotFoundException(`Username ${username} not found`);
        }

        if (withException) {
            return {
                doublename: user.username,
                publicKey: user.mainPublicKey,
            };
        }

        return {
            userId: user.userId,
            doublename: user.username,
            publicKey: user.mainPublicKey,
        };
    }

    async findByPublicKey(publicKey: string, withException = false): Promise<UserDto> {
        const user = await this._prisma.user.findUnique(findUserByPublicKeyQuery(publicKey));
        if (!user && !withException) {
            console.error(`PublicKey ${publicKey} not found`);
            return null;
        }
        if (!user && withException) {
            throw new NotFoundException(`PublicKey ${publicKey} not found`);
        }

        return {
            doublename: user.username,
            publicKey: user.mainPublicKey,
        };
    }

    async changeEmail(username: string, email: string, requestHeaders: string): Promise<UpdatedUserDto> {
        const headers = JSON.parse(JSON.stringify(requestHeaders));

        const signedHeader = headers['jimber-authorization'];
        if (!signedHeader) {
            console.error(`No Jimber Authorization header available for ${username}`);
            throw new ExpectationFailedException(`No Jimber Authorization header available for ${username}`);
        }

        username = username.trim().toLowerCase();
        const user = await this.findByUsername(username);
        if (!user) {
            console.error(`Username ${username} not found`);
            throw new NotFoundException(`Username ${username} not found`);
        }

        if (!isBase64(signedHeader)) {
            console.error(`Signed header ${signedHeader} is not Base64 encoded`);
            throw new ExpectationFailedException(`Signed header ${signedHeader} is not Base64 encoded`);
        }

        const signedData = verifyMessage(decodeBase64(signedHeader), decodeBase64(user.publicKey));
        if (!signedData) {
            console.error(`Signature mismatch for ${user.publicKey}`);
            throw new BadRequestException(`Signature mismatch for ${user.publicKey}`);
        }

        const verifiedHeaders: AuthorizationHeaders = JSON.parse(signedData);
        if (verifiedHeaders.intention != UserIntentions.CHANGE_EMAIL) {
            console.error(`Wrong intention: ${verifiedHeaders.intention}`);
            throw new BadRequestException(`Wrong intention: ${verifiedHeaders.intention}`);
        }

        const updatedUser = await this.updateEmail(user.userId, email);

        return {
            userId: updatedUser.userId,
        };
    }

    async create(user: CreateUserDto): Promise<CreatedUserDto> {
        const username = user.username.toLowerCase().trim();
        const email = user.email.trim();
        const publicKey = user.mainPublicKey;

        const isFound = await this.findByUsername(username);
        if (isFound) {
            console.error(`User ${username} already exists`);
            throw new BadRequestException(`User ${username} already exists`);
        }

        const isFoundByPublicKey = await this.findByPublicKey(user.mainPublicKey);
        if (isFoundByPublicKey) {
            console.error(`PublicKey ${user.mainPublicKey} already exists`);
            throw new BadRequestException(`User ${user.mainPublicKey} already exists`);
        }

        const createdUser = await this._prisma.user.create({
            data: { username: username, email: email, mainPublicKey: publicKey },
        });

        return {
            userId: createdUser.userId,
        };
    }

    async doesUserExist(username: string): Promise<boolean> {
        const user = await this._prisma.user.findUnique(findUserByUsernameQuery(username));
        return !!user;
    }

    async updateEmail(userId: string, email: string) {
        return this._prisma.user.update(updateEmailOfUserQuery(userId, email));
    }
}
