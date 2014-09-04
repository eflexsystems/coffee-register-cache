crypto = require 'crypto'
path = require 'path'

CoffeeScript = require 'coffee-script'
fs = require 'fs-plus'

getCachePath = (coffeeCacheDir, coffee) ->
  digest = crypto.createHash('md5').update(coffee, 'utf8').digest('hex')
  path.join(coffeeCacheDir, "#{digest}.js")

getCachedJavaScript = (cachePath) ->
  if fs.isFileSync(cachePath)
    try
      fs.readFileSync(cachePath, 'utf8')

compileCoffeeScript = (coffee, filePath, cachePath) ->
  {js} = CoffeeScript.compile(coffee, filename: filePath)
  try
    fs.writeFileSync(cachePath, js)
  js

requireCoffeeScript = (coffeeCacheDir) ->
  (module, filePath) ->
    coffee = fs.readFileSync(filePath, 'utf8')
    cachePath = getCachePath(coffeeCacheDir, coffee)
    js = getCachedJavaScript(cachePath) ? compileCoffeeScript(coffee, filePath, cachePath)
    module._compile(js, filePath)

module.exports =
  register: (cacheDir) ->
    coffeeCacheDir = path.join(cacheDir, 'coffee')
    Object.defineProperty(require.extensions, '.coffee', {
      writable: false
      value: requireCoffeeScript(coffeeCacheDir)
    })
