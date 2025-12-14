import axios, { AxiosResponse } from 'axios'
import config from '@/config'

interface UserData {
  doubleName: string
  [key: string]: any
}

interface UserService {
  getUserData(doubleName: string): Promise<AxiosResponse<UserData>>
}

const userService: UserService = {
  getUserData(doubleName: string): Promise<AxiosResponse<UserData>> {
    return axios.get(`${config.apiurl}api/users/${doubleName}`)
  }
}

export default userService
