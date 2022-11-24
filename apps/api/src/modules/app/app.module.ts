import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from 'nestjs-prisma';
import { UserModule } from '../user/user.module';
import { ScheduleModule } from '@nestjs/schedule';
import { FlagsmithModule } from '../flagsmith/flagsmith.module';
import { FlagsmithService } from '../flagsmith/flagsmith.service';
import { DigitalTwinModule } from '../digitaltwin/digitaltwin.module';
import { LoginModule } from '../login/login.module';
import { SignModule } from '../sign/sign.module';
import { JsonBodyMiddleware } from '../../middleware/JsonBodyMiddleware';

@Module({
    imports: [
        ConfigModule.forRoot({}),
        PrismaModule.forRoot({ isGlobal: true }),
        ScheduleModule.forRoot(),
        UserModule,
        FlagsmithModule,
        DigitalTwinModule,
        LoginModule,
        SignModule,
    ],
    controllers: [AppController],
    providers: [AppService, FlagsmithService],
})
export class AppModule implements NestModule {
    public configure(consumer: MiddlewareConsumer): void {
        consumer.apply(JsonBodyMiddleware).forRoutes('*');
    }
}
