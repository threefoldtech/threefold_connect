import { MessageBody, SubscribeMessage, WebSocketGateway, WebSocketServer } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

import {
    ISocketCheckName,
    ISocketJoin,
    ISocketLeave,
    ISocketLogin,
    ISocketSign,
    LoginAttemptDto,
    SocketEvents,
    SocketTypes,
} from 'shared-types';
import { UserService } from './user.service';
import { SignedSignAttemptDto } from '../sign/dtos/sign.dto';

interface IQueueMessage {
    event: string;
    data: Object;
}

@WebSocketGateway({ cors: true })
export class UserGateway {
    constructor(private _userService: UserService) {}

    private _messageQueue = {};
    private _socketRoom = {};

    @WebSocketServer()
    server: Server;

    @SubscribeMessage(SocketTypes.CHECK_NAME)
    async checkName(@MessageBody() data: ISocketCheckName) {
        console.log('[SOCKET RECEIVE]: CHECK NAME: ', data.username);
        const exist = await this._userService.doesUserExist(data.username);
        return this.server.emit(exist ? SocketTypes.NAME_KNOWN : SocketTypes.NAME_UNKNOWN);
    }

    @SubscribeMessage(SocketTypes.LOGIN)
    async handleLogin(@MessageBody() data: ISocketLogin) {
        if (!data.encryptedLoginAttempt) return;
        console.log('[SOCKET RECEIVE]: LOGIN: ', data.username);

        data.type = SocketEvents.LOGIN;
        data.created = new Date().getTime();

        const m: IQueueMessage = {
            event: SocketEvents.LOGIN,
            data: data,
        };

        this._emitOrQueue(m, data.username);
    }

    @SubscribeMessage(SocketTypes.SIGN)
    async handleSign(@MessageBody() data: ISocketSign) {
        if (!data.encryptedSignAttempt) return;
        console.log('[SOCKET RECEIVE]: LOGIN: ', data.username);

        data.type = SocketEvents.SIGN;
        data.created = new Date().getTime();

        const m: IQueueMessage = {
            event: SocketEvents.SIGN,
            data: data,
        };

        this._emitOrQueue(m, data.username);
    }

    @SubscribeMessage(SocketTypes.JOIN)
    async handleJoinRoom(client: Socket, data: ISocketJoin) {
        if (client.id == null) return;
        if (data.room == null) return;

        console.log('[SOCKET RECEIVE]: JOIN: ', data.room.toLowerCase());

        const socketId = client.id;

        const room = data.room.toLowerCase();

        console.log('User ', room, ' joined the room');
        client.join(room);

        // User joined + we are sure he can get notifications inside the app
        if (data.app) {
            if (Object.values(this._socketRoom).includes(room)) {
                const key = Object.keys(this._socketRoom).find(key => this._socketRoom[key] === room);
                client.leave(room);
                delete this._socketRoom[key];
            }

            this._socketRoom[socketId] = room;
            console.log(this._socketRoom);
        }

        if (Object.keys(this._messageQueue).includes(room) && Object.values(this._socketRoom).includes(room)) {
            this._sendQueuedMessages(room);
        }
    }

    @SubscribeMessage(SocketTypes.LEAVE)
    async handleLeaveRoom(client: Socket, data: ISocketLeave) {
        if (client.id == null) return;
        if (data.room == null) return;

        console.log('[SOCKET RECEIVED]: LEAVE: ', data.room);

        const socketId = client.id;

        if (Object.keys(this._socketRoom).includes(socketId)) {
            const room = this._socketRoom[socketId];
            this._socketRoom[socketId] = null;

            console.log('User ', room, ' left the room');
            client.leave(room);
        }
    }

    @SubscribeMessage(SocketTypes.DISCONNECT)
    async handleDisconnect(client: Socket) {
        if (client.id == null) return;

        console.log('[SOCKET RECEIVED]: DISCONNECT: ', client.id);

        const socketId = client.id;
        if (Object.keys(this._socketRoom).includes(socketId)) {
            const room = this._socketRoom[socketId];
            this._socketRoom[socketId] = null;

            console.log('User ', room, ' left the room');
            client.leave(room);
        }
    }

    async emitCancelLoginAttempt(username: string): Promise<void> {
        console.log('[SOCKET EMIT]: CANCEL LOGIN: ', username);
        this.server.to(username).emit(SocketTypes.LOGIN_CANCEL, { scanned: true });
    }

    async emitCancelSignAttempt(username: string): Promise<void> {
        console.log('[SOCKET EMIT]: CANCEL SIGN: ', username);
        this.server.to(username).emit(SocketTypes.SIGN_CANCEL, { scanned: true });
    }

    async emitEmailVerified(username: string): Promise<void> {
        console.log('[SOCKET EMIT]: EMAIL VERIFIED: ', username);
        this.server.to(username).emit(SocketTypes.EMAIL_VERIFIED, '');
    }

    async emitSmsVerified(username: string): Promise<void> {
        console.log('[SOCKET EMIT]: PHONE VERIFIED: ', username);
        this.server.to(username).emit(SocketTypes.PHONE_VERIFIED, '');
    }

    async emitSignedLoginAttempt(room: string, data: LoginAttemptDto): Promise<void> {
        console.log('[SOCKET EMIT]: SIGNED LOGIN ATTEMPT: ', data.doubleName);
        this.server.to(room).emit(SocketTypes.LOGIN_CALLBACK, data);
    }

    async emitSignedSignAttempt(room: string, data: SignedSignAttemptDto): Promise<void> {
        console.log('[SOCKET EMIT]: SIGNED SIGN ATTEMPT: ', data.doubleName);
        this.server.to(room).emit(SocketTypes.SIGN_CALLBACK, data);
    }

    private _sendQueuedMessages(room: string) {
        console.log('Firing queue for ', room);

        this._messageQueue[room].forEach((m: IQueueMessage) => {
            this.server.to(room).emit(m.event, m.data);
        });

        this._messageQueue[room] = [];
    }

    private _emitOrQueue(message: IQueueMessage, room: string) {
        if (Object.values(this._socketRoom).includes(room)) {
            console.log('Sending message to ', room);
            return this.server.to(room).emit(message.event, message.data);
        }

        console.log('Putting message in queue');
        let q = this._messageQueue[room] ? this._messageQueue[room] : [];
        q.push(message);

        return (this._messageQueue[room] = q);
    }
}
