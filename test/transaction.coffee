sinon = require 'sinon'
should = require 'should'
  
describe 'transaction', ->
  
  it 'prepares the images and transactions tables, calling back passing tx', ->
    sinon.stub(@lib, 'prepareTransactionsTable').yields()
    sinon.stub(@lib, 'prepareImagesTable').yields()
    stub = sinon.stub()
    @lib.transaction @db, stub
    stub.calledOnce.should.be.true
    should.not.exist stub.args[0][0]
    stub.args[0][1].should.equal @lib.tx
    @lib.prepareTransactionsTable.restore()
    @lib.prepareImagesTable.restore()
  
  it 'errors if preparing the transactions table errors', ->
    sinon.stub(@lib, 'prepareTransactionsTable').yields('ERROR')
    stub = sinon.stub()
    @lib.transaction @db, stub
    stub.calledOnce.should.be.true
    stub.args[0][0].should.equal 'ERROR'
    @lib.prepareTransactionsTable.restore()
      
  it 'errors if preparing the images table errors', ->
    sinon.stub(@lib, 'prepareImagesTable').yields('ERROR')
    stub = sinon.stub()
    @lib.transaction @db, stub
    stub.calledOnce.should.be.true
    stub.args[0][0].should.equal 'ERROR'
    @lib.prepareImagesTable.restore()
