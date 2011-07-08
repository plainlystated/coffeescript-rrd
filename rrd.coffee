sys = require('sys')
exec = require('child_process').exec
spawn = require('child_process').spawn
fs = require('fs')

RRDRecord = require('./rrdRecord').RRDRecord

class RRD
  constructor: (@filename) ->

  create: (rrdArgs, options, cb) ->
    start = options.start ? new Date
    console.log start
    cmd = "rrdtool create #{@filename} --start #{_rrdTime(start)} --step 300 #{rrdArgs.join(" ")}"
    console.log " - #{cmd}"
    exec(cmd, cb)

  destroy: (cb) ->
    fs.unlink(@filename, cb)

  dump: (cb) ->
    this.rrdExec("dump", "", cb)

  rrdExec: (command, cmd_args, cb) ->
    cmd = "rrdtool #{command} #{@filename} #{cmd_args}"
    console.log cmd
    exec(cmd, {maxBuffer: 500 * 1024}, cb)

  update: (time, values, cb) ->
    this.rrdExec("update", "#{_rrdTime(time)}:#{values.join(':')}", cb)

  fetch: (start, end, cb) ->
    this.rrdExec "fetch", "AVERAGE --start #{start} --end #{end}", (err, data) ->
      lines = data.split("\n")
      fieldNames = lines.shift().replace(new RegExp("^ +"), "").split(new RegExp(" +"))
      lines.shift()

      records = for line in lines
        continue if line == ""
        continue if line.match(" nan ")

        fields = line.split(new RegExp("[: ]+"))
        record = new RRDRecord(fields.shift(), fieldNames)
        for i in [0..fields.length-1]
          record[fieldNames[i]] = fields[i]
        record

      cb(records)

  graph: (graphFilename, lines, options, cb) ->
    cmd = "rrdtool graph #{graphFilename} #{(this._rrdGraphLine(line) for line in lines).join(" ")} --start #{options.start}"
    console.log cmd
    exec(cmd, {maxBuffer: 500 * 1024}, cb)

  _rrdTime = (date) ->
    return Math.round(date.valueOf() / 1000)

RRD.restore = (filenameXML, filenameRRD, cb) ->
  exec "rrdtool restore #{filenameXML} #{filenameRRD}", cb
exports.RRD = RRD
