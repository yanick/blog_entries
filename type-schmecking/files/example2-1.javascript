import JsonSchemaValidator from './lib/json-schema-type-checking';

const { args, returns } = JsonSchemaValidator();

class Foo {

    @args({ items: { type: 'string' } })
    @returns({ type: 'string', minimumLength: 15 })
    static passwordify( seed_word ) {
        while( seed_word.length < 10 ) {
            seed_word = seed_word + '1' 
        }
        return seed_word;
    }

};

console.log( Foo.passwordify( 's3cr3t' ) );
console.log( Foo.passwordify( { not: 'good' } ) );

