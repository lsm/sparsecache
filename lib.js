// Generated by CoffeeScript 1.4.0

/*
Module dependencies
*/


(function() {
  var EventEmitter, LRU, SparseCache, msgpack, os, zmq,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  zmq = require('zmq');

  msgpack = require('msgpack');

  LRU = require('lru').LRU;

  EventEmitter = require('events').EventEmitter;

  os = require('os');

  /*
  Export `SparseCache`
  */


  exports.SparseCache = SparseCache;

  /*
  Class `SparseCache`
  */


  SparseCache = (function(_super) {

    __extends(SparseCache, _super);

    function SparseCache(options) {
      var _ref;
      this.options = options != null ? options : {};
      this.cache = new LRU((_ref = this.options.max) != null ? _ref : 1000);
      this.connect(this.options.pgm);
    }

    SparseCache.prototype.connect = function(pgm) {
      var _this = this;
      if (pgm == null) {
        pgm = "epgm://225.0.0.0:5555";
      }
      this.pubSocket = zmq.socket('pub');
      this.pubSocket.identity = os.hostname() + "_pub_" + process.pid;
      this.pubSocket.connect(pgm);
      this.subSocket = zmq.socket('sub');
      this.subSocket.identity = os.hostname() + "_sub_" + process.pid;
      this.subSocket.setsockopt('_subscribe', new Buffer(''));
      this.subSocket.connect(pgm);
      return this.subSocket.on('message', function(msg) {
        var event;
        msg = msgpack.unpack(msg);
        event = msg[0];
        switch (event) {
          case "set":
            return _this._set(msg[1], msg[2]);
          case "remove":
            return _this._remove(msg[1]);
        }
      });
    };

    SparseCache.prototype._set = function(key, value) {
      return this.cache.set(key, value);
    };

    SparseCache.prototype.set = function(key, value) {
      var msg;
      msg = msgpack.pack(['set', key, value]);
      return this.pubSocket.send(msg);
    };

    SparseCache.prototype.get = function(key) {
      return this.cache.get(key);
    };

    SparseCache.prototype._remove = function(key) {
      return this.cache.remove(key);
    };

    SparseCache.prototype.remove = function(key) {
      var msg;
      msg = msgpack.pack(['remove', key]);
      return this.pubSocket.send(msg);
    };

    return SparseCache;

  })(EventEmitter);

  /*
  sc = new SparseCache
  
  sc.subSocket.on 'message', (data) ->
    # console.log @identity, ' received: ', data.toString()
    console.log sc.get 'test key'
  
  sc2 = new SparseCache
  val = 0
  setInterval () ->
    sc2.set 'test key', {a: ++val}
  , 1000
  */


}).call(this);
