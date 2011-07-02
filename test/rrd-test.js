vows = require('vows')
assert = require('assert')

RRD = require('../rrd').RRD

vows.describe('RRD').addBatch({
  'A valid RRD database': {
    topic: new RRD('./valid.rrd'),

    'when fetching some records': {
      topic: function (rrd) {
        rrd.fetch('1309466999', '1309467599', this.callback);
      },

      'has no error': function (err, records) {
        assert.equal(err, undefined);
      },

      'has 3 records': function (err, records) {
        assert.equal(records.length, 3);
      },
 
      'has records with the appropriate properties': function (err, records) {
        assert.equal(records[0].timestamp, '1309467000');
        assert.deepEqual(records[0].fieldNames, [ 'numCats', 'numDogs' ]);
        assert.equal(records[0].numCats, '2.3038666667e+02');
        assert.equal(records[0].numDogs, '4.4397333333e+02');
      }
    }
  },

  'An invalid RRD database': {
    topic: new RRD('./invalid.rrd'),

    'when fetching some records': {
      topic: function (rrd) {
        rrd.fetch('1309466999', '1309467601', this.callback);
      },

      'has an error': function (err, records) {
        assert.equal(err, "Command failed: ERROR: opening './invalid.rrd': No such file or directory\n");
      },

      'has no records': function (err, records) {
        assert.equal(records, undefined);
      }
    }
  }
}).export(module); 
