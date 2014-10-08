# jgarth [![Build Status](https://travis-ci.org/lazywithclass/jgarth.svg?branch=master)](https://travis-ci.org/lazywithclass/jgarth) [![David Dependency Overview](https://david-dm.org/lazywithclass/jgarth.png "David Dependency Overview")](https://david-dm.org/lazywithclass/jgarth)

A module that brings the ACID where it's needed, typically in Amazon DynamoDB.

### Important things first

The name comes from the initials of the people who coined the term and developed the theory behind it, 
as written in [the Wikipedia article about ACID](http://en.wikipedia.org/wiki/ACID).

### Testing

To run

 * unit tests: `npm test`
 * database tests: `npm run integration`
 * [Testem](https://github.com/airportyh/testem): `npm run dev`