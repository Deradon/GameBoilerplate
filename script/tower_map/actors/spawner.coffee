
# TODO:
# * speed should be aware of delta
# * get a sprite
class Spawner
  constructor: (@creep, @creeps, @quantity, @coor, @spawn_rate) ->
    @current_spawn_rate = 0
    @creep.speed = new Vector(0,0.07)
    @level = 0
    @base_quantity = @quantity

  update: (delta, map) ->
    if @quantity > 0
      @current_spawn_rate += delta
      if @current_spawn_rate >= @spawn_rate
        @current_spawn_rate -= @spawn_rate
        @spawn()
        @quantity -= 1

  render: (ctx) ->

  spawn: () ->
    new_creep = new Creep @creep.eventmanager, {"coor": @coor, "speed_factor": @creep.speed_factor, "skin": @creep.skin, "hp": @creep.hp }
    @creeps.push(new_creep)

  new_level: (new_creep, new_creeps, new_quantity, new_spawn_rate) =>
    @level += 1
    @creep =  new_creep
    @creeps = new_creeps
    @quantity = new_quantity
    @spawn_rate = new_spawn_rate

  gc: ->
    #console.log "GC"
    #@creeps =(creep for creep in @creeps when creep.state != "done")

