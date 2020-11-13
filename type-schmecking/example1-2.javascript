// args must be a string
function passwordify( seed_word ) {
    while( seed_word.length < 10 ) {
        seed_word = seed_word + '1' 
    }
    return seed_word;
}
