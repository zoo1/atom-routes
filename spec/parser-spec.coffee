
atom.config.set 'routes.parsingAlgorithm', 'Coldfusion Fusebox'
Parser = require '../lib/parser'

describe 'Coldfusion Fusebox', ->

  describe "parseInput", ->
    describe "When no data is entered for input or routes", ->
      it "fails parseInput", ->
        expect(Parser.parseInput("",[])).toBeUndefined()
        expect(Parser.parseInput("fuseaction=test.bed")).toBeUndefined()

    describe "When a URL is passed as valid input", ->
      it "correctly parses circuit and innercircuit", ->
        result = Parser.parseInput("test.test.com/fuseaction=circuit.inner",[["/","file/path"]])
        expect(result).toBeDefined()
        expect(result.circuit).toEqual "circuit"
        expect(result.innercircuit).toEqual "inner"