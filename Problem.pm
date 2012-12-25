package Problem;
# abstract class for computer-generated math problems
# The idea is that for each subclass which implements a different kind of problem
# you can generate many random problems, so everyone can have a similar set of problems,
# but with different numbers. 

use Moose;
use namespace::autoclean;
use Carp;
use List::Util qw ( min max sum shuffle );
use TomfyTex qw ( box_chain answer_box );

my $page_tex_template = 
  'BSES Math Team  \\hspace{1in}   PAGE_TITLE  \newline \vspace{4 mm} \newline ' . "\n" .
 ' What is your name? ' . answer_box('3.5in') . ' \newline \vspace{0.5mm} \newline' . "\n" .
' EXAMPLE \newline ' . # \vspace{4mm} ' .
  '\begin{enumerate}   [itemsep=2em, topsep=0.3em]  ' . "\n" .
 # '\item What is your name? ' . answer_box('3.5in') . ' \vspace{0.5mm}' . "\n" .
  ' THE_PROBLEMS ' . ' \end{enumerate}  \pagebreak ' . "\n";

has problem_text_template => (
	isa => 'Str',
	is => 'rw',
	default => ''
);

has problem_text_templates => (
                                isa     => 'ArrayRef',
                                is      => 'rw',
                                default => sub { [] }
                              );

has answer_text_template => (
        isa => 'Str',
        is => 'rw',
        default => ''
);

has page_tex_template => (
		 isa => 'Str',
		 is => 'rw',
		 default => "$page_tex_template"
);


sub shuffle_arrays {
  my $self = shift;
  my $arrays_to_shuffle = shift; # array ref.
  for my $a ( @{$arrays_to_shuffle} ) {
    if (exists $self->{$a}) {
      my @array = shuffle @{ $self->{$a} };
      $self->{$a} = \@array;
    }
  }
}

# shift, push, and return the shifted value
# argument is string, the name of array to cycle 
sub cycle_array {
  my $self = shift;
  my $array_to_cycle = shift;
  my $value = shift @{$self->{$array_to_cycle}};
  push @{$self->{$array_to_cycle}}, $value;
return $value;
}

# given array ref return random element (equal weights)
sub choose_random{
my $self = shift;
my $choices_aref = shift;
my @choices = @$choices_aref;
my $n = scalar @choices;
return $choices[ int(rand()*$n) ];
}
# given hash ref with values representing weights (i.e. rel probabilities) return random key
sub weighted_choose_random{
my $self = shift;
my $choice_weight = shift; #$self->unit_weights();
my $sum_weights = sum(values %$choice_weight);
my $n_weights = scalar keys %$choice_weight;
my $cume_weight = 0;
my $rndm = rand()* $sum_weights;
foreach my $choice (keys %$choice_weight){
$cume_weight += $choice_weight->{$choice};
return $choice if($rndm <= $cume_weight);
}
warn "in Problem::weighted_choose_random. $rndm, $cume_weight, $sum_weights.\n";
}

__PACKAGE__->meta->make_immutable;

1;
