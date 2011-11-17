# Creep spawned by Spawners
class Creep
  constructor: (@eventmanager, options) ->

    @skin = options["skin"] ? 0
    @sprite = new Sprite
      "texture": "assets/images/towermap.png"
      "width": 64
      "height": 64
      "key":
        "done": 15
        "dead": 15
        "normal": @skin

    @checkout = false
    @state = "normal"

    @speed_factor = options["speed_factor"] ? 1
    @speed = new Vector(0, @speed_factor)

    @coor  = options["coor"] ? new Vector(0, 0)
    @start_coor = @coor

    @hp = options["hp"] ? 1000


  update: (delta, map) ->
    if @state != "normal"
      return

    current_tile = map.tileAtVector(@coor)
    if @targetReached(current_tile)
      if @state != "done"
        @state = "done"
    else
      new_coor = @coor.add(@speed.mult delta)
      new_tile = map.tileAtVector(new_coor)

      if new_tile.isWalkable?()
        @coor = new_coor
      else
        @speed = newSpeed(current_tile, @speed, @speed_factor)


  render: (ctx) ->
    ctx.save()
    ctx.translate @coor.x-90, @coor.y-30
    ctx.rotate -(Math.PI/4)
    ctx.scale 1, 1/0.4
    @sprite.render( @state, ctx )
    ctx.restore()

  targetReached: (tile) ->
    tile.isTarget()

  newSpeed = (tile, speed, speed_factor) =>
    for key, direction_tile of tile.sourrounding
      if direction_tile?.isWalkable?()
        switch key
          when "left"   then new_speed = new Vector(-speed_factor,0)
          when "right"  then new_speed = new Vector(speed_factor, 0)
          when "top"    then new_speed = new Vector(0,-speed_factor)
          when "bottom" then new_speed = new Vector(0,speed_factor)

        # HACK - following does not work: speed != new_speed.mult(-1)
        # used sp1.x != sp2.x && sp1.y != sp2.y
        # TO BE FIXED
        test_speed = new_speed.mult(-1)
        if speed.x != test_speed.x && speed.y != test_speed.y
          return new_speed

  hit: (bullet) ->
    @hp -= bullet.damage
    if @hp <= 0
      @state = "dead"
      @eventmanager.trigger "gain_gold"

