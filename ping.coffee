zmq = require 'zmq'


server = 'tcp://192.168.1.141:5555'

socket = zmq.socket 'req'
socket.identity = 'ping' + process.pid

socket.connect server

socket.on 'message', (msg) ->
  console.log msg.toString()

socket.on 'error', (error) ->
  console.log error

setInterval () ->
  msg = (new Date).getTime()
  socket.send msg
  console.log msg
, 1000