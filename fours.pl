
use Math::BigRat;
use Scalar::Util qw(blessed);
use strict;
# seen[$n]{$m} records an expression with $n numbers
# whose value is $m
my @seen;
my $TARGET = shift // 24;

my %op = ( '+' => sub { $_[0] + $_[1] },
           '*' => sub { $_[0] * $_[1] },
           '-' => sub { $_[0] - $_[1] },
           '/' => sub { $_[1] != 0 ? $_[0] / $_[1] : undef },
           );

for (1..13) {
  $seen[1]{$_} = [Math::BigRat->new($_)];
}

scan_seen(1, 1);
scan_seen(1, 2);
scan_seen(2, 1);
scan_seen(1, 3);
scan_seen(2, 2);
scan_seen(3, 1);

for my $x (@{$seen[4]{$TARGET}}) {
  printf "%s\n", expr_to_string($x);
}

sub expr_to_string {
  my ($x) = @_;
  return "$x" if ref $x eq "Math::BigRat";
  my ($op, $a, $b) = @$x;
  return sprintf "( %s $op %s )", expr_to_string($a), expr_to_string($b);
}

sub scan_seen {
  my ($a, $b) = @_;  # sizes of subexpressions
  print STDERR "($a, $b): \n";
  my $sa = $seen[$a];
  my $sb = $seen[$b];
  for my $ka (keys %$sa) {
#    print STDERR "  $ka\n";
    for my $kb (keys %$sb) {
#      print STDERR "    $kb\n";
      for my $xa (@{$sa->{$ka}}) {
        for my $xb (@{$sb->{$kb}}) {
          for my $op (qw(+ - * /)) {
            expression($a+$b, $op, $xa, $xb, $ka, $kb);
          }
        }
      }
    }
  }
}

sub expression {
  my ($n, $op, $x1, $x2, $v1, $v2) = @_;
  my $v = $op{$op}->($v1, $v2);
  return unless defined $v;
  push @{$seen[$n]{$v}}, [$op, $x1, $x2];
}


