
# TODO:
# * speed should be aware of delta
# * get a sprite
class Hero
  constructor: (@towers, @eventmanager, @keyboard, options) ->

    @sprite = new Sprite
      "texture": "assets/images/towermap.png"
      "width": 64
      "height": 64
      "key":
        "normal": 5
    @state = "normal"

    # Coordinates of the mighty Hero
    @coor = options["coor"]

    # And his/her speed
    @speed = new Vector(0, 0)

    # Acceleration (speed-up / speed-down)
    @force = 0.01

    # Used to slow down movements if no keys pressed
    @decay = 0.95


  update: (delta, map, gold) ->
    @determine_speed()

    new_coor = @coor.add(@speed.mult delta)
    new_tile = map.tileAtVector(new_coor)
    if new_tile.isHeroWalkable?()
      @coor = new_coor
    else
      # TODO: add some soft bouncing
      @speed.y = 0
      @speed.x = 0

    # Space: Stop and Build or Update Tower
    if @keyboard.key("space")
      console.log(gold)
      if new_tile.isBuildable() && new_tile.builded == false && gold >= 150
       @towers.push new Tower @eventmanager, "coor": map.vectorAtTile(new_tile.col,new_tile.row)
       new_tile.builded = true
       gold -= 150

    return gold

  render: (ctx) ->
    ctx.save()
    ctx.translate @coor.x-120, @coor.y-60
    ctx.rotate -(Math.PI/4)
    ctx.scale 1, 1/0.4
    @sprite.render(@state, ctx)
    ctx.restore()

  # Handling Keyboard events and get new speed
  determine_speed: ->
    # left/right movement
    if @keyboard.key("right")
      @speed.x += @force
    else if @keyboard.key("left")
      @speed.x -= @force
    else
      @speed.x *= @decay

    # up/down
    if @keyboard.key("up")
      @speed.y -= @force
    else if @keyboard.key("down")
      @speed.y += @force
    else
      @speed.y *= @decay

