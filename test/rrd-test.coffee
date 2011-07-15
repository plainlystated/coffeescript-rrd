vows = require('vows')
assert = require('assert')
RRD = require('../rrd').RRD
exec = require('child_process').exec

vows.describe('RRD').addBatch(
  'created a database with invalid contents':
    topic: (rrd) ->
      rrd = new RRD('empty-and-invalid.rrd')
      rrd.create([], {}, @callback)
      return

    'gives an error': (err, result) ->
      assert.equal(err, 'ERROR: you must define at least one Round Robin Archive\n')
      assert.equal(result, undefined)

  'creating a database with valid contents':
    topic: (rrd) ->
      rrd = new RRD('create-test.rrd')
      rrd.create(["DS:temperature:GAUGE:600:U:U", "RRA:AVERAGE:0.5:1:300"], {}, @callback)
      return

    'gives no error': (err, result) ->
      assert.equal(err, undefined)
      assert.equal(result, 'ok')

  'an invalid RRD':
    topic: new RRD('invalid.rrd')

    'when fetching':
      topic: (rrd) ->
        rrd.fetch('1310664300', '1310664900', @callback)
        return

      'returns an error': (err, result) ->
        assert.equal(err, "Command failed: ERROR: opening 'invalid.rrd': No such file or directory\n")

      'does not return any results': (err, result) ->
        assert.equal(result, undefined)

    'when dumping':
      topic: (rrd) ->
        rrd.dump(@callback)
        return

      'returns an error': (err, xml) ->
        assert.equal(err, "ERROR: opening 'invalid.rrd': No such file or directory\n")

      'returns no xml': (err, xml) ->
        assert.equal(xml, undefined)

    'when updating':
      topic: (rrd) ->
        rrd.update(new Date, [1,2,3], @callback)
        return

      'returns an error': (err) ->
        assert.equal(err, "ERROR: opening 'invalid.rrd': No such file or directory\n")

  'a valid RRD':
    topic: new RRD('valid.rrd')

    'when fetching':
      topic: (rrd) ->
        rrd.fetch('1310664300', '1310664900', @callback)
        return

      'returns no error': (err, results) ->
        assert.equal(err, undefined)

      'returns 3 results': (err, results) ->
        assert.equal(results.length, 3)

      'has results with a timestamp': (err, results) ->
        assert.equal(results[0].timestamp, '1310664600')

      'has results with appropriate fields': (err, results) ->
        assert.equal(results[0].temperature, '6.7620000000e+01')
        assert.equal(results[0].target_temp, '6.8000000000e+01')
        assert.equal(results[0].state, '0.0000000000e+00')

    'when dumping':
      topic: (rrd) ->
        rrd.dump(@callback)
        return

      'returns no error': (err, xml) ->
        assert.equal(err, null)

      'returns some xml': (err, xml) ->
        assert.match(xml, /^<\?xml version="1.0" encoding="utf-8"\?>/)
        assert.match(xml, /<\/rrd>/)

    'when updating':
      topic: (rrd) ->
        rrd.update(new Date, [1,2,3], @callback)
        return

      # Need to figure out how to test this without messing up subsequent test runs
      # 'returns no error': (err) ->
      #   assert.equal(err, undefined)
  'when restoring':
    'a valid file':
      topic: () ->
        RRD.restore('valid.xml', "tmp-restore.rrd", @callback)
        return

      'returns no error': (err) ->
        assert.equal(err, null)

    'an invalid file':
      topic: () ->
        RRD.restore('invalid.xml', "tmp-restore.rrd", @callback)
        return

      # The underlying process never returns an error here..  need to figure out a better way to handle this
      # 'returns an error': (err) ->
      #   assert.equal(err, 'some error')

).addBatch(
  'cleanup': () ->
    exec('rm tmp-*')
).export(module, {error: false})

