
class Map
  constructor: (hash) ->
    @sprite = hash["sprite"]
    @tiles = []
    @width = 0 # width and height of the map in tiles - can only be determined after the mapfile loading has completed
    @height = 0
    @loadMapDataFromImage hash["mapfile"], hash["pattern"],  hash["callback"]

  render: (ctx) ->
    for tile in @tiles
      tile.render(ctx)

  loadMapDataFromImage: (file, pattern, callback) ->
    map = new Image()
    map.src = file
    m = []
    $(map).load =>
      canvas = document.createElement("canvas")
      @width = map.width
      @height = map.height
      canvas.width = map.width
      canvas.height = map.height
      ctx = canvas.getContext("2d")
      ctx.drawImage( map, 0, 0)
      data = ctx.getImageData(0,0,map.width,map.height).data

      for p,i in data by 4
        row = Math.floor((i/4)/map.width)
        m[row] ?= []
        m[row].push [Number(data[i]).toHex(),Number(data[i+1]).toHex(),Number(data[i+2]).toHex(),Number(data[i+3]).toHex()]

      switch pattern
        when "towermap"
          for row in [0..map.height-2]
            for col in [0..map.width-2]
              type = "#{m[row][col][0]}#{m[row][col+1][0]}#{m[row+1][col][0]}#{m[row+1][col+1][0]}"
              type2 = "#{m[row][col][1]}#{m[row][col+1][1]}#{m[row+1][col][1]}#{m[row+1][col+1][1]}"
              green = parseInt( m[row][col][1], 16 )
              z = 0#parseInt( m[row][col][2], 16 )
              @tiles.push( new Tile( @sprite, type, type2, row, col, green, z ))
          #console.log @tiles #HACK
        when "simple"
          for row in [0..map.height-1]
            for col in [0..map.width-1]
              type = "#{m[row][col][0]}"
              green = parseInt( m[row][col][1], 16 )
              z = parseInt( m[row][col][2], 16 )
              @tiles.push( new Tile( @sprite, type, type2, row, col, green, z ))
        when "square"
          #EDITED ... CAN BE RESTORED
          for row in [0..map.height-2]
            for col in [0..map.width-2]
              type = "#{m[row][col][0]}#{m[row][col+1][0]}#{m[row+1][col][0]}#{m[row+1][col+1][0]}"
              type2 = "#{m[row][col][1]}#{m[row][col+1][1]}#{m[row+1][col][1]}#{m[row+1][col+1][1]}"
              green = parseInt( m[row][col][1], 16 )
              z = 0#parseInt( m[row][col][2], 16 )
              @tiles.push( new Tile( @sprite, type, type2, row, col, green, z ))
          #console.log @tiles #HACK
        when "cross"
          for row in [1..map.height-2] by 2
            for col in [1..map.width-2] by 2
              unless m[row][col][0] is "00"
                type = "#{m[row-1][col][0]}#{m[row][col+1][0]}#{m[row+1][col][0]}#{m[row][col-1][0]}"
                green = parseInt( m[row][col][1], 16 )
                z = parseInt( m[row][col][2], 16 )
                @tiles.push( new Tile( @sprite, type, type2, row/2, col/2, green, z ))
      
      # Updates surrounding tiles
      for tile in @tiles 
        if tile.row && tile.col

          for s_tile in @tiles
            if ((s_tile.row == (tile.row - 1)) && (tile.col == s_tile.col))
              tile.sourrounding["top"] = s_tile
            if ((s_tile.row == (tile.row + 1)) && (tile.col == s_tile.col))
              tile.sourrounding["bottom"] = s_tile
            if ((s_tile.row == tile.row) && ((tile.col + 1) == s_tile.col))
              tile.sourrounding["right"] = s_tile
            if ((s_tile.row == tile.row) && ((tile.col - 1) == s_tile.col))
              tile.sourrounding["left"] = s_tile
          
        #tile.sourrounding["left"]   = @tiles[(tile.row * @width + (tile.col - 1))-1]
        #tile.sourrounding["right"]  = @tiles[(tile.row * @width + (tile.col + 1))-1]
        #tile.sourrounding["top"]    = @tiles[((tile.row - 1) * @width + tile.col)-1]
        #tile.sourrounding["bottom"] = @tiles[((tile.row + 1) * @width + tile.col)-1]
      callback()
      
  # Original Method bugged
  tileAtVector: (vec) ->
    col = Math.floor( vec.x / @sprite.innerWidth )
    row = Math.floor( vec.y / @sprite.innerHeight )
#    index = row * @width + col
#    return @tiles[index]
    for tile in @tiles
      if tile.col == col && tile.row == row
        return tile

  # HACK
  vectorAtTile: (col, row) ->
    return new Vector(@sprite.innerWidth*(col+0.5), @sprite.innerHeight*(row+0.5))

class Tile
  constructor: (@sprite, @type, @type2, @row, @col, @green=0, @z=0) ->
    @sourrounding = {"left":null,"right":null,"top":null,"bottom":null}
    @builded = false
    
  isWalkable: ->
    #@green is 0
    @type is "99999999"

  isSpawner: ->
    @type2 is "ffffffff"
    
  isHeroSpawner: ->
    @type2 is "55555555"
    
  isHeroWalkable: ->
    @type is "00000000"
    
  isBuildable: ->
    @type is "00000000"
    
  isTarget: ->
    @type2 is "aaaaaaaa"

  render: (ctx) ->
    ctx.save()
    ctx.translate @col*@sprite.innerWidth - @z, @row*@sprite.innerHeight - @z
    @sprite.render( @type, ctx )
    ctx.restore()

