import { Body, Controller, Get, HttpStatus, Param, Post, Put, Res } from '@nestjs/common';
import { DigitalTwinService } from './digitaltwin.service';
import {
    CreatedDigitalTwinDto,
    CreateDigitalTwinDto,
    DigitalTwinDto,
    UpdatedDigitalTwinDto,
    UpdateDigitalTwinIpDto,
    UsernameDto,
} from 'shared-types';

@Controller('digitaltwin')
export class DigitalTwinController {
    constructor(private readonly digitalTwinService: DigitalTwinService) {}

    @Post('')
    async create(@Body() data: CreateDigitalTwinDto, @Res() res): Promise<CreatedDigitalTwinDto> {
        const userId = await this.digitalTwinService.create(data);

        if (!userId) return res.status(HttpStatus.NO_CONTENT).send();
        return userId;
    }

    @Put(':username/ip')
    async update(
        @Param('') username: UsernameDto,
        @Body() data: UpdateDigitalTwinIpDto
    ): Promise<UpdatedDigitalTwinDto> {
        return await this.digitalTwinService.updateYggdrasilOfTwin(username.username, data);
    }

    @Get('')
    async findAll(): Promise<DigitalTwinDto[]> {
        return await this.digitalTwinService.findAll();
    }

    @Get(':username')
    async findByUsername(@Param('') username: UsernameDto): Promise<DigitalTwinDto[]> {
        return await this.digitalTwinService.findByUsername(username.username, true);
    }

    @Get(':username/:appId')
    async findByUsernameAndAppId(
        @Param('') username: UsernameDto,
        @Param('appId') appId: string
    ): Promise<DigitalTwinDto> {
        return await this.digitalTwinService.findByUsernameAndAppId(username.username, appId, true);
    }
}
