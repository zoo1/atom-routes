
Main = require '../lib/main'

describe 'Routes', ->
  [routes, editor, editorView] = []

  beforeEach ->
    atom.config.set 'routes.parsingAlgorithm', 'Coldfusion Fusebox'
    waitsForPromise ->
      atom.workspace.open('sample.js')

    runs ->
      Main.activate()
      editor = atom.workspace.getActiveTextEditor()
      editorView = atom.views.getView(editor)
      editor.setCursorBufferPosition([1, 0])


  describe "when routes:toggle is triggered", ->
    it "adds a modal panel", ->
      expect(atom.workspace.getModalPanels()[0].isVisible()).toBeFalsy()
      atom.commands.dispatch 'atom-workspace', 'routes:toggle'
      expect(atom.workspace.getModalPanels()[0].isVisible()).toBeTruthy()