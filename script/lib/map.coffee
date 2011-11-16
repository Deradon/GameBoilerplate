
class Map
  constructor: (hash) ->
    @sprite = hash["sprite"]
    @tiles = []
    @width = 0 # width and height of the map in tiles - can only be determined after the mapfile loading has completed
    @height = 0
    @loadMapDataFromImage hash["mapfile"], hash["pattern"]

  render: (ctx) ->
    for tile in @tiles
      tile.render(ctx)

  loadMapDataFromImage: (file, pattern) ->
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
        when "simple"
          for row in [0..map.height-1]
            for col in [0..map.width-1]
              type = "#{m[row][col][0]}"
              green = parseInt( m[row][col][1], 16 )
              z = parseInt( m[row][col][2], 16 )
              @tiles.push( new Tile( @sprite, type, row, col, green, z ))
        when "square"
          for row in [0..map.height-2]
            for col in [0..map.width-2]
              type = "#{m[row][col][0]}#{m[row][col+1][0]}#{m[row+1][col][0]}#{m[row+1][col+1][0]}"
              green = parseInt( m[row][col][1], 16 )
              z = 0#parseInt( m[row][col][2], 16 )
              @tiles.push( new Tile( @sprite, type, row, col, green, z ))
          #console.log @tiles #HACK
        when "cross"
          for row in [1..map.height-2] by 2
            for col in [1..map.width-2] by 2
              unless m[row][col][0] is "00"
                type = "#{m[row-1][col][0]}#{m[row][col+1][0]}#{m[row+1][col][0]}#{m[row][col-1][0]}"
                green = parseInt( m[row][col][1], 16 )
                z = parseInt( m[row][col][2], 16 )
                @tiles.push( new Tile( @sprite, type, row/2, col/2, green, z ))
      
      # Updates surrounding tiles
      #for tile in @tiles 

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
  constructor: (@sprite, @type, @row, @col, @green=0, @z=0) ->
    @tileTop = null
    @tileBottom = null
    @tileLeft = null
    @tileRight = null
    
  isWalkable: ->
    #@green is 0
    @type is "99999999"

  render: (ctx) ->
    ctx.save()
    ctx.translate @col*@sprite.innerWidth - @z, @row*@sprite.innerHeight - @z
    @sprite.render( @type, ctx )
    ctx.restore()

