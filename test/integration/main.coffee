spawn = require('child_process').spawn
awsSDK = require 'aws-sdk'
lib = require '../../index'

awsSDK.config.update
  accessKeyId: 'key'
  secretAccessKey: 'secret'
  region: 'dagobah'
dynamodb = new awsSDK.DynamoDB endpoint: new awsSDK.Endpoint 'http://localhost:8000'

lib.prepareTransactionsTable dynamodb, 'transactions-table', (e) ->
  console.log e.stack if e
  console.log 'done'

# make this a proper integration test
# assert that the table is there
# dynamodb.listTables (err, data) ->
#   console.log err, err.stack
