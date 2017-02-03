parse = null

algorithms =
  'Coldfusion Fusebox': 'CFFusebox'

updateAlgo = (algo) ->
  parse = require "./parser/#{algorithms[algo]}"

updateAlgo(atom.config.get('routes.parsingAlgorithm'))
atom.config.observe 'routes.parsingAlgorithm', (value) ->
  updateAlgo(value)

module.exports = parse