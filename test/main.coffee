should = require 'should'
sinon = require 'sinon'

describe 'testing', ->

  it 'works', -> (42).should.equal 42

describe 'lib', ->

  beforeEach ->
    @lib = require '../index'

  it 'could be required', -> should.exist @lib
    
  describe 'transaction', ->

    beforeEach ->
      conf =
        transactionsTable: 'transaction-table'
        imagesTable: 'images-table'
      @transaction = @lib conf

    it 'is a function', -> @lib.should.be.a.Function
  
    it 'returns a function', -> @transaction.should.be.a.Function

    it 'creates the transaction table if it does not exist', ->
      fail()

    it 'creates the images table if it does not exist', ->
      fail()

    it 'returns the execution to the module when the tables are there', (done) ->
      done 'ERROR'
      
    describe 'tx', ->
  
      # it should just wrap around the node aws sdk object
      # and also expose the following

      it 'wraps the amazon sdk module (aws-sdk)', ->
        fail()

      it 'writes the record to the temporary table (EXPAND WITH THE CORRECT DESCRIPTION)', (done) ->
        done 'ERROR'

      describe 'commit', ->

        it 'should be available', ->
          @lib (tx) -> tx.commit.should.be.a.Function
   
        it 'cleans the transaction table after the commit', (done) ->
          done 'ERROR'

        it 'cleans the images table after the commit', ->
          done 'ERROR'
