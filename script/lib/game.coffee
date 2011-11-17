

class Game
  constructor: (@width, @height) ->
    canvas = $('<canvas />').attr({"width": @width, "height": @height})
    $("body").append(canvas)
    @ctx = canvas[0].getContext('2d')
    @ctx.font = 'bold 36px Arial, sans-serif'
    @ctx.fillStyle = "#ffffff"
    @loop = null
    @timer = new Timer

  gameloop: =>
    @update()
    @render()

  start: ->
    @loop = setInterval @gameloop, 1

  stop: ->
    @loop.clearInterval()

  update: ->
    @timer.punch()

  render: ->
    #@ctx.fillText( @timer.fps().toFixed(1), 20, 40 )
    #@ctx.strokeText( @timer.fps().toFixed(1), 20, 40 )


