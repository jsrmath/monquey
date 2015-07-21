# monquee
A cleaner MongoDB shell syntax

## Usage
* make
* echo "some query here" | ./mongo

## Testing
* python test.py

## Syntactic features
* Pipe separated arguments
* Semicolon separated arrays
* Non-bracketed objects
* No ":" for key-value pairs
* Support for comparison operator identifiers
* Singleton object expansion (e.g., `a b c 1` becomes `a: {b: {c: 1}}`)
* `=>` operator absorbs everything up until the next separator into an object

## Examples
`db people find | name "Julian", age 19`

`db.people.find({"name": "Julian", "age": 19});`
***
`db people find | name "Julian", age 19 | age 0`

`db.people.find({"name": "Julian", "age": 19}, {"age": 0});`
***
`db.people.find`

`db.people.find();`
***
`db.people.find |`

`db.people.find({});`
***
`db people find | age 19, name => first "Julian", last "Rosenblum"`

`db.people.find({"age": 19, "name": {"first": "Julian", "last": "Rosenblum"}});`
***
`db inventory find | $or [ qty > 100 ; price < 10 ]`

`db.inventory.find({"$or": [{"qty": {"$gt": 100}}, {"price": {"$lt": 10}}]});`
***
`db inventory find | type $in ['food' ; 'snacks']`

`db.inventory.find({"type": {"$in": ["food", "snacks"]}});`
***
`db inventory find | ratings => $elemMatch => > 5, < 9`

`db.inventory.find({"ratings": {"$elemMatch": {"$gt": 5, "$lt": 9}}});`