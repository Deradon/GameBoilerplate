
# TODO:
# * speed should be aware of delta
# * get a sprite
class Spawner
  constructor: (@creep, @creeps, @quantity) ->
    @spawn_rate = 1500
    @current_spawn_rate = 0
    @creep.speed = new Vector(0,0.07)

  update: (delta, map) ->
    if @quantity > 0
      @current_spawn_rate += delta
      if @current_spawn_rate >= @spawn_rate
        @current_spawn_rate -= @spawn_rate
        @spawn()
        @quantity -= 1

  render: (ctx) ->

  spawn: () ->
    new_creep = new Creep @creep.eventmanager, {"coor": @creep.coor, "speed": @creep.speed }
    @creeps.push(new_creep)

  gc: ->
    #console.log "GC"
    #@creeps =(creep for creep in @creeps when creep.state != "done")

