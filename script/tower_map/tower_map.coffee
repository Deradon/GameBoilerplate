
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
  tower_map = new TowerMap( 800, 600 )
  tower_map.start()

