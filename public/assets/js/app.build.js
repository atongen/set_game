/**
 * Compile-time requirejs configuration
 */
{
  shim: {
    jquery: {
      exports: 'jquery'
    },
    websocket: {
        deps: ['jquery'],
        exports: 'websocket'
    },
    bootstrap: {
        deps: ['jquery'],
        exports: 'bootstrap'
    },
    json: {
      exports: 'json'
    }
  },
  baseUrl: '.',
  paths: {
      domReady:        'vendor/domReady',
      text:            'vendor/text',
      jquery:          'vendor/jquery',
      json:            'vendor/json2',
      underscore:      'vendor/underscore',
      bootstrap:       'vendor/bootstrap',
      backbone_vendor: 'vendor/backbone',
      backbone:        'lib/BackboneWrapper'
  },
  name: 'main',
  out:  'main-built.js'
}
