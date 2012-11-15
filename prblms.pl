#!/usr/bin/perl -w
use strict;
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
# $tex_string .= '\begin{enumerate}' . "\n"; 
my $N = shift || 2;

my $Mystery_obj = MysteryNumber->new();

my $Div_obj = Divisibility->new();

my $Factors_obj = Factors->new();

my $max_intermediate = shift || 50;
my $WB_problem_object = WorkBackwards->new({'max_answer' => 25, 'max_intermediate_number' => $max_intermediate});

for my $page (1..$N) {		# loop over pages
 # if(1){
  $tex_string .= "\n" . " BSES Math Team  \\hspace{1in}  Divisibility  \n" . ' \vspace {4 mm} ';
  $tex_string .= '\begin{enumerate}   [itemsep=2em, topsep=0.3em]  ' . "\n";
  $tex_string .= '\item What is your name? ' . answer_box('3.5in') . "\n";

  # $tex_string .= " \item ";

  # divisibility problems:

  $tex_string .= '\item Fill in this table, following the example. \newline \vspace{4mm} ';
  $tex_string .= '\begin{tabular}{|c|c|p{1cm}|p{1cm}|p{1cm}|p{1cm}|p{1cm}|p{1cm}|} ';
  $tex_string .= ' \hline ' .
    ' & & \multicolumn{6}{|c|}{Is the number divisible by:} \tabularnewline ';

  $tex_string .= ' \hline digit sum & Number & 2? & 3? & 4? & 5? & 9? & 10?  \tabularnewline ' .
    '\hline
';
  $tex_string .= '\hline 21 & 3756 & yes & yes & yes & no & no & no \tabularnewline ';
  for (1..3) {
    #	print "number to test for div: ", $Div_obj->random_problem(), "\n";
    $tex_string .= '\hline & ' . $Div_obj->random_problem($_+1) . ' &  &  &  &  &  & \tabularnewline ';



  }
  $tex_string .= '\hline \end{tabular}  \vspace {0 mm}'; # \newline ';
 $tex_string .= '\end{enumerate}' ."\n" . ' \pagebreak ' . "\n";
}
if(1){
############# end Divisibility tests table ###############
for (1..$N){ 
############# begin Mystery Number problems ###############
  if(0){
  for (1..3) {
    my ($mystery_problem, $mystery_answer) = $Mystery_obj->random_problem();
    #print "mystery number text: \n" . "$problem.\n";

    $tex_string .= '\item ' . $mystery_problem . 
      answer_box('1.5in') . ' \vspace{0.5mm}'; 
  }
  $tex_string .= '\end{enumerate}' ."\n" . ' \pagebreak ' . "\n";
}else{
print STDERR $Mystery_obj->page_o_problems();
$tex_string .= $Mystery_obj->page_o_problems();

}
}
print $tex_string, "\n";
exit;
#$tex_string .= ' \end{document} '; print $tex_string;  exit;
}
############# end Mystery Number problems ###############

############# begin Factoring problems:

for (1..0){
  $tex_string .=  " BSES Math Team   \\hspace{1in}    Factoring  \n" . ' \vspace {4 mm} '; #"BSES Math Team   Factoring  
  $tex_string .= '\begin{enumerate}   [itemsep=2em, topsep=0.3em]  ' . "\n";
  $tex_string .= '\item What is your name? ' . answer_box('3.5in') . "\n";

$tex_string .= '\item Fill in this table, following the example. \newline \vspace {4 mm} ';
$tex_string .= '\begin{tabular}{|c|c|}
\hline ' .
  'number & factor pairs \tabularnewline ' .
  '\hline
';
$tex_string .= '\hline 36 & \hspace {0.5 in} 1x36 \hspace {5 mm} 2x18 \hspace {5 mm} 3x12 \hspace {5 mm} 4x9 \hspace {5 mm} 6x6 \hspace {0.5 in} \tabularnewline ';
my @factors = $Factors_obj->random_problem();
for (@factors) {
  #       print "number to test for div: ", $Div_obj->random_problem(), "\n";
  $tex_string .= '\hline ' . $_ . ' & \tabularnewline ';
}
$tex_string .= '\hline \end{tabular} \vspace {4 mm}'; # \newline ';
$tex_string .= ' \end{enumerate}  \pagebreak ' . "\n";
} # end of loop over factoring pages
############## end Factoring problems #####################

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
