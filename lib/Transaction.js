var uuid = require('node-uuid');

function Transaction(db) {
  this.id = uuid.v4();
  this.db = db;
}

Transaction.prototype.lockItem = function(query, done) {

  var self = this;

  function tryToAcquireTheLock(retries, cb) {
    self.db.updateItem({}, function(e) {
      if (e && e.message && e.message.indexOf('ConditionalCheckFailedException') > -1 && retries < 9) {
        tryToAcquireTheLock(retries + 1, cb);
      } else {
        done(e);
      }
    });
  }
  
  tryToAcquireTheLock(0, done);
};


module.exports = Transaction;
