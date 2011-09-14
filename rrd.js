(function() {
  var RRD, RRDRecord, exec, fs, spawn, sys;
  sys = require('sys');
  exec = require('child_process').exec;
  spawn = require('child_process').spawn;
  fs = require('fs');
  RRDRecord = require('./rrdRecord').RRDRecord;
  RRD = (function() {
    var _rrdTime;
    function RRD(filename) {
      this.filename = filename;
    }
    RRD.prototype.create = function(rrdArgs, options, cb) {
      var cmdArgs, err, proc, start, _ref;
      start = (_ref = options.start) != null ? _ref : new Date;
      cmdArgs = ["create", this.filename, "--start", _rrdTime(start), "--step", 300].concat(rrdArgs);
      console.log(" - rrdtool " + (cmdArgs.join(" ")));
      proc = spawn("rrdtool", cmdArgs);
      err = "";
      proc.stderr.on('data', function(data) {
        return err += data;
      });
      return proc.on('exit', function(code) {
        if (code === 0) {
          return cb(void 0, 'ok');
        } else {
          return cb(err, void 0);
        }
      });
    };
    RRD.prototype.destroy = function(cb) {
      return fs.unlink(this.filename, cb);
    };
    RRD.prototype.dump = function(cb) {
      return this.rrdSpawn("dump", [], cb);
    };
    RRD.prototype.rrdExec = function(command, cmd_args, cb) {
      var cmd;
      cmd = "rrdtool " + command + " " + this.filename + " " + cmd_args;
      console.log(cmd);
      return exec(cmd, {
        maxBuffer: 500 * 1024
      }, cb);
    };
    RRD.prototype.rrdSpawn = function(command, args, cb) {
      var err, out, proc;
      proc = spawn("rrdtool", [command, this.filename].concat(args));
      err = "";
      out = "";
      proc.stderr.on('data', function(data) {
        return err += data;
      });
      proc.stdout.on('data', function(data) {
        return out += data;
      });
      return proc.on('exit', function(code) {
        if (code === 0) {
          return cb(null, out);
        } else {
          return cb(err, null);
        }
      });
    };
    RRD.prototype.update = function(time, values, cb) {
      return this.rrdSpawn("update", ["" + (_rrdTime(time)) + ":" + (values.join(':'))], cb);
    };
    RRD.prototype.fetch = function(start, end, cb) {
      return this.rrdExec("fetch", "AVERAGE --start " + start + " --end " + end, function(err, data) {
        var fieldNames, fields, i, line, lines, record, records;
        if (err) {
          cb(err.message);
          return;
        }
        lines = data.split("\n");
        fieldNames = lines.shift().replace(new RegExp("^ +"), "").split(new RegExp(" +"));
        lines.shift();
        records = (function() {
          var _i, _len, _ref, _results;
          _results = [];
          for (_i = 0, _len = lines.length; _i < _len; _i++) {
            line = lines[_i];
            if (line === "") {
              continue;
            }
            if (line.match(" nan ")) {
              continue;
            }
            fields = line.split(new RegExp("[: ]+"));
            record = new RRDRecord(fields.shift(), fieldNames);
            for (i = 0, _ref = fields.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
              record[fieldNames[i]] = fields[i];
            }
            _results.push(record);
          }
          return _results;
        })();
        return cb(void 0, records);
      });
    };
    _rrdTime = function(date) {
      return Math.round(date.valueOf() / 1000);
    };
    return RRD;
  })();
  RRD.restore = function(filenameXML, filenameRRD, cb) {
    return exec("rrdtool restore " + filenameXML + " " + filenameRRD, cb);
  };
  exports.RRD = RRD;
}).call(this);
