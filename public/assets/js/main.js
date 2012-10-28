/**
 * Run-time requirejs config
 */
require.config({
  shim: {
    underscore: {
        exports: '_'
    },
    websocket: {
        deps: ['jquery'],
        exports: 'websocket'
    }
  },
  baseUrl: '.',
  paths: {
      main: 'main',
      application: 'application',
      domReady:   'vendor/domReady',
      text:        'vendor/text',
      jquery:      'vendor/jquery',
      websocket:  'vendor/jquery.websocket',
      json:        'vendor/json2',
      underscore: 'vendor/underscore'
  }
});

require([
    'domReady',
    'application'
],
    function(domReady, app){
        app.bootstrap();

        domReady(function () {
            app.init();
        });
    }
);