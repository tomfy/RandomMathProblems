#!/usr/bin/perl -w
use strict;

#my $four_number_string = shift;
#print STDERR "AAA: $four_number_string \n";
#my @four_numbers = split(" ", $four_number_string);
#print STDERR "BBB: ", join("::", @four_numbers), "\n";
#die "Must input four 1-digit numbers (space separated) e.g. '1 2 3 4' \n" if(scalar @four_numbers != 4);


my $arg = shift // 0; # e.g. '1,3,5,6', or 0 to do all.
my $target_number = shift // 24;
my $verbose = 0;

my @cl_four_numbers = split(/[\s,;]*/, $arg);
if (defined $arg) {
  $verbose = 1 if($arg ne 0);
}


my @permutations = ( [1,2,3,4], [1,2,4,3],
		     [1,4,2,3], [1,4,3,2],
		     [1,3,4,2], [1,3,2,4] );

for my $i (1..3) {
  for my $j (0..5) {
    my @a = @{$permutations[$j]};
    for (@a) {
      $_ += $i;
      $_ -= 4 if($_ > 4);
    }
    push @permutations, \@a;
  }
}

my %canfour_count = ();

if (scalar @cl_four_numbers == 4) {
  one_problem_solutions(\@cl_four_numbers, \@permutations, 1);
} else {			# do them all
  my @four_numbers = (1,1,1,1);
  for my $i1 (1..9) {
    $four_numbers[0] = $i1;
    for my $i2 (1..9) {
      $four_numbers[1] = $i2;
      for my $i3 (1..9) {
	$four_numbers[2] = $i3;
	for my $i4 (1..9) {
	  $four_numbers[3] = $i4;
	  my @s4nmbrs = sort @four_numbers;
	  #print join(", ", @s4nmbrs), "\n";
	  $canfour_count{join(",", @s4nmbrs)}++;
	  #	one_problem_solutions(\@four_numbers, \@permutations);
	}
      }
    }
  }

  my $outstring = '';

  #print scalar keys %canfour_count, "\n\n";
  my $counter = 0;
  my @sorted_4nmbrs = sort keys %canfour_count;
  #for my $frnmbrs (keys %canfour_count) {
  for my $frnmbrs (@sorted_4nmbrs){
  my @fournmbrs = split(",", $frnmbrs);
    my $n_solns = one_problem_solutions(\@fournmbrs, \@permutations, $verbose);
    if ($n_solns > 0) {
      $outstring .= "$frnmbrs => $n_solns\n";
      #$counter++;
      #$outstring .= "\n" if(($counter % 8) == 0);
    }
  }

  #$outstring .= '}';
  print "$outstring \n";
}

sub one_problem_solutions{
  my $nmbrs = shift;
  my $perms = shift;
my $verbose = shift; 
  my @four_numbers = @$nmbrs;
  my @permutations = @$perms;

  my $solution_count = 0;
  for my $the_perm (@permutations) {
    # print join(", ", @$the_perm), "\n";
    my @permed_4_numbers = ();
    for (0..3) {
      $permed_4_numbers[$_] = $four_numbers[$the_perm->[$_] - 1 ];
    }
    # print STDERR join("  ", @permed_4_numbers), "\n";



    for my $op1 ('+','-', '*', '/') {
      for my $op2 ('+','-', '*', '/') {
	for my $op3 ('+','-', '*', '/') {
	  my @operations = ($op1, $op2, $op3);

	  $solution_count += eval_under_5_paren_patterns(\@permed_4_numbers, \@operations, $verbose);

	}
      }
    }
  }
  #print STDOUT join("", @four_numbers), "   $solution_count \n"; 
return $solution_count;
}

sub eval_under_5_paren_patterns{
  my $numbers = shift;
  my $ops = shift;
  my $verbose = shift || 0;
  my ($a, $b, $c, $d) = @$numbers;
  my ($op1, $op2, $op3) = @$ops;
  my $solution_count = 0;
  my $epsilon = 0.00001;
#  print "XXXXXXXXXXX\n";
  # print STDERR "$a $op1 $b $op2 $c $op3 $d \n";
  my $result1 = f1($numbers, $ops); # bop( bop( bop( $a, $op1, $b), $op2, $c), $op3, $d);
  if (defined $result1  and  (abs($result1 - $target_number) <= $epsilon)) { # $result1 == 24) {
    print STDERR "( ($a $op1 $b) $op2 $c) $op3 $d \n" if($verbose);
    $solution_count++;
  }
  my $result2 = f2($numbers, $ops); # bop( bop( $a, $op1, bop( $b, $op2, $c) ), $op3, $d);
  if (defined $result2  and  (abs($result2 - $target_number) <= $epsilon)) { # $result2 == 24) {
    print STDERR "($a $op1 ($b $op2 $c) ) $op3 $d \n" if($verbose);
    $solution_count++;
  }

  my $result3 = f3($numbers, $ops); # bop( $a, $op1, bop( bop( $b, $op2, $c), $op3, $d));
  if (defined $result3  and  (abs($result3 - $target_number) <= $epsilon)) { # $result3 == 24) {
    print  STDERR "$a $op1 ( ($b $op2 $c) $op3 $d )\n" if($verbose);
    $solution_count++;
  }
  my $result4 = f4($numbers, $ops); # bop( $a, $op1, bop( $b, $op2, bop($c, $op3, $d)));
  if (defined $result4  and  (abs($result4 - $target_number) <= $epsilon)) { # $result4 == 24) {
    print  STDERR "$a $op1 ($b $op2 ($c $op3 $d)) \n" if($verbose);
    $solution_count++;
  }

  my $result5 = f5($numbers, $ops); # bop( bop( $a, $op1, $b), $op2, bop($c, $op3, $d));
  if (defined $result5  and  (abs($result5 - $target_number) <= $epsilon)) { # $result5 == 24) {
    print  STDERR "($a $op1 $b) $op2 ($c $op3 $d) \n" if($verbose);
    $solution_count++;
  }
  return $solution_count;
}



sub bop{
  my $x1 = shift;
  my $op = shift;
  my $x2 = shift;
  return undef if(!defined $x1);
  return undef if(!defined $x2);
  # print "[$x1]  $op  [$x2] \n";
  if ($op eq '+') {
    return $x1+$x2;
  } elsif ($op eq '-') {
    return $x1-$x2;
  } elsif ($op eq '*') {
    return $x1*$x2;
  } elsif ($op eq '/') {
    return ($x2 == 0)? undef : $x1/$x2;
  } else {
    die "Unknown operation: $op \n";
  }
}

sub f1{
  my $numbers = shift;
  my $ops = shift;
  my ($a, $b, $c, $d) = @$numbers;
  my ($op1, $op2, $op3) = @$ops;
return bop( bop( bop( $a, $op1, $b), $op2, $c), $op3, $d);
}

sub f2{
  my $numbers = shift;
  my $ops = shift;
  my ($a, $b, $c, $d) = @$numbers;
  my ($op1, $op2, $op3) = @$ops;
return bop( bop( $a, $op1, bop( $b, $op2, $c) ), $op3, $d);
}

sub f3{
  my $numbers = shift;
  my $ops = shift;
  my ($a, $b, $c, $d) = @$numbers;
  my ($op1, $op2, $op3) = @$ops;
return  bop( $a, $op1, bop( bop( $b, $op2, $c), $op3, $d));
}

sub f4{
  my $numbers = shift;
  my $ops = shift;
  my ($a, $b, $c, $d) = @$numbers;
  my ($op1, $op2, $op3) = @$ops;
return bop( $a, $op1, bop( $b, $op2, bop($c, $op3, $d)));
}

sub f5{
  my $numbers = shift;
  my $ops = shift;
  my ($a, $b, $c, $d) = @$numbers;
  my ($op1, $op2, $op3) = @$ops;
return bop( bop( $a, $op1, $b), $op2, bop($c, $op3, $d));
}
