package NumberRecycler;

# Problems about iterated functions,
# e.g. if a (whole) number is one digit multiply by 2
# if two digits, add them together.
# iterate, e.g.:   3,6,12,3,6,12,...
# e.g.:  4,8,16,7,14,5,10,1,2,4,...
# or 1 digit -> *2
#  2 digits, take difference of digits.
# 1,2,4,8,16,5,10,1...    3,6,12,1...   7,14,3,6,...   9,18,7,14,3,...
# 1 digit-> *3; 2 digits, take difference of digits:
# 1,3,9,27,5,15,4,12,1   2,6,18,7,21,1,...   8,24,2,6,...
# *4, diff of digits: 1,4,16,5,20,2,8,32,1...  3,12,1... 6,24,2,8,32,1...
# 7,28,6,...  9,36,3,
use strict;
use Moose;
use namespace::autoclean;
use Carp;
use List::Util qw ( min max sum );
use TomfyTex qw ( box_chain answer_box );

use base 'Problem';

has small_number_criteria => (
    isa     => 'HashRef',
    is      => 'ro',
    default => sub { 
      {'one_digit' => [ ' is a one-digit number ', ' has more than one digit ' ] } 
}
);

#			'up_to' =>  [['times', 'plus', 'square'],['digit_sum', 'digit_difference', 'digit_product', 'remainder']]
#			'multiple_of',
#			'odd'

has small_number_functions => (
    isa     => 'ArrayRef',
    is      => 'ro',
    default => sub { [ 'times', 'plus', 'times', 'plus', 'square' ] }
);

has large_number_functions => (
    isa => 'ArrayRef',
    is  => 'ro',
    default =>
      sub { [ 'digit_sum', 'digit_difference', 'digit_product', 
#'remainder' 
] }
);

has multipliers => (
    isa     => 'ArrayRef',
    is      => 'ro',
    default => sub { [ 2, 3, 4, 5 ] }
);

has divisors => (
    isa     => 'ArrayRef',
    is      => 'ro',
    default => sub { [ 2, 3, 4, 5 ] }
);

has increments => (
    isa     => 'ArrayRef',
    is      => 'ro',
    default => sub { [ 2, 3, 4, 5, 6, 7, 8, 9, 10 ] }
);

has max_iterations_to_cycle => (
isa => 'Int',
is => 'rw',
default => 12
);

has function_texts => (
		       isa => 'HashRef',
		       is => 'ro',
		       default => sub {
         {
             'times'         => ' multiply it by MULTIPLIER ',
             'plus'           => ' add INCREMENT to it ',
             'square'        => ' square it ',
             'digit_sum'     => ' output the sum of its digits ',
             'digit_product' => ' output the product of its digits ',
             'digit_difference' =>
 ' output the difference between its digits (the larger digit minus the smaller digit) ',
#             'remainder' => ' find the remainder when the input number is divided by DIVISOR and output that '
	   }});

has small_number_criterion => (
    isa     => 'Maybe[Str]',
    is      => 'rw',
    default => undef
);

has small_number_function => (
    isa     => 'Maybe[Str]',
    is      => 'rw',
    default => undef
);

has large_number_function => (
    isa     => 'Maybe[Str]',
    is      => 'rw',
    default => undef
);

has multiplier => (
    isa     => 'Maybe[Int]',
    is      => 'rw',
    default => undef
);

has divisor => (
    isa     => 'Maybe[Int]',
    is      => 'rw',
    default => undef
);

has increment => (
    isa     => 'Maybe[Int]',
    is      => 'rw',
    default => undef
);

sub BUILD {
    my $self = shift;

    my $problem_text_templates = [
' My number-recycling machine takes a whole number as input, and produces '
          . ' an output number by following these rules: '
 . ' \begin{itemize} [itemsep=-0.3em, topsep=-0.3em] '
          . ' \item If the input SMALL_N_CRITERION, SMALL_N_FUNCTION and output the result. '
          . ' \item If the input LARGE_N_CRITERION, LARGE_N_FUNCTION. '
 . ' \end{itemize}  '
          . ' (Example: If the input is NSMALL the output is FNSMALL; if the input is NLARGE the output is FNLARGE.) '
   . ' I start by putting NSTART into my machine, and each time I get an output number I '
      . ' put it back into the machine. \newline '
. ' * What will the first NITERATIONS1 output numbers? ' . answer_box('2.5in') . ' \newline '
. ' * What will be the NITERATIONS2 output number? ' . answer_box('2.5in') . ' \newline '
    ];

    $self->problem_text_templates($problem_text_templates);

    my $answer_text_template = "The mystery number is ANSWER.";
    $self->answer_text_template($answer_text_template);

    $self->shuffle_arrays(
        [
            'small_number_functions', 'large_number_functions',
            'divisors',               'multipliers',
            'increments'
        ]
    );

    return $self;
}

sub example {
    my $self = shift;
    my $example_text =
' Example problem: '
. ' My number-recycling machine takes a whole number as input, and produces '
      . ' an output number by following these rules: '
 . ' \begin{itemize} [itemsep=-0.3em, topsep=-0.3em] '
      . ' \item If the input is a one-digit number, double it and output the result. '
      . ' \item If the input has more than one digit, output the sum of its digits. '
. ' \end{itemize} '
      . ' For example, if the input is 3 the output is 6, and if the input is 26 the output is 8. '
      . ' I start by putting 3 into my machine, and each time I get an output number I '
      . ' put it back into the machine. \newline '
. ' * What will be the first 8 output number? '
      . 'Answer: First input: 3, first output: 6; '
      . ' second input: 6, second output: 12; etc. '
. ' The first 6 outputs are 6,12,3,6,12,3,6,12. \newline '
      . ' * What will be the 100th output number? '
. ' Answer: The 3rd, 6th, 9th, etc. output numbers will be 3. '
      . ' The 99th output number will also be 3, so the 100th will be 6. ';
    return $example_text;
}

sub random_problem {
    my $self = shift;

   my $problem_text = $self->choose_random( $self->problem_text_templates() );
    while(1){
    my $small_number_criterion = 'one_digit'; # $self->small_number_criteria()->[0];
my $small_n_criterion_text =  $self->small_number_criteria()->{$small_number_criterion}->[0];
my $large_n_criterion_text =  $self->small_number_criteria()->{$small_number_criterion}->[1];
    my $small_number_function  = $self->cycle_array('small_number_functions');
    my $large_number_function  = $self->cycle_array('large_number_functions');
    my $divisor                = $self->cycle_array('divisors');
    my $multiplier             = $self->cycle_array('multipliers');
    my $increment              = $self->cycle_array('increments');
    my $small_number_text = $self->function_texts()->{$small_number_function};
    my $large_number_text = $self->function_texts()->{$large_number_function};
   my $small_n_function_text = $self->function_texts()->{$small_number_function};
    my $large_n_function_text = $self->function_texts()->{$large_number_function};

my $f_params =  [ $small_number_criterion, $small_number_function, $large_number_function, $multiplier, $divisor, $increment ];
print STDERR join("; ", @$f_params), "\n";

my $small_in = int(rand(8)) + 2;
my $smallin_out = $self->the_function($small_in, $f_params);
my $large_in = int(rand(20)) + 10;
my $largein_out = $self->the_function($large_in, $f_params);
my $nstart = int(rand(20)) + 2;
my $n_iterations1 = 8; # int(rand(4) + 5);
my $n_iterations2 = 10*(int(rand(4)) + 3);  # 
$n_iterations2 .= _ordinal_ending($n_iterations2);
my ($iterations_to_cycle, $cycle_length) = $self->_iterate_to_cycle($nstart, $f_params);
print STDERR "iterations to cycle, cycle length:  $iterations_to_cycle, $cycle_length \n";
  #      print STDERR "small number text: $small_number_text \n";
    $problem_text =~ s/SMALL_N_CRITERION/$small_n_criterion_text/g;
    $problem_text =~ s/LARGE_N_CRITERION/$large_n_criterion_text/g;
    $problem_text =~ s/SMALL_N_FUNCTION/$small_n_function_text/g;
    $problem_text =~ s/LARGE_N_FUNCTION/$large_n_function_text/g;
    $problem_text =~ s/MULTIPLIER/$multiplier/g;
    $problem_text =~ s/DIVISOR/$divisor/g;
    $problem_text =~ s/INCREMENT/$increment/g;


# print STDERR $iterations_to_cycle, "\n";
$problem_text =~ s/FNSMALL/$smallin_out/g;
$problem_text =~ s/NSMALL/$small_in/g;
$problem_text =~ s/FNLARGE/$largein_out/g;
$problem_text =~ s/NLARGE/$large_in/g;

$problem_text =~ s/NSTART/$nstart/g;
$problem_text =~ s/NITERATIONS1/$n_iterations1/g;
$problem_text =~ s/NITERATIONS2/$n_iterations2/g;
$problem_text =~ s/(\S) ([,.])/$1$2/g;
  last if($iterations_to_cycle <= $self->max_iterations_to_cycle());
  }
    my $answer_text = $self->answer_text_template();
    $answer_text =~ s/ANSWER/(answer not calculated)/;
    return ( $problem_text, $answer_text );
}

sub the_function {
    my $self         = shift;
    my $input_number = shift;
    my $params       = shift;    # arrayr$problem_text =~ s/FNLARGE/$largein_out/g;$problem_text =~ s/FNLARGE/$largein_out/g;ef
    my ( $small_n_criterion, $f_small, $f_large, $multiplier, $divisor, $increment )
      = @$params;
    die "Input number negative: $input_number. Exiting.\n"
      if ( $input_number < 0 );
    if ( $small_n_criterion eq 'one_digit' ) {
        if ( $input_number < 10 ) {    # one digit
            if ( $f_small eq 'times' ) {
                return $input_number * $multiplier;
            }
            elsif ( $f_small eq 'plus' ) {
                return $input_number + $increment;
            }
            elsif ( $f_small eq 'square' ) {
                return $input_number * $input_number;
            }
        }
        else {                         # > 1 digit
            if ( $f_large eq 'digit_sum' ) {
                return _digit_sum($input_number);
            }
            elsif ( $f_large eq 'digit_difference' ) {
                return _digit_difference($input_number);
            }
            elsif ( $f_large eq 'digit_product' ) {
                return _digit_product($input_number);
            }
            elsif ( $f_large eq 'remainder' ) {
                return $input_number % $divisor;
            }
        }
    }
    else {
        die "small number criterion $small_n_criterion not implemented.\n";
    }
    return;
}

sub page_o_problems {
    my $self               = shift;
    my $n_problems_on_page = shift || 2;    # number of problems on the page.
                                            # my $version = shift;
         # if(!defined $version){ $version = 1; };
    $self->shuffle_arrays(
        [
            'small_number_functions', 'large_number_functions',
            'divisors',               'multipliers',
            'increments'
        ]
    );

    my $problems_string = '';
    for ( 1 .. $n_problems_on_page ) {
        my ( $problem, $answer ) = $self->random_problem();
    #    my $answer_box_width = '2in';    #($version == 0)? '4.5in' : '1.5in';
        $problems_string .=
            '\item ' 
          . $problem
          . ' \vspace{-5mm}' . "\n";
    }
    my $page_string = $self->page_tex_template();
    $page_string =~ s{PAGE_TITLE}{Number Recycler};
my $example = $self->example(); # print STDERR $example, "\n";

$page_string =~ s{EXAMPLE}{$example};
    $page_string =~ s{THE_PROBLEMS}{$problems_string};
    return $page_string;
}

sub _iterate_to_cycle{
  my $self         = shift;
    my $input_number = shift;
    my $params       = shift;    # arrayr$problem_text =~ s/FNLARGE/$largein_out/g;$problem_text =~ s/FNLARGE/$largein_out/g;ef
    my ( $small_n_criterion, $f_small, $f_large, $multiplier, $divisor, $increment )
      = @$params;
my $max_iterations = 40;
    die "Input number negative: $input_number. Exiting.\n" if($input_number < 0);
my $number = $input_number;
#print STDERR "input number : $number \n";
my $iterations = 0;
my %iterates = ();
      while(1){
	print STDERR "iterations, number: $iterations  $number\n";
	if(exists $iterates{$number} or $iterations > $max_iterations){
	  my $cycle_length = $iterations - $iterates{$number};
	  return ($iterations, $cycle_length);
	}elsif($iterations >= $max_iterations){
	  return ($iterations, undef);
	}
	$iterates{$number} = $iterations;
	$iterations++;
	$number = $self->the_function($number, $params);


      }
  return ($iterations, $number);
}
	

sub _digit_sum {
    my $number = shift;
    my $digit_sum = 0;
    while ( $number > 0 ) {
        my $digit = $number % 10;
        $digit_sum += $digit;
        $number = ( $number - $digit ) / 10;
    }
    return $digit_sum;
}

sub _digit_difference {
    my $number = shift;
    my $digit_sum   = 0;
    my $digit_count = 0;
    while ( $number > 0 ) {
        my $digit = $number % 10;
        $digit_count++;
        $digit_sum =
          ( $digit_count % 2 == 1 )
          ? $digit_sum + $digit
          : $digit_sum - $digit;    # one's +, ten's -, etc.
        $number = ( $number - $digit ) / 10;
    }
    return ( $digit_sum < 0 ) ? 0 - $digit_sum : $digit_sum;
}

sub _digit_product {
    my $number = shift;
    my $digit_product = 1;
    while ( $number > 0 ) {
        my $digit = $number % 10;
        $digit_product *= $digit;
        $number = ( $number - $digit ) / 10;
    }
    return $digit_product;
}

sub _ordinal_ending{
  my $number = shift;
  if($number =~ /1[123]$/){ return 'th'; }
  elsif($number =~ /1$/){ return 'st'; }
  elsif($number =~ /3$/){ return 'rd'; }
  elsif($number =~ /2$/){ return 'nd'; }
else{ return 'th'; }
return;
}

__PACKAGE__->meta->make_immutable;

1;
