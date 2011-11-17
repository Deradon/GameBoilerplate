# Bullets shot by Towers
class Bullet
  constructor: (from_coor, to_coor, options) ->

    @exp1 = [16..47]
    @exp2 = [48..79]
    @exp3 = [80..111]
    @exp4 = [112..143]
    @exp5 = [144..175]


    @sprite = new Sprite
      "texture": "assets/images/towermap.png"
      "width": 64
      "height": 64
      "key":
        "normal": 160
        "done": 15

    @sprite.addAnimation "exploding", { frames: @exp1, fps: 32, loop: false, callback: @explode }

    @state          = "normal"
    @range_traveled = 0

    @direction      = to_coor.subtract(from_coor).norm()
    @coor           = from_coor

    @speed          = 0.8#options["speed"]         ? 1
    @damage         = 200#options["damage"]        ? 100
    @max_range      = 600#options["max_range"]     ? 1000
    @splash_radius  = 50#options["splash_radius"] ? 50
    @splash_damage  = 10#options["splash_damage"] ? 10

    # HACK
    @trigger_range  = 1200

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
        @target.hit(this)

      if @range_traveled >= @max_range
        @state = "done"


  render: (ctx) ->
    ctx.save()
    ctx.translate @coor.x-90, @coor.y-30
    ctx.rotate -(Math.PI/4)
    ctx.scale 1, 1/0.4
    @sprite.render( @state, ctx )
    ctx.restore()

  closest_target: (targets) ->
    min_range = 999999
    min_target = null
    for target in targets when target.state == "normal"
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

