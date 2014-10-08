
var SparseCache = require('sparsecache').SparseCache;

var cache = new SparseCache({pgm: 'epgm://226.0.0.0:6666'});

var key = 'recent_4770101';

cache.set(key, '20121126');

var v = cache.get(key);

console.log(v);

cache.close()