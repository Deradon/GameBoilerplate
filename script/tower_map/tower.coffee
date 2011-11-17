

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

  update: (delta, targets) -> #TODO targets
    @current_scan_rate += delta
    if @current_scan_rate >= @scan_rate
      @current_scan_rate -= @scan_rate
      @scan(targets)

    for bullet in @bullets
      bullet.update(delta, targets) #TODO targets

    # Remove Bullets
    @garbage_count += 1
    if @garbage_count > @garbage_every
      @garbage_count = 0
      @bullets = (bullet for bullet in @bullets when bullet.state != "done")


  render: (ctx) ->
    ctx.save()
    ctx.translate @coor.x, @coor.y
    @sprite.render( @state, ctx )
    ctx.restore()
    for bullet in @bullets
      bullet.render(ctx)

  scan: (targets) ->
    target = @closest_target(targets)

    if target?
      dist = @coor.subtract(target.coor).lengthSquared()
      if dist < @range
        @state = "attacking"
        @bullets.push new Bullet(@coor, target.coor)
      else
        @state = "normal"
    else
      @state = "normal"

  closest_target: (targets) ->
    #console.log targets

    min_range = 999999
    min_target = null
    for target in targets
      dist = @coor.subtract(target.coor).lengthSquared()
      if dist < min_range
        min_target = target
        min_range  = dist
    if min_range < @trigger_range
      return min_target
    else
      return null

