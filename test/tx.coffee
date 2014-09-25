awsSDK = require 'aws-sdk'
sinon = require 'sinon'
should = require 'should'

describe 'tx', ->

  beforeEach ->      
    @db = new awsSDK.DynamoDB();
          
  it 'exists', -> should.exist @lib.tx

  describe 'putItem', ->

    it 'should call sdk putItem', (done) ->
      sinon.stub(@db, 'putItem').yields()
      @lib.tx.putItem @db, 'ITEM', =>
        @db.putItem.calledOnce.should.be.true
        @db.putItem.args[0][0].should.equal 'ITEM'
        done()
