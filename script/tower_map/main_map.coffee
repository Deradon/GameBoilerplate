
stateclass["main_map"] = class StateMainMap extends State
  constructor: (@parent) ->
    @camera = new Camera {"projection": "iso", "vpWidth": @parent.width, "vpHeight": @parent.height}

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
      "pattern": "square"
      "sprite": beach3d

    @creep = new Creep @parent.eventmanager, {"coor": @map.vectorAtTile(2,0), "speed": new Vector(0,0.1)}



  update: (delta) ->
    @creep.update(delta, @map)
    #@camera.coor = @hero.coor

  render: (ctx) ->
    @camera.apply ctx, =>
      @map.render(ctx)
      @creep.render(ctx)

