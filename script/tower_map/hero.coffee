

class Hero
  constructor: (@eventmanager, @keyboard, options) ->

    @state = "normal"
    @sprite = new Sprite
      "texture": "assets/images/test.png"
      "width": 50
      "height": 50
      "key":
        "normal": 3
        "jumping": 5

    @coor = options["coor"]
    @start_coor = @coor
    @speed = new Vector( 0, 0 )
    @force = 0.01
    @gravity = 0.00

    # event Manager
    @eventmanager.register "touchdown", @touchdown

  touchdown: ->
    console.log "Hero says: Touchdown occurred"

  update: (delta, map) ->
    tile = map.tileAtVector(@coor)
    $("#debug").html("#{tile.row} - #{tile.col}")

    # left/right movement
    if @keyboard.key("right")
      @speed.x += @force
    else if @keyboard.key("left")
      @speed.x -= @force
    else
      if @speed.x > 0
        @speed.x -= @force
      else
        @speed.x += @force

    # up/down movement
    # left/right movement
    if @keyboard.key("up")
      @speed.y -= @force
    else if @keyboard.key("down")
      @speed.y += @force
    else
      if @speed.y > 0
        @speed.y -= @force
      else
        @speed.y += @force

    # apply gravity
    if !tile.isWalkable?()
      $("#debug-last-tile").html("#{tile.row} - #{tile.col}")
      console.log tile
      @coor = @start_coor
      @speed.y = 0
      @speed.x = 0

    if @keyboard.key("up")
      @speed.y -= 0.0
      @speed.x -= 0.0

#    # jump
#    if @keyboard.key("space") and @state isnt "jumping"
#      @state = "jumping"
#      @speed.y = -0.5

    @coor = @coor.add( @speed.mult delta )

  render: (ctx) ->
    ctx.save()
    ctx.translate @coor.x, @coor.y
    @sprite.render( @state, ctx )
    ctx.restore()

