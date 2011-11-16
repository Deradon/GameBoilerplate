

class Tower
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
#    @start_coor = @coor
#    @speed = new Vector( 0, 0 )
#    @force = 0.01
#    @gravity = 0.00



  update: (delta) ->


  render: (ctx) ->
    ctx.save()
    ctx.translate @coor.x, @coor.y
    @sprite.render( @state, ctx )
    ctx.restore()

