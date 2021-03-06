package MultSubtractWord;
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
has n_to_keep => (    # number to keep before dividing among friends
                   isa     => 'ArrayRef[Int]',
                   is      => 'rw',
                   default => sub { [ 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 ] }
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
            'I have some THING_TYPE. I keep N_KEEP and give N_EACH ' . 
'to each of my N_FRIENDS friends. \newline '
          . ' How many THING_TYPE did I have to start with? ',

        'I had some THING_TYPE. I had N_KEEP left after I gave N_EACH ' . 
'to each of my N_FRIENDS friends. '
          . ' How many THING_TYPE did I have to start with? ',

        'I have N_THINGS THING_TYPE. '
          . 'If I give N_EACH to each of my N_FRIENDS friends,  '
           . 'how many THING_TYPE will I have left?',

        'My friends saw that I only had N_KEEP THING_TYPE, ' .
'so N_FRIENDS of my friends each gave me N_EACH THING_TYPE  ' . 
'How many THING_TYPE do I have now?',

        'My RELATIVE gave me some THING_TYPE. I gave N_EACH to each of my N_FRIENDS friends, ' .
'and then I had N_KEEP left. '
          . 'How many THING_TYPE did I have before giving any away? '
    ];
    $self->problem_text_templates($problem_text_templates);

    my $answer_text_template = "Each friend gets ANSWER THING_TYPE.";
    $self->answer_text_template($answer_text_template);

    $self->shuffle_arrays( [ 'n_to_keep', 'divisors', 'types_of_things', 'problem_text_templates' ] );
    return $self;
}

sub random_problem {
    my $self         = shift;
    my $divisors_ref = shift || undef;
    my @divisors     = ( defined $divisors_ref ) ? @$divisors_ref : @{ $self->divisors() };
    my $divisor      = shift @divisors;
    push @divisors, $divisor;
    $self->divisors( \@divisors );

    # my @types_of_things = @{ $self->types_of_things() };
    # my $type_of_thing   = shift @types_of_things;
    # push @types_of_things, $type_of_thing;
    # $self->types_of_things( \@types_of_things );

    my $type_of_thing = shift @{ $self->types_of_things() };
    push @{ $self->types_of_things() }, $type_of_thing;

    my @ns_to_keep = @{ $self->n_to_keep() };
    my $n_to_keep  = shift @ns_to_keep;
    push @ns_to_keep, $n_to_keep;
    $self->n_to_keep( \@ns_to_keep );

    my $problem_text = shift @{ $self->problem_text_templates() };
    push @{ $self->problem_text_templates() }, $problem_text;

    my $multiplier;
    my $product;
    my $n_start;
    while (1) {
        $multiplier = int( rand() * ( $self->max_multiplier() - 1 ) ) + 2;
        $product    = $divisor * $multiplier;
        $n_start    = $product + $n_to_keep;
        last if ( $product <= $self->max_n_things() );
    }

    # print "A $problem_text \n";
    my $relative = (' grandmother ', ' grandpa ', 
		    ' aunt ', ' uncle ', ' cousin ', 
		    ' brother ', ' sister ' )[ int(rand() * 7)];
    $problem_text =~ s/RELATIVE/$relative/g;
    $problem_text =~ s/N_THINGS/$n_start/g;
    $problem_text =~ s/THING_TYPE/$type_of_thing/g;
    $problem_text =~ s/N_EACH/$multiplier/g;
    $problem_text =~ s/N_FRIENDS/$divisor/g;
    $problem_text =~ s/N_KEEP/$n_to_keep/g;

    #$problem_text .= "What is the mystery number?";

    my $answer_text = $self->answer_text_template();
    $answer_text =~ s/ANSWER/$multiplier/;
    return ( $problem_text, $answer_text );
}

sub page_o_problems {
    my $self               = shift;
    my $n_problems_on_page = shift || 6;    # number of problems on the page.
    my $problems_string    = '';
    $self->shuffle_arrays( [ 'n_to_keep', 'divisors', 'types_of_things', 'problem_text_templates' ] );

    # my @divisors           = shuffle @{ $self->divisors() };
    # $self->divisors( \@divisors );
    # my @ptts = shuffle @{ $self->problem_text_templates() };
    # $self->problem_text_templates( \@ptts );
    # my @tots = shuffle @{ $self->types_of_things() };
    # $self->types_of_things( \@tots );

    for ( 1 .. $n_problems_on_page ) {
        my ( $problem, $answer ) = $self->random_problem();
        $problems_string .= '\item ' . $problem . answer_box('1.5in') . ' \vspace{0.5mm}' . "\n";
    }
    my $page_string = $self->page_tex_template();
    $page_string =~ s{PAGE_TITLE}{Multiplication and Subtraction};
    $page_string =~ s{THE_PROBLEMS}{$problems_string};
    return $page_string;
}

__PACKAGE__->meta->make_immutable;

1;
