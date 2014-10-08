zmq = require 'zmq'


server = 'tcp://192.168.1.141:5555'

socket = zmq.socket 'rep'
socket.identity = 'pong' + process.pid

socket.bind server, (error) ->
  if error then throw error

  socket.on 'message', (msg) ->
    msg = msg.toString()
    console.log msg
    socket.send 'server: ' + msg

  socket.on 'error', (error) ->
    console.log error