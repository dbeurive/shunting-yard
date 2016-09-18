use lib './lib';

use strict;
use Term::ANSIColor;
use Parser;
use Data::Dumper;

my $DEBUG = 0;

my $parser     = undef;
my $input      = undef;
my $err        = undef;
my $inputs     = undef;




$parser = new Parser();
if ($DEBUG) { $parser->activateDebugMode(); }

### -------------------------------------
### Testing the basic stuff
### -------------------------------------

$inputs = loadTests('basic', \$err);
unless (defined($inputs)) {
	print STDERR "ERROR: $err\n";
	exit(1);
}

foreach my $input (@{$inputs}) {
	my $n = undef;

	print "Input:  $input";
	$parser->setInfixExpression($input);
	$parser->parse();

	print "Status: ";
	if ($parser->getStatus()) {
		print color 'bold green';
		print "SUCESS\n";
		print color 'reset';
		print "\n" . dumpRpn($parser->getRpn) . "\n";
	} else {
		print color 'bold red';
		print "ERROR: " . $parser->getErrorMessage . "\n";
		print color 'reset';
	}

	print "\n\n";
}

### -------------------------------------
### Mixing with logical expressions
### -------------------------------------

$inputs = loadTests('bool', \$err);
unless (defined($inputs)) {
	print STDERR "ERROR: $err\n";
	exit(1);
}

foreach my $input (@{$inputs}) {
	my $n = undef;

	print "Input:  $input";
	$parser->setInfixExpression($input);
	$parser->parse();

	print "Status: ";
	if ($parser->getStatus()) {
		print color 'bold green';
		print "SUCESS\n";
		print color 'reset';
		print "\n" . dumpRpn($parser->getRpn) . "\n";
	} else {
		print color 'bold red';
		print "ERROR: " . $parser->getErrorMessage . "\n";
		print color 'reset';
	}

	print "\n\n";
}

### -------------------------------------
### Mixing with function calls
### -------------------------------------

$inputs = loadTests('function', \$err);
unless (defined($inputs)) {
	print STDERR "ERROR: $err\n";
	exit(1);
}

foreach my $input (@{$inputs}) {
	my $n = undef;

	print "Input:  $input";
	$parser->setInfixExpression($input);
	$parser->parse();

	print "Status: ";
	if ($parser->getStatus()) {
		print color 'bold green';
		print "SUCESS\n";
		print color 'reset';
		print "\n" . dumpRpn($parser->getRpn) . "\n";
	} else {
		print color 'bold red';
		print "ERROR: " . $parser->getErrorMessage . "\n";
		print color 'reset';
	}

	print "\n\n";
}

### -------------------------------------
### Mixing with variables
### -------------------------------------

$inputs = loadTests('var', \$err);
unless (defined($inputs)) {
	print STDERR "ERROR: $err\n";
	exit(1);
}

foreach my $input (@{$inputs}) {
	my $n = undef;

	print "Input:  $input";
	$parser->setInfixExpression($input);
	$parser->parse();

	print "Status: ";
	if ($parser->getStatus()) {
		print color 'bold green';
		print "SUCESS\n";
		print color 'reset';
		print "\n" . dumpRpn($parser->getRpn) . "\n";
	} else {
		print color 'bold red';
		print "ERROR: " . $parser->getErrorMessage . "\n";
		print color 'reset';
	}

	print "\n\n";
}

### -------------------------------------
### Mixing with strings
### -------------------------------------

$inputs = loadTests('string', \$err);
unless (defined($inputs)) {
	print STDERR "ERROR: $err\n";
	exit(1);
}

foreach my $input (@{$inputs}) {
	my $n = undef;

	print "Input:  $input";
	$parser->setInfixExpression($input);
	$parser->parse();

	print "Status: ";
	if ($parser->getStatus()) {
		print color 'bold green';
		print "SUCESS\n";
		print color 'reset';
		print "\n" . dumpRpn($parser->getRpn) . "\n";
	} else {
		print color 'bold red';
		print "ERROR: " . $parser->getErrorMessage . "\n";
		print color 'reset';
	}

	print "\n\n";
}


sub dumpRpn {
	my ($inRpn) = @_;
	my @res = ();
	foreach my $token (reverse @{$inRpn}) {
		push(@res, $token->{value});
	}
	return join(', ', @res);
}

sub loadTests
{
	my ($inName, $outErr) = @_;
	my $dir   = undef;
	my @tests = ();

	$$outErr = undef;
	unless(opendir($dir, 'tests')) {
		$$outErr = "Can't opendir 'tests': $!";
		return undef;
	}
	while(readdir $dir) {
		my $path    = './tests/' . $_;
		my @parts   = ();
		my $content = undef;
		next unless -f $path;
		@parts = split(/\-/, $_);
		next if scalar(@parts) != 2;
		next if $parts[0] ne $inName;
		$content = loadFile($path, $outErr);
		unless (defined($content)) {
			return undef;
		}
		push(@tests, $content);
    }
    closedir $dir;
	return \@tests;
}

sub loadFile
{
	my ($inPath, $outErr) = @_;
	my $content = '';
	my $fd      = undef;

	$$outErr = undef;
	unless (open($fd, $inPath)) {
		$$outErr = "Can not open file '$inPath': $!";
		return undef;
	}
	while (<$fd>) {
		$content .= $_;
	}
	close $fd;
	return $content;
}

sub printInput
{
	my ($inInput) = @_;
	my @res   = ();
	my $n     = 0;
	my @lines = split(/\r?\n/, $inInput);

	foreach my $line (@lines) {
		push(@res, sprintf("\t%4d: %s", $n, $line));
		$n++;
	}
	return join("\n", @res);
}
