

class Creep
  constructor: (@eventmanager, options) ->

    @state = "normal"
    @sprite = new Sprite
      "texture": "assets/images/test.png"
      "width": 50
      "height": 50
      "key":
        "normal": 3
        "jumping": 5

    #@last_tile = null
    @coor = options["coor"]
    @start_coor = @coor
    if options["speed"]
      @speed = options["speed"]
    else
      @speed = new Vector( 0, 0 )
    @force = 0.00
    @gravity = 0.00

  update: (delta, map) ->
    tile = map.tileAtVector(@coor)
    
    new_coor = @coor.add( @speed.mult delta )
    walkable = map.tileAtVector(new_coor).isWalkable?()
    if map.tileAtVector(new_coor).isWalkable?()
      @coor = new_coor
    else
      #console.log("nicht walkable")
      console.log(tile)
      #console.log(@last_tile)
      #console.log(direction_tile != @last_tile)
      for key, direction_tile of tile.sourrounding
        
        if direction_tile && direction_tile?.isWalkable?()
          console.log("walkable tile vorhanden")
          #if !((direction_tile.col == @last_tile.col) && (direction_tile.row == @last_tile.row))
            #console.log("#{direction_tile.col} - #{direction_tile.row}")
            #console.log("#{@last_tile.col} - #{@last_tile.row}")
            #console.log((direction_tile.col != @last_tile.col)  && (direction_tile.row != @last_tile.row))
          if key == "left"
            @new_speed = new Vector( 0,0.07 )
          else if key == "right"
            @new_speed = new Vector( 0,-0.07 )
          else if key == "top"
            @new_speed = new Vector(  0.07,0 )
          else if key == "bottom"
            @new_speed = new Vector( -0.07,0 )
          
         
          if @speed != @new_speed.mult(-1)
            console.log("#{key} - speed: #{@speed.x}, #{@speed.y}")
            console.log("#{key} - new speed: #{@new_speed.x}, #{@new_speed.y}")
            @speed = @new_speed
          
         
          
      #if (tile.leftTile && tile.leftTile.isWalkable?() && (tile.leftTile != @last_tile))
      #  @speed = new Vector( -0.1, 0 )
      #else if (tile.rigthTile && tile.rigthTile.isWalkable?() && (tile.rigthTile != @last_tile))
      #  @speed = new Vector( 0.1, 0 )
      #else if (tile.bottomTile && tile.bottomTile.isWalkable?() && (tile.bottomTile != @last_tile))
      #  @speed = new Vector( 0, 0.1 )
      #else if (tile.topTile && tile.topTile.isWalkable?() && (tile.topTile != @last_tile))
      #  @speed = new Vector( 0, -0.1 )

    #if @last_tile != tile
    #  @last_tile = tile
    #@coor = @coor.add( @speed.mult delta )

  render: (ctx) ->
    ctx.save()
    ctx.translate @coor.x, @coor.y
    @sprite.render( @state, ctx )
    ctx.restore()

