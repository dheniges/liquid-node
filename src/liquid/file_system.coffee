Liquid = require("../liquid")
fs     = require("fs")
path   = require('path')

module.exports = class FileSystem

  constructor: (root) ->
    @root = root

  readTemplateFile: (template_path, context) ->
    fullPath = @lookupFullPath(template_path)
    fs.readFileSync(fullPath)

  lookupFullPath: (lookupPath) ->
    path.join(@root, lookupPath)