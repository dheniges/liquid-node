Liquid = require "../../liquid"
fs     = require 'fs'

# TODO: include support for 'with' and 'for'

module.exports = class Include extends Liquid.Tag

  Syntax = ///(#{Liquid.QuotedFragment.source})///

  # TODO the ruby version supports a with/for syntax for passing additional context restrictions
  #   SyntaxTwo = ///(#{Liquid.QuotedFragment.source})(\s+(?:with|for)\s+(#{Liquid.QuotedFragment.source}))?///

  SyntaxHelp = "Syntax Error in 'include' -
                Valid syntax: include [templateName]"

  constructor: (template, tagName, markup, tokens) ->
    match = Syntax.exec(markup)
    throw new Liquid.SyntaxError(SyntaxHelp) unless match

    super

    @engine = template.engine
    @templateName = match[1]

    # TODO the ruby version populates the context with specified 'with'
    # variables and tag attributes. If needed, these should be replaced
    # in context during @render
    # @variableName = match[3] || @templateName
    # @attributes = {}

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
    cachedPartials = context.registers['cachedPartials'] || {}
    cached = cachedPartials[@templateName]
    if cached
      return cached
    @readTemplateFromFileSystem(context).then (source) =>
      parsed = @engine.parse(source)
      cachedPartials[@templateName] = parsed
      context.registers['cachedPartials'] = cachedPartials
      parsed

  readTemplateFromFileSystem: (context) ->
    Liquid.Template.fileSystem.readTemplateFile(@templateName)


