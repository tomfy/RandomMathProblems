package TomfyTex;
 require Exporter;
  @ISA = qw(Exporter);
  @EXPORT_OK = qw( box_chain answer_box );  # symbols to export on request

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


sub answer_box{
  my $size = shift || '1in';
  my $text = ' \begin{tabular}{|>{\centering}p{' . $size . '}|}';
  $text .= ' \hline \tabularnewline \hline \end{tabular} ';


# $text = ' \framebox[' . $size . '][c]{xxx} ';
  return $text;
}





1;
