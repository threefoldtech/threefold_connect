import { IsBase64, IsNotEmpty, IsString, MaxLength, MinLength, Validate } from 'class-validator';
import { EndsWith3Bot } from 'api/src/validators/index';

export class CreateDigitalTwinDto {
    @Validate(EndsWith3Bot)
    @MinLength(6)
    @MaxLength(55)
    @IsString()
    @IsNotEmpty()
    username: string;

    @IsNotEmpty()
    @IsBase64()
    @IsString()
    signedData: string;
}

export class VerifiedCreateDigitalTwinDto {
    @IsNotEmpty()
    @IsBase64()
    @IsString()
    derivedPublicKey: string;

    @IsNotEmpty()
    @IsString()
    appId: string;
}

export class UpdateDigitalTwinIpDto {
    @IsNotEmpty()
    @IsBase64()
    @IsString()
    signedYggdrasilIp: string;

    @IsNotEmpty()
    @IsString()
    appId: string;
}

export interface DigitalTwinDto {
    username: string;
    location: string;
    appId: string;
    derivedPublicKey: string;
}

export interface DigitalTwinDetailsDto extends DigitalTwinDto {
    twinId: string;
}

export interface CreatedDigitalTwinDto {
    twinId: string;
}

export interface UpdatedDigitalTwinDto {
    twinId: string;
}
