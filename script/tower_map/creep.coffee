

class Creep
  constructor: (@eventmanager, options) ->

    @sprite = new Sprite
      "texture": "assets/images/test.png"
      "width": 50
      "height": 50
      "key":
        "done": 2
        "normal": 3

    @checkout = false
    @state = "normal"
    @speed = options["speed"] ? new Vector(0, 0)
    @coor  = options["coor"]
    @start_coor = @coor


  update: (delta, map) ->
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
        @speed = newSpeed(current_tile, @speed)
        

  render: (ctx) ->
    ctx.save()
    ctx.translate @coor.x, @coor.y
    @sprite.render( @state, ctx )
    ctx.restore()

  targetReached: (tile) ->
    tile.isTarget()

  newSpeed = (tile, speed) ->
    for key, direction_tile of tile.sourrounding
      if direction_tile?.isWalkable?()
        switch key
          when "left"   then new_speed = new Vector(-0.07,0)
          when "right"  then new_speed = new Vector(0.07, 0)
          when "top"    then new_speed = new Vector(0,-0.07)
          when "bottom" then new_speed = new Vector(0,0.07)

        # HACK - following does not work: speed != new_speed.mult(-1)
        # used sp1.x != sp2.x && sp1.y != sp2.y
        # TO BE FIXED
        test_speed = new_speed.mult(-1)
        if speed.x != test_speed.x && speed.y != test_speed.y
          return new_speed

