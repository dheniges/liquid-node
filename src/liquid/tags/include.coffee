Q = require 'q'
Liquid = require "../../liquid"

module.exports = class Include extends Liquid.Tag
  Syntax = /([a-z0-9\/\\_-]+)/i
  SyntaxHelp = "Syntax Error in 'include' -
                Valid syntax: include [templateName]"

  constructor: (template, tagName, markup, tokens) ->
    match = Syntax.exec(markup)
    throw new Liquid.SyntaxError(SyntaxHelp) unless match

    @filepath = match[1]
    deferred = Q.defer()
    @included = deferred.promise

    template.engine.importer @filepath, (err, src) ->
      subTemplate = engine.extParse src, template.engine.importer
      subTemplate.then (t) -> deferred.resolve t

    super

  render: (context) ->
    @included.then (i) -> i.render context