###
Module dependencies
###
zmq = require 'zmq'
msgpack = require 'msgpack'
{LRU} = require 'lru'
{EventEmitter} = require 'events'
os = require 'os'


###
Class `SparseCache`
###
exports.SparseCache = class SparseCache extends EventEmitter
	constructor: (@options={}) ->
    @cache = new LRU(@options.max ? 1000)
    @identity = os.hostname() + "_" + process.pid

    if @options.peers 
      @selfPeer = @getSelfPeer @options.peers
      if @selfPeer and @options.bindSelf
        # create respond socket
        @serverSocket = zmq.socket 'rep'
        # bind the socket to local network address
        @serverSocket.bind @selfPeer, (err) =>
          if err then throw err
          # serverSocket gets event 'set', 'remove' and 'rget'
          # send event 'get'
          @serverSocket.on 'message', (msg) =>
            @handleMessage msg, @serverSocket

        # remove self from peer list
        @options.peers = @options.peers.filter (peer) =>
          return true if @selfPeer isnt peer
      # connect to rest of peers
      @connectPeers @options.peers

    else
      throw new Error('No network address supplied')

  getSelfPeer: (peers) ->
    for peer in peers
      for device, addresses of os.networkInterfaces()
        for address in addresses
          r = new RegExp(address.address)        
          return peer if r.test peer
            

  connectPeers: (peers) ->
    @peers = []
    for peer in peers
      # @connectPeer peer unless @options.server is peer
      peerSocket = zmq.socket 'req'
      peerSocket.connect peer
      peerSocket.on 'message', (msg) =>
        @handleMessage msg, peerSocket
      @peers.push peerSocket


  handleMessage: (msg, socket) ->
    msg = msgpack.unpack(msg)
    event = msg[0]
    switch event
      # server events (requests from clients)
      when "set" 
        @_set msg[1], msg[2]
        @emit "set", {key: msg[1], value: msg[2]}
        socket.send msgpack.pack ['ok']
      when "remove"
        @_remove msg[1]
        @emit "remove", msg[1]
        socket.send msgpack.pack ['ok']
      when "rget"
        value = @get msg[1]
        getMsg = ['get', msg[1], value ? null, msg[2]]
        socket.send msgpack.pack getMsg
      # client events (responses from server)
      when "get" 
        if msg[3] is @identity
          @emit "get", {key: msg[1], value: msg[2]}

  send: (msg) ->
    msg = msgpack.pack msg
    for peerSocket in @peers
      peerSocket.send msg
    return @

  _set: (key, value) ->
    @cache.set(key, value)

  set: (key, value) ->
    @_set key, value
    @send ['set', key, value]
    return @

  get: (key) ->
    @cache.get(key)

  rget: (key) ->
    msg = msgpack.pack 
    @send ['rget', key, @identity]
    return @

  _remove: (key) ->    
    @cache.remove(key)

  remove: (key) ->
    @_remove key
    @send ['remove', key]

  close: () ->
    @pubSocket.close()
    @subSocket.close()

  connectPgm: (pgm="epgm://225.0.0.0:5555") ->
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
    @subSocket.on 'message', (data) =>
      @handleMessage data  


# sc = new SparseCache

# sc.subSocket.on 'message', (data) ->
# #   console.log @identity, ' received: ', data.toString()
#   console.log sc.get 'test key'

# sc2 = new SparseCache
# val = 0
# setInterval () ->
#   sc2.set 'test key', {a: ++val}
# , 1000



