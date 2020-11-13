# prints '/with_tags'
say $_->entry
    for $store->search(Tag => { tag => 'moose' } )->all;

