#!/usr/bin/perl -w
use strict;

my $epsilon = 1e-10;

# for a set of 4 1-digit numbers,
# find all the numerical values obtainable by
# expressions involving the 4 numbers, the 4 basic
# arithmetic operations (+ - * /), and parentheses

my $verbose = shift // 0;
my $n4string = shift // '1,2,3,4';

my @ops = ('+', '-', '*', '/');
#my %ev_expressions = ();
my $m = 9;
my %set4__v_xs = ();
for my $n1 (1..$m) {
  for my $n2 (1..$m) {
    print STDERR "$n1 $n2 \n";
    for my $n3 (1..$m) {
      for my $n4 (1..$m) {

	my @a = ($n1, $n2, $n3, $n4);
	my @sa = sort {$a <=> $b} @a;
	my $set4_str = join(",", @sa);
	$set4__v_xs{$set4_str} = {} if(!exists $set4__v_xs{$set4_str});
	for my $op1 (@ops) {
	  for my $op2 (@ops) {
	    for my $op3 (@ops) {
	      for my $pp (1..5) {

		my ($value, $expression) = expression_value(\@a, $op1, $op2, $op3, $pp);
		if (defined $value  and  defined $expression) {
		  if ($value > -1.0*$epsilon) {
		    my $integer_value = int($value + 0.5);
		    my $delta = abs($value - $integer_value);
		    if ($delta <= $epsilon) { # value is integer
		      #print "$s   $expression = $value\n";
		      #$ev_expressions{$integer_value} .= "$expression; ";
		      $set4__v_xs{$set4_str}->{$integer_value} = {} if(!exists $set4__v_xs{$set4_str}->{$integer_value});
		      $set4__v_xs{$set4_str}->{$integer_value}->{$expression}++; # just count the number of expressions giving this value
		    }
		  }
		}

	      }
	    }
	  }
	}
	#$set4__v_m{$set4_str} = \%val_mult;
      }
    }
  }
}
my @sorted_s4s = sort keys %set4__v_xs;
#while(my ($s4, $vxs) = each %set4__v_xs){
for my $s4 (@sorted_s4s){
  my $vxs = $set4__v_xs{$s4};
  my @svals = sort {$a <=> $b} keys %$vxs;
  my $vmax = -1;
  while(my($i, $v) = each @svals){
    last if($i != $v);
    $vmax = $v;
    # print "$v ";
  }
  if($verbose>0){
    print "$s4  $vmax  ", scalar @svals, "\n";
    for my $vv (@svals){
      my $ex_m = $vxs->{$vv};
      if($verbose == 1){
	      print " $vv,", scalar keys %$ex_m;
	    }else{
	      print "  $vv  ", join(" ", keys %$ex_m), "\n";
	    }
    }
    print "\n" if($verbose == 1);
  }else{
  print "$s4  $vmax  ", scalar @svals, "  ";
  print join(" ", @svals);
  print "\n";
}
}



sub xxx{
  my $in_hash = shift;
  my $new_number = shift;
  my %out_hash = ();
  while (my($k, $v) = each %$in_hash) {
    my @array = split(",", $k);
    for my $i (0..scalar @array) {
      my $out_array = insert(\@array, $new_number, $i);
      my $out_str = join(",", @$out_array);
      # print $out_str, "\n";
      $out_hash{$out_str}++;
    }
  }
  return \%out_hash;
}

sub insert{			# insert a number into an array
  # position will be index of the inserted number in the output array
  my $iah = shift;
  my @in_array = @{$iah};
  my $new_number = shift;
  my $position = shift;	    # where to insert new number; [0,$in_size]
  my $in_size = scalar @in_array;
  my @out_array;
  if ($position == 0) {
    @out_array = ($new_number);
    push @out_array, @in_array;
  } else {
    @out_array = @in_array[0..$position-1];
    push @out_array, $new_number;
    push @out_array, @in_array[$position..$#in_array];
  }
  return \@out_array;
}


sub expression_value{
  my $ar = shift;		# array ref, e.g. [1,5,4,7]
  my ($a, $b, $c, $d) = @$ar;
  my $op1 = shift;
  my $op2 = shift;
  my $op3 = shift;
  my $pp = shift;

  # print join(",", @$ar), " $op1 $op2 $op3  $pp \n";

  my ($res, $expr);
  if ($pp == 1) {		# ((a*b)*c)*d
    ($res, $expr) = bop($a, $op1, $b, $a, $b);
    ($res, $expr) = bop($res, $op2, $c, $expr, $c);
    ($res, $expr) = bop($res, $op3, $d, $expr, $d);
  } elsif ($pp == 2) {		# (a*(b*c))*d
    ($res, $expr) = bop($b, $op2, $c, $b, $c);
    ($res, $expr) = bop($a, $op1, $res, $a, $expr);
    ($res, $expr) = bop($res, $op3, $d, $expr, $d);
  } elsif ($pp == 3) {		# a*((b*c)*d)
    ($res, $expr) = bop($b, $op2, $c, $b, $c);
    ($res, $expr) = bop($res, $op3, $d, $expr, $d);
    ($res, $expr) = bop($a, $op1, $res, $a, $expr);
  } elsif ($pp == 4) {		# a*(b*(c*d))
    ($res, $expr) = bop($c, $op3, $d, $c, $d);
    ($res, $expr) = bop($b, $op2, $res, $b, $expr);
    ($res, $expr) = bop($a, $op1, $res, $a, $expr)
  } elsif ($pp == 5) {		# (a*b)*(c*d)
    my ($r1, $expr1) = bop($a, $op1, $b, $a, $b);
    my ($r2, $expr2) = bop($c, $op3, $d, $c, $d);
    ($res, $expr) = bop($r1, $op2, $r2, $expr1, $expr2);
  }
  return ($res, $expr);
}

sub bop{			# binary operation
  my $k1 = shift;		# 
  my $op = shift;
  my $k2 = shift;
  my $ex1 = shift;
  my $ex2 = shift;

  if (defined $k1  and  defined $k2) {
    #  print "$k1  $op  $k2  \n";
    my ($v, $ex);
    if ($op eq '+') {
      $v = $k1+$k2;
      $ex = ($k1 <= $k2)? "($ex1+$ex2)" : "($ex2+$ex1)";
    } elsif ($op eq '-') {
      $v = $k1-$k2;
      $ex = "($ex1-$ex2)";
    } elsif ($op eq '*') {
      $v = $k1*$k2;
      $ex = ($k1 <= $k2)? "($ex1*$ex2)" : "($ex2*$ex1)";
    } elsif ($op eq '/') {
      if ($k2 >= $epsilon) {
	$v = $k1/$k2;
      } else {
	$v = undef;
      }
      $ex = "($ex1/$ex2)";
    } else {
      return ( undef , '-');
    }
    #  print " $ex = $v\n";
    return ($v, $ex);
  } else {
    return (undef, undef);
  }
}
