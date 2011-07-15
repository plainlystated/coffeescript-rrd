vows = require('vows')
assert = require('assert')
RRD = require('../rrd').RRD

vows.describe('RRD').addBatch(
  'an invalid RRD':
    topic: new RRD('invalid.rrd')

    'when fetching':
      topic: (rrd) ->
        rrd.fetch('1310664300', '1310664900', this.callback)
        return

      'returns an error': (err, result) ->
        assert.equal(err, "Command failed: ERROR: opening 'invalid.rrd': No such file or directory\n")

      'does not return any results': (err, result) ->
        assert.equal(result, undefined)
  'a valid RRD':
    topic: new RRD('valid.rrd')

    'when fetching':
      topic: (rrd) ->
        rrd.fetch('1310664300', '1310664900', this.callback)
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

).export(module)

