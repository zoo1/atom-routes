module.exports =
  # Your config schema
  config:
    parsingAlgorithm:
      type: 'string'
      default: 'Coldfusion Fusebox'
      enum: ['Coldfusion Fusebox']
    originFiles:
      type: 'string'
      default: '[]'

  activate: ->
    #Init Views
    routesView = require './routes-view'
    routes = new routesView()

    #Init commands
    atom.commands.add 'atom-workspace', 'routes:toggle', ->
      routes.toggle()
      false