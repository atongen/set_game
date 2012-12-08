/**
 * @name ImageLoader
 * @namespace
 */
define([
  'underscore',
  'lib/Dictionary'
],

function(
    _,
    Dictionary
) {
    /**
     * Image Loading Library / Dictionary
     * @class  ImageLoader
     */
    var ImageLoader = function() {
        this.images = new Dictionary;
        this.namespaces = {
            'default': ''
        };
        this.defaultNamespace = 'default';
    };

    /**
     * Add an image to the library
     * @param {String} file       URL to load image from
     * @param {Object[]} callbacks An array of objects
     */
    ImageLoader.prototype.add = function(file, callbacks, namespace) {
        if (!namespace || namespace == '') namespace = 'default';
        var callBacks = _.isArray(callbacks) ? callbacks : _.isObject(callbacks) ? [callbacks] : [];

        var existingImage = this.images.lookup(this._getNamespacedKey(file, namespace));
        if (existingImage) {
            for (var i = 0, len = callBacks.length; i < len; i++) {
                existingImage.callbacks.push(callBacks[i]);
            }
            existingImage.callbacks.concat(callBacks);
            if (existingImage.isLoaded) {
                this._executeCallbacks(file, namespace);
            }
        } else {
            var self = this;
            var storedObj = {
                storedImage: new Image,
                callbacks: callBacks,
                isLoaded: false
            };
            storedObj.storedImage.onload = function() {
                self.images.lookup(self._getNamespacedKey(file, namespace)).isLoaded = true;
                self._executeCallbacks.call(self, file, namespace);
            };
            this.images.store(this._getNamespacedKey(file, namespace), storedObj);
            storedObj.storedImage.src = file;
        }
    };

    ImageLoader.prototype.getImage = function(file, namespace) {
        if (!namespace || namespace == '') namespace = 'default';
        var foundImage = this.images.lookup(this._getNamespacedKey(file, namespace));
        if (foundImage.isLoaded) {
            return foundImage.storedImage;
        }
        return null;
    };

    ImageLoader.prototype.isLoaded = function(file, namespace) {
        if (!namespace || namespace == '') namespace = 'default';
        var foundImage = this.images.lookup(this._getNamespacedKey(file, namespace));
        return foundImage.isLoaded;
    };

    /**
     * Deletes all properties in the dictionary store and removes the key
     * @param  {String} file lookup url
     * @return {null}
     */
    ImageLoader.prototype.remove = function(file, namespace) {
        if (!namespace || namespace == '') namespace = 'default';
        var dictObj = this.images.lookup(this._getNamespacedKey(file, namespace));
        for (var key in dictObj)
            delete dictObj[key];

        this.images.remove(this._getNamespacedKey(file, namespace));
    };

    ImageLoader.prototype._getCallbacksForImage = function(file, namespace) {
        return this.images.lookup(this._getNamespacedKey(file, namespace)).callbacks;
    };

    ImageLoader.prototype._executeCallbacks = function(file, namespace) {

        var dictObj = this.images.lookup(this._getNamespacedKey(file, namespace));

        while (dictObj.callbacks.length > 0) {
            var callbackObj = dictObj.callbacks.shift();
            callbackObj.fn.call(
                callbackObj.context,
                dictObj.storedImage
            );
        }
    };

    ImageLoader.prototype._getNamespacedKey = function(file, namespace) {
        return namespace + file;
    };

    return ImageLoader;
});
