import { Module } from '@nestjs/common';
import { FlagsmithService } from './flagsmith.service';

@Module({
    providers: [FlagsmithService],
    exports: [FlagsmithService],
})
export class FlagsmithModule {}
