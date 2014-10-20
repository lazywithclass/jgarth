awsSDK = require 'aws-sdk'
sinon = require 'sinon'
should = require 'should'

describe 'TransactionItem', ->

  beforeEach ->      
    @lib = require '../index'
    @db = new awsSDK.DynamoDB()
          
  it 'exists', -> should.exist @lib.TransactionItem
