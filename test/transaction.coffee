awsSDK = require 'aws-sdk'
sinon = require 'sinon'
should = require 'should'
  
describe 'transaction', ->

  db = new awsSDK.DynamoDB()
  
  Transaction = require '../lib/Transaction'

  it 'exists', -> should.exist Transaction

  it 'creates a transaction id', ->
    stub = sinon.stub()
    transaction = new Transaction db
    should.exist transaction.id
    transaction.id.should.match /[0-9a-f]{22}|[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i

  it 'creates a transaction id different from each time', ->
    new Transaction(db).id.should.not.equal new Transaction(db).id

  it 'stores the passed db object', ->
    transaction = new Transaction db
    should.exist transaction.db

  describe 'lockItem', ->
    
    beforeEach ->
      @clock = sinon.useFakeTimers 42
      @db = updateItem: sinon.stub() 
      @transaction = new Transaction @db
      @db.updateItem.yields null, TransactionId: S: @transaction.id

    afterEach ->
      @clock.restore()
    
    it 'exists', -> should.exist @transaction.lockItem

    it 'calls updateItem', (done) ->
      cb = sinon.stub()
      @transaction.lockItem Key: {}, =>
        @db.updateItem.calledOnce.should.be.true
        done()
    
    it 'retries a maximum 10 times after which it calls back with an error', (done) ->
      error = message: 'ConditionalCheckFailedException: some other text here'
      db = updateItem: sinon.stub().yields error
      transaction = new Transaction db
      transaction.lockItem Key: {}, (e) ->
        db.updateItem.callCount.should.equal 10
        e.should.eql error
        done()

    it 'can acquire the lock on an item that we expect to be there', ->
      query =
        TableName: 'Posts'
        Key: ThreadId: S: '1'

      @transaction.lockItem query, (e, result) =>
        @db.updateItem.args[0][0].TableName.should.equal 'Posts'
        @db.updateItem.args[0][0].Expected.should.eql
          TransactionId: Exists: 'false'
          ThreadId: Value: S: '1'
        @db.updateItem.args[0][0].Key.should.eql ThreadId: S: '1'
        @db.updateItem.args[0][0].ReturnValues.should.equal 'ALL_NEW'
        @db.updateItem.args[0][0].AttributeUpdates.should.eql
          TransactionId: Value: S: @transaction.id
          TransactionDate: Value: N: '42'
        
        result.should.eql TransactionId: S: @transaction.id

    it.skip 'cannot acquire the lock if a different transaction has the lock', ->
      @db = updateItem: sinon.stub() 
      @transaction = new Transaction @db
      @db.updateItem.yields null, TransactionId: S: 'another-transaction-id'
      query =
        TableName: 'Posts'
        Key: ThreadId: S: '1'

      @transaction.lockItem query, (e, result) =>
        @db.updateItem.args[0][0].TableName.should.equal 'Posts'
        @db.updateItem.args[0][0].Expected.should.eql
          TransactionId: Exists: 'false'
          ThreadId: Value: S: '1'
        @db.updateItem.args[0][0].Key.should.eql ThreadId: S: '1'
        @db.updateItem.args[0][0].ReturnValues.should.equal 'ALL_NEW'
        @db.updateItem.args[0][0].AttributeUpdates.should.eql
          TransactionId: Value: S: @transaction.id
          TransactionDate: Value: N: '42'
        
        result.should.eql TransactionId: S: @transaction.id
  
  describe 'getOwner', ->

    beforeEach ->
      @db = updateItem: sinon.stub().yields()
      @transaction = new Transaction @db

    it 'exists', -> should.exist @transaction.getOwner
    
    it 'returns the transaction id of an item', ->
      transactionId = @transaction.getOwner TransactionId: S: 'this-is-a-hash'
      transactionId.should.equal 'this-is-a-hash'
