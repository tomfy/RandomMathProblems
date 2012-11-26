#!/usr/bin/perl -w
use strict;
use TomfyTex qw( answer_box box_chain );
use NumberRecycler;

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
my $N = shift || 2;
my $n_digits = shift || 2;

############# begin Mystery Number problems ###############
my $Mystery_obj = NumberRecycler->new();
for (1..$N){
my $n_probs_on_page = 4;

$tex_string .= $Mystery_obj->page_o_problems($n_probs_on_page, ($_ - 1) % 2);
}
############# end Mystery Number problems ###############

$tex_string .= '\end{document}' . "\n";
print $tex_string;

exit;
