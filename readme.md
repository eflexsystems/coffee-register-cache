# coffeescript-register-cache

`require()` cache for CoffeeScript 2 inspired by git://github.com/guillaume86/coffee-register-cache

## usage
```js
  require('coffeescript2-register-cache')('/usr/me/cache')
```

The exported function takes a cachePath parameter.

Alternatively the path can be set with an env var: `COFFEE_REGISTER_CACHE_CACHE_DIR`.

If not set the path will default to `"PROJECT-ROOT/.coffee-cache"`.
