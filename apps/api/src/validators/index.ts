import { ValidationArguments, ValidatorConstraint, ValidatorConstraintInterface } from 'class-validator';

@ValidatorConstraint({ name: 'EndsWith3Bot', async: false })
export class EndsWith3Bot implements ValidatorConstraintInterface {
    validate(text: string, args: ValidationArguments) {
        return text.endsWith('.3bot');
    }

    defaultMessage(args: ValidationArguments) {
        return `Username has to end with .3bot`;
    }
}
