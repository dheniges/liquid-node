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

    templateName = match[1]
    variableName = templateName[1..-2]
    [first, ..., last] = variableName.split('/')

    # The ruby liquid implementation defines an Expression class
    # with a parse method that is defined in this library as a
    # `resolve` function on the context object. We do not have
    # access to context in the constructor, so we have to resolve
    # variables in render
    @unresolvedVariableName = variableName #context.resolve(variableName)
    @contextVariableName = last
    @unresolvedTemplateName = templateName #context.resolve(templateName)
    @attributes = {}

    # TODO: iterate over markup to assign @attributes keys
    # markup.scan(TagAttributes) {|key, value| @attributes[key] = Expression.parse(value)}

  parse: (tokens) ->

  render: (context) ->
    console.log('variable name: ')
    console.log @unresolvedVariableName
    console.log('template name: ')
    console.log(@unresolvedTemplateName)
    # See comment on unresolved variables in the constructor
    @variableName = context.resolve(@unresolvedVariableName)
    @templateName = context.resolve(@unresolvedTemplateName)
    console.log 'resolved template name'
    console.log @templateName
    @loadCachedPartial(context).then (partial) =>
      variable = context.evaluate(@variableName)
      context[@contextVariableName] = variable
      partial.render(context)

  loadCachedPartial: (context) ->
    # cachedPartials = context.registers['cachedPartials'] || {}
    # TODO: implement caching
    source = @readTemplateFromFileSystem(context)
    template = new Liquid.Template
    template.parse(@, source)

  readTemplateFromFileSystem: (context) ->
    Liquid.Template.fileSystem.readTemplateFile(@templateName)


