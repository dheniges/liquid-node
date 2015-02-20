Liquid  = require "../liquid"
Promise = require "bluebird"
Q       = require 'q'

module.exports = class Liquid.Engine
  constructor: ->
    @tags = {}
    @Strainer = (@context) ->
    @registerFilters Liquid.StandardFilters

    isSubclassOf = (klass, ofKlass) ->
      unless typeof klass is 'function'
        false
      else if klass == ofKlass
        true
      else
        isSubclassOf klass.__super__?.constructor, ofKlass

    for own tagName, tag of Liquid
      continue unless isSubclassOf(tag, Liquid.Tag)
      isBlockOrTagBaseClass = [Liquid.Tag, Liquid.Block].indexOf(tag.constructor) >= 0
      @registerTag tagName.toLowerCase(), tag unless isBlockOrTagBaseClass

  registerTag: (name, tag) ->
    @tags[name] = tag

  registerFilters: (filters...) ->
    filters.forEach (filter) =>
      for own k, v of filter
        @Strainer::[k] = v if v instanceof Function

  parse: (source) ->
    template = new Liquid.Template
    template.parse @, source

  parseAndRender: (source, args...) ->
    @parse(source).then (template) ->
      template.render(args...)

###
  extParse = (src, importer) ->
    engine.importer = importer
    parser = engine.parse src

    parser.then (baseTemplate) ->
      return baseTemplate unless baseTemplate.extends

      stack = [baseTemplate]
      depth = 0
      deferred = Q.defer()

      walker = (tmpl, cb) ->
        return cb() unless tmpl.extends

        tmpl.engine.importer tmpl.extends, (err, data) ->
          return cb err if err
          return cb "too many `extends`" if depth > 100
          depth++

          engine.extParse(data, importer)
            .then((subTemplate) ->
              stack.unshift subTemplate
              walker subTemplate, cb
            )
            .catch((err) -> cb(err ? "Failed to parse template."))

      walker stack[0], (err) ->
        return deferred.reject err if err

        [rootTemplate, subTemplates...] = stack

        # Queries should find the block of the lowest,
        # most specific child.
        #
        # query   | root.a | c1.a | c2.a | result
        # ---------------------------------------
        # a       |        | "C1" |      | "C1"
        # a       | "ROOT" | "C1" | "C2" | "C2"
        #
        subTemplates.forEach (subTemplate) ->

          # blocks
          subTemplateBlocks = subTemplate.exportedBlocks or {}
          rootTemplateBlocks = rootTemplate.exportedBlocks or {}
          rootTemplateBlocks[k]?.replace(v) for own k, v of subTemplateBlocks

        deferred.resolve rootTemplate

      deferred.promise
###