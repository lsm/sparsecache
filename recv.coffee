{SparseCache} = require './lib.coffee'
os = require 'os'

options =
  peers: [
    "tcp://192.168.1.141:5555",
    "tcp://192.168.1.107:5555"
  ]

# options = {pgm: 'epgm://225.0.0.0:5555'}

cache = new SparseCache options

cache.on 'set', (args) ->
  console.log args 