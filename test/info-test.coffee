vows = require('vows')
assert = require('assert')
RRDInfo = require('../rrdInfo').RRDInfo
valid_contents = require('fs').readFileSync('./valid.info').toString()

vows.describe('RRDInfo').addBatch(
  'from a valid rrd file':
    topic: new RRDInfo(valid_contents)

    'should have the filename set': (topic) ->
      assert.equal(topic.filename, 'valid.rrd')

    'should parse multi level lines': (topic) ->
      assert.equal(topic.ds.state.last_ds, 0)

    'should list the ds_names': (topic) ->
      assert.include(topic.ds_names(), 'temperature')
      assert.include(topic.ds_names(), 'target_temp')
      assert.include(topic.ds_names(), 'state')
  
).export(module, {error: false})
