package WorkBackwards;
use strict;
use Moose;
use namespace::autoclean;
use Carp;
use List::Util qw' min max sum';

use base 'Problem';

# the idea here is to produce random problems of the type:
# Start with N, then multiply by X, then add Y, then divide by Z. 
# This gives M. What was the number N you started with?
# N, M, X, Y, and Z are all counting numbers.
# They shouldn't be too big (e.g. N*X + Y should be <= 2 digits)

has result => (
	       isa => 'Maybe[Int]',
	       is => 'rw',
	       default => undef
);

has max_answer => (
	       isa => 'Int',
	       is => 'ro',
	       default => 20
);

has max_multiplier => (
	       isa => 'Int',
	       is => 'ro',
	       default => 10
);

has max_delta => (
	       isa => 'Int',
	       is => 'ro',
	       default => 12
);

has max_divisor => (
	       isa => 'Int',
	       is => 'ro',
	       default => 10
);

has max_intermediate_number => (
	       isa => 'Int',
	       is => 'ro',
	       default => 50
);


sub BUILD{
  my $self = shift;
  print STDERR "max_answer: ", $self->max_answer(), "\n";
	my $problem_text_template = "I pick a number and multiply it by MULTIPLIER. I then ADDSUBTRACT " . 
		"DELTA PREPOSITION the result and finally divide this new number by DIVISOR. " .
		"The result of this division is RESULT. What number did I start with?";
	$self->problem_text_template($problem_text_template);

	my $answer_text_template = "The number I started with was ANSWER.";
	$self->answer_text_template($answer_text_template);
	return $self;
}

sub random_problem{
	my $self = shift;
	my ($N0, $N1, $N2, $N3, $multiplier, $add_or_subtract, $delta, $divisor);
	while(1){
		$N0 = int ( $self->max_answer() * rand() + 1);
		$multiplier = int (($self->max_multiplier() - 1) * rand() + 2);
		$N1 = $N0 * $multiplier;
# print "max intermediate: ", $self->max_intermediate_number(), "\n";
		next if ($N1 > $self->max_intermediate_number()); 
#			$delta = 1 + int ( $self->max_delta() * rand() + 1);
		$add_or_subtract = (rand() < 0.5)? 'add' : 'subtract';

		if($add_or_subtract eq 'add'){
			$delta = 1 + int ( $self->max_delta() * rand() + 1);
			$N2 = $N1 + $delta;
		}elsif($add_or_subtract eq 'subtract'){
			my $max_delta = min( $self->max_delta(), $N1 - 2);
			$delta = 1 + int ( $max_delta * rand());
			$N2 = $N1 - $delta;
		}else{
			die "Unknown operation: $add_or_subtract in random_problem.\n";
		}
		next if ($N2 > $self->max_intermediate_number()); 
		my @factors = ();
		for(my $i = 2; $i <= $self->max_divisor(); $i++){
			if($N2 % $i eq 0){
				push @factors, $i;
			}
		}
		my $n_factors = scalar @factors;
		next if($n_factors == 0);
		my $i_factor = int ($n_factors * rand());
		$divisor = $factors[$i_factor];
		$N3 = $N2 / $factors[$i_factor];
		#return ($N0, $multiplier, $add_or_subtract, $delta, $N3);
	#	print "$N0, $N1, $N2, $N3;  $multiplier, $delta, $divisor \n";
		last;
	      }
	$self->result($N3);
	my $problem_text = $self->problem_text_template();
# print "A $problem_text \n";
	$problem_text =~ s/MULTIPLIER/$multiplier/;
	$problem_text =~ s/DELTA/$delta/;
	$problem_text =~ s/ADDSUBTRACT/$add_or_subtract/;
	my $preposition = ($add_or_subtract eq 'add')? 'to' : 'from';
	$problem_text =~ s/PREPOSITION/$preposition/;
	$problem_text =~ s/DIVISOR/$divisor/;
	$problem_text =~ s/RESULT/$N3/;
# print "B $problem_text \n";
	my $answer_text = $self->answer_text_template();
	$answer_text =~ s/ANSWER/$N0/;
	return ($problem_text, $answer_text);
}

__PACKAGE__->meta->make_immutable;

1;
