import { Injectable } from '@nestjs/common';
import { PrismaService } from 'nestjs-prisma';
import { CreatedUserDto, CreateUserDto } from 'shared-types';
import { BadRequestException, NotFoundException } from '../../exceptions';
import { findUserByPublicKeyQuery, findUserByUsernameQuery } from './queries/user.queries';
import { User as UserModel } from '@prisma/client';
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

    async findByUsername(username: string, withException = false): Promise<UserDto> {
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

    async create(user: CreateUserDto): Promise<CreatedUserDto> {
        const username = user.username.toLowerCase().trim();
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
            data: { username: username, mainPublicKey: publicKey },
        });

        return {
            userId: createdUser.userId,
        };
    }

    async doesUserExist(username: string): Promise<boolean> {
        const user = await this._prisma.user.findUnique(findUserByUsernameQuery(username));
        return !!user;
    }
}
