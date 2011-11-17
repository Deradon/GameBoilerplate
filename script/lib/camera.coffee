

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

        # MONKEYPATCH: Added viewport to iso camera
        # TODO: correct center
        #ctx.translate 300, -400 # 200,-400
        ctx.translate @vpWidth/2 - @coor.x + 300, @vpHeight/2 - @coor.y - 250

        callback()
        ctx.restore()

