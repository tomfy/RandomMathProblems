package SocksAndGumballs;

# Problems about choosing socks at random from
# a drawer full of socks.
# e.g.
# My sock draw contains 13 green socks, 16 red socks,
# and 9 blue socks. If I choose socks at random from the
# drawer (without looking), how many socks to I have to take
# to be sure of getting a matched pair, i.e. 2 socks of the same color?

use strict;
use Moose;
use namespace::autoclean;
use Carp;
use List::Util qw ( min max sum );
use TomfyTex qw ( box_chain answer_box );

use base 'Problem';

has colors => (
                isa     => 'ArrayRef',
                is      => 'ro',
                default => sub { [ 'red', 'blue', 'green', 'white', 'black', 'purple', 'orange' ] }
              );

has gumball_prices => (
                        isa     => 'ArrayRef',
                        is      => 'ro',
                        default => sub { [ '25 cents', '20 cents', '10 cents', '30 cents', '35 cents' ] }
                      );
has friends => (
    isa     => 'ArrayRef',
    is      => 'ro',
    default => sub {
        [ 'Alice', 'Boris', 'Carol', 'Dennis', 'Ellie', 'Fernando', 'Gabriela', 'Henry', 'Isaac', 'Julia' ];
    }
);

has questions => (
    isa     => 'HashRef',
    is      => 'ro',
    default => sub {
        {
           'QUESTION_SELF' => ' How much do I need to be willing to spend to be sure of getting what I want? ',
           'QUESTION_SELF_AND_FRIENDS' =>
             ' How much should I be willing to spend to be sure of getting the gumballs that my friends and I want? '
        };
    }
);

has sock_requirements_easy => (
    isa     => 'ArrayRef',
    is      => 'ro',
    default => sub {
        [
           ' a pair of COLOR1 socks? ',

           ' a matched pair of socks? (I don\'t care '
             . ' what color the pair is as long as there are '
             . ' two socks of the same color. ) ',

           ' two socks which are NOT the same color? ',
        ];
    }
);

has sock_requirements_medium => (
    isa     => 'ArrayRef',
    is      => 'ro',
    default => sub {
        [
           ' a pair of COLOR1 socks and a pair of COLOR2 socks? ',

           ' at least one COLOR1 sock and one COLOR2 sock? ',

           ' a COLOR1 pair, a COLOR2 pair, and a COLOR3 pair? ',

           ' at least one sock of each color? '
        ];
    }
);

has sock_requirements_hard => (
    isa     => 'ArrayRef',
    is      => 'ro',
    default => sub {
        [
               ' pairs of socks of two different colors? '
             . ' (Either a COLOR1 pair and a COLOR2 pair, a COLOR2 pair '
             . ' and a COLOR3 pair, or a COLOR3 pair and a COLOR1 pair.) ',

           ' two pairs of socks which are not COLOR3? '
             . ' (i.e. either a COLOR1 pair and a COLOR2 pair, or '
             . ' four COLOR1 socks or four COLOR2 socks.) ',

           ' either four COLOR1 socks or four COLOR2 socks? ',

           ' a pair of socks of the same color, and another pair ' . ' which are not the same color as each other? '
        ];
    }
);
has gumball_requirements_easy => (
    isa     => 'ArrayRef',
    is      => 'ro',
    default => sub {
        [
           ' a COLOR1 gumball. QUESTION_SELF',

           ' at least two different colors of gumballs. QUESTION_SELF',

           ' two gumballs of the same color. QUESTION_SELF'
        ];
    }
);

has gumball_requirements_medium => (
    isa     => 'ArrayRef',
    is      => 'ro',
    default => sub {
        [
           ' a gumball of each of the four colors. QUESTION_SELF',

           ' at least one COLOR1 gumball, and NCOLOR2_REQUIRED COLOR2 gumballs. QUESTION_SELF',

           ' gumballs that will make me and my '
             . ' friends FRIEND1, and FRIEND2 happy. I want a COLOR1 gumball, FRIEND1 wants COLOR2, and '
             . ' FRIEND2 wants COLOR4. QUESTION_SELF_AND_FRIENDS',
        ];
    }
);

has gumball_requirements_hard => (
    isa     => 'ArrayRef',
    is      => 'ro',
    default => sub {
        [

          #' gumballs for myself and my ' .
          #' friends FRIEND1, and FRIEND2. I want a COLOR1 gumball, FRIEND1 wants either COLOR2 or COLOR3, and ' .
          #' FRIEND2 wants COLOR1 or COLOR4. QUESTION_SELF_AND_FRIENDS',

          ' gumballs for myself and my friends FRIEND1, and FRIEND2. '
            . ' I hate COLOR1 gumballs, any other color is OK, '
            . ' FRIEND1 likes COLOR2, and '
            . ' FRIEND2 likes COLOR3. QUESTION_SELF_AND_FRIENDS',

          #' gumballs for myself and my friends FRIEND1 and FRIEND2. ' .
          #' I hate COLOR1 gumballs, any other color is OK, ' .
          #' FRIEND1 likes all colors except COLOR2, and ' .
          #' FRIEND2 likes all colors except COLOR3. QUESTION_SELF_AND_FRIENDS'

          # ' gumballs for myself and my '
          #   . ' friends FRIEND1 and FRIEND2. I want a COLOR1 gumball, FRIEND1 wants either COLOR2 or COLOR3, and '
          #   . ' FRIEND2 wants COLOR1 or COLOR4. QUESTION_SELF_AND_FRIENDS',
        ];
    }
);

sub BUILD {
    my $self = shift;

    my $problem_text_templates = [
            ' In my sock drawer I have NCOLOR1 COLOR1 socks, '
          . ' NCOLOR2 COLOR2 socks, '
          . ' and NCOLOR3 COLOR3 socks. '
          . ' If I close my eyes and take socks at random from the drawer, how many '
          . ' do I have to take to be sure of getting SOCK_REQUIREMENT ',

        ' A gumball machine has NCOLOR1 COLOR1 gumballs, NCOLOR2 COLOR2 ones, NCOLOR3 COLOR3 ones, '
          . ' and NCOLOR4 COLOR4 ones. Gumballs cost GUMBALL_PRICE apiece. I want to get GUMBALL_REQUIREMENT '

    ];

    $self->problem_text_templates($problem_text_templates);

    my $answer_text_template = "The mystery number is ANSWER.";
    $self->answer_text_template($answer_text_template);

    $self->shuffle_arrays(
                           [
                             'colors',                    'sock_requirements_easy',
                             'sock_requirements_medium',  'friends',
                             'gumball_requirements_easy', 'gumball_requirements_medium',
                             'gumball_prices'
                           ]
                         );

    return $self;
}

sub random_problem {
    my $self         = shift;
    my $difficulty   = shift || 'easy';
    my $problem_text = $self->cycle_array('problem_text_templates');

    my $color1 = $self->cycle_array('colors');
    my $color2 = $self->cycle_array('colors');
    my $color3 = $self->cycle_array('colors');
    my $color4 = $self->cycle_array('colors');

    my $n_color1 = 4 + int( rand() * 12 );
    my $n_color2 = 4 + int( rand() * 12 );
    my $n_color3 = 4 + int( rand() * 12 );
    my $n_color4 = 4 + int( rand() * 12 );

    $problem_text =~ s/NCOLOR1/$n_color1/g;
    $problem_text =~ s/COLOR1/$color1/g;

    $problem_text =~ s/NCOLOR2/$n_color2/g;
    $problem_text =~ s/COLOR2/$color2/g;

    $problem_text =~ s/NCOLOR3/$n_color3/g;
    $problem_text =~ s/COLOR3/$color3/g;

    $problem_text =~ s/NCOLOR4/$n_color4/g;
    $problem_text =~ s/COLOR4/$color4/g;

    my $sock_requirement = $self->cycle_array( 'sock_requirements_' . $difficulty );

    $sock_requirement =~ s/COLOR1/$color1/g;
    $sock_requirement =~ s/COLOR2/$color2/g;
    $sock_requirement =~ s/COLOR3/$color3/g;

    $problem_text =~ s/SOCK_REQUIREMENT/$sock_requirement/;

    my $gumball_price       = $self->cycle_array('gumball_prices');
    my $gumball_requirement = $self->cycle_array( 'gumball_requirements_' . $difficulty );

    my $ncolor2_required = int( rand() * 4 ) + 2;
    $gumball_requirement =~ s/NCOLOR2_REQUIRED/$ncolor2_required/;
    $gumball_requirement =~ s/COLOR1/$color1/g;
    $gumball_requirement =~ s/COLOR2/$color2/g;
    $gumball_requirement =~ s/COLOR3/$color3/g;
    $gumball_requirement =~ s/COLOR4/$color4/g;

    my @friends = @{ $self->friends() };

    $gumball_requirement =~ s/FRIEND1/$friends[0]/g;
    $gumball_requirement =~ s/FRIEND2/$friends[1]/g;

    $gumball_requirement =~ s/COLOR4/$color4/g;
    for ( keys %{ $self->questions() } ) {
        my $question = $self->questions()->{$_};
        $gumball_requirement =~ s/$_/$question/g;
    }
    $problem_text =~ s/GUMBALL_PRICE/$gumball_price/g;

    $problem_text =~ s/GUMBALL_REQUIREMENT/$gumball_requirement/;

    my $answer_text = $self->answer_text_template();
    $answer_text =~ s/ANSWER/(answer not calculated)/;
    return ( $problem_text, $answer_text );
}

sub page_o_problems {
    my $self               = shift;
    my $n_problems_on_page = shift || 3;             # number of problems on the page.
    my $n_each_difficulty  = shift || '1000,0,0';    # default: all easy
    my ( $n_easy, $n_medium, $n_hard ) = split( ",", $n_each_difficulty );
    $self->shuffle_arrays(
                           [
                             'colors',                    'sock_requirements_easy',
                             'sock_requirements_medium',  'friends',
                             'gumball_requirements_easy', 'gumball_requirements_medium',
                             'gumball_prices'
                           ]
                         );
    my $problems_string = '';
    for ( 1 .. $n_problems_on_page ) {
        my ( $problem, $answer );
        if ( $_ <= $n_easy ) {
            ( $problem, $answer ) = $self->random_problem('easy');
        } elsif ( $_ <= ( $n_easy + $n_medium ) ) {
            ( $problem, $answer ) = $self->random_problem('medium');
        } else {
            ( $problem, $answer ) = $self->random_problem('hard');
        }

        my $answer_box_width = '2in';    #($version == 0)? '4.5in' : '1.5in';
        $problems_string .= '\item ' . $problem . answer_box($answer_box_width) . ' \vspace{0.5mm}' . "\n";
    }
    my $page_string = $self->page_tex_template();
    $page_string =~ s{PAGE_TITLE}{Socks and Gumballs};
    $page_string =~ s{THE_PROBLEMS}{$problems_string};
    return $page_string;
}

__PACKAGE__->meta->make_immutable;

1;
