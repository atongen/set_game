/**
 * Run-time requirejs config
 */
require.config({
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
  baseUrl: '/assets/js',
  paths: {
      domReady:        'vendor/domReady',
      text:            'vendor/text',
      jquery:          'vendor/jquery',
      json:            'vendor/json2',
      underscore:      'vendor/underscore',
      bootstrap:       'vendor/bootstrap',
      backbone_vendor: 'vendor/backbone',
      backbone:        'lib/BackboneWrapper'
  }
});

require([
  'jquery',
  'domReady',
  'app/views/app'
],
function (
  $,
  domReady,
  AppView
) {
  domReady(function () {
    var game_id = $('body').data('game-id');
    if (game_id) {
      new AppView({ game_id: game_id });
    }
  });
});
