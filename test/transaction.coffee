awsSDK = require 'aws-sdk'
sinon = require 'sinon'
should = require 'should'
  
describe 'transaction', ->
  
  lib = require '../index'
  db = new awsSDK.DynamoDB()

  afterEach ->
    delete lib.transactionId
  
  it 'prepares the images and transactions tables, calling back passing tx', ->
    sinon.stub(lib, 'prepareTransactionsTable').yields()
    sinon.stub(lib, 'prepareImagesTable').yields()
    stub = sinon.stub()
    lib.transaction db, stub
    stub.calledOnce.should.be.true
    should.not.exist stub.args[0][0]
    stub.args[0][1].should.equal lib.tx
    lib.prepareTransactionsTable.restore()
    lib.prepareImagesTable.restore()
  
  it 'errors if preparing the transactions table errors', ->
    sinon.stub(lib, 'prepareTransactionsTable').yields 'ERROR'
    stub = sinon.stub()
    lib.transaction db, stub
    stub.calledOnce.should.be.true
    stub.args[0][0].should.equal 'ERROR'
    lib.prepareTransactionsTable.restore()
      
  it 'errors if preparing the images table errors', ->
    sinon.stub(lib, 'prepareImagesTable').yields 'ERROR'
    stub = sinon.stub()
    lib.transaction db, stub
    stub.calledOnce.should.be.true
    stub.args[0][0].should.equal 'ERROR'
    lib.prepareImagesTable.restore()

  it 'creates a transaction id', ->
    sinon.stub(lib, 'prepareTransactionsTable').yields()
    sinon.stub(lib, 'prepareImagesTable').yields()
    stub = sinon.stub()
    lib.transaction db, stub
    should.exist lib.transactionId
    lib.transactionId.should.match /[0-9a-f]{22}|[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i
    lib.prepareTransactionsTable.restore()
    lib.prepareImagesTable.restore()

  it 'does not create a transaction id if checking tables errors', ->
    sinon.stub(lib, 'prepareTransactionsTable').yields 'ERROR'
    sinon.stub(lib, 'prepareImagesTable').yields 'ERROR'
    stub = sinon.stub()
    lib.transaction db, stub
    should.not.exist lib.transactionId
    lib.prepareTransactionsTable.restore()
    lib.prepareImagesTable.restore()
