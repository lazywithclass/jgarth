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

    db = updateItem: sinon.stub().yields()
    transaction = new Transaction db
    
    it 'exists', -> should.exist transaction.lockItem

    it 'calls updateItem', (done) ->
      cb = sinon.stub()
      transaction.lockItem db, =>
        db.updateItem.calledOnce.should.be.true
        done()
    
    it 'retries a maximum 10 times after which it calls back with an error', (done) ->
      error = message: 'ConditionalCheckFailedException: some other text here'
      db = updateItem: sinon.stub().yields error
      transaction.lockItem db, (e) =>
        db.updateItem.callCount.should.equal 10
        e.should.eql error
        done()
        
    it.skip 'can acquire the lock on the item', ->      
