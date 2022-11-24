import { Injectable } from '@nestjs/common';
import * as flagsmith from 'flagsmith-nodejs';

@Injectable()
export class FlagsmithService {
    constructor() {
        flagsmith.init({
            environmentID: process.env.FLAGSMITH_API_KEY,
            api: process.env.FLAGSMITH_URL,
        });
    }

    hasFeature(name: string) {
        return flagsmith.hasFeature(name);
    }

    getFeature(name: string) {
        return flagsmith.getValue(name);
    }

    async isInMaintenance(): Promise<boolean> {
        return await this.hasFeature('maintenance');
    }

    async getMinimumVersions() {
        return await this.getFeature('minimum-version');
    }

    async getEnvironmentVariables() {
        return await flagsmith.getFlags();
    }
}
