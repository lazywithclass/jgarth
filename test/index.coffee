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
    sinon.stub(@db, 'query').yields()
    sinon.stub(@db, 'updateItem').yields()

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

  describe 'transactional', ->

    beforeEach ->
      sinon.stub(lib, 'prepareTable').yields()
      sinon.stub(lib, 'prepareTables').yields()

    afterEach ->
      lib.prepareTable.restore()
      lib.prepareTables.restore()
    
    it 'is a function', ->
      should.exist lib.transactional
      lib.transactional.should.be.a.Function

    it 'prepares tables', (done) ->
      lib.transactional @db, =>
        lib.prepareTables.calledOnce.should.be.true
        lib.prepareTables.args[0][0].should.eql @db
        done()        

    it 'calls back giving a prepared Transaction instance', (done) ->
      lib.transactional @db, (err, transaction) ->
        should.exist transaction
        transaction.should.be.an.instanceOf Transaction
        done()

    it 'calls back giving a commit function', (done) ->
      lib.transactional @db, (err, transaction, commit) ->
        should.exist commit
        commit.should.be.a.Function
        done()

    describe 'commit', ->

      it 'fetches the transaction', (done) ->
        result =
          Items: [
            Requests:
              S: JSON.stringify require './integration/fixtures/questions-update-item.json'
          ]
        @db.query.restore()
        sinon.stub(@db, 'query').yields null, result
        lib.transactional @db, (err, transaction, commit) =>
          commit =>
            @db.query.calledOnce.should.be.true
            @db.query.args[0][0].TableName.should.equal 'transactions-table'
            transactionId = @db.query.args[0][0].KeyConditions.TransactionId
            transactionId.AttributeValueList[0].S.should.equal transaction.id
            transactionId.ComparisonOperator.should.equal 'EQ'
            done()

      it 'writes to the required table', (done) ->
        result =
          Items: [
            Requests:
              S: JSON.stringify require './integration/fixtures/questions-update-item.json'
          ]
        @db.query.restore()
        sinon.stub(@db, 'query').yields null, result
        lib.transactional @db, (err, transaction, commit) =>
          questionQuery = require './integration/fixtures/questions-update-item.json'
          transaction.updateItem questionQuery, =>
            commit =>
              @db.updateItem.args[1][0].should.eql questionQuery
              done()

      it.skip 'writes to the required tables (multiple as requested)', (done) ->
        # TODO
        done()

    it 'errors if prepareTables errors', (done) ->
      lib.prepareTables.restore()
      sinon.stub(lib, 'prepareTables').yields 'ERROR'
      lib.transactional @db, (err, transaction) =>
        err.should.equal 'ERROR'
        should.not.exist transaction
        done()
