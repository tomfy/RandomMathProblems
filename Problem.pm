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
  "\n BSES Math Team  \\hspace{1in}    PAGE_TITLE  \n" . 
  ' \vspace {4 mm} ' . "\n" .
  '\begin{enumerate}   [itemsep=2em, topsep=0.3em]  ' . "\n" .
  '\item What is your name? ' . answer_box('3.5in') . "\n" .
  ' THE_PROBLEMS ' . ' \end{enumerate}  \pagebreak ' . "\n";

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


__PACKAGE__->meta->make_immutable;

1;
