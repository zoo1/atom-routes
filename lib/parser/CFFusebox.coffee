fs = require 'fs'
{Point} = require 'atom'

parse = (input, routes) ->
  fuseaction = input
  if fuseaction.match(/fuseaction=/i)
    fuseaction = fuseaction.split("fuseaction=")[1]
    if fuseaction.match(/&/)
      fuseaction = fuseaction.split("&")[0]
  [circuit, innercircuit] = fuseaction.split('.')

  return {error: "There was an error parsing your input."} unless circuit? and innercircuit? and routes?
  data =
    circuit: circuit
    innercircuit: innercircuit
  for pair in routes
    if input.indexOf(pair[0]) > -1
      data.route = pair[1]
      return findFile data
  data.route = routes[routes.length - 1][1]
  findFile data

findFile = ({route, circuit, innercircuit}) ->
  path = route.slice(0, 1+route.lastIndexOf("/", route.lastIndexOf("/")-1))
  read = fs.readFileSync route, "utf8"
  searchregex = new RegExp("fusebox.circuits.#{circuit} = \"(.*)\"", 'i')
  result = searchregex.exec read
  if result isnt null
    file = (path + result[1] + '/fbx_switch.cfm')
    return findLine {file, innercircuit}
  {error: "There was an error finding your file."}

findLine = ({file, innercircuit}) ->
  read = fs.readFileSync file, "utf8"
  searchregex = new RegExp('\<cfcase value=".*\\b' + innercircuit + '\\b.*">', 'i')
  result = searchregex.exec read
  if result isnt null
    indexedRead = read.slice(0, result.index)
    row = indexedRead.split(/\r\n|\r|\n/).length - 1
    column = indexedRead.length - indexedRead.lastIndexOf("\n") - 1
    point = new Point(row, column)
    {file, point}
  else if read.indexOf('<cfdefaultcase>') > -1
    indexedRead = read.slice(0, read.lastIndexOf('<cfdefaultcase>'))
    row = indexedRead.split(/\r\n|\r|\n/).length - 1
    column = indexedRead.length - indexedRead.lastIndexOf("\n") - 1
    point = new Point(row, column)
    {file, point}
  else
    point = new Point(0, 0)
    {file, point}

module.exports = parse