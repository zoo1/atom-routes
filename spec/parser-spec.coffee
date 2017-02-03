
atom.config.set 'routes.parsingAlgorithm', 'Coldfusion Fusebox'
Parser = require '../lib/parser'

describe 'Coldfusion Fusebox', ->

  describe "parseInput", ->
    describe "When no data is entered for input or routes", ->
      it "fails parseInput", ->
        expect(Parser.parse("",[]).error).toBeDefined()
        expect(Parser.parse("fuseaction=test.bed").error).toBeDefined()
