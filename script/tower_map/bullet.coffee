

class Bullet
  constructor: (from_coor, to_coor, options) ->


    @sprite = new Sprite
      "texture": "assets/images/enemies.png"
      "width": 50
      "height": 50
      "key":
        "normal": 1
        "done": 13

    @sprite.addAnimation "exploding", { frames: [0,1,2,3,4,13], fps: 8, loop: false, callback: @explode }

    @state          = "normal"
    @range_traveled = 0

    @direction      = to_coor.subtract(from_coor).norm()
    @coor           = from_coor

    @speed          = 1#options["speed"]         ? 1
    @damage         = 100#options["damage"]        ? 100
    @max_range      = 600#options["max_range"]     ? 1000
    @splash_radius  = 50#options["splash_radius"] ? 50
    @splash_damage  = 10#options["splash_damage"] ? 10

    # HACK
    @trigger_range  = 225

  update: (delta, targets) ->#, targets
    if @state == "normal"
      new_dist = delta*@speed
      # Cap to max_range
      if @range_traveled + new_dist >= @max_range
        new_dist = @max_range - @range_traveled
      @range_traveled += new_dist
      @coor = @coor.add(@direction.mult(new_dist))

      @target = @closest_target(targets)
      if @target
        @state = "exploding"

      if @range_traveled >= @max_range
        @state = "done"


  render: (ctx) ->
    ctx.save()
    ctx.translate @coor.x, @coor.y
    @sprite.render( @state, ctx )
    ctx.restore()

  closest_target: (targets) ->
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

  explode: =>
    @state = "done"

