{$, TextEditorView, View}  = require 'atom-space-pen-views'
parser = require './parser'

module.exports =
class RoutesView extends View
  @content: ->
    @div class: 'routes', =>
      @subview 'miniEditor', new TextEditorView(mini: true)
      @span class: 'message', outlet: 'message'

  initialize: ->
    @panel = atom.workspace.addModalPanel(item: this, visible: false)

    @miniEditor.on 'blur', => @close() unless not document.hasFocus()

    atom.commands.add @miniEditor.element, 'core:confirm', => @confirm()
    atom.commands.add @miniEditor.element, 'core:cancel', => @close()

  toggle: ->
    if @panel.isVisible()
      @close()
    else
      @open()

  close: ->
    return unless @panel.isVisible()

    miniEditorFocused = @miniEditor.hasFocus()
    @miniEditor.setText('')
    @panel.hide()
    @restoreFocus() if miniEditorFocused

  confirm: ->
    input = @miniEditor.getText()
    #TODO add a better way to add origin files
    originFiles = JSON.parse(atom.config.get('routes.originFiles'))

    @close()

    # need to add checks for the existance of input and routes
    return unless input.length and originFiles.length

    data = parser.parseInput input, originFiles
    if not data?
      @error "There was an error parsing your input."
      return
    data = parser.findFile data
    if not data?
      @error "There was an error finding your file."
      return
    data = parser.findLine data
    if not data?
      @error "There was an error finding the correct line number."
      return

    atom.workspace.open(data.file)
    .then (editor) ->
      editor.scrollToBufferPosition(data.point, center: true)
      editor.setCursorBufferPosition(data.point)

  error: (message) ->
    atom.notifications.addError message,
      dismissable: true

  storeFocusedElement: ->
    @previouslyFocusedElement = $(':focus')

  restoreFocus: ->
    if @previouslyFocusedElement?.isOnDom()
      @previouslyFocusedElement.focus()
    else
      atom.views.getView(atom.workspace).focus()

  open: ->
    return if @panel.isVisible()

    @storeFocusedElement()
    @panel.show()
    @message.text("Enter the route you want to go to")
    @miniEditor.focus()
