(function() {
  var RRDRecord;
  RRDRecord = (function() {
    function RRDRecord(timestamp, fieldNames) {
      this.timestamp = timestamp;
      this.fieldNames = fieldNames;
    }
    return RRDRecord;
  })();
  exports.RRDRecord = RRDRecord;
}).call(this);
