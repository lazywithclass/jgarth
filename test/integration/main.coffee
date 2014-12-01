should = require 'should'
spawn = require('child_process').spawn
awsSDK = require 'aws-sdk'
async= require 'async'
lib = require '../../index'

awsSDK.config.update
  accessKeyId: 'key'
  secretAccessKey: 'secret'
  region: 'dagobah'
dynamodb = new awsSDK.DynamoDB endpoint: new awsSDK.Endpoint 'http://localhost:8000'
  

describe 'dynamodb interaction', ->

  tables = ['transactions-table', 'images-table', 'questions', 'answers']

  beforeEach (done) ->
    createTable = (name, cb) -> lib.prepareTable dynamodb, name, cb
    async.each tables, createTable, done

  afterEach (done) ->
    deleteTable = (name, cb) -> dynamodb.deleteTable TableName: name, cb
    async.each tables, deleteTable, done
  
  it 'creates the transaction table', (done) ->
    dynamodb.listTables (e, data) ->
      should.not.exist e
      data.TableNames.should.containEql 'transactions-table'
      done()

  it 'creates the images table', (done) ->
    dynamodb.listTables (e, data) ->
      should.not.exist e
      data.TableNames.should.containEql 'images-table'
      done()

  it 'writes to the transactions table', (done) ->
    questionQuery = require './fixtures/questions-update-item.json'
    answerQuery = require './fixtures/answers-update-item.json'
  
    lib.transactional dynamodb, (err, transaction) ->
      transaction.updateItem questionQuery, (err, resultQuestion) ->
        should.not.exist err
        transaction.updateItem answerQuery, (err, resultAnswer) ->
          should.not.exist err
    
          dynamodb.scan TableName: 'transactions-table', (err, result) ->
            should.not.exist err
            result.Count.should.equal 1
            done()
