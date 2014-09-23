should = require 'should'
sinon = require 'sinon'
awsSDK = require 'aws-sdk'
async = require 'async'

describe 'testing', ->

  it 'works', -> (42).should.equal 42

describe 'lib', ->

  beforeEach ->
    @lib = require '../index'
    @db = new awsSDK.DynamoDB()
    
  it 'could be required', -> should.exist @lib
  
  it 'is a module', -> @lib.should.be.a.Object

  describe 'prepareTransactionsTable', ->

    beforeEach -> sinon.stub(@db, 'createTable').yields()
    afterEach -> @db.createTable.restore()
     
    it 'creates the transactions table if it does not exist', ->
      sinon.stub(@db, 'describeTable').yields code: 'ResourceNotFoundException'
      @lib.prepareTransactionsTable @db, 'transactions-table'
      @db.describeTable.calledOnce.should.be.true
      @db.createTable.calledOnce.should.be.true
      @db.createTable.args[0][0].should.equal 'transactions-table'
      @db.describeTable.restore()

    it 'does not create the transactions table if it exists', ->
      stub = sinon.stub(@db, 'describeTable')
      stub.withArgs('transactions-table').yields null
      @lib.prepareTransactionsTable @db, 'transactions-table'
      @db.describeTable.calledOnce.should.be.true
      @db.createTable.calledOnce.should.be.false
      @db.describeTable.restore()
    
  describe 'prepareImagesTable', ->

    beforeEach -> sinon.stub(@db, 'createTable').yields()
    afterEach -> @db.createTable.restore()
    
    it 'creates the images table if it does not exist', ->
      sinon.stub(@db, 'describeTable').yields code: 'ResourceNotFoundException'
      @lib.prepareImagesTable @db, 'images-table'
      @db.describeTable.calledOnce.should.be.true
      @db.createTable.calledOnce.should.be.true
      @db.createTable.args[0][0].should.equal 'images-table'
      @db.describeTable.restore()

    it 'does not create the images table if it exists', ->
      stub = sinon.stub(@db, 'describeTable')
      stub.withArgs('images-table').yields null
      @lib.prepareImagesTable @db, 'images-table'
      @db.describeTable.calledOnce.should.be.true
      @db.createTable.calledOnce.should.be.false
      @db.describeTable.restore()
  
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
          
      xit 'writes the record to the temporary table (EXPAND WITH THE CORRECT DESCRIPTION)', (done) ->
        done 'ERROR'

      xdescribe 'commit', ->

        it 'should be available', ->
          @transaction (tx) -> tx.commit.should.be.a.Function
   
        it 'cleans the transaction table after the commit', (done) ->
          done 'ERROR'

        it 'cleans the images table after the commit', (done) ->
          done 'ERROR'
