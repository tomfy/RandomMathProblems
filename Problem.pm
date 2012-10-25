package Problem;
# abstract class for computer-generated math problems
# The idea is that for each subclass which implements a different kind of problem
# you can generate many random problems, so everyone can have a similar set of problems,
# but with different numbers. 

use Moose;
use namespace::autoclean;
use Carp;
use List::Util qw / min max sum /;

has problem_text_template => (
	isa => 'Str',
	is => 'rw',
	default => ''
);

has answer_text_template => (
        isa => 'Str',
        is => 'rw',
        default => ''
);


__PACKAGE__->meta->make_immutable;

1;
