import { Injectable } from '@nestjs/common';
import { PrismaService } from 'nestjs-prisma';
import { UserService } from '../user/user.service';
import { BadRequestException, NotFoundException } from '../../exceptions';
import { decodeBase64 } from 'tweetnacl-util';
import {
    CreatedDigitalTwinDto,
    CreateDigitalTwinDto,
    DigitalTwinDetailsDto,
    DigitalTwinDto,
    UpdatedDigitalTwinDto,
    UpdateDigitalTwinIpDto,
    VerifiedCreateDigitalTwinDto,
} from 'shared-types';
import {
    findAllTwinsByUsernameQuery,
    findAllTwinsQuery,
    findTwinByUsernameAndAppIdQuery,
    getTwinByPublicKeyQuery,
    updateTwinYggdrasilIpQuery,
} from './queries/digitaltwin.queries';
import { verifyMessage } from '../../utils/crypto.utils';

@Injectable()
export class DigitalTwinService {
    constructor(private _prisma: PrismaService, private readonly userService: UserService) {}

    async create(createDigitalTwin: CreateDigitalTwinDto): Promise<CreatedDigitalTwinDto> {
        const user = await this.userService.findByUsername(createDigitalTwin.username);
        if (!user) {
            console.error(`Username ${createDigitalTwin.username} doesn't exist`);
            throw new NotFoundException(`Username ${createDigitalTwin.username} doesn't exist`);
        }

        const signedData = verifyMessage(decodeBase64(createDigitalTwin.signedData), decodeBase64(user.publicKey));
        if (!signedData) {
            console.error(`Signature mismatch for ${user.publicKey} with data ${createDigitalTwin.signedData}`);
            throw new BadRequestException(
                `Signature mismatch for ${user.publicKey} with data ${createDigitalTwin.signedData}`
            );
        }

        const verifiedData = JSON.parse(signedData) as VerifiedCreateDigitalTwinDto;
        const existingTwins = await this.findByUsernameAndAppId(user.doublename, verifiedData.appId);
        if (existingTwins) {
            // When record is already created => just early return and don't make new database record
            console.log(`Combination of username ${user.doublename} and appId ${verifiedData.appId} already exists`);
            return;
        }

        const publicKeyExists = await this.doesPublicKeyExists(verifiedData.derivedPublicKey);
        if (publicKeyExists) {
            // When public key already exists => just early return and don't make new database record
            console.log(`Derived public key ${verifiedData.derivedPublicKey} already exists`);
            return;
        }

        const createdTwin = await this._prisma.digitalTwin.create({
            data: {
                derivedPublicKey: verifiedData.derivedPublicKey,
                appId: verifiedData.appId,
                userId: user.userId,
            },
        });

        return {
            twinId: createdTwin.id,
        };
    }

    async updateYggdrasilOfTwin(
        username: string,
        updateTwinDto: UpdateDigitalTwinIpDto
    ): Promise<UpdatedDigitalTwinDto> {
        console.log('Username: ', username);
        console.log('AppId: ', updateTwinDto.appId);

        const twin = await this.findByUsernameAndAppId(username, updateTwinDto.appId);
        if (!twin) {
            console.error(`There is no twin named ${username} with appId ${updateTwinDto.appId}`);
            throw new NotFoundException(`There is no twin named ${username} with appId ${updateTwinDto.appId}`);
        }

        const verifiedIp = verifyMessage(
            decodeBase64(updateTwinDto.signedYggdrasilIp),
            decodeBase64(twin.derivedPublicKey)
        );
        console.log(verifiedIp);

        const updatedTwin = await this.update(verifiedIp, twin.twinId);
        return {
            twinId: updatedTwin.id,
        };
    }

    async update(yggdrasilIp: string, twinId: string) {
        return this._prisma.digitalTwin.update(updateTwinYggdrasilIpQuery(yggdrasilIp, twinId));
    }

    async findAll(): Promise<DigitalTwinDto[]> {
        const t = await this._prisma.digitalTwin.findMany(findAllTwinsQuery);

        return t.map(twin => {
            return {
                derivedPublicKey: twin.derivedPublicKey,
                location: twin.yggdrasilIp,
                appId: twin.appId,
                username: twin.user.username,
            };
        });
    }

    async doesPublicKeyExists(derivedPublicKey: string): Promise<boolean> {
        const twin = await this._prisma.digitalTwin.findMany(getTwinByPublicKeyQuery(derivedPublicKey));
        return !(!twin || twin.length == 0);
    }

    async findByUsername(username: string, withException = false): Promise<DigitalTwinDetailsDto[]> {
        const user = await this.userService.findByUsername(username);
        if (!user && withException) {
            console.error(`Username ${username} does not exists`);
            throw new NotFoundException(`Username ${username} does not exists`);
        }

        if (!user) return null;

        const t = await this._prisma.digitalTwin.findMany(findAllTwinsByUsernameQuery(user.userId));
        if ((!t || t.length == 0) && withException) {
            console.error(`No twins found for username ${username}`);
            throw new NotFoundException(`No twins found for username ${username}`);
        }

        if (!t || t.length == 0) return null;

        return t.map(twin => {
            return {
                twinId: twin.id,
                location: twin.yggdrasilIp,
                appId: twin.appId,
                username: twin.user.username,
                derivedPublicKey: twin.derivedPublicKey,
            };
        });
    }

    async findByUsernameAndAppId(
        username: string,
        appId: string,
        withException = false
    ): Promise<DigitalTwinDetailsDto> {
        const user = await this.userService.findByUsername(username);
        if (!user && withException) {
            console.error(`Username ${username} does not exists`);
            throw new NotFoundException(`Username ${username} does not exists`);
        }

        if (!user) return null;

        const t = await this._prisma.digitalTwin.findFirst(findTwinByUsernameAndAppIdQuery(username, appId));
        if (!t && withException) {
            console.error(`No twins found for username ${username} in combination with ${appId}`);
            throw new NotFoundException(`No twins found for username ${username} in combination with ${appId}`);
        }

        if (!t) return null;

        return {
            twinId: t.id,
            location: t.yggdrasilIp,
            appId: t.appId,
            username: t.user.username,
            derivedPublicKey: t.derivedPublicKey,
        };
    }
}
