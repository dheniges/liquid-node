// Generated by CoffeeScript 1.7.1
(function() {
  var Liquid, Promise, Raw,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Liquid = require("../../liquid");

  Promise = require("bluebird");

  module.exports = Raw = (function(_super) {
    __extends(Raw, _super);

    function Raw() {
      return Raw.__super__.constructor.apply(this, arguments);
    }

    Raw.prototype.parse = function(tokens) {
      return Promise["try"]((function(_this) {
        return function() {
          var match, token;
          if (tokens.length === 0 || _this.ended) {
            return Promise.cast();
          }
          token = tokens.shift();
          match = Liquid.Block.FullToken.exec(token.value);
          if ((match != null ? match[1] : void 0) === _this.blockDelimiter()) {
            return _this.endTag();
          }
          _this.nodelist.push(token.value);
          return _this.parse(tokens);
        };
      })(this));
    };

    return Raw;

  })(Liquid.Block);

}).call(this);

//# sourceMappingURL=raw.map