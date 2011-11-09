class RRDInfo
  constructor: (raw_output) ->
    this.parse_line(line) for line in raw_output.split('\n')

  ds_names: () ->
    keys = []
    keys.push(k) for k of this['ds']
    return keys

  parse_line: (line) ->
    line = line.replace(/["\s]/g, '')
    return if line == ''

    [key, value] = line.split('=')

    key_tree = if key.match  /[\.\[]/
      key.replace(/\[/g, '.').replace(/[\]\s]/g, '').split('.')
    else
      [key]

    _add_value(key_tree, value, this)

  _add_value =  (key_tree, value, obj) ->
    return obj[key_tree[0]] = value if key_tree.length == 1
    new_key = key_tree.shift()
    obj[new_key] ?= new Object

    return _add_value(key_tree, value, obj[new_key])

exports.RRDInfo = RRDInfo
