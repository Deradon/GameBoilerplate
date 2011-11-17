
stateclass["main_map"] = class StateMainMap extends State
  constructor: (@parent) ->
#    @camera = new Camera {"projection": "normal", "vpWidth": @parent.width, "vpHeight": @parent.height}
    @camera = new Camera {"projection": "iso", "vpWidth": @parent.width, "vpHeight": @parent.height}

    @creeps   = []
    @lives    = 20
    @gameover = false
    @gold     = 500
    @spawners = []
    @towers   = []
    @won = false

    @level = 1
    @creep_levels = []
    @creep_levels[0] = {
      "creep": new Creep(@parent.eventmanager, {
        "speed_factor": 0.1
        "skin": 0
        "hp": 500
      }),
      "amount": 5,
      "spawn_rate": 1000
    }

    @creep_levels[1] = {
      "creep": new Creep(@parent.eventmanager, {
        "speed_factor": 0.2
        "skin": 4
        "hp": 1000
      }),
      "amount": 10,
      "spawn_rate": 1000
    }

    @creep_levels[2] = {
      "creep": new Creep(@parent.eventmanager, {
        "speed_factor": 0.25
        "skin": 6
        "hp": 1500
      }),
      "amount": 20,
      "spawn_rate": 1000
    }

    @creep_levels[3] = {
      "creep": new Creep(@parent.eventmanager, {
        "speed_factor": 0.25
        "skin": 1
        "hp": 2200
      }),
      "amount": 99,
      "spawn_rate": 700
    }


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

        for tile in @map.tiles
          if tile.isSpawner()
            #@creep = new Creep @parent.eventmanager, {"coor": @map.vectorAtTile(tile.col,tile.row), "speed": new Vector(0,0.07)}
            @spawner = new Spawner @creep_levels[@level-1]["creep"], @creeps, @creep_levels[@level-1]["amount"], @map.vectorAtTile(tile.col,tile.row), @creep_levels[@level-1]["spawn_rate"]
            @spawners.push(@spawner)
          if tile.isHeroSpawner()
            @hero = new Hero @towers, @parent.eventmanager, @parent.keyboard, "coor": @map.vectorAtTile(tile.col,tile.row)


        @parent.eventmanager.register "gain_gold", =>
          @gold += 50

          creeps_dead = true
          for creep in @creeps
            if creep.state == "normal"
              creeps_dead = false

          if creeps_dead
            @creeps = []
            if @level < @creep_levels.length
              @level += 1
              for spawner in @spawners
                spawner.new_level @creep_levels[@level-1]["creep"], @creeps, @creep_levels[@level-1]["amount"], @creep_levels[@level-1]["spawn_rate"]
            else
              @won = true



  update: (delta) ->
    if !@gameover
      @gold = @hero.update(delta, @map, @gold)
      @camera.coor = @hero.coor
    else
      @camera.coor = @creeps[0].coor

    # DEBUG TOWER
    for tower in @towers
      tower.update(delta, @creeps)

    for spawner in @spawners
      spawner.update(delta, @map)

    for creep in @creeps
      if creep.state == "done"
        if creep.checkout == false
          if @lives > 0
            @lives -= 1
            #@eventmanager.trigger "creep_reached"
          else
            @gameover = true
          creep.checkout = true
      else
        creep.update(delta, @map)
    @gc()

  render: (ctx) ->
    @camera.apply ctx, =>
      @map.render(ctx)
      #@creep.render(ctx)


      # DEBUG TOWER
      for creep in @creeps
        creep.render(ctx)
      for tower in @towers
        tower.render(ctx)
      if !@gameover
        @hero.render(ctx)

    if @gameover
      ctx.font = 'bold 70px Arial, sans-serif'
      ctx.fillText( "GAME OVER", 190, 300 )
      ctx.strokeText( "GAME OVER", 190, 300 )
    else
      if @won
        ctx.font = 'bold 70px Arial, sans-serif'
        ctx.fillText( "YOU WON !!!", 190, 300 )
        ctx.strokeText( "YOU WON !!!", 190, 300 )
      else
        ctx.fillText( "Leben: #{@lives}", 20, 40 )
        ctx.strokeText( "Leben: #{@lives}", 20, 40 )
        ctx.fillText( "Gold: #{@gold}", 20, 75 )
        ctx.strokeText( "Gold: #{@gold}", 20, 75 )
        ctx.fillText( "Level: #{@level}", 20, 110 )
        ctx.strokeText( "Level: #{@level}", 20, 110 )

  gc: =>
    # Remove Bullets
    @garbage_count += 1
    if @garbage_count > @garbage_every
      @garbage_count = 0

      for spawner in @spawners
        spawner.gc()

      for tower in @towers
        tower.gc()

