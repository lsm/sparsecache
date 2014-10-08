
var SparseCache = require('sparsecache').SparseCache;

var x = 0;

var cache =  new SparseCache({pgm:'epgm://226.0.0.0:5555'});
setInterval(function(){

  cache.set('xxx', x++);

}, 500);
