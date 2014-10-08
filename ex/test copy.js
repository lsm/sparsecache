var gm = require('gm');

gm('./test.jpg').identify(function () {
  console.log(arguments);
});