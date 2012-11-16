###
Module dependencies
###
zmq = require 'zmq'
msgpack = require 'msgpack'
{LRU} = require 'lru'
{EventEmitter} = require 'events'
os = require 'os'


###
Export `SparseCache`
###
exports.SparseCache = SparseCache

###
Class `SparseCache`
###
class SparseCache extends EventEmitter
	constructor: (@options={}) ->
    @cache = new LRU(@options.max ? 1000)
    @connect @options.pgm

	connect: (pgm="epgm://225.0.0.0:5555") ->
    # create publish socket
    @pubSocket = zmq.socket 'pub'
    @pubSocket.identity = os.hostname() + "_pub_" + process.pid
    @pubSocket.connect pgm
    
    # create subscirbe socket
    @subSocket = zmq.socket 'sub'
    @subSocket.identity = os.hostname() + "_sub_" + process.pid
    # subscribe to all topics
    @subSocket.setsockopt('_subscribe', new Buffer '')
    @subSocket.connect pgm

    # handle broadcasted cache event
    @subSocket.on 'message', (msg) =>
      msg = msgpack.unpack(msg)
      event = msg[0]
      switch event
        when "set" then @_set(msg[1], msg[2])
        when "remove" then @_remove(msg[1])
    
  _set: (key, value) ->
    @cache.set(key, value) 

  set: (key, value) ->
    msg = msgpack.pack(['set', key, value])
    @pubSocket.send msg

  get: (key) ->
    @cache.get(key)

  _remove: (key) ->    
    @cache.remove(key)

  remove:(key) ->
    msg = msgpack.pack ['remove', key]
    @pubSocket.send msg
  

###
sc = new SparseCache

sc.subSocket.on 'message', (data) ->
  # console.log @identity, ' received: ', data.toString()
  console.log sc.get 'test key'

sc2 = new SparseCache
val = 0
setInterval () ->
  sc2.set 'test key', {a: ++val}
, 1000

###

