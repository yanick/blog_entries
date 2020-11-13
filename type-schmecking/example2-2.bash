$ babel-node example.js

s3cr3t1111
{ not: 'good' }

<error> args value failed validation { args: [ { not: 'good' } ],
  errors:
   [ { keyword: 'type',
       dataPath: '[0]',
       schemaPath: '#/items/type',
       params: [Object],
       message: 'should be string' } ],
  stack: [] } (in json-schema-type-checking.js:20)

<error> return value failed validation { value: { not: 'good' },
  errors:
   [ { keyword: 'type',
       dataPath: '',
       schemaPath: '#/type',
       params: [Object],
       message: 'should be string' } ],
  stack: [] } (in json-schema-type-checking.js:20)
