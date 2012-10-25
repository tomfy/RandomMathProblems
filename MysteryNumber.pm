package MysteryNumber;
use strict;
use Moose;
use namespace::autoclean;
use Carp;
use List::Util qw' min max sum';

use base 'Problem';

# the idea here is to produce random problems of the type:
# I'm thinking of a 3 digit number. It is the largest [or smallest] 3 digit number which:
# * is a multiple of 2 [or 3,4,5,6,9], and
# * has at least one digit which as a 5 [or 0-9], and
# * has at least one digit which is a 9 [or 0-9].
# What number am I thinking of? _______________
# (The answer is 958, smallest would be 590)


has n_digits => (
	       isa => 'Int',
	       is => 'ro',
	       default => 3
);

has divisors => (
	       isa => 'Maybe[ArrayRef]',
	       is => 'ro',
	       default => sub{ [2,3,4,5,6,7,8,9,10] }
);

# sub n_digits{
# 	my $self = shift;
# 	my $n_digits = shift;
# 	if(defined $n_digits){
# 		$self->{n_digits} = $n_digits;
# 	}
# 	return $self->{n_digits};
# }

# sub divisors{
# 	my $self = shift;
# 	my $divisors = shift;
# 	if(defined $divisors){
# 		$self->{divisors} = $divisors;
# 	}
# 	return $self->{divisors};
# }

sub BUILD{
my $self = shift;
	# my $class = shift;
	# my $self = bless {}, $class;
	# my $args = shift || {}; # hash ref with args and values
	# my $default_params = { 'n_digits' => 3, 'divisors' => [2, 3, 4, 5, 10] };
	# foreach (keys %$default_params){
	#   $self->{$_} = $default_params->{$_};
	# }
	# foreach (keys %$args){
	#  # print "resetting parameter $_ to ", $args->{$_}, "\n";
	#   $self->{$_} = $args->{$_};
	# }

	my $problem_text_template = 'Can you figure out the mystery number? Here are some clues. \newline ' .
	"It is the EXTREME NDIGITS-digit number which: " .
	  ' \begin{itemize} [itemsep=-0.3em, topsep=-0.3em] ' .
	" OTHER_CLUES " .
	  ' \end{itemize} ' .
	"What is the mystery number? ";
	$self->problem_text_template($problem_text_template);

	my $answer_text_template = "The mystery number is ANSWER.";
	$self->answer_text_template($answer_text_template);
	return $self;
}

sub random_problem{
	my $self = shift;
	my $which_extreme = (rand() < 0.5)? ' largest ': ' smallest ';
 	my $n_digits = shift || $self->n_digits();
	my $divisors_ref = shift;
	my @divisors = (defined $divisors_ref)? @$divisors_ref :  @{$self->divisors()};
#	print "divisors: ", join("; ", @divisors), "\n";
	my $divisor ;
# my %div_count = ();
# 	for (1..300) {
	  my $index = int(rand() * scalar @divisors);
	  $divisor = $divisors[$index];
#	  $div_count{$divisor}++;
	#  print "divisor: $divisor \n";
#	}
	# for(keys %div_count){
	#   print $_, "  ", $div_count{$_}, "\n";
	# }
	my %required_digits = ();
	my $n_required_digits_chosen = 0;

	while (scalar keys %required_digits < $n_digits - 1){
		my $candidate_required_digit = int(rand() * 10);
		$required_digits{$candidate_required_digit}++;
  	}
 		
	my $problem_text = $self->problem_text_template();
# print "A $problem_text \n";
	$problem_text =~ s/EXTREME/$which_extreme/;
	$problem_text =~ s/NDIGITS/$n_digits/;
# * is a multiple of 2 [or 3,4,5,6,9], and
# * has at least one digit which as a 5 [or 0-9], and
# * has at least one digit which is a 9 [or 0-9].
# What number am I thinking of? _______________
# (The answer is 958, smallest would be 590)

my $other_clues = ' \item is a multiple of ' . $divisor . ' and ';
for (keys %required_digits){
$other_clues .= ' \item has at least one digit which is a ' . $_ . ', and ';
}
$other_clues =~ s/, and\s*$/. /;
	$problem_text =~ s/OTHER_CLUES/$other_clues/;
#$problem_text .= "What is the mystery number?";

my $answer_text = $self->answer_text_template();
	$answer_text =~ s/ANSWER/(answer not calculated)/;
	return ($problem_text, $answer_text);
}



__PACKAGE__->meta->make_immutable;


1;
