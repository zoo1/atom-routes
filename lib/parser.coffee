fs = require 'fs'
{Point} = require 'atom'
[parseInput, findFile, findLine] = []

updateAlgorithms = (newAlgorithm) ->
  parseInput = algorithms[newAlgorithm].parseInput
  findFile = algorithms[newAlgorithm].findFile
  findLine = algorithms[newAlgorithm].findLine

algorithms =
  "Coldfusion Fusebox":
    parseInput: (input, routes) ->
      fuseaction = input
      if fuseaction.match(/fuseaction=/i)
        fuseaction = fuseaction.split("fuseaction=")[1]
        if fuseaction.match(/&/)
          fuseaction = fuseaction.split("&")[0]
      [circuit, innercircuit] = fuseaction.split('.')
      return unless circuit? and innercircuit? and routes?
      data =
        circuit:	circuit
        innercircuit:	innercircuit
      for pair in routes
        if input.indexOf(pair[0]) > -1
          data.route = pair[1]
          return data
      data.route = routes[routes.length - 1][1]
      return data
    findFile: (data) ->
      file = data.route
      path = file.slice(0, 1+file.lastIndexOf("/", file.lastIndexOf("/")-1))
      read = fs.readFileSync file, "utf8"
      searchregex = new RegExp('fusebox.circuits.' + data.circuit + ' = "(.*)"', 'i')
      result = searchregex.exec read
      if result isnt null
        data.file = (path + result[1] + '/fbx_switch.cfm')
        return data
      return
    findLine: (data) ->
      read = fs.readFileSync data.file, "utf8"
      searchregex = new RegExp('\<cfcase value=".*\\b' + data.innercircuit + '\\b.*">', 'i')
      result = searchregex.exec read
      if result isnt null
        indexedRead = read.slice(0, result.index)
        row = indexedRead.split(/\r\n|\r|\n/).length - 1
        column = indexedRead.length - indexedRead.lastIndexOf("\n") - 1
        data.point = new Point(row, column)
        return data
      if read.indexOf('<cfdefaultcase>') > -1
        indexedRead = read.slice(0, read.lastIndexOf('<cfdefaultcase>'))
        row = indexedRead.split(/\r\n|\r|\n/).length - 1
        column = indexedRead.length - indexedRead.lastIndexOf("\n") - 1
        data.point = new Point(row, column)
        return data
      data.point = new Point(0, 0)
      return data

updateAlgorithms(atom.config.get('routes.parsingAlgorithm'))
atom.config.observe 'routes.parsingAlgorithm', (newValue) ->
  updateAlgorithms(newValue)

module.exports =
  parseInput: parseInput
  findFile: findFile
  findLine: findLine