var tx = {
  commit: function() {}
};

var configuration = {};

module.exports = function transaction(conf) {

  // configuration = conf.transactionsTable;
  // configuration = conf.imagesTable;

  return function(fun) {
    return fun(tx);
  };
};


// EXAMPLE
// transaction(function(tx) {
//   async.parallel([
//     function(cb) {
//       return fun1(tx, cb);
//     },
//     function(cb) {
//       return fun2(tx, cb);
//     }
//   ], function() {
//     tx.commit();
//     tx.cleanup(); // might as well go into commit
//   });
// });
