

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
    @decay = 0.95


  update: (delta, map) ->
    tile = map.tileAtVector(@coor)

    # left/right movement
    if @keyboard.key("right")
      @speed.x += @force
    else if @keyboard.key("left")
      @speed.x -= @force
    else
      @speed.x *= @decay

    # up/down movement
    # left/right movement
    if @keyboard.key("up")
      @speed.y -= @force
    else if @keyboard.key("down")
      @speed.y += @force
    else
      @speed.y *= @decay

    new_coor = @coor.add( @speed.mult delta )
    walkable = map.tileAtVector(new_coor).isWalkable?()
    if map.tileAtVector(new_coor).isWalkable?()
      @coor = new_coor
    else

      @speed.y = 0
      @speed.x = 0

    if @keyboard.key("space")
      @speed.y = 0.0
      @speed.x = 0.0

#    # jump
#    if @keyboard.key("space") and @state isnt "jumping"
#      @state = "jumping"
#      @speed.y = -0.5



  render: (ctx) ->
    ctx.save()
    ctx.translate @coor.x, @coor.y
    @sprite.render( @state, ctx )
    ctx.restore()

