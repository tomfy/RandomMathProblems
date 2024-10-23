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


my $tex_answer_box = ' \begin{tabular}{|>{\centering}p{1in}|} \hline \tabularnewline \hline \end{tabular} ';
my $framebox = ' \framebox [1 cm] [] {} ';
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

my $N = shift // 2;
my $max_intermediate = shift // 50;
my $WB_problem_object = WorkBackwards->new({'max_answer' => 25, 'max_intermediate_number' => $max_intermediate});


############## begin Work Backwards problems ##################
  for(1..$N){
    $tex_string .= $WB_problem_object->page_o_problems();
  }
############## end Work Backwards problems ##################

# other problem:
# $tex_string .= '\item I spend 1/2 of the money I have at one store, and then I spend 1/3 of what I have left ' .
#   ' at a different store. At that point I have 12 dollars left. How much money did I have to start with? ' . 
#   answer_box('1.0 in') . "\n";
# $tex_string .= '\end{enumerate}' . "\n" . ' \pagebreak ' . "\n";

$tex_string .= '\end{document}' . "\n";
print $tex_string;

exit;
