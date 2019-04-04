import JsonSchemaValidator from './lib/json-schema-type-checking';

const { args, returns } = JsonSchemaValidator();

class Foo {

    @args({ items: [ 
        { type: 'number' }, 
        { type: 'number', minimum: { '$data': '1/0' } } 
    ] } )
    static avg(min,max) {
        return (min+max)/2;
    };

};

console.log( Foo.avg( 2, 8 ) );
console.log( Foo.avg( 9, 8 ) );



