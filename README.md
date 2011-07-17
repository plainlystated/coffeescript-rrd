RRD
-

This library relies upon rrdtool being installed an available. It can be used to create, destroy, update, fetch, dump, and restore an RRD database. It's a work in progress, and pull-requests are welcomed (with tests, please).

Examples
-

> npm install rrd
> RRD = require('rrd').RRD
> 
> rrdTime = (date) ->
>   return Math.round(date.valueOf() / 1000)
> 
> rrd = new RRD('valid.rrd')
> 
> # Create a new database
> rrd.create ["DS:temperature:GAUGE:600:U:U", "RRA:AVERAGE:0.5:1:300"], {}, (err) ->
>   if err
>     console.log "error: #{err}"
> 
> # Update the database
> rrd.update new Date, [100], (err) ->
>   if err
>     console.log "error: #{err}"
> 
> # Query the database
> rrd.fetch rrdTime(rrdStartTime), rrdTime(new Date), (err, results) ->
>   if err
>     console.log "error: #{err}"
>   else
>     console.log results

This library relies upon rrdtool being installed an available. It can be used to create, destroy, update, fetch, dump, and restore an RRD database. It's a work in progress, and pull-requests are welcomed (with tests, please).


Installation
-
This library is available as a npm package.
> npm install rrd

More Info
-

You can find more information on [my blog](http://www.plainlystated.com/tag/coffeescript-rrd).
