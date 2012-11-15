package NoMooseProblem;
# this is the old version of Problem class
# that doesn't use moose.
use strict;
use warnings;

sub new{
	my $class = shift;
	my $self = bless {}, $class;
	return $self;
}

# accessors:

sub problem_text_template{
	my $self = shift;
	my $problem_text_template = shift;
	if(defined $problem_text_template){
		$self->{problem_text_template} = $problem_text_template;
	}
	return $self->{problem_text_template};
}

sub answer_text_template{
  my $self = shift;
  my $answer_text_template = shift;
  if (defined $answer_text_template) {
    $self->{answer_text_template} = $answer_text_template;
  }
  return $self->{answer_text_template};
}

1;



