# Towers built by Hero
class Tower
  constructor: (@eventmanager, options) ->

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
    @range       = options["range"] ? 450
    @range       *= @range
    @last_target = null
    @scan_rate   = options["scan_rate"] ? 500
    @fire_rate   = options["fire_rate"] ? 1000
    @damage      = options["damage"] ? 100

    @current_scan_rate = 0

    @bullets = []
    @garbage_every = 30
    @garbage_count = 0

  update: (delta, targets) ->
    @current_scan_rate += delta
    if @current_scan_rate >= @scan_rate
      @current_scan_rate -= @scan_rate
      @scan(targets)

    for bullet in @bullets
      bullet.update(delta, targets)


  render: (ctx) ->
    ctx.save()
    ctx.translate @coor.x-90, @coor.y-30
    ctx.rotate -(Math.PI/4)
    ctx.scale 1, 1/0.4
    @sprite.render( @state, ctx )
    ctx.restore()
    for bullet in @bullets
      bullet.render(ctx)

  scan: (targets) ->
    target = @closest_target(targets)

    if target?
      @state = "attacking"
      @bullets.push new Bullet(@coor, target.coor)
    else
      @state = "normal"

  closest_target: (targets) ->
    min_range = 999999
    min_target = null
    for target in targets when target.state == "normal"
      dist = @coor.subtract(target.coor).lengthSquared()
      if dist < min_range
        min_target = target
        min_range  = dist
    if min_range < @range
      return min_target
    else
      return null

  gc: =>
    @bullets = (bullet for bullet in @bullets when bullet.state isnt "done")

