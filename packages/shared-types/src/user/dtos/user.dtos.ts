import { isBase64, IsBase64, IsEmail, IsNotEmpty, IsString, MaxLength, MinLength, Validate } from 'class-validator';
import { EndsWith3Bot } from 'api/src/validators/index';

export class CreateUserDto {
    @IsString()
    @IsNotEmpty()
    @IsEmail()
    email: string;

    @Validate(EndsWith3Bot)
    @MinLength(6)
    @MaxLength(55)
    @IsString()
    @IsNotEmpty()
    username: string;

    @IsString()
    @IsNotEmpty()
    @IsBase64()
    mainPublicKey: string;
}

export class UsernameDto {
    @Validate(EndsWith3Bot)
    @MinLength(6)
    @MaxLength(55)
    @IsString()
    @IsNotEmpty()
    username: string;
}

export class DoubleNameDto {
    @Validate(EndsWith3Bot)
    @MinLength(6)
    @MaxLength(55)
    @IsString()
    @IsNotEmpty()
    doubleName: string;
}

export class PublicKeyDto {
    @IsBase64()
    @IsString()
    @IsNotEmpty()
    publicKey: string;
}

export class ChangeEmailDto {
    @IsString()
    @IsNotEmpty()
    @IsEmail()
    email: string;
}

export type GetUserDto = {
    userId: string;
    username: string;
    mainPublicKey: string;
};

export type UserDto = {
    userId?: string;
    doublename: string;
    publicKey: string;
};

export type CreatedUserDto = {
    userId: string;
};

export type UpdatedUserDto = {
    userId: string;
};
