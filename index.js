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
        S: ''
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
      State: {
        ComparisonOperator: 'EQ',
        AttributeValueList: [ { S: 'PENDING' } ]
      }
    }   
  };
  db.updateItem(query, cb);
};

var jgarth = {
  
  TransactionItem: TransactionItem,

  prepareTransactionsTable: function(db, name, cb) {
    db.describeTable({
      TableName: name
    }, function(e, data) {
      if (e && e.code && e.code === 'ResourceNotFoundException') {
        return db.createTable(name, cb);
      }
      return cb();
    });
  },
  
  prepareImagesTable: function(db, name, cb) {
    db.describeTable({
      TableName: name
    }, function(e, data) {
      if (e && e.code && e.code === 'ResourceNotFoundException') {
        return db.createTable(name, cb);
      }
      return cb();
    });
  },

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
  }
};

module.exports = jgarth;
