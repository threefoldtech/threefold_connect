import { HttpException, HttpStatus } from '@nestjs/common';

export class ForbiddenException extends HttpException {
    constructor(message: string) {
        super(message, HttpStatus.FORBIDDEN);
    }
}

export class BadRequestException extends HttpException {
    constructor(message: string) {
        super(message, HttpStatus.BAD_REQUEST);
    }
}

export class NotFoundException extends HttpException {
    constructor(message: string) {
        super(message, HttpStatus.NOT_FOUND);
    }
}

export class ExpectationFailedException extends HttpException {
    constructor(message: string) {
        super(message, HttpStatus.EXPECTATION_FAILED);
    }
}

export class ConflictException extends HttpException {
    constructor(message: string) {
        super(message, HttpStatus.CONFLICT);
    }
}
