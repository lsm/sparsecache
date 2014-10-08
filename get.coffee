{SparseCache} = require './lib.coffee'
os = require 'os'

options = {
  peers: [
    "tcp://10.0.0.31:6666",
    "tcp://10.0.0.34:6666",
    "tcp://10.0.0.32:6666",
    "tcp://10.0.0.33:6666"
  ]
}

# options = {pgm: 'epgm://225.0.0.0:5555'}

# console.log os.getNetworkInterfaces();

cache = new SparseCache options

key = 'recent_4770101'

cache.on 'get', (obj) ->
  console.log obj

cache.rget key


# setInterval () ->
#   # cache.rget remoteKey
#   _v = os.hostname() + '_' + ++v
#   cache.set key, v
#   console.log "set key: #{key}, value: #{v}"
# , 1000
