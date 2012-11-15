package Divisibility;
use strict;
use List::Util qw' min max sum shuffle ';

use base 'Problem';


sub new{
	my $class = shift;
	my $self = bless {}, $class;
	my $args = shift || {}; # hash ref with args and values
		my $default_params = {'n_digits' => 4};
	foreach (keys %$default_params){
		$self->{$_} = $default_params->{$_};
	}
	foreach (keys %$args){
		print "resetting parameter $_ to ", $args->{$_}, "\n";
		$self->{$_} = $args->{$_};
	}
	return $self;
}

sub random_problem{
	my $self = shift;
	my $n_digits = shift || $self->n_digits();
	my $the_number = '';
	while(1){
		for(1..$n_digits){
			my $digit = int(rand()*10);
			$the_number = $digit . $the_number;
		}
		$the_number =~ s/^0+//; # remove leading zeroes
			return $the_number if(length $the_number >= 2);
	}
}

# accessors:

sub n_digits{
        my $self = shift;
        my $n_digits_new = shift;
        if(defined $n_digits_new){
                $self->{n_digits} = $n_digits_new;
        }
        return $self->{n_digits};
}

1;
