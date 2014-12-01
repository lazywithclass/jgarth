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

  it 'creates the transaction table', (done) ->
    lib.prepareTable dynamodb, 'transactions-table', (e) ->
      dynamodb.listTables (e, data) ->
        should.not.exist e
        data.TableNames.should.containEql 'transactions-table'
        done()

  it 'creates the images table', (done) ->
    lib.prepareTable dynamodb, 'images-table', (e) ->
      dynamodb.listTables (e, data) ->
        should.not.exist e
        data.TableNames.should.containEql 'images-table'
        done()

  it 'writes to the transactions table', (done) ->
    async.parallel [
      (cb) -> lib.prepareTable dynamodb, 'questions', cb
      (cb) -> lib.prepareTable dynamodb, 'answers', cb
    ], (err, result) ->
    
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

  it.skip 'does not write if there is already a transaction pending', (done) ->
    
