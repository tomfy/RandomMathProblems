package DivisionWord;
use strict;
use Moose;
use namespace::autoclean;
use Carp;
use List::Util qw ( min max sum shuffle );
use TomfyTex qw ( box_chain answer_box );

use base 'Problem';

# the idea here is to produce random problems of the type:
# I have N things, I give them all away to my M friends, so that each friend
# gets the same number of things. How many things does each friend get?
# or:

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

has divisors => (
                  isa     => 'Maybe[ArrayRef]',
                  is      => 'rw',
                  default => sub { [ 2, 3, 4, 5, 6, 7, 8, 9, 10 ] }
                );

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

    my $problem_text_templates = [
            'I have N_THINGS THING_TYPE. I give them all away to my N_FRIENDS friends, '
          . ' so that each friend gets the same number of THING_TYPE. \newline '
          . ' How many THING_TYPE does each friend get? ',

        'I had N_THINGS THING_TYPE. I gave them all away to my N_FRIENDS friends, '
          . ' so that each friend got the same number of THING_TYPE. \newline '
          . ' How many THING_TYPE did each friend get? ',

        'I have N_THINGS THING_TYPE. '
          . 'If I gave the same number of THING_TYPE to each of my N_FRIENDS friends, '
          . 'I wouldn\'t have any THING_TYPE left. \newline '
          . 'How many THING_TYPE would each friend get?',

        'My friends saw that I didn\'t have any THING_TYPE, so each of them gave me N_FRIENDS THING_TYPE, '
          . 'and now I have N_THINGS THING_TYPE. \newline How many friends do I have?',

        'My grandmother gave me N_THINGS THING_TYPE. I got rid of them all '
          . 'by giving N_FRIENDS THING_TYPE to each of my friends. \newline '
          . 'How many friends do I have? '
    ];
    $self->problem_text_templates($problem_text_templates);

    my $answer_text_template = "Each friend gets ANSWER THING_TYPE.";
    $self->answer_text_template($answer_text_template);

$self->shuffle_arrays( [ 'divisors', 'types_of_things', 'problem_text_templates' ] );
    return $self;
}

sub random_problem {
    my $self         = shift;
    my $divisors_ref = shift || undef;
    my @divisors     = ( defined $divisors_ref ) ? @$divisors_ref : @{ $self->divisors() };
    my $divisor      = shift @divisors;
    push @divisors, $divisor;
    $self->divisors( \@divisors );
    my @types_of_things = @{ $self->types_of_things() };
    my $type_of_thing   = shift @types_of_things;
    push @types_of_things, $type_of_thing;
    $self->types_of_things( \@types_of_things );
    my $multiplier;
    my $product;

    while (1) {
        $multiplier = int( rand() * ( $self->max_multiplier() - 1 ) ) + 2;
        $product = $divisor * $multiplier;
        last if ( $product <= $self->max_n_things() );
    }

    my $problem_text = shift @{ $self->problem_text_templates() };
    push @{ $self->problem_text_templates() }, $problem_text;

    # print "A $problem_text \n";
    $problem_text =~ s/N_THINGS/$product/;
    $problem_text =~ s/THING_TYPE/$type_of_thing/g;
    $problem_text =~ s/N_FRIENDS/$divisor/;

    #$problem_text .= "What is the mystery number?";

    my $answer_text = $self->answer_text_template();
    $answer_text =~ s/ANSWER/$multiplier/;
    return ( $problem_text, $answer_text );
}

sub page_o_problems {
    my $self               = shift;
    my $n_problems_on_page = shift || 5;                       # number of problems on the page.
    my $problems_string    = '';
    $self->shuffle_arrays( [ 'divisors', 'types_of_things', 'problem_text_templates' ] );
    for ( 1 .. $n_problems_on_page ) {
        my ( $problem, $answer ) = $self->random_problem();
        $problems_string .= '\item ' . $problem . answer_box('1.5in') . ' \vspace{0.5mm}' . "\n";
    }
    my $page_string = $self->page_tex_template();
    $page_string =~ s{PAGE_TITLE}{Division};
    $page_string =~ s{THE_PROBLEMS}{$problems_string};
    return $page_string;
}




__PACKAGE__->meta->make_immutable;

1;
