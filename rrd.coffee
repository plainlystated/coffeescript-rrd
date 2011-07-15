sys = require('sys')
exec = require('child_process').exec
spawn = require('child_process').spawn
fs = require('fs')

RRDRecord = require('./rrdRecord').RRDRecord

class RRD
  constructor: (@filename) ->

  create: (rrdArgs, options, cb) ->
    start = options.start ? new Date
    cmdArgs = ["create", @filename, "--start", _rrdTime(start), "--step", 300].concat rrdArgs

    console.log " - rrdtool #{cmdArgs.join(" ")}"

    proc = spawn("rrdtool", cmdArgs)
    err = ""
    proc.stderr.on 'data', (data) ->
      err += data
    proc.on 'exit', (code) ->
      if code == 0
        cb undefined, 'ok'
      else
        cb err, undefined

  destroy: (cb) ->
    fs.unlink(@filename, cb)

  dump: (cb) ->
    @rrdSpawn("dump", [], cb)

  rrdExec: (command, cmd_args, cb) ->
    cmd = "rrdtool #{command} #{@filename} #{cmd_args}"
    console.log cmd
    exec(cmd, {maxBuffer: 500 * 1024}, cb)

  rrdSpawn: (command, args, cb) ->
    proc = spawn("rrdtool", [command, @filename].concat(args))
    err = ""
    out = ""
    proc.stderr.on 'data', (data) ->
      err += data
    proc.stdout.on 'data', (data) ->
      out += data
    proc.on 'exit', (code) ->
      if code == 0
        cb null, out
      else
        cb err, null

  update: (time, values, cb) ->
    @rrdSpawn("update", ["#{_rrdTime(time)}:#{values.join(':')}"], cb)

  fetch: (start, end, cb) ->
    this.rrdExec "fetch", "AVERAGE --start #{start} --end #{end}", (err, data) ->
      if err
        cb(err.message)
        return

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

      cb(undefined, records)

  _rrdTime = (date) ->
    return Math.round(date.valueOf() / 1000)

RRD.restore = (filenameXML, filenameRRD, cb) ->
  exec "rrdtool restore #{filenameXML} #{filenameRRD}", cb
exports.RRD = RRD
