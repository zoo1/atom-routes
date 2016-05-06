{Point} = require 'atom'
fs = require 'fs'
{$, TextEditorView, View}  = require 'atom-space-pen-views'

module.exports =
class RoutesView extends View
  @content: ->
    @div class: 'routes', =>
      @subview 'miniEditor', new TextEditorView(mini: true)
      @span class: 'message', outlet: 'message'
      @span id: 'settings', class: 'icon icon-gear inline-block pull-right', style: 'color:#528bff;'

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
    routes = JSON.parse(atom.config.get('routes.originFiles'))

    @close()

    # need to add checks for the existance of input and routes
    return unless input.length and routes.length

    #parse URL and split into parts
    parseInput = (input, routes) ->
      fuseaction = input
      if fuseaction.match(/fuseaction=/i)
        fuseaction = fuseaction.split("fuseaction=")[1]
        if fuseaction.match(/&/)
          fuseaction = fuseaction.split("&")[0]
      [circuit, innercircuit] = fuseaction.split('.')
      data =
        circuit:	circuit
        innercircuit:	innercircuit
      for pair in routes
        if input.indexOf(pair[0]) > -1
          data.route = pair[1]
          return data

    data = parseInput input, routes
    return unless data.circuit? and data.innercircuit?


    findfile = (data) ->
      file = data.route
      pre = file.slice(0, 1+file.lastIndexOf("/", file.lastIndexOf("/")-1))
      read = fs.readFileSync file, "utf8"
      result = read.match(/<cfset .+\/>/g)
      for match in result
        string = match.split("fusebox.circuits.")[1].replace(/\s/g, '')[0...-2]
        if string.split("=")[0].toLowerCase() is data.circuit.toLowerCase()
          data.file = (pre + string.split("=")[1].replace(/"/g, '') + '/fbx_switch.cfm')
          return data

    data = findfile data

    findline = (data) ->
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

    # finds the line
    data = findline data

    atom.workspace.open(data.file)
    .then (editor) ->
      editor.scrollToBufferPosition(data.point, center: true)
      editor.setCursorBufferPosition(data.point)

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
