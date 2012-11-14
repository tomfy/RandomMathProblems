package Area;

# Problems about area and perimeter
# e.g. A rectangle has a perimeter of 32 inches. The lengths of all of its sides
# are whole numbers of inches. What is the smallest/largest area that the rectangle can have?
#
# A rectangle is assembled from 34 square tiles. The square tiles are 1 inch
# on a side. What is the smallest largest perimeter the rectangle can have?
# A rectangle is assembled from square tiles. The tiles are 1 inch on a side. If
# the perimeter or the rectangle is 34 inches, what is the smallest/largest area
# the rectangle can have?
# Using 1 inch x 1 inch square tiles, what is the largest number of tiles that can
# be used to make a rectangle with a perimeter of 34 inches?

use strict;
use Moose;
use namespace::autoclean;
use Carp;
use List::Util qw ( min max sum );
use TomfyTex qw ( box_chain answer_box );

use base 'Problem';

has max_perimeter => (
                       isa     => 'Int',
                       is      => 'ro',
                       default => 100
                     );

has max_area => (
                  isa     => 'Int',
                  is      => 'ro',
                  default => 100
                );

has max_tile_sizes => (
                        isa     => 'HashRef',
                        is      => 'ro',
                        default => sub { { foot => 2, inch => 12, cm => 20, centimeter => 20 } }
                      );

has tilesize_weights => (
                    isa     => 'HashRef',
                    is      => 'ro',
                    default => sub { { 1 => 6, 2 => 4, 3 => 2, 4 => 1, 5 => 1, 8 => 1, 10 => 1 } }
                  );

has unit_weights => (
		     isa => 'HashRef',
		     is => 'ro',
		     default => sub { { foot => 1, inch => 2, cm => 1, centimeter => 1 } }
);

has unit_plurals => (
                      isa     => 'HashRef',
                      is      => 'ro',
                      default => sub { { foot => 'feet', inch => 'inches', cm => 'cm', centimeter => 'centimeters' } }
                    );

has problem_selection => (
			  isa => 'ArrayRef',
			  is => 'ro',
			  default => sub { [0,1,2] }
);

sub BUILD {
    my $self = shift;

    my $problem_text_templates = [
            ' A rectangle has a perimeter of PERIMETER UNITS. '
          . ' The lengths of all of its sides are whole numbers of UNITS. '
          . ' What is the EXTREME area that the rectangle can have? ',

        ' A rectangle is assembled from N_TILES square tiles. '
          . ' The tiles are TILE_SIZE on a side. '
          . ' What is the EXTREME perimeter the rectangle can have? ',

        ' A rectangle is assembled from square tiles. The tiles are TILE_SIZE on a side. '
          . ' If the perimeter of the rectangle is PERIMETER UNITS, '
          . ' what is the EXTREME area the rectangle can have? '

    ];
my @probs = ();
    for (@{$self->problem_selection()}){
push @probs, $problem_text_templates->[$_];
}
    $self->problem_text_templates(\@probs);

    my $answer_text_template = "The mystery number is ANSWER.";
    $self->answer_text_template($answer_text_template);

    #   $self->shuffle_arrays( [ 'divisors', 'required_digits' ] );

    return $self;
}

sub random_problem {
    my $self = shift;

    # get extreme (smallest or largest):
    my $which_extreme = ( rand() < 0.5 ) ? ' largest ' : ' smallest ';

    my @units = keys %{ $self->unit_plurals() };
    my $unit  = $self->weighted_choose_random($self->unit_weights()); # $units[ int( rand() * 3 ) ];
    my $perimeter;
    my $unit_maybe_plural;
my $unit_plural =  $self->unit_plurals()->{$unit};
    my $tile_size_number;
    my $tile_size_text; # includes unit, e.g. '4 cm'
    while (1) {
        $tile_size_number = $self->weighted_choose_random($self->tilesize_weights());
	$unit_maybe_plural = ( $tile_size_number == 1 ) ? $unit : $unit_plural;
                $tile_size_text = "$tile_size_number $unit_maybe_plural ";
                print STDERR "[$tile_size_number]    [$tile_size_text] \n";
                $perimeter = 2 * int( rand() * $self->max_perimeter() / ( 2 * $tile_size_number ) + 1 );
                $perimeter *= $tile_size_number;
                last if ( $perimeter <= $self->max_perimeter() );
        }
        my $n_tiles = int( rand() * 40 ) + 6;    # 6..45

        my $problem_text = $self->choose_random($self->problem_text_templates());
print STDERR "perimeter: $perimeter \n";
        $problem_text =~ s/PERIMETER/$perimeter/g;
        $problem_text =~ s/N_TILES/$n_tiles/g;
        $problem_text =~ s/EXTREME/$which_extreme/g;
        $problem_text =~ s/UNITS/$unit_plural/g;
        $problem_text =~ s/TILE_SIZE/$tile_size_text/g;

        my $answer_text = $self->answer_text_template();
        $answer_text =~ s/ANSWER/(answer not calculated)/;
        return ( $problem_text, $answer_text );
    }


    sub page_o_problems {
          my $self               = shift;
          my $n_problems_on_page = shift || 3;    # number of problems on the page.
                                                  # my $version = shift;
                                                  # if(!defined $version){ $version = 1; };

          # $self->shuffle_arrays( [ 'divisors', 'required_digits' ] );

          my $problems_string = '';
          for ( 1 .. $n_problems_on_page ) {
              my ( $problem, $answer ) = $self->random_problem();
              my $answer_box_width = '2in';       #($version == 0)? '4.5in' : '1.5in';
              $problems_string .= '\item ' . $problem . answer_box($answer_box_width) . ' \vspace{0.5mm}' . "\n";
          }
          my $page_string = $self->page_tex_template();
          $page_string =~ s{PAGE_TITLE}{Area and Perimeter};
          $page_string =~ s{THE_PROBLEMS}{$problems_string};
          return $page_string;
    }

    __PACKAGE__->meta->make_immutable;

    1;
