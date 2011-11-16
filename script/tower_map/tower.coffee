

class Tower
  constructor: (@eventmanager, @keyboard, options) ->

    @state = "normal"
    @sprite = new Sprite
      "texture": "assets/images/enemies.png"
      "width": 50
      "height": 50
      "key":
        "normal": 7
        "attacking": 3

    @coor        = options["coor"]
    @hp          = options["hp"] ? 100
    @range       = options["range"] ? 200
    @last_target = null
    @scan_rate   = options["scan_rate"] ? 2000
    @fire_rate   = options["fire_rate"] ? 1000
    @damage      = options["damage"] ? 100

  update: (delta) ->
    #console.log delta


  render: (ctx) ->
    ctx.save()
    ctx.translate @coor.x, @coor.y
    @sprite.render( @state, ctx )
    ctx.restore()

