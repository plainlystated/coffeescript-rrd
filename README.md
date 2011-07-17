## RRD

This library relies upon rrdtool being installed an available. It can be used to create, destroy, update, fetch, dump, and restore an RRD database. It's a work in progress, and pull-requests are welcomed (with tests, please).

## Examples

### Creating a database

    RRD = require('rrd').RRD
    rrd = new RRD('valid.rrd')
    rrd.create ["DS:temperature:GAUGE:600:U:U", "RRA:AVERAGE:0.5:1:300"], {}, (err) ->
      if err
        console.log "error: #{err}"

### Updating a database

    RRD = require('rrd').RRD
    rrd = new RRD('valid.rrd')
    rrd.update new Date, [100], (err) ->
      if err
        console.log "error: #{err}"

### Querying the database

    rrdTime = (date) ->
      return Math.round(date.valueOf() / 1000)
    
    RRD = require('rrd').RRD
    rrd = new RRD('valid.rrd')
    rrd.fetch rrdTime(rrdStartTime), rrdTime(new Date), (err, results) ->
      if err
        console.log "error: #{err}"
      else
        console.log results
    

This library relies upon rrdtool being installed an available. It can be used to create, destroy, update, fetch, dump, and restore an RRD database. It's a work in progress, and pull-requests are welcomed (with tests, please).


## Installation

This library is available as a npm package.

    npm install rrd

## Projects

This library is used by [Hot or Not](http://hot-or-not.plainlystated.com).

Are you using this in an interesting project? I'd love to hear about it!

## More Info

You can find more information on [my blog](http://www.plainlystated.com/tag/coffeescript-rrd).
