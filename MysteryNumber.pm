package MysteryNumber;
use strict;
use Moose;
use namespace::autoclean;
use Carp;
use List::Util qw ( min max sum );
use TomfyTex qw ( box_chain answer_box );

use base 'Problem';

# the idea here is to produce random problems of the type:
# I'm thinking of a 3 digit number. It is the largest [or smallest] 3 digit number which:
# * is a multiple of 2 [or 3,4,5,6,9], and
# * has at least one digit which as a 5 [or 0-9], and
# * has at least one digit which is a 9 [or 0-9].
# What number am I thinking of? _______________
# (The answer is 958, smallest would be 590)

has n_digits => (
                  isa     => 'Int',
                  is      => 'ro',
                  default => 3
                );

has divisors => (
                  isa     => 'ArrayRef',
                  is      => 'ro',
                  default => sub { [ 2, 3, 4, 5, 6, 7, 8, 9, 10, 'odd' ] }
                );

has required_digits => (
			isa => 'ArrayRef',
			is => 'ro',
			default => sub{ [0,1,2,3,4,5,6,7,8,9] }
);

sub BUILD {
    my $self = shift;

    my $problem_text_templates = [
        ' Can you find a number which:' .                       #  \newline ' .
          ' \begin{itemize} [itemsep=-0.3em, topsep=-0.3em] '
          . ' \item is a NDIGITS-digit number, and '
          . ' OTHER_CLUES '
          . ' \end{itemize}  '
	 . ' Write down as many such numbers as you can find: \newline ' . "\n",    #  \vspace{5mm} ',

        'Can you figure out the mystery number? Here are some clues. \newline '
          . "It is the EXTREME NDIGITS-digit number which: "
          . ' \begin{itemize} [itemsep=-0.3em, topsep=-0.3em] '
          . " OTHER_CLUES "
          . ' \end{itemize} '
          . "What is the mystery number? ",

    ];
    $self->problem_text_templates($problem_text_templates);

    my $answer_text_template = "The mystery number is ANSWER.";
    $self->answer_text_template($answer_text_template);

    $self->shuffle_arrays( [ 'divisors', 'required_digits' ] );

    return $self;
}

sub random_problem {
    my $self         = shift;
    my $n_digits     = shift || $self->n_digits();
    my $divisors_ref = shift;                        # to specify a set of divisors other than default.
    my $version      = shift || 1;

    # get extreme (smallest or largest):
    my $which_extreme = ( rand() < 0.5 ) ? ' largest ' : ' smallest ';

    # get divisor:
    my $divisor = shift @{ $self->divisors() };
    push @{ $self->divisors() }, $divisor;

    # get required digit(s):
    my @required_digits = ();
    for (1..$n_digits-1){
      my $a_required_digit = shift @{$self->required_digits()};
      push @{$self->required_digits()}, $a_required_digit;
      push @required_digits, $a_required_digit;
    }
#print STDERR "version: [$version] \n"; 
#print STDERR " required digits: ", join("; ",  @{$self->required_digits()}), "\n";
#exit;
    my $problem_text;
    my $other_clues = '';
    if ( $version == 0 ) {
        $problem_text = $self->problem_text_templates()->[0];
#print STDERR $problem_text, "\n\n";
        for ( @required_digits ) {
            $other_clues .= ' \item has at least one digit which is a ' . $_ . ', and ';
#	    print STDERR "other clues: ", $other_clues, "\n";
        }
	$other_clues .= ( $divisor eq 'odd' )
          ? ' \item is an odd number, and '
          : ' \item is a multiple of ' . $divisor . ". ";

    } else {
        $problem_text = $self->problem_text_templates()->[1];
        $other_clues =
          ( $divisor eq 'odd' )
          ? ' \item is an odd number, and '
         # : ' \item is a multiple of ' . $divisor . ' and ';
	  : ' \item is divisible by ' . $divisor . ' and ';
        for ( @required_digits ) {
            $other_clues .= ' \item has at least one digit which is a ' . $_ . ', and ';
        }
        $other_clues  =~ s/, and\s*$/. /;
        #$problem_text .= "What is the mystery number?";
    }
 $other_clues =~ s/a 8/an 8/;
#print STDERR $problem_text, "\n";

 $problem_text =~ s/EXTREME/$which_extreme/;
        $problem_text =~ s/NDIGITS/$n_digits/;
        $problem_text =~ s/OTHER_CLUES/$other_clues/;

# print STDERR $problem_text, "\n"; exit;
    my $answer_text = $self->answer_text_template();
    $answer_text =~ s/ANSWER/(answer not calculated)/;
    return ( $problem_text, $answer_text );
}

sub page_o_problems {
    my $self               = shift;
    my $n_problems_on_page = shift || 3;    # number of problems on the page.
    my $version = shift;
    if(!defined $version){ $version = 1; };

  $self->shuffle_arrays( [ 'divisors', 'required_digits' ] );

    my $problems_string    = '';
    for ( 1 .. $n_problems_on_page ) {
     #    my ( $problem, $answer ) = $self->random_problem(undef, undef, $version);
# my $answer_box_width = ($version == 0)? '4.5in' : '1.5in';
#         $problems_string .= '\item ' . $problem . answer_box($answer_box_width) . ' \vspace{0.5mm}' . "\n";

$problems_string .= $self->random_problem_tex();
    }
    my $page_string = $self->page_tex_template();
    $page_string =~ s{PAGE_TITLE}{Mystery Numbers};
    $page_string =~ s{THE_PROBLEMS}{$problems_string};
    return $page_string;
}

__PACKAGE__->meta->make_immutable;

1;
