import { io } from "socket.io-client";
import config from "../../public/config";

// Shared Socket.IO client for the Vue app
// Uses same apiurl as the existing frontend config
const socket = io(config.apiurl, {
  transports: ["websocket", "polling"],
  withCredentials: true,
});

export default socket;
