var async = require('async'),
    Transaction = require('./lib/Transaction');

var jgarth = {
  
  Transaction: Transaction,

  prepareTable: function(db, name, cb) {
    db.describeTable({
      TableName: name
    }, function(e, data) {
      if (e && e.code && e.code === 'ResourceNotFoundException') {
        return db.createTable({ 
          TableName: name,
          AttributeDefinitions: [{
            AttributeName: 'TransactionId',
            AttributeType: 'S'
          }], 
          KeySchema: [{
            AttributeName: 'TransactionId',
            KeyType: 'HASH'
          }], 
          ProvisionedThroughput: {
            ReadCapacityUnits: 1,
            WriteCapacityUnits: 1
          }
        }, cb);
      }
      return cb(e);
    });
  },

  prepareTables: function(db, done) {
    async.parallel([
      function(cb) {
        jgarth.prepareTable(db, 'transactions-table', cb);
      },
      function(cb) {
        jgarth.prepareTable(db, 'images-table', cb);
      }
    ], done);
  },

  transactional: function(db, cb) {
    // get to a green and refactor this to be more clear
    // * name functions
    // * move the query away
    // * macro that allows async.parallel without all the boilerplate
    //   probabily this could be done with a more recent version of node?
    jgarth.prepareTables(db, function(e) {
      if (e) {
        return cb(e);
      }

      var transaction = new Transaction(db);
      cb(e, transaction, function(committed) {
        var query = {
          TableName: 'transactions-table',
          KeyConditions: {
            TransactionId: {
              AttributeValueList: [ { S: transaction.id } ],
              ComparisonOperator: 'EQ'
            }
          }
        };
        db.query(query, function(err, result) {
          var actualQuery = JSON.parse(result.Items[0].Requests.S);
          db.updateItem(actualQuery, function(err) {
            db.deleteItem({
              TableName: 'transactions-table',
              Key: {
                TransactionId: {
                  S: transaction.id
                }
              }
            }, committed);
          });
        });
      });
    });
  }
};

module.exports = jgarth;
