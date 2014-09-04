(function() {
  var CoffeeScript, compileCoffeeScript, crypto, fs, getCachePath, getCachedJavaScript, path, requireCoffeeScript;

  crypto = require('crypto');

  path = require('path');

  CoffeeScript = require('coffee-script');

  fs = require('fs-plus');

  getCachePath = function(coffeeCacheDir, coffee) {
    var digest;
    digest = crypto.createHash('md5').update(coffee, 'utf8').digest('hex');
    return path.join(coffeeCacheDir, "" + digest + ".js");
  };

  getCachedJavaScript = function(cachePath) {
    if (fs.isFileSync(cachePath)) {
      try {
        return fs.readFileSync(cachePath, 'utf8');
      } catch (_error) {}
    }
  };

  compileCoffeeScript = function(coffee, filePath, cachePath) {
    var js;
    js = CoffeeScript.compile(coffee, {
      filename: filePath
    }).js;
    try {
      fs.writeFileSync(cachePath, js);
    } catch (_error) {}
    return js;
  };

  requireCoffeeScript = function(coffeeCacheDir) {
    return function(module, filePath) {
      var cachePath, coffee, js, _ref;
      coffee = fs.readFileSync(filePath, 'utf8');
      cachePath = getCachePath(coffeeCacheDir, coffee);
      js = (_ref = getCachedJavaScript(cachePath)) != null ? _ref : compileCoffeeScript(coffee, filePath, cachePath);
      return module._compile(js, filePath);
    };
  };

  module.exports = {
    register: function(cacheDir) {
      var coffeeCacheDir;
      coffeeCacheDir = path.join(cacheDir, 'coffee');
      return Object.defineProperty(require.extensions, '.coffee', {
        writable: false,
        value: requireCoffeeScript(coffeeCacheDir)
      });
    }
  };

}).call(this);
