/**
 * @name Dictionary
 * @namespace
 */
define([
  ],

  function(
    ) {
    /**
     * Dictionary store
     * @param {Object} startValues An object of key-value starting values
     */
    var Dictionary = function(startValues) {
        this.values = startValues || {};
    };

    /**
     * Stores a data value
     * @param  {String} name  Lookup name
     * @param  {mixed} value  Value to store
     * @return {null}
     */
    Dictionary.prototype.store = function(name, value) {
        this.values[name] = value;
    };

    /**
     * Retrieve the value associated with name key
     * @param  {String} name Lookup name
     * @return {mixed}       Stored value
     */
    Dictionary.prototype.lookup = function(name) {
        return this.values[name];
    };

    /**
     * Returns truthy if name lookup key exists
     * @param  {String} name Lookup name
     * @return {null}
     */
    Dictionary.prototype.contains = function(name) {
        return Object.prototype.hasOwnProperty.call(this.values, name) &&
            Object.prototype.propertyIsEnumerable.call(this.values, name);
    };

    /**
     * Method to iterate over every lookup name / value pair
     * @param  {Function} action  Iterator function.  Takes the stored value as the only parameter
     * @param  {Object}   context Value of 'this' inside of the iterator function's scope
     * @return {null}
     */
    Dictionary.prototype.each = function(action, context) {
        for (var name in this.values) {
            if (Object.prototype.hasOwnProperty.call(this.values, name)) {
                action.call(context, this.values[name]);
            }
        }
    };

    /**
     * Iterates over the values object and counts enumerable properties
     * @return {Integer} the size of the dictionary
     */
    Dictionary.prototype.count = function() {
        var count = 0;
        this.each(function(item){count++;}, this);
        return count;
    };

    /**
     * Simple test if the values store contains the name
     * @return {Boolean} returns true | false
     */
    Dictionary.prototype.isEmpty = function() {
        for (var name in this.values) {
            if (Object.prototype.hasOwnProperty.call(this.values, name)) {
                return false;
            }
        }
        return true;
    };

    /**
     * Removes a name from the dictionary.  Does not delete any properties on the associated resource; if a reference to
     * the stored object exists elsewhere, it will not be garbage.
     * 
     * @return {null}
     */
    Dictionary.prototype.remove = function (name) {
        delete this.values[name];
    };

    return Dictionary;
});
