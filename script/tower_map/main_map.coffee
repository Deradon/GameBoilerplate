
stateclass["main_map"] = class StateMainMap extends State
  constructor: (@parent) ->
#    @camera = new Camera {"projection": "normal", "vpWidth": @parent.width, "vpHeight": @parent.height}
    @camera = new Camera {"projection": "iso", "vpWidth": @parent.width, "vpHeight": @parent.height}

    @creeps = []
    @lives = 3
    @spawners = []
    @towers = []

    @garbage_every = 31
    @garbage_count = 0

    beach3d = new Sprite
      "texture": "assets/images/wc33d.png"
      "width": 107
      "height": 107
      "innerWidth": 87
      "innerHeight": 87
      "key":
        "00990000": 0
        "99000000": 1
        "00009900": 2
        "00000099": 3
        "00990099": 4
        "99990000": 5
        "99009900": 6
        "00009999": 7
        "99990099": 8
        "99999900": 9
        "99009999": 10
        "00999999": 11
        "00000000": 12
        "99999999": 13
        "00999900": 14
        "99000099": 15

    @map = new Map
      "mapfile": "assets/towermap_map1.png"
      "pattern": "towermap"
      "sprite": beach3d
      "callback": =>

        #while @map["tiles"].length == 0
        #  console.log("wait");
        #window.setTimeout('console.log("wait")',5000);
        #console.log(@map)
        #console.log(@map.tiles)
        #tiles = @map.tiles
        #console.log(tiles)
        #console.log(tiles[5])
        for tile in @map.tiles
          if tile.isSpawner()
            @creep = new Creep @parent.eventmanager, {"coor": @map.vectorAtTile(tile.col,tile.row), "speed": new Vector(0,0.07)}
            @spawner = new Spawner @creep, @creeps, 5
            @spawners.push(@spawner)
          if tile.isHeroSpawner()
            @hero = new Hero @towers, @parent.eventmanager, @parent.keyboard, "coor": @map.vectorAtTile(tile.col,tile.row)

        # DEBUG TOWERS
#        @towers.push new Tower @parent.eventmanager, @parent.keyboard, "coor": @map.vectorAtTile(4,5)
#        @towers.push new Tower @parent.eventmanager, @parent.keyboard, "coor": @map.vectorAtTile(5,5)
#        @towers.push new Tower @parent.eventmanager, @parent.keyboard, "coor": @map.vectorAtTile(9,3)
#        @towers.push new Tower @parent.eventmanager, @parent.keyboard, "coor": @map.vectorAtTile(10,3)
#        @towers.push new Tower @parent.eventmanager, @parent.keyboard, "coor": @map.vectorAtTile(10,6)
#        @towers.push new Tower @parent.eventmanager, @parent.keyboard, "coor": @map.vectorAtTile(10,10)
#        @towers.push new Tower @parent.eventmanager, @parent.keyboard, "coor": @map.vectorAtTile(9,10)
#        @towers.push new Tower @parent.eventmanager, @parent.keyboard, "coor": @map.vectorAtTile(4,9)
#        @towers.push new Tower @parent.eventmanager, @parent.keyboard, "coor": @map.vectorAtTile(0,14)
#        @towers.push new Tower @parent.eventmanager, @parent.keyboard, "coor": @map.vectorAtTile(4,14)


  update: (delta) ->
    @hero.update(delta, @map)

    # DEBUG TOWER
    for tower in @towers
      tower.update(delta, @creeps)

    @camera.coor = @hero.coor
    for spawner in @spawners
      spawner.update(delta, @map)

    for creep in @creeps
      if creep.state == "done"
        if creep.checkout == false
          @lives -=
          creep.checkout = true
      else
        creep.update(delta, @map)

    if @lives < 0
      console.log("EPIC FAIL YOU NOOB")

    @gc(@creeps)

  render: (ctx) ->
    @camera.apply ctx, =>
      @map.render(ctx)
      #@creep.render(ctx)
      @hero.render(ctx)

      # DEBUG TOWER
      for tower in @towers
        tower.render(ctx)
      for creep in @creeps
        creep.render(ctx)

  gc: (creeps) ->
    # Remove Bullets
    @garbage_count += 1
    if @garbage_count > @garbage_every
      @garbage_count = 0

      if creeps.length > 0
        creeps =(creep for creep in creeps when creep.state != "done")
      #console.log creeps

      for tower in @towers
        tower.gc()
    return creeps

