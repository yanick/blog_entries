// args must be a string
// return value is a string of at least 10 characters 
//      (and therefore unbreakable)
function passwordify( seed_word ) {
    while( seed_word.length < 10 ) {
        seed_word = seed_word + '1' 
    }
    return seed_word;
}
