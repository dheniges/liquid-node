Q      = require 'q'
Liquid = require "../../liquid"
fs     = require 'fs'

# TODO: include support for 'with' and 'for'

module.exports = class Include extends Liquid.Tag

  Syntax = /([a-z0-9\/\\_-]+)/i
  SyntaxTwo = ///(#{Liquid.QuotedFragment.source})///

  SyntaxHelp = "Syntax Error in 'include' -
                Valid syntax: include [templateName]"

  constructor: (template, tagName, markup, tokens) ->
    console.log('constructing')
    match = SyntaxTwo.exec(markup)
    throw new Liquid.SyntaxError(SyntaxHelp) unless match

    super

    @engine = template.engine
    @templateName = match[1]
    #@variableName = match[3] || @templateName

    # The ruby liquid implementation defines an Expression class
    # with a parse method that is defined in this library as a
    # `resolve` function on the context object. We do not have
    # access to context in the constructor, so we have to resolve
    # variables in render

    @attributes = {}

    # TODO: iterate over markup to assign @attributes keys
    # markup.scan(TagAttributes) {|key, value| @attributes[key] = Expression.parse(value)}

  parse: (tokens) ->

  render: (context) ->
    #@variableName = context.resolve(@variableName)
    @templateName = context.resolve(@templateName)

    @loadCachedPartial(context).then (partial) ->
      #variable = context.evaluate(@variableName)
      #context[@contextVariableName] = variable
      partial.render(context)

  loadCachedPartial: (context) ->
    # cachedPartials = context.registers['cachedPartials'] || {}
    # TODO: implement caching
    source = @readTemplateFromFileSystem(context)
    @engine.parse(source)

  readTemplateFromFileSystem: (context) ->
    Liquid.Template.fileSystem.readTemplateFile(@templateName)


