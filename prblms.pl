#!/usr/bin/perl -w
use strict;
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
  $tex_string .= "\n" . " BSES Math Team  \\hspace{1in}  Divisibility  \n" . ' \vspace {4 mm} ';
  $tex_string .= '\begin{enumerate}   [itemsep=2em, topsep=0.3em]  ' . "\n";
  $tex_string .= '\item What is your name? ' . tex_answer_box('3.5in') . "\n";

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

############# end Divisibility tests table ###############

############# begin Mystery Number problems ###############
  for (1..3) {
    my ($mystery_problem, $mystery_answer) = $Mystery_obj->random_problem();
    #print "mystery number text: \n" . "$problem.\n";

    $tex_string .= '\item ' . $mystery_problem . 
      tex_answer_box('1.5in') . ' \vspace{0.5mm}'; 
  }
  $tex_string .= '\end{enumerate}' ."\n" . ' \pagebreak ' . "\n";
}    #end of loop over divisibility pages
#$tex_string .= ' \end{document} '; print $tex_string;  exit;

############# end Mystery Number problems ###############

############# begin Factoring problems:

for (1..0){
  $tex_string .=  " BSES Math Team   \\hspace{1in}    Factoring  \n" . ' \vspace {4 mm} '; #"BSES Math Team   Factoring  
  $tex_string .= '\begin{enumerate}   [itemsep=2em, topsep=0.3em]  ' . "\n";
  $tex_string .= '\item What is your name? ' . tex_answer_box('3.5in') . "\n";

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
 $tex_string .= " BSES Math Team  \\hspace{1in}    Working Backwards  \n" . ' \vspace {4 mm} ';
  $tex_string .= '\begin{enumerate}   [itemsep=2em, topsep=0.3em]  ' . "\n";
  $tex_string .= '\item What is your name? ' . tex_answer_box('3.5in') . "\n";
 my ($problem_text, $answer_text) = $WB_problem_object->random_problem();
 # $tex_string .= '\item ' . "$problem_text " . tex_answer_box('1.2in') . "\n" . ' \vspace {4 mm} ';
for (1..3) {
  ($problem_text, $answer_text) = $WB_problem_object->random_problem();
  $tex_string .= ' \item ' . "$problem_text " . tex_answer_box('1.2in') . ' \newline  \vspace {14 mm} ';
$tex_string .= 'Show you work by filling in the numbers in this chain of boxes: \newline ';
  #	$tex_string .= $framebox . "\n";
  #$tex_string .= ' \begin{picture}(100,15)
  #\multiput(0,0)(20,0){5}{\framebox(10,8){} {\vector(1,0){7}} }
  #\end{picture} ';
  #$tex_string .= "\n";
  $tex_string .= box_chain(4, 10, 8, $WB_problem_object->result() ) . "\n";
}
$tex_string .= ' \end{enumerate}  \pagebreak ';
}
############## end Work Backwards problems ##################

# other problem:
# $tex_string .= '\item I spend 1/2 of the money I have at one store, and then I spend 1/3 of what I have left ' .
#   ' at a different store. At that point I have 12 dollars left. How much money did I have to start with? ' . 
#   tex_answer_box('1.0 in') . "\n";
# $tex_string .= '\end{enumerate}' . "\n" . ' \pagebreak ' . "\n";

$tex_string .= '\end{document}' . "\n";
print $tex_string;

 
exit;

sub box_chain{
  my $n_boxes = shift;
  my $box_width = shift;
  my $box_height = shift;
  my $R_box_text = shift || ''; #default is empty string.
print STDERR "R box text: $R_box_text \n";
  my $picture_width = 2*$n_boxes*$box_width;
  my $picture_height = 1.2*$box_height;
  my $box_separation = 1.4*$box_width;
  my $box_x;
  my $gap = 0.1;
  my $tex_string = " \\begin{picture}($picture_width, $picture_height) ";
  for my $i (0..$n_boxes-2) {
    $box_x = $i*($box_width + $box_separation);
    my $arrow_x = $box_x + $box_width + $gap*$box_separation;
    my $arrow_y = 0.5*$box_height;
    my $arrow_length = (1 - 2*$gap)*$box_separation;
#    my $text_in_box = ($i == $n_boxes-2)? $R_box_text: '';
    $tex_string .= " \\put($box_x,0){ \\framebox($box_width, $box_height){} } \\put($arrow_x, $arrow_y) { \\vector(1,0){$arrow_length} } ";
  }
  $box_x += $box_width + $box_separation;
  $tex_string .= " \\put($box_x,0){ \\framebox($box_width, $box_height){$R_box_text} } ";
  $tex_string .= ' \end{picture} ';
  return $tex_string;
}


sub tex_answer_box{
  my $size = shift || '1in';
  my $text = ' \begin{tabular}{|>{\centering}p{';
  $text .= $size;
  $text .= '}|} \hline \tabularnewline \hline \end{tabular} ';
  return $text;
} 
