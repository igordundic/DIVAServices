_               = require 'lodash'
path            = require 'path'
ImageHelper     = require './imageHelper'
IoHelper        = require './ioHelper'
ParameterHelper = require './parameterHelper'

class ResultHelper

  @parameterHelper = new ParameterHelper()
  @ioHelper = new IoHelper()

  @checkCollectionResultAvailable: (collection) ->
    collection.rootFolder = collection.name
    _.forIn(collection.inputHighlighters, (value,key) ->
      collection.inputHighlighters[key] = String(value)
    )

    @parameterHelper.loadParamInfo(collection)
    collection.resultFile = collection.outputFolder + path.sep + 'result.json'
    return IoHelper.checkFileExists(collection.resultFile)

  @checkProcessResultAvailable: (process) ->
    @parameterHelper.loadParamInfo(process)
    return process.resultFile? and IoHelper.checkFileExists(process.resultFile)

  @loadResult: (info) ->
    return IoHelper.loadFile(info.resultFile)

  @saveResult: (info, callback) ->
    IoHelper.saveFile(info.resultFile, info.result, callback)
  
  @removeResult: (process) ->
    @parameterHelper.removeParamInfo(process)
    IoHelper.deleteFolder(process.outputFolder)
    
  @loadAvailableResults: (folder, image) ->
    files = IoHelper.readdir(folder)
    results = []
    if(files?)
      files = _.filter(files, (file) ->
        return file.endsWith('.json')
      )
      for file in files
        methodResults = IoHelper.loadFile(folder + path.sep + file)
        for methodResult in methodResults
          processResult = IoHelper.loadFile(methodResult.folder + path.sep + image.name + '.json')
          processResult['method'] = file.split('.')[0]
          processResult['parameters'] = methodResult.parameters
          results.push(processResult)
    return results

  @loadResultsForMd5: (md5) ->
    images = ImageHelper.loadImagesMd5(md5)
    response = []
    for image in images
      availableResults = @loadAvailableResults(image.rootFolder, image)
      for result in availableResults
        message =
          resultLink: result.resultLink
          method: result.method
          collectionName: result.collectionName
          parameters: result.parameters
        response.push message

    response['status'] = 'done'
    return response

module.exports = ResultHelper