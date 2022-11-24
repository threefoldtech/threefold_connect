import { IsNotEmpty, IsString, MaxLength, MinLength, Validate } from 'class-validator';
import { EndsWith3Bot } from 'api/src/validators/index';

export class SignedLoginAttemptDto {
    @IsString()
    @IsNotEmpty()
    state: string;

    @IsString()
    @IsNotEmpty()
    room: string;

    @IsString()
    @IsNotEmpty()
    appId: string;

    selectedImageId: number | null;

    scopeData: any;
}

export class LoginAttemptDto {
    @Validate(EndsWith3Bot)
    @MinLength(6)
    @MaxLength(55)
    @IsString()
    @IsNotEmpty()
    doubleName: string;

    @IsNotEmpty()
    signedAttempt: SignedLoginAttemptDto;
}
