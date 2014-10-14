should = require 'should'
sinon = require 'sinon'
awsSDK = require 'aws-sdk'
async = require 'async'

describe 'testing', ->

  it 'works', -> (42).should.equal 42

describe 'lib', ->

  TransactionItem = require '../lib/TransactionItem'
  Transaction = require '../lib/Transaction'
  lib = require '../index'
  
  beforeEach ->
    @db = new awsSDK.DynamoDB()
    sinon.stub(@db, 'createTable').yields()

  afterEach -> @db.createTable.restore()
  
  it 'could be required', -> should.exist lib
  
  it 'is a module', -> lib.should.be.a.Object

  describe 'prepareTable', ->
     
    it 'creates a table if it does not exist', (done) ->
      sinon.stub(@db, 'describeTable').yields code: 'ResourceNotFoundException'
      lib.prepareTable @db, 'transactions-table', =>
        @db.describeTable.calledOnce.should.be.true
        @db.createTable.calledOnce.should.be.true
        @db.createTable.args[0][0].should.eql
          TableName: 'transactions-table'
          AttributeDefinitions: [
            AttributeName: 'TransactionId'
            AttributeType: 'S'
          ]
          KeySchema: [
            AttributeName: 'TransactionId'
            KeyType: 'HASH'
          ]
          ProvisionedThroughput: 
            ReadCapacityUnits: 1
            WriteCapacityUnits: 1
        @db.describeTable.restore()
        done()

    it 'does not create the table if it exists', (done) ->
      stub = sinon.stub(@db, 'describeTable').yields()
      lib.prepareTable @db, 'transactions-table', =>
        @db.describeTable.calledOnce.should.be.true
        @db.createTable.calledOnce.should.be.false
        @db.describeTable.restore()
        done()

    it 'errors if the call to dynamo errors', (done) ->
      stub = sinon.stub(@db, 'describeTable').yields 'ERROR'
      lib.prepareTable @db, 'transactions-table', (e) =>
        @db.describeTable.calledOnce.should.be.true
        @db.createTable.calledOnce.should.be.false
        e.should.equal 'ERROR'
        @db.describeTable.restore()
        done()

  describe 'prepareTables', ->

    it 'prepares the images and transactions tables', (done) ->
      sinon.stub(lib, 'prepareTable').yields()
      lib.prepareTables @db, (err, transactionItem) ->
        lib.prepareTable.calledTwice.should.be.true
        lib.prepareTable.args[0][1].should.equal 'transactions-table'
        lib.prepareTable.args[1][1].should.equal 'images-table'
        lib.prepareTable.restore()
        done()
  
    it 'errors if preparing the transactions table errors', (done) ->
      sinon.stub(lib, 'prepareTable').withArgs(@db, 'transactions-table').yields 'ERROR'
      lib.prepareTables @db, (err, transactionItem) ->
        err.should.equal 'ERROR'
        lib.prepareTable.restore()
        done()
      
    it 'errors if preparing the images table errors', (done) ->
      sinon.stub(lib, 'prepareTable').withArgs(@db, 'images-table').yields 'ERROR'
      lib.prepareTables @db, (err, transactionItem) ->
        err.should.equal 'ERROR'
        lib.prepareTable.restore()
        done()
