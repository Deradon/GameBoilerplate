# https://github.com/jashkenas/coffee-script/wiki/[HowTo]-Compiling-and-Setting-Up-Build-Tools

fs     = require 'fs'
{exec} = require 'child_process'

libFiles  = [
  'irf/background'
  'irf/boundingbox'
  'irf/camera'
  'irf/eventmanager'
  'irf/game'
  'irf/helpers'
  'irf/keyboard'
  'irf/map'
  'irf/scene'
  'irf/scenemanager'
  'irf/sprite'
  'irf/timer'
  'irf/vector'
]
libFiles.push 'irf' # THIS MUST BE LAST REQUIRED FILE


task 'build', 'Build single application file from source files', ->
  files = libFiles
  appContents = new Array remaining = files.length
  for file, index in files then do (file, index) ->
    fs.readFile "src/#{file}.coffee", 'utf8', (err, fileContents) ->
      throw err if err
      appContents[index] = fileContents
      process() if --remaining is 0
  process = ->
    fs.writeFile 'lib/irf.coffee', appContents.join('\n\n'), 'utf8', (err) ->
      throw err if err
      exec 'coffee --compile lib/irf.coffee', (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr
        fs.unlink 'lib/irf.coffee', (err) ->
          throw err if err
          console.log 'Done.'

