package C;

use Dancer;

{ package ::main; use Dancer ':syntax'; }

END {
    get '/' => \&::index if defined &::index;
    dance;
}

1;
