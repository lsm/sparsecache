{SparseCache} = require './lib.coffee'
os = require 'os'

options = {
  peers: [
    "tcp://192.168.1.141:5555",
    "tcp://192.168.1.107:5555"
  ]
}

# options = {pgm: 'epgm://225.0.0.0:5555'}

# console.log os.getNetworkInterfaces();

cache = new SparseCache options

key = 'test key'

v = 0;

cache.on 'get', (obj) ->
  console.log obj

cache.rget key


setInterval () ->
  # cache.rget remoteKey
  _v = os.hostname() + '_' + ++v
  cache.set key, v
  console.log "set key: #{key}, value: #{v}"
, 1000
