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
  baseUrl: '/assets/js/lib',
  paths: {
      application: '/assets/js/application',
      domReady:   '/assets/js/vendor/domReady',
      text:        '/assets/js/vendor/text',
      jquery:      '/assets/js/vendor/jquery',
      websocket:  '/assets/js/vendor/jquery.websocket',
      json:        '/assets/js/vendor/json2',
      underscore: '/assets/js/vendor/underscore'
  }
});

require([
    'domReady',
    'application'
],
    function(domReady, app){
        domReady(function () {
            app.init();
        });
    }
);