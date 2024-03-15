#!/usr/bin/perl -w
use strict;

use File::Basename 'dirname';
use Cwd 'abs_path';
my ( $bindir, $libdir );
BEGIN {     # this has to go in Begin block so happens at compile time
  $bindir =
    dirname( abs_path(__FILE__) ) ; # the directory containing this script
  $libdir = $bindir; #  . './'; # '/../lib';
  $libdir = abs_path($libdir);	# collapses the bin/../lib to just lib
}
use lib $libdir;

use TomfyTex qw( answer_box box_chain );
use WorkBackwards;
use Factors;
use Divisibility;
use MysteryNumber;



# the idea here is to produce random problems of the type:
# Start with N, then multiply by X, then add Y, then divide by Z. 
# This gives M. What was the number N you started with?
# N, M, X, Y, and Z are all counting numbers.
# They shouldn't be too big (e.g. N*X + Y should be <= 2 digits)


#my $tex_answer_box = ' \begin{tabular}{|>{\centering}p{1in}|} \hline \tabularnewline \hline \end{tabular} ';
#my $framebox = ' \framebox [1 cm] [] {} ';

my $tex_string = '';
$tex_string .= ' \documentclass[14pt,english]{extarticle}
\usepackage[T1]{fontenc}
\usepackage[latin9]{inputenc}
\usepackage{array}
\usepackage{enumitem}
\usepackage[margin=0.8in]{geometry}

\makeatletter

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LyX specific LaTeX commands.
%% Because html converters dont know tabularnewline
%\providecommand{\tabularnewline}{\\}

\makeatother

\usepackage{babel}

\begin{document}

\setlength{\unitlength}{1.4 mm}
% \set
';
$tex_string .= ' \pagestyle {empty} ';
# $tex_string .= '\begin{enumerate}' . "\n"; 
my $N_pages = shift // 2;
my $n_digits = shift // 2;

############# begin Mystery Number problems ###############
my $Mystery_obj_2digit = MysteryNumber->new(
				     {n_digits => 2,
				  #    divisors => [ 2, 3, 4, 5, 6, 9, 10, 'odd' ],
				       divisors => [ 2, 3, 5, 9, 10, 'odd' ],
				      required_digits => [1,2,3,4,5,6,7,8,9] }
					   );

my $Mystery_obj_3digit = MysteryNumber->new(
				     {n_digits => 3,
				  #    divisors => [ 2, 3, 4, 5, 6, 9, 10, 'odd' ],
				       divisors => [ 2, 3, 5, 9, 10, 'odd' ],
				      required_digits => [1,2,3,4,5,6,7,8,9] }
						   );
for (1..$N_pages) {
  my $n_probs_on_page = 3;
  if ($n_digits == 2) {
    $n_probs_on_page = 4;
  }
  $tex_string .= $Mystery_obj_2digit->page_o_problems(4, 1); # ($_ - 1) % 2);
  $tex_string .= $Mystery_obj_3digit->page_o_problems(4, 1); # ($_ - 1) % 2);
}
############# end Mystery Number problems ###############

$tex_string .= '\end{document}' . "\n";
print $tex_string;

exit;
