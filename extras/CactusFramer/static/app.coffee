getTime = Date.now

if performance.now
	getTime = -> performance.now()

# class Timer
# 	constructor: -> @start()
# 	start: -> @_startTime = getTime()
# 	stop:  -> getTime() - @_startTime

class FPSTimer

	constructor: -> @start()

	start: ->
		@_frameCount = 0
		@_startTime = getTime()

		Framer.Loop.on("render", @_tick)

	stop: ->

		time = getTime() - @_startTime

		Framer.Loop.off("render", @_tick)
		
		results =
			time: time
			frames: @_frameCount
			fps: 1000 / (time / @_frameCount)

		return results

	_tick: =>
		@_frameCount++

run = (options, callback) ->
	
	context = new Framer.Context(name:"TestRun")
	context.run -> _run options, (results) ->
		context.reset()
		callback(results)

_run = (options, callback) ->

	startTime = getTime()
	results = {}

	LAYERS = for i in [1..options.n]

		layerC = new Layer 
			x: Math.random() * window.innerWidth, 
			y: Math.random() * window.innerHeight
	
	results.layers = Framer.CurrentContext._layerList.length
	results.buildTotal = getTime() - startTime
	results.buildLayer = results.buildTotal / results.layers

	t1 = new FPSTimer

	for layer in LAYERS
		
		layer.animate
			properties:
				x: Math.random() * window.innerWidth, 
				y: Math.random() * window.innerHeight
			curve: "spring(1000, 10, 0)"

	layer.on Events.AnimationEnd, ->
		results.fps = t1.stop()
		callback(results)

Utils.domComplete ->

	c = 0

	callback = (results) ->

		if results
			print "#{c} - #{results.layers}
				Build: #{Utils.round(results.buildTotal, 0)}ms/#{Utils.round(results.buildLayer, 2)}ms
				FPS: #{Utils.round(results.fps.fps, 1)}"

		if c < 100
			c++
			run {n: c * 20}, callback

	callback()




