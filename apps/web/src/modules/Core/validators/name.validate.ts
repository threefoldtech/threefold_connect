export interface INameValidation {
    error: string | null;
    valid: boolean;
}

export const validateName = (name: string): INameValidation => {
    if (!name) {
        return {
            error: 'Name is required',
            valid: false,
        };
    }

    if (name.length <= 0) {
        return {
            error: 'Name is required',
            valid: false,
        };
    }

    if (name.length > 50) {
        return {
            error: 'Name must be less than 50 characters',
            valid: false,
        };
    }

    const regEx = new RegExp(/^(\w+)$/);
    const isValid = regEx.test(name);

    if (!isValid) {
        return {
            error: 'Name must be alphanumeric',
            valid: false,
        };
    }

    return { error: null, valid: true };
};
