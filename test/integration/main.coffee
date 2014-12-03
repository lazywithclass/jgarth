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

  tables = [
    { name: 'transactions-table', id: 'TransactionId' },
    { name: 'images-table', id: 'TransactionId' },
    { name: 'Questions', id: 'Id' },
    { name: 'Answers', id: 'Id' }
    ]

  beforeEach (done) ->

    createTable = (table, cb) ->
      dynamodb.createTable({ 
        TableName: table.name,
        AttributeDefinitions: [{
          AttributeName: table.id,
          AttributeType: 'S'
        }], 
        KeySchema: [{
          AttributeName: table.id,
          KeyType: 'HASH'
        }], 
        ProvisionedThroughput: {
          ReadCapacityUnits: 1,
          WriteCapacityUnits: 1
        }
      }, cb)

    async.each tables, createTable, done

  afterEach (done) ->
    deleteTable = (table, cb) -> dynamodb.deleteTable TableName: table.name, cb
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
  
    lib.transactional dynamodb, (err, transaction) ->
      transaction.updateItem questionQuery, (err, resultQuestion) ->
        should.not.exist err
        dynamodb.scan TableName: 'transactions-table', (err, result) ->
          should.not.exist err
          result.Count.should.equal 1
          done()

  it 'commits a transaction to the requested table', (done) ->
    lib.transactional dynamodb, (err, transaction, commit) ->
      should.not.exist err
      questionQuery = require './fixtures/questions-update-item.json'
      transaction.updateItem questionQuery, (err, a) ->
        should.not.exist err
        commit ->
          dynamodb.scan TableName: 'Questions', (err, result) ->
            should.not.exist err
            result.Count.should.equal 1
            done()
