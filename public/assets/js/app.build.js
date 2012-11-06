/**
 * Compile-time requirejs configuration
 */
{
  shim: {
    underscore: {
        exports: '_'
    },
    websocket: {
        deps: ['jquery'],
        exports: 'websocket'
    },
    bootstrap: {
      deps: ['jquery'],
      exports: 'bootstrap'
    }
  },
  baseUrl: '.',
  paths: {
      main:        'main',
      application: 'application',
      domReady:    'vendor/domReady',
      text:        'vendor/text',
      jquery:      'vendor/jquery',
      websocket:   'vendor/jquery.websocket',
      json:        'vendor/json2',
      underscore:  'vendor/underscore',
      bootstrap:   'vendor/bootstrap'
  },
  name: 'main',
  out:  'main-built.js'
}
