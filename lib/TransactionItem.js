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

module.exports = TransactionItem;
