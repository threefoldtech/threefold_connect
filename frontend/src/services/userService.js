import axios from "axios";
import config from "../../public/config";

export default {
    getUserData(doubleName) {
        return axios.get(`${config.apiurl}api/users/${doubleName}`);
    },
};