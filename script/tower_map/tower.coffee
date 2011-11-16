

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
    @range       = options["range"] ? 250
    @range       *= @range
    @last_target = null
    @scan_rate   = options["scan_rate"] ? 500
    @fire_rate   = options["fire_rate"] ? 1000
    @damage      = options["damage"] ? 100

    @current_scan_rate = 0

  update: (delta, hero) ->
    @current_scan_rate += delta
    if @current_scan_rate >= @scan_rate
      @current_scan_rate = @scan_rate - @current_scan_rate
      @scan(hero)


  render: (ctx) ->
    ctx.save()
    ctx.translate @coor.x, @coor.y
    @sprite.render( @state, ctx )
    ctx.restore()

  scan: (hero) ->
    dist = @coor.subtract(hero.coor).lengthSquared()
    if dist < @range
      @state = "attacking"
    else
      @state = "normal"

