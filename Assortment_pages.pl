#!/usr/bin/perl -w
use strict;
use TomfyTex qw( answer_box box_chain );
use NumberRecycler;
use ConsecutiveNumbers;
use DivSubtractWord;
use MysteryNumber;
use WorkBackwards;
use SocksAndGumballs;
use TwentyFour;
# the idea here is to produce random problems of the type:
# Start with N, then multiply by X, then add Y, then divide by Z. 
# This gives M. What was the number N you started with?
# N, M, X, Y, and Z are all counting numbers.
# They shouldn't be too big (e.g. N*X + Y should be <= 2 digits)


#my $tex_answer_box = ' \begin{tabular}{|>{\centering}p{1in}|} \hline \tabularnewline \hline \end{tabular} ';
#my $framebox = ' \framebox [1 cm] [] {} ';

my $mmvspace = '12mm';

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
my $N = shift || 2;
$tex_string .=  '\begin{enumerate}   [itemsep=2em, topsep=0.3em]  ' . "\n";
  for (1..$N) {

my  $Problem_obj = MysteryNumber->new();
    $tex_string .= $Problem_obj->random_problem_tex() . ' \vspace{' . $mmvspace . '}';

 $Problem_obj = TwentyFour->new();
    $tex_string .= $Problem_obj->random_problem_tex() . ' \vspace{' . $mmvspace . '}';

  $Problem_obj = SocksAndGumballs->new();
    $tex_string .= $Problem_obj->random_problem_tex() . ' \vspace{' . $mmvspace . '}';

    $Problem_obj = NumberRecycler->new();
    $tex_string .= $Problem_obj->random_problem_tex();

    $tex_string .=  '\pagebreak' .  "\n";
  }
############# end Mystery Number problems ###############
$tex_string .= '\end{enumerate} ' . '\pagebreak' .  "\n";
$tex_string .= '\end{document}' . "\n";
print $tex_string;

exit;
