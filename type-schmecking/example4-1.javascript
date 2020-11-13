import JsonSchemaValidator from './lib/json-schema-type-checking';

const { args, returns } = JsonSchemaValidator();

class Foo {

    @returns({
        type: 'object',
        properties: {
            amount: { type: 'number' },
            tax:    { type: 'number' },
            tip:    { type: 'number', default: 2.00 },
        }
    })
    static calculate_bill( amount, tip ) {
        let bill = { amount };
        bill.tax = amount * 0.10;
        if ( tip ) bill.tip = tip;
        return bill;
    }

};

console.log( Foo.calculate_bill( 10, 3 ) );
console.log( Foo.calculate_bill( 10 ) );
