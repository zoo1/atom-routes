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
      return unless circuit? and innercircuit?
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
      pre = file.slice(0, 1+file.lastIndexOf("/", file.lastIndexOf("/")-1))
      read = fs.readFileSync file, "utf8"
      result = read.match(/<cfset .+\/>/g)
      for match in result
        string = match.split("fusebox.circuits.")[1].replace(/\s/g, '')[0...-2]
        if string.split("=")[0].toLowerCase() is data.circuit.toLowerCase()
          data.file = (pre + string.split("=")[1].replace(/"/g, '') + '/fbx_switch.cfm')
          return data
      return
    findLine: (data) ->
      read = fs.readFileSync data.file, "utf8"
      searchregex = new RegExp('\<cfcase value=".*' + data.innercircuit + '.*">', 'i')
      if searchregex.exec(read) isnt null
        indexedRead = read.slice(0, searchregex.exec(read).index)
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