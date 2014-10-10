var async = require('async'),
    uuid = require('node-uuid');

var TransactionItem = function(options) {
  this.id = options && options.id;
};

TransactionItem.prototype.updateItem = function(db, item, cb) {
  var query = {
    TableName: 'transactions-table',
    Key: {
      TransactionId: {
        S: this.id.toString()
      }
    },
    AttributeUpdates: {
      Requests: {
        Value: {
          S: JSON.stringify(item)
        },
        Action: 'PUT'
      },
      Version: {
        Value: {
          S: '1'
        },
        Action: 'ADD'
      },
      Date: {
        Value: {
          S: new Date().getTime().toString()
        },
        Action: 'PUT'
      }
    },
    Expected: {
      // version is missing here
      State: {
        ComparisonOperator: 'EQ',
        AttributeValueList: [ { S: 'PENDING' } ]
      }
    }   
  };
  db.updateItem(query, cb);
};

function _prepareTable(db, name, cb) {
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
}

var jgarth = {
  
  TransactionItem: TransactionItem,

  prepareTransactionsTable: _prepareTable,
  
  prepareImagesTable: _prepareTable,

  transaction: function(db, done) {    
    async.parallel([
      function(cb) {
        jgarth.prepareTransactionsTable(db, 'transactions-table', cb);
      },
      function(cb) {
        jgarth.prepareImagesTable(db, 'images-table', cb);
      }
    ], function(err, results) {
      done(err, new jgarth.TransactionItem({
        id: uuid.v4()
      }));
    });
  },

  lockItem: function(db, done) {
    
    function tryToAcquireTheLock(retries, cb) {
      db.updateItem({}, function(e) {
        if (e && e.message && e.message.indexOf('ConditionalCheckFailedException') > -1 && retries < 9) {
          tryToAcquireTheLock(retries + 1, cb);
        } else {
          done(e);
        }
      });
    }
    
    tryToAcquireTheLock(0, done);
  }
};

module.exports = jgarth;
