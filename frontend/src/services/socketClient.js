import { io } from "socket.io-client";
import config from "../../public/config";
import store from "../store";

// Shared Socket.IO client for the Vue app
// Uses same apiurl as the existing frontend config
const socket = io(config.apiurl, {
  transports: ["websocket", "polling"],
  withCredentials: true,
});

// Recreate vue-socket-io's SOCKET_* → Vuex action mapping
socket.on("connect", () => {
  store.dispatch("SOCKET_connect");
});

socket.on("nameknown", () => {
  store.dispatch("SOCKET_nameknown");
});

socket.on("namenotknown", () => {
  store.dispatch("SOCKET_namenotknown");
});

socket.on("cancelLogin", () => {
  store.dispatch("SOCKET_cancelLogin");
});

socket.on("cancelSign", () => {
  store.dispatch("SOCKET_cancelSign");
});

socket.on("signedAttempt", (data) => {
  store.dispatch("SOCKET_signedAttempt", data);
});

socket.on("signedSignDataAttempt", (data) => {
  store.dispatch("SOCKET_signedSignDataAttempt", data);
});

socket.on("phoneverified", () => {
  store.dispatch("SOCKET_phoneverified");
});

socket.on("emailverified", () => {
  store.dispatch("SOCKET_emailverified");
});

export default socket;
