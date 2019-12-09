import vm from '../main.js'

export default {
  emit (type, message) {
    console.log(`emit`)
    // console.log(JSON.stringify(vm))
    if (vm) {
      console.log(type, message)

      vm.$socket.emit(type, message)
    } else {
      setTimeout(() => {
        console.log(`WAIT TO EMIT`)
        this.emit(type, message)
      }, 100)
    }
  }
}
