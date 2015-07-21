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

## CRUD Examples

### Create

`db people insert | name "Julian", age 19`

`db.people.insert({"name": "Julian", "age": 19});`
***
`db people insert | age 19, name => first "Julian", last "Rosenblum"`

`db.people.insert({"age": 19, "name": {"first": "Julian", "last": "Rosenblum"}});`
***
`db people insert | [ name "Julian", age 19 ; name "Glenna", age 21 ]`

`db.people.insert([{"name": "Julian", "age": 19}, {"name": "Glenna", "age": 21}]);`

### Read

`db.people.find`

`db.people.find();`
***
`db inventory find | $or [ qty > 100 ; price < 10 ]`

`db.inventory.find({"$or": [{"qty": {"$gt": 100}}, {"price": {"$lt": 10}}]});`
***
`db inventory find | type $in ['food' ; 'snacks']`

`db.inventory.find({"type": {"$in": ["food", "snacks"]}});`
***
`db inventory find | ratings => $elemMatch => > 5, < 9`

`db.inventory.find({"ratings": {"$elemMatch": {"$gt": 5, "$lt": 9}}});`

### Update

`db inventory update | manufacturer "XYZ Company" | $set details.model "14Q2" | multi true`

`db.inventory.update({"manufacturer": "XYZ Company"}, {"$set": {"details.model": "14Q2"}}, {"multi": true});`
***
`db inventory update | item "MNO2" | $set { category "apparel", details => model "14Q3", manufacturer "XYZ Company" }, $currentDate lastModified true`

`db.inventory.update({"item": "MNO2"}, {"$set": {"category": "apparel", "details": {"model": "14Q3", "manufacturer": "XYZ Company"}}, "$currentDate": {"lastModified": true}});`

### Delete

`db people remove |`

`db.people.remove({});`
***
`db inventory remove | type "food" | 1`

`db.inventory.remove({"type": "food"}, 1);`