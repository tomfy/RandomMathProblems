#!/usr/bin/perl -w
use strict;
use TomfyTex qw( answer_box box_chain );
use SockDrawer;

# the idea here is to produce random problems of the type:
# I have 8 red socks, 13 blue socks and 10 green socks. 
# If I take socks out of my drawer without looking, how
# many do I need to take to be sure of getting (at least)
# 2 red socks? 

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
my $problem_obj = SockDrawer->new( );
my $n_probs_on_page = 4;
$tex_string .= $problem_obj->page_o_problems($n_probs_on_page);
############# end Mystery Number problems ###############

$tex_string .= '\end{document}' . "\n";
print $tex_string;

exit;
