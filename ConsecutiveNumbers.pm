package ConsecutiveNumbers;
use strict;
use Moose;
use namespace::autoclean;
use Carp;
use List::Util qw ( min max sum shuffle );
use TomfyTex qw ( box_chain answer_box );

use base 'Problem';

# the idea here is to produce random problems of the type:
# I am thinking of 3 consecutive 2-digit numbers (e.g. 13,14,15)
# The first (smallest) one is a multiple of 3, the middle one is
# a multiple of 4, and the last one is a multiple of 5.
# What are the 3 numbers. (A: 63,64,65 )

has max_n_things => (
                      isa     => 'Int',
                      is      => 'ro',
                      default => 72
                    );

has max_multiplier => (
                        isa     => 'Int',
                        is      => 'ro',
                        default => 12
                      );

has intro_text => (
		   isa => 'Str',
		   is => 'rw',
		   default => ''
		  );

has divisors => (
    isa     => 'Maybe[ArrayRef]',
    is      => 'rw',
    default => sub {
        [
           [ 3, 4, 5 ], [ 4, 5, 3 ], [ 5, 3, 4 ], [ 5, 4, 3 ], [ 4, 3, 5 ], [ 3, 5, 4 ],    # LCM: 60
           [ 4, 5, 6 ], [ 6, 5, 4 ],                                                        # LCM: 60
           [ 3, 5, 7 ], [ 5, 7, 3 ], [ 7, 5, 3 ], [ 3, 7, 5 ],                              # LCM: 105

           # [5,3,7] -> 5,6,7 & 110,111,112, [7,3,5] -> 98,99,100 # LCM: 105
           [ 4, 7, 3 ],  [ 3, 7,  4 ], [ 7,  3, 4 ], [ 4, 3,  7 ], [ 3,  4, 7 ], [ 7, 3, 4 ],     #LCM: 84
           [ 2, 3, 11 ], [ 3, 11, 2 ], [ 11, 2, 3 ], [ 2, 11, 3 ], [ 11, 3, 2 ], [ 3, 2, 11 ],    # LCM: 66
           [ 2, 5, 11 ], [ 5, 11, 2 ], [ 11, 2, 5 ], [ 11, 5, 2 ], [ 5, 2, 11 ],

           # [2,11,5]                98,99,100
           [ 5, 7, 11 ], [ 4, 7, 11 ],                                                            # 20,21,22

           # [5,6,7], #
           # X5,7,6
           # 7,6,5
           # 7,5,6
           [ 6, 5, 7 ],                                                                           #  54,55,56
           [ 6, 7, 5 ]
        ];
      }    # 48,49,50
);
has divisors_and_prime => (
    isa     => 'ArrayRef',
    is      => 'rw',
    default => sub {
        [
          [ 3, 'p', 5 ],    # 18,19,20 & 78,79,80
          [ 3, 'p', 4 ],    # 18,19,20; 30,31,32; 42,43,44; 66,67,68
          [ 4, 'p', 5 ],    # 28,29,30; 88,89,90
          [ 5, 'p', 6 ],    # 10,11,12; 40,41,42; 70,71,72
          [ 6, 'p', 5 ],    # 18,19,20; 78,79,80
          [ 5, 'p', 3 ],    # 10,11,12; etc. same as 5,p,6
          [ 4, 'p', 3 ],    # 16,17,18; 28,29,30; 40,41,42; 52,53,54; 88,89,90
          [ 5, 'p', 4 ],    # 10,11,12; 30,31,32; 70,71,72;
        ];
    }
);

# A: 3,5,7 -> 54,55,56;  5,7,3 -> 55,56,57; 7,5,3 -> 49,50,51; 5,3,7 -> X, 3,7,5->48,49,50
# 4,7,6 -> 76,77,78; 6,7,4 -> 90,91,92;
# 3,7,4 -> 90,91,92;  4,7,3 -> 76,77,78
# 3,4,7 -> 75,76,77; 7,4,3-> 91,92,93
# 4,3,7
# 3,2,7 -> 33,34,35 & 75,76,77
# 6,7,8 ->  6,7,8 &  174,175,176 but none with 2-digit numbers
# 2,3,5,7 ->
has problem_text_templates => (
                                isa     => 'ArrayRef[Str]',
                                is      => 'rw',
                                default => sub { [] }
                              );

has types_of_things => (
    isa     => 'ArrayRef',
    is      => 'rw',
    default => sub {
        [ 'apples', 'gummy bears', 'fossils', 'books', 'hats', 'stickers', 'socks', 'buttons' ];
    }
);

sub BUILD {
    my $self = shift;
my $intro_text = 'Numbers are consecutive if each number is one greater than the preceding one, like ' .
  ' \'58, 59, 60\' for example.';
$self->intro_text($intro_text);
  my $problem_text_templates = [
            'I am thinking of three 2-digit numbers which are consecutive (like 23,24,25). '
          . ' The smallest number is divisible by DIVISOR1, '
          . 'the middle number is divisible by DIVISOR2, '
          . 'and the largest number is divisible by DIVISOR3. \newline '
          . 'What three numbers could they be? ',

        'A set of three consecutive 2-digit numbers has '
          . 'a smallest number which is a multiple of DIVISOR1, '
          . 'a middle number which is a multiple of DIVISOR2, '
          . ' and a largest number which is a multiple of DIVISOR3. \newline '
          . ' What three numbers could they be? '
    ];
    $self->problem_text_templates($problem_text_templates);

    my $answer_text_template = "Each friend gets ANSWER THING_TYPE.";
    $self->answer_text_template($answer_text_template);

    $self->shuffle_arrays( [ 'divisors', 'problem_text_templates' ] );
    return $self;
}

sub random_problem {
    my $self                = shift;
    my $divisors_ref        = shift || undef;
    my @divisors            = ( defined $divisors_ref ) ? @$divisors_ref : @{ $self->divisors() };
    my $divisor_permutation = shift @divisors;
    push @divisors, $divisor_permutation;
    $self->divisors( \@divisors );

    #   my @types_of_things = @{ $self->types_of_things() };
    #    my $type_of_thing   = shift @types_of_things;
    #    push @types_of_things, $type_of_thing;
    #    $self->types_of_things( \@types_of_things );

    # my $multiplier;
    # my $product;

    # while (1) {
    #     $multiplier = int( rand() * ( $self->max_multiplier() - 1 ) ) + 2;
    #     $product = $divisor * $multiplier;
    #     last if ( $product <= $self->max_n_things() );
    # }

    my $problem_text = shift @{ $self->problem_text_templates() };
    push @{ $self->problem_text_templates() }, $problem_text;

    # print "A $problem_text \n";
    $problem_text =~ s/DIVISOR1/$divisor_permutation->[0]/;
    $problem_text =~ s/DIVISOR2/$divisor_permutation->[1]/;
    $problem_text =~ s/DIVISOR3/$divisor_permutation->[2]/;

    #$problem_text .= "What is the mystery number?";

    my $answer_text = $self->answer_text_template();
    $answer_text =~ s/ANSWER/Answer not calculated/;
    return ( $problem_text, $answer_text );
}

sub page_o_problems {
    my $self               = shift;
    my $n_problems_on_page = shift || 4;    # number of problems on the page.
    my $problems_string    = ''; #$self->intro_text() . ' \newline ';
    my @divisor_phrases = (' divisible by DIVISOR', ' a multiple of DIVISOR', ' has DIVISOR as a factor ');
    $self->shuffle_arrays( [ 'divisors', 'problem_text_templates' ] );
    for ( 1 .. $n_problems_on_page ) {
        my ( $problem, $answer ) = $self->random_problem();
	if($_ == 1){
	  $problem = $self->intro_text() . " " . $problem;
	}
        $problems_string .= '\item ' . $problem . answer_box('1.5in') . ' \newline \vspace{0.5mm}' . "\n";
    }
    my $page_string = $self->page_tex_template();
    $page_string =~ s{PAGE_TITLE}{Consecutive Numbers and Divisibility};
    $page_string =~ s{THE_PROBLEMS}{$problems_string};
    return $page_string;
}

__PACKAGE__->meta->make_immutable;

1;
