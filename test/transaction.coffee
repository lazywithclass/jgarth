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

  it 'exists', -> should.exist @lib.Transaction

  it 'creates a transaction id', ->
    stub = sinon.stub()
    transaction = new @lib.Transaction db
    should.exist transaction.id
    transaction.id.should.match /[0-9a-f]{22}|[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i

  it 'creates a transaction id different from each time', ->
    new @lib.Transaction(db).id.should.not.equal new @lib.Transaction(db).id

  it 'stores the passed db object', ->
    transaction = new @lib.Transaction db
    should.exist transaction.db

  it 'prepares the images and transactions tables, calling back passing transactionItem', (done) ->
    sinon.stub(@lib, 'prepareTransactionsTable').yields()
    sinon.stub(@lib, 'prepareImagesTable').yields()
    transaction = new @lib.Transaction db, (err, transactionItem) =>
      transactionItem.should.be.an.instanceOf @lib.TransactionItem
      @lib.prepareTransactionsTable.calledOnce.should.be.true
      @lib.prepareImagesTable.calledOnce.should.be.true
      @lib.prepareTransactionsTable.restore()
      @lib.prepareImagesTable.restore()
      done()
  
  it 'errors if preparing the transactions table errors', (done) ->
    sinon.stub(@lib, 'prepareTransactionsTable').yields 'ERROR'
    transaction = new @lib.Transaction db, (err) =>
      err.should.equal 'ERROR'
      @lib.prepareTransactionsTable.restore()
      done()
      
  it.skip 'errors if preparing the images table errors', (done) ->
    sinon.stub(@lib, 'preparesImagesTable').yields 'ERROR'
    transaction = new @lib.Transaction db, (err) =>
      err.should.equal 'ERROR'
      @lib.preparesImagesTable.restore()
      done()
