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
    'lib/Ga',
    'app/views/app'
],

function (
    $,
    domReady,
    Ga,
    AppView
) {

    var load_fb = function() {
        (function(d, s, id) {
            var js, fjs = d.getElementsByTagName(s)[0];
            if (d.getElementById(id)) return;
            js = d.createElement(s); js.id = id;
            js.src = "//connect.facebook.net/en_US/all.js#xfbml=1";
            fjs.parentNode.insertBefore(js, fjs);
        }(document, 'script', 'facebook-jssdk'));
    }

    domReady(function () {
        Ga.init();
        load_fb();

        var game_id = $('body').data('game-id');
        if (game_id) {
            var player_id = $('body').data('player-id');
            new AppView({
                game_id:   game_id,
                player_id: player_id
            });
        }
    });

});
