import vm from '../main.js'

export default {

  emit (type, message) {
    if (vm) {
      vm.$socket.emit(type, message)
    } else {
      setTimeout(() => {
        this.emit(type, message)
      }, 100)
    }
  }

}
