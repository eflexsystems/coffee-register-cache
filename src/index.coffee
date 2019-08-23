crypto = require "crypto"
path   = require "path"

CoffeeScript = require "coffeescript"
fs           = require "fs-plus"


debug = Boolean Number process.env.COFFEE_REGISTER_CACHE_DUBEG

log = -> console.log.apply console, arguments if debug


ignoredOptions = [
  "filename"
  "jsPath"
  "sourceRoot"
  "sourceFiles"
  "generatedFile"
]


getRootModule = ( module ) ->

  if module.parent then getRootModule module.parent else module


definedKeysWithoutKeys = ( obj, ignoredKeys ) ->

  key for key, val of obj when val? and key not in ignoredKeys


stringifyOptions = ( options ) ->

  definedSortedKeys = ( definedKeysWithoutKeys options, ignoredOptions ).sort()

  definedAndSortedOptions = {}
  definedAndSortedOptions[ key ] = options[ key ] for key in definedSortedKeys

  JSON.stringify definedAndSortedOptions


getCachePath = ( cacheDir, coffee, options ) ->

  stringifiedOptions = stringifyOptions options

  log "stringifiedOptions:", stringifiedOptions

  digest = crypto
    .createHash "md5"
    .update ( coffee + stringifiedOptions ), "utf8"
    .digest "hex"

  path.join cacheDir, "#{ digest }.js"


getCachedJavaScript = ( cachePath ) ->
  # TODO log error
  try fs.readFileSync cachePath, "utf8" if fs.isFileSync cachePath


compileCoffeeScriptAndCache = ( module, filePath, options, cachePath ) ->

  js = CoffeeScript._compileFile filePath, options

  # TODO log error
  try fs.writeFileSync cachePath, js

  js


requireCoffeeScript = ( cacheDir ) ->

  ( module, filePath ) ->

    coffee  = fs.readFileSync filePath, "utf8"
    options = module.options ? ( getRootModule module ).options

    log "coffee source:", coffee
    log "options:", options

    cachePath = getCachePath cacheDir, coffee, options

    log "cachePath:", cachePath

    js = getCachedJavaScript cachePath

    if js?

      log "loaded from cache:", js
      CoffeeScript.registerCompiled filePath, coffee

    else

      js = compileCoffeeScriptAndCache module, filePath, options, cachePath
      log "compiled from source:", js

    module._compile js, filePath


module.exports = ( cacheDir ) ->

  cacheDir ?=
    process.env.COFFEE_REGISTER_CACHE_CACHE_DIR ?
    "#{ require "app-root-path" }/.coffee-cache"

  requireCoffee = requireCoffeeScript cacheDir

  for ext in CoffeeScript.FILE_EXTENSIONS

    Object.defineProperty(
      require.extensions
      ext
      {
        writable : false
        value    : requireCoffee
      }
    )
