Liquid  = require("../liquid")
Promise = require("bluebird")
fs      = require("fs")
path    = require("path")

module.exports = class FileSystem

  constructor: (root) ->
    @root = root

  readTemplateFile: (template_path, context) ->
    fullPath = @lookupFullPath(template_path)
    Promise.promisify(fs.readFile)(fullPath)

  lookupFullPath: (lookupPath) ->
    path.join(@root, lookupPath)
