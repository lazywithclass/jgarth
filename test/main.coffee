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
    sinon.stub(@db, 'createTable').yields()

  afterEach -> @db.createTable.restore()
  
  it 'could be required', -> should.exist @lib
  
  it 'is a module', -> @lib.should.be.a.Object

  describe 'prepareTransactionsTable', ->
     
    it 'creates the transactions table if it does not exist', (done) ->
      sinon.stub(@db, 'describeTable').yields code: 'ResourceNotFoundException'
      @lib.prepareTransactionsTable @db, 'transactions-table', =>
        @db.describeTable.calledOnce.should.be.true
        @db.createTable.calledOnce.should.be.true
        @db.createTable.args[0][0].should.equal 'transactions-table'
        @db.describeTable.restore()
        done()

    it 'does not create the transactions table if it exists', (done) ->
      stub = sinon.stub(@db, 'describeTable').yields null
      @lib.prepareTransactionsTable @db, 'transactions-table', =>
        @db.describeTable.calledOnce.should.be.true
        @db.createTable.calledOnce.should.be.false
        @db.describeTable.restore()
        done()
    
  describe 'prepareImagesTable', ->
    
    it 'creates the images table if it does not exist', (done) ->
      sinon.stub(@db, 'describeTable').yields code: 'ResourceNotFoundException'
      @lib.prepareImagesTable @db, 'images-table', =>
        @db.describeTable.calledOnce.should.be.true
        @db.createTable.calledOnce.should.be.true
        @db.createTable.args[0][0].should.equal 'images-table'
        @db.describeTable.restore()
        done()

    it 'does not create the images table if it exists', (done) ->
      sinon.stub(@db, 'describeTable').yields null
      @lib.prepareImagesTable @db, 'images-table', =>
        @db.describeTable.calledOnce.should.be.true
        @db.createTable.calledOnce.should.be.false
        @db.describeTable.restore()
        done()
