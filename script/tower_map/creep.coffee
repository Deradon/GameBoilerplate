

class Creep
  constructor: (@eventmanager, options) ->

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
    if options["speed"]
      @speed = options["speed"]
    else  
      @speed = new Vector( 0, 0 )
    @force = 0.00
    @last_tile = null
    @gravity = 0.00

  update: (delta, map) ->
    tile = map.tileAtVector(@coor)
    if !tile.isWalkable?()

    @coor = @coor.add( @speed.mult delta )
    @last_tile = tile
    
  render: (ctx) ->
    ctx.save()
    ctx.translate @coor.x, @coor.y
    @sprite.render( @state, ctx )
    ctx.restore()

