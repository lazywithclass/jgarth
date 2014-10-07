awsSDK = require 'aws-sdk'
sinon = require 'sinon'
should = require 'should'
  
describe 'transaction', ->

  db = new awsSDK.DynamoDB()
  
  beforeEach ->
    @lib = require '../index'

  afterEach ->
    delete @lib.transactionId
    @lib = undefined

  it 'prepares the images and transactions tables, calling back passing transactionItem', ->
    sinon.stub(@lib, 'prepareTransactionsTable').yields()
    sinon.stub(@lib, 'prepareImagesTable').yields()
    stub = sinon.stub()
    @lib.transaction db, stub
    stub.calledOnce.should.be.true
    should.not.exist stub.args[0][0]
    stub.args[0][1].should.be.an.instanceOf @lib.TransactionItem
    @lib.prepareTransactionsTable.restore()
    @lib.prepareImagesTable.restore()
  
  it 'errors if preparing the transactions table errors', ->
    sinon.stub(@lib, 'prepareTransactionsTable').yields 'ERROR'
    stub = sinon.stub()
    @lib.transaction db, stub
    stub.calledOnce.should.be.true
    stub.args[0][0].should.equal 'ERROR'
    @lib.prepareTransactionsTable.restore()
      
  it 'errors if preparing the images table errors', ->
    sinon.stub(@lib, 'prepareImagesTable').yields 'ERROR'
    stub = sinon.stub()
    @lib.transaction db, stub
    stub.calledOnce.should.be.true
    stub.args[0][0].should.equal 'ERROR'
    @lib.prepareImagesTable.restore()

  it 'creates a transaction id', ->
    sinon.stub(@lib, 'prepareTransactionsTable').yields()
    sinon.stub(@lib, 'prepareImagesTable').yields()
    stub = sinon.stub()
    @lib.transaction db, stub
    transactionItem = stub.args[0][1]
    should.exist transactionItem.id
    transactionItem.id.should.match /[0-9a-f]{22}|[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i
    @lib.prepareTransactionsTable.restore()
    @lib.prepareImagesTable.restore()

  it 'creates a transaction id different from each time', ->
    sinon.stub(@lib, 'prepareTransactionsTable').yields()
    sinon.stub(@lib, 'prepareImagesTable').yields()
    
    stub1 = sinon.stub()
    @lib.transaction db, stub1
    transactionItem1 = stub1.args[0][1]
    stub2 = sinon.stub()
    @lib.transaction db, stub2
    transactionItem2 = stub2.args[0][1]
    transactionItem1.id.should.not.equal transactionItem2.id
    
    @lib.prepareTransactionsTable.restore()
    @lib.prepareImagesTable.restore()
    
