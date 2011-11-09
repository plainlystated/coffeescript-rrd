(function() {
  var RRDInfo;

  RRDInfo = (function() {
    var _add_value;

    function RRDInfo(raw_output) {
      var line, _i, _len, _ref;
      _ref = raw_output.split('\n');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        this.parse_line(line);
      }
    }

    RRDInfo.prototype.ds_names = function() {
      var k, keys;
      keys = [];
      for (k in this['ds']) {
        keys.push(k);
      }
      return keys;
    };

    RRDInfo.prototype.parse_line = function(line) {
      var key, key_tree, value, _ref;
      line = line.replace(/["\s]/g, '');
      if (line === '') return;
      _ref = line.split('='), key = _ref[0], value = _ref[1];
      key_tree = key.match(/[\.\[]/) ? key.replace(/\[/g, '.').replace(/[\]\s]/g, '').split('.') : [key];
      return _add_value(key_tree, value, this);
    };

    _add_value = function(key_tree, value, obj) {
      var new_key, _ref;
      if (key_tree.length === 1) return obj[key_tree[0]] = value;
      new_key = key_tree.shift();
      if ((_ref = obj[new_key]) == null) obj[new_key] = new Object;
      return _add_value(key_tree, value, obj[new_key]);
    };

    return RRDInfo;

  })();

  exports.RRDInfo = RRDInfo;

}).call(this);
