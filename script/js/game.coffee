
root = this 

stateclass = {}

# http://coffeescriptcookbook.com/chapters/arrays/shuffling-array-elements
Array::shuffle = -> @sort -> 0.5 - Math.random()

Number::toHex = (padding=2) ->
  hex = @toString 16
  while (hex.length < padding) 
    hex = "0" + hex
  return hex


# A simple Timer:
# it helps you keep track of the time that has elapsed since you last "punch()"-ed it


class Timer
  constructor: ->
    @last_time = new Date().getTime()
    @delta = 0
  
  # punch resets the timer and returns the time (in ms) between the last two punches
  punch: ->
    this_time = new Date().getTime()
    @delta = this_time - @last_time
    @last_time = this_time
    return @delta
    
  # delta gives you the time that has elapsed since the timer was punched the last time
  timeSinceLastPunch: ->
    this_time = new Date().getTime()
    this_time - @last_time
    
  fps: ->
    1000 / @delta

#
#  vector.coffee
#
#  Created by Kolja Wilcke in October 2011
#  Copyright 2011. All rights reserved.
#


class Vector
  constructor: (x = 0, y = 0) ->
    @x = x
    @y = y  

  clone: ->
    new Vector @x, @y

  # Add another Vector
  add: (vec) ->
    new Vector @x + vec.x, @y + vec.y

  # Just for convenience
  subtract: (vec) ->
    new Vector @x - vec.x, @y - vec.y

  # multiply the vector with a Number
  mult: (num) ->
    new Vector @x * num, @y * num

  # returns the length of the vector (Betrag)
  length: ->
    Math.sqrt @x*@x + @y*@y

  # return the length squared (for optimisation)
  lengthSquared: ->
    @x*@x + @y*@y

  # returns the normalized vector (Length = 1)
  norm: (factor=1) ->
    l = @length()
    if ( l > 0 ) 
      return @mult factor/l
    else
      return null

  # returns the scalarproduct
  scalarProduct: (vec) ->
    @x * vec.x + @y * vec.y

  sameDirection: (vec) ->
    if (@lengthSquared() < @add(vec).lengthSquared())
      return true
    else
      return false

  # returns the angle it forms with a given vector
  angleWith: (vec) ->
    Math.acos( @scalarProduct( vec ) / @length() * vec.length() )

  # returns the vectorproduct (vector/Kreuzprodukt) -- not yet implemented
  vectorProduct: (vec) ->
    return this

  # returns the component parallel to a given vector
  projectTo: (vec) ->
    vec.mult( @scalarProduct(vec) / vec.lengthSquared() )



  # Class method: checks if two vectors are intersecting - returns intersection point
  @intersecting: (oa, a, ob, b) ->
    
    c = ob.subtract oa
    b = b.mult -1
    col = []
    
    col[0] = a.clone()
    col[1] = b.clone()
    col[2] = c.clone()
    l=0; m=1; n=2
    
    # Multiplicator
    
    mult = col[0].y / col[0].x
    
    # Bring Matrix into Triangular shape
     
    col[0].y = 0
    col[1].y = col[1].y - (mult * col[1].x)    
    col[2].y = col[2].y - (mult * col[2].x)
    
    # Reverse Substitution
    
    mu = col[n].y / col[m].y
    # lb = (col[n].x - (col[m].x * mu)) / col[l].x #  mu is sufficient so this doesn't need to be done
    
    return ob.subtract( b.mult(mu) )
    
  print: ->
    return "(#{@x}, #{@y})"






class Eventmanager
  constructor: ->
    @eventlist = {} 
  
  register: (event, callback) ->
    unless @eventlist[event]?
      @eventlist[event] = []
    @eventlist[event].push callback

  trigger: (event, origin) ->
    for callback in @eventlist[event]
      callback(origin)


class Keyboard
  constructor: ->
    @keyarray = []
    for direction in ['left', 'up', 'right', 'down', 'space']
      @keyarray[direction] = false
      
    $("html").bind "keydown", (event) =>
      directions = {37:"left",38:"up",39:"right",40:"down",32:"space"}
      @keyarray[directions[event.which]] = true
      
    $("html").bind "keyup", (event) =>
      directions = {37:"left",38:"up",39:"right",40:"down",32:"space"}
      @keyarray[directions[event.which]] = false
      
  key: (which) ->
    return @keyarray[which]



class Game
  constructor: (@width, @height) ->
    canvas = $('<canvas/>').attr({"width": @width, "height": @height})
    $("body").append(canvas)
    @ctx = canvas[0].getContext('2d')
    @ctx.font = '400 18px Helvetica, sans-serif'
    @loop = null
    @timer = new Timer

  gameloop: =>
    @update()
    @render()

  start: ->
    @loop = setInterval @gameloop, 1

  stop: ->
    @loop.clearInterval()

  update: ->
    @timer.punch()

  render: ->
    @ctx.fillText( @timer.fps().toFixed(1), 960, 20 )




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
    #@tileTop = null
    #@tileBottom = null
    #@tileLeft = null
    #@tileRight = null
    
  isWalkable: ->
    #@green is 0
    @type is "99999999"

  render: (ctx) ->
    ctx.save()
    ctx.translate @col*@sprite.innerWidth - @z, @row*@sprite.innerHeight - @z
    @sprite.render( @type, ctx )
    ctx.restore()





class Background

  constructor: (@sprite) ->
    @sprite.addImage "background", 0
  

  render: (ctx) ->
    @sprite.render( "background", ctx )
    
        


# Every sprite has a Texture and a number of Assets.
# These Assets can be of type Shape (simple Images) or Animation
# 
# usage:
#
# sprite = new Sprite
#   "texture": "img/texture.png
#   "width":50
#   "height":50
#   "key":
#     "spaceship": 1
#     "rock": 2
#     "enemy": 3
# 
# sprite.render("spaceship")
#

class Sprite
  constructor: (hash) ->
    @assets = {}
    @width = hash["width"]
    @height = hash["height"]
    @texture = new Image()
    @texture.src = hash["texture"]
    @key = hash["key"] ? {}
      
    for key, i of @key
      @addImage key, i

    @innerWidth = hash["innerWidth"] ? @width
    @innerHeight = hash["innerHeight"] ? @height
    
  addImage: (name, index) ->
    $(@texture).load =>
      @texWidth = @texture.width
      @assets[name] = new Shape this, index
    
  addAnimation: (name, params) ->
    $(@texture).load =>
      @texWidth = @texture.width
      @assets[name] = new Animation this, params
    
  render: (name, ctx) ->
    @assets[name].render(ctx) if @assets[name]?

class Shape
  constructor: (@sprite, index) ->
    @sx = ( index * @sprite.width ) % @sprite.texWidth
    @sy = Math.floor(( index * @sprite.width ) / @sprite.texWidth) * @sprite.height
    
  render: (ctx) ->
    ctx.save()
    ctx.translate @sprite.width/2, @sprite.height/2
    ctx.drawImage( @sprite.texture, @sx, @sy, @sprite.width, @sprite.height, 0, 0, @sprite.width, @sprite.height )
    ctx.restore()

class Animation 
  constructor: (@sprite, params) ->
    @fps = params["fps"] ? 30
    @loop = params["loop"] ? true
    @callback = params["callback"] ? null
    @frames = for index in params["frames"]
      new Shape @sprite, index
    @lastFrame = @frames.length - 1
    @timer = new Timer
    @currentFrame = 0
    @playing = true
    
  render: (ctx) ->
    if @playing
      @currentFrame = Math.floor( @timer.timeSinceLastPunch() / (1000 / @fps) )
      if @currentFrame > @lastFrame
        @callback()
        if @loop
          @rewind()
        else
          @currentFrame = @lastFrame
          @stop()
        
    @frames[@currentFrame].render(ctx)
    
  play: ->
    @playing = true
    
  stop: ->
    @playing = false
    
  rewind: ->
    @currentFrame = 0
    @timer.punch()
    


class State

	constructor: ->

	update: ->

	draw: ->


class Statemanager
  constructor: (@parent, states) ->
    @statearray = {}
    @currentState = null
    for state in states  
      @addState state
    
  addState: (state) ->
    @statearray[state] = new stateclass[state] @parent
    @setState state unless @currentState? # when a state is added for the first time, it automatically becomes the @currentState

  setState: (state) ->
    @currentState = @statearray[state]




class Camera

  constructor: (hash) ->
    @projection = hash["projection"]
    @vpWidth = hash["vpWidth"]
    @vpHeight = hash["vpHeight"]
    @coor = new Vector( 100, 100 )

  update: (delta) ->

  apply: (ctx, callback) ->
    switch @projection
      when "normal"
        ctx.save()
        ctx.translate @vpWidth/2 - @coor.x, @vpHeight/2 - @coor.y
        callback()
        ctx.restore()
      when "iso"
        ctx.save()
        ctx.scale 1, 0.4 # 1,0.4
        ctx.rotate Math.PI/4
        ctx.translate 300, -400 # 200,-400
        callback()
        ctx.restore()




# Main Game Controller / Root entry point
# Adjustments you make here will affect your whole Game.


class TowerMap extends Game

  constructor: (width, height) ->
    super width, height

    @eventmanager = new Eventmanager
    @keyboard = new Keyboard

    @stateManager = new Statemanager this, ["main_map"]
    @stateManager.setState "main_map"


  update: ->
    super()
    @stateManager.currentState.update @timer.delta

  render: ->
    @ctx.clearRect 0, 0, @width, @height
    @stateManager.currentState.render @ctx
    super()


$ ->
  tower_map = new TowerMap( 1024, 768 )
  tower_map.start()




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





class Hero
  constructor: (@eventmanager, @keyboard, options) ->

    @state = "normal"
    @sprite = new Sprite
      "texture": "assets/images/test.png"
      "width": 50
      "height": 50
      "key":
        "normal": 3
        "jumping": 5

    @coor = options["coor"]
    @start_coor = @coor
    @speed = new Vector( 0, 0 )
    @force = 0.01
    @gravity = 0.00

    # event Manager
    @eventmanager.register "touchdown", @touchdown

  touchdown: ->
    console.log "Hero says: Touchdown occurred"

  update: (delta, map) ->
    tile = map.tileAtVector(@coor)
    $("#debug").html("#{tile.row} - #{tile.col}")

    # left/right movement
    if @keyboard.key("right")
      @speed.x += @force
    else if @keyboard.key("left")
      @speed.x -= @force
    else
      if @speed.x > 0
        @speed.x -= @force
      else
        @speed.x += @force

    # up/down movement
    # left/right movement
    if @keyboard.key("up")
      @speed.y -= @force
    else if @keyboard.key("down")
      @speed.y += @force
    else
      if @speed.y > 0
        @speed.y -= @force
      else
        @speed.y += @force

    # apply gravity
    if !tile.isWalkable?()
      $("#debug-last-tile").html("#{tile.row} - #{tile.col}")
      console.log tile
      @coor = @start_coor
      @speed.y = 0
      @speed.x = 0

    if @keyboard.key("up")
      @speed.y -= 0.0
      @speed.x -= 0.0

#    # jump
#    if @keyboard.key("space") and @state isnt "jumping"
#      @state = "jumping"
#      @speed.y = -0.5

    @coor = @coor.add( @speed.mult delta )

  render: (ctx) ->
    ctx.save()
    ctx.translate @coor.x, @coor.y
    @sprite.render( @state, ctx )
    ctx.restore()





class Creep
  constructor: (@eventmanager, options) ->

    

  update: (delta, map) ->
    tile = map.tileAtVector(@coor)
    if !tile.isWalkable?()

    @coor = @coor.add( @speed.mult delta )
    @last_tile = tile
    
  render: (ctx) ->
    ctx.save()
    ctx.translate @coor.x, @coor.y
    @sprite.render( @state, ctx )
    ctx.restore()

