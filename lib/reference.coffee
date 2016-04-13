###
PDFReference - represents a reference to another object in the PDF object heirarchy
By Devon Govett
###

class PDFReference
  constructor: (@document, @id, @data = {}) ->
    @gen = 0
    @deflate = null
    @compress = false
    @uncompressedLength = 0
    @chunks = []

  write: (chunk) ->
    unless Buffer.isBuffer(chunk)
      chunk = new Buffer(chunk + '\n', 'binary')
    @uncompressedLength += chunk.length
    @data.Length ?= 0
    @chunks.push chunk
    @data.Length += chunk.length

  end: (chunk) ->
    if typeof chunk is 'string' or Buffer.isBuffer(chunk)
      @write chunk
    @finalize()

  finalize: =>
    @offset = @document._offset
    
    @document._write "#{@id} #{@gen} obj"
    @document._write PDFObject.convert(@data)
    
    if @chunks.length
      @document._write 'stream'
      for chunk in @chunks
        @document._write chunk
        
      @chunks.length = 0 # free up memory
      @document._write '\nendstream'
      
    @document._write 'endobj'
    @document._refEnd(this)
    
  toString: ->
    return "#{@id} #{@gen} R"
      
module.exports = PDFReference
PDFObject = require './object'
