# jgarth [![Build Status](https://travis-ci.org/lazywithclass/jgarth.svg?branch=master)](https://travis-ci.org/lazywithclass/jgarth) [![David Dependency Overview](https://david-dm.org/lazywithclass/jgarth.png "David Dependency Overview")](https://david-dm.org/lazywithclass/jgarth)

A module that brings the ACID where it's needed, typically in Amazon DynamoDB.

### Progress

This is still under development, right now I'm working on:
* delete transation after a successfull commit
* write integration tests around `transactional` to be sure that
it works with 2+ saves

### Usage

This is still under development but the final API should be like:

```javascript
updateQuestion(questionQuery, function(e, updatedQuestion) {
  addAnswer(answerQuery, function(e, updatedAnswer) {
    // done
  });
}); 

// what if updateQuestion succeeds but addAnswer fails 
// for example for exceeded throughput?
    
jgarth.transactional(dynamodb, function(e, transaction) {

  // you should take care of using transaction instead of the original
  // dynamodb object this could change in the future if it will prove too
  // cumbersome to use

  updateQuestion(questionQuery, function(e, updatedQuestion) {
    addAnswer(answerQuery, function(e, updatedAnswer) {
      // done
    });
  }); 
});
```

### Naming 

The name comes from the initials of the people who coined the term and developed the theory behind it, 
as written in [the Wikipedia article about ACID](http://en.wikipedia.org/wiki/ACID).

### Testing

To run

 * unit tests: `npm test`
 * database tests: `npm run integration`
 * [Testem](https://github.com/airportyh/testem): `npm run dev`
