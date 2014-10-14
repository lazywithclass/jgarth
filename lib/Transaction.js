var uuid = require('node-uuid');

function Transaction(db) {
  this.id = uuid.v4();
  this.db = db;
}

Transaction.prototype.lockItem = function(query, done) {

  var self = this;
  // clone query to avoid changing the parameter?
  query.Expected = {
    TransactionId: {
      Exists: 'false'
    }
  };
  var key = Object.keys(query.Key)[0];
  query.Expected[key] = {
    Value: query.Key[key]
  };
  query.ReturnValues = 'ALL_NEW';
  query.AttributeUpdates = {
    TransactionId: {
      Value: {
        S: this.id
      }
    },
    TransactionDate: {
      Value: {
        N: new Date().getTime()
      }
    }
  };

  function tryToAcquireTheLock(retries, cb) {
    self.db.updateItem(query, function(e, result) {
      if (e && e.message && e.message.indexOf('ConditionalCheckFailedException') > -1 && retries < 9) {
        tryToAcquireTheLock(retries + 1, cb);
      } else {
        done(e, result);
      }
    });
  }
  
  tryToAcquireTheLock(0, done);
};

Transaction.prototype.getOwner = function(item) {
  return item.TransactionId.S;
};


module.exports = Transaction;
