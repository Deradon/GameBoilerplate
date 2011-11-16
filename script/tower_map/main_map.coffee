
stateclass["main_map"] = class StateMainMap extends State
  constructor: (@parent) ->
    @camera = new Camera {"projection": "iso", "vpWidth": @parent.width, "vpHeight": @parent.height}

    @hero = new Hero @parent.eventmanager, @parent.keyboard
    @hero.coor = new Vector(200,200)
    @hero.gravity = 0.0

    console.log @hero

    beach3d = new Sprite
      "texture": "assets/images/beach3d.png"
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

    @background = new Map
      "mapfile": "assets/towermap_map1.png"
      "pattern": "square"
      "sprite": beach3d


  update: (delta) ->
    @hero.update(delta, @background)
    @camera.coor = @hero.coor

  render: (ctx) ->
    @camera.apply ctx, =>
      @background.render(ctx)
      @hero.render(ctx)

