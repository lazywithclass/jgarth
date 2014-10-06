awsSDK = require 'aws-sdk'
sinon = require 'sinon'
should = require 'should'

describe 'tx', ->

  beforeEach ->      
    @lib = require '../index'
    @db = new awsSDK.DynamoDB()
          
  it 'exists', -> should.exist @lib.tx

  describe 'updateItem', ->

    beforeEach ->
      sinon.useFakeTimers 42
    
    it 'should add the item to the transaction', (done) ->
      sinon.stub(@db, 'updateItem').yields()
      item = { answer: 42 }
      @lib.tx.updateItem @db, item, =>
        @db.updateItem.calledOnce.should.be.true
        @db.updateItem.args[0][0].TableName.should.equal 'transactions-table'
        @db.updateItem.args[0][0].AttributeUpdates.Requests.Value.S.should.equal JSON.stringify item
        @db.updateItem.args[0][0].AttributeUpdates.Requests.Action.should.equal 'PUT'
        @db.updateItem.args[0][0].AttributeUpdates.Version.Value.S.should.equal '1'
        @db.updateItem.args[0][0].AttributeUpdates.Version.Action.should.equal 'ADD'
        @db.updateItem.args[0][0].AttributeUpdates.Date.Value.S.should.equal '42'
        @db.updateItem.args[0][0].AttributeUpdates.Date.Action.should.equal 'PUT'        
        @db.updateItem.args[0][0].Expected.State.ComparisonOperator.should.equal 'EQ'
        @db.updateItem.args[0][0].Expected.State.AttributeValueList.should.eql [ { S: 'PENDING' } ]
        # figure out how to handle the transaction id
        @db.updateItem.args[0][0].Key.TransactionId.should.eql S: ''
        
        done()
