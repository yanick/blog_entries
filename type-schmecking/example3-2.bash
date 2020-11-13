$ babel-node example.js

5
8.5

<error> args value failed validation { args: [ 9, 8 ],
  errors:
   [ { keyword: 'minimum',
       dataPath: '[1]',
       schemaPath: '#/items/1/minimum',
       params: [Object],
       message: 'should be >= 9' } ],
  stack: [] } (in json-schema-type-checking.js:20)
