package Factors;
use strict;
use List::Util qw' min max sum shuffle ';

use base 'Problem';


sub new{
	my $class = shift;
	my $self = bless {}, $class;
	my $args = shift || {}; # hash ref with args and values
		my $default_params = {'max_number_to_factor' => 40};
	foreach (keys %$default_params){
		$self->{$_} = $default_params->{$_};
	}
	foreach (keys %$args){
		print "resetting parameter $_ to ", $args->{$_}, "\n";
		$self->{$_} = $args->{$_};
	}

	my @numbers = shuffle(8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36);  # 1..$self->max_number_to_factor());
	$self->numbers(\@numbers);
	$self->number_array_index(0);

#	print join(", ", @numbers), "\n";	
#	print join (", ", @{$self->numbers()}), "\n";
	my $problem_text_template = "For each of the following numbers, list all of its  pairs of factors.";
		$self->problem_text_template($problem_text_template);

	my $answer_text_template = "The number I started with was ANSWER.";
	$self->answer_text_template($answer_text_template);
	return $self;
}

sub increment_index{
	my $self = shift;
	my $size = scalar @{$self->numbers()};
	my $new_index = ($self->number_array_index()+1) % $size;
	$self->number_array_index($new_index); 
}

sub random_problem{
	my $self = shift;
#	print "in random_proble. numbers: ", join(", ", @{$self->numbers()}), "\n";
	my $middle = $self->numbers()->[$self->number_array_index()];
	$self->increment_index();
	return ($middle-1, $middle, $middle+1);
}


# accessors:

sub max_number_to_factor{
        my $self = shift;
        my $max_number_to_factor = shift;
        if(defined $max_number_to_factor){
                $self->{max_number_to_factor} = $max_number_to_factor;
}
return $self->{max_number_to_factor};
}

sub numbers{ # get array ref, or set array ref.
        my $self = shift;
        my $numbers_arg = shift;
        if(defined $numbers_arg){
                $self->{numbers} = $numbers_arg;
        }
        return $self->{numbers};
}

sub number_array_index{
        my $self = shift;
        my $index = shift;
        if(defined $index){
                $self->{number_array_index} = $index;
        }
        return $self->{number_array_index};
}

1;
