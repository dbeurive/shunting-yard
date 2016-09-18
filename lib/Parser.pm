package Parser;

use warnings;
use strict;
use HOP::Lexer 'string_lexer';

my @input_tokens = (
     [  'STRING'           , qr/"(?:[^"\\]|\\["\\])+"/,              ],
     [  'VARIABLE'         , qr/V\d+/                                ],
     [  'FUNCTION'         , qr/[a-z_]+[0-9]*/                       ],
     [  'NUMERIC'          , qr/\d+/                                 ],
     [  'PARAM_SEPARATOR'  , qr/,/                                   ],
     [  'OPEN_BRACKET'     , qr/\(/                                  ],
     [  'CLOSE_BRACKET'    , qr/\)/                                  ],
     [  'OPERATOR'         , qr/<>|~|%|\+|\-|\*|\/|\^|>=|<=|>|<|=|&/ ],
     [  'SPACE'            , qr/\s*/, sub { () }                     ]
);

my %precedences = (
    '%' => 4,
    '~' => 4,
    '^' => 4,
    '&' => 3,
    '*' => 3,
    '/' => 3,
    '+' => 2,
    '-' => 2,
    '>' => 1,
    '<' => 1,
    '>=' => 1,
    '<=' => 1,
    '='  => 1,
    '<>' => 1
);

my %associativities = (
    '~' => 'right',  # Try "left" to see the result
    '%' => 'right',  # Try "left" to see the result
    '^' => 'right',
    '&' => 'left',
    '*' => 'left',
    '/' => 'left',
    '+' => 'left',
    '-' => 'left',
    '>' => 'left',
    '<' => 'left',
    '>=' => 'left',
    '<=' => 'left',
    '='  => 'left',
    '<>' => 'left'
);

sub new {
	my $class = shift;
 	my $self = {
 		infix         => undef,
    status        => undef,
    message       => undef,
    tokens        => undef,
    debug         => 0,
    operatorStack => [],
    outputQueue   => []
 	};
 	bless($self, $class);
 	return($self);
}

sub getErrorMessage {
  my $self = shift;
  return $self->{message};
}

sub getStatus {
  my $self = shift;
  return $self->{status};
}

sub getRpn {
  my $self = shift;
  return $self->{outputQueue};
}

sub getTokens {
  my $self = shift;
  return $self->{tokens};
}

sub getInfixExpression {
  my $self = shift;
  return $self->{infix};
}
sub activateDebugMode {
  my $self = shift;
  $self->{debug} = 1;
  return $self;
}

sub pushToOperatorStack {
 	my $self = shift;
  my ($inOperator) = @_;
  push(@{$self->{operatorStack}}, $inOperator);
  return $self;
}

sub popOffOperatorStack {
  my $self = shift;
	return pop(@{$self->{operatorStack}});
}

sub peekTopOfOperatorStack {
  my $self = shift;
  if (0 == int(@{$self->{operatorStack}})) { return undef; }
  return $self->{operatorStack}->[-1];
}

sub dumpOperatorStack  {
  my $self = shift;
  my @res = ();
  foreach my $o (@{$self->{operatorStack}}) {
    push(@res, $o->{value});
  }
  return join(', ', @res);
};

sub pushToOutputQueue {
  my $self = shift;
  my ($inElement) = @_;
  unshift(@{$self->{outputQueue}} , $inElement);
  return $self;
};

sub dumpOutputQueue {
  my $self = shift;
  my @res = ();
  foreach my $o (@{$self->{outputQueue}}) {
    push(@res, $o->{value});
  }
  return join(', ', @res);
};

sub reset {
  my $self = shift;
  $self->{operatorStack} = [];
  $self->{outputQueue} = [];
  $self->{status} = undef;
  $self->{message} = undef;
  $self->{tokens} = [];
  return $self;
}

sub setInfixExpression {
  my $self = shift;
  my ($inInfixExpression) = @_;
  $self->reset();
  $self->{infix} = $inInfixExpression;
  return $self;
}

sub parse {
  my $self = shift;
  $self->reset();

  unless (defined($self->{infix})) { die("No infix expression to parse!"); }

  # Split the infix expression into tokens.

  my $lexer = string_lexer( $self->{infix}, @input_tokens );
  while ( my $_token = $lexer->() ) {
      push @{$self->{tokens}}, $_token;
  }

  # Execute the Shunting Yard algorithm.

  foreach my $_token (@{$self->{tokens}}) {

    my $type    = $_token->[0];
    my $value   = $_token->[1];
    my $element = { type => $type, value => $value };

    if ($self->{debug}) {
      print "## GOT($value, $type)\n";
      print "   STACK: " . $self->dumpOperatorStack() . "\n";
      print "   QUEUE: " . $self->dumpOutputQueue() . "\n";
    }

    if ($type =~ m/^STRING|VARIABLE|NUMERIC$/) {
      $self->pushToOutputQueue($element);
      if ($self->{debug}) {
        print "   Push $value into the output queue\n";
      }
      next;
    }

    if ($type eq 'FUNCTION') {
      $self->pushToOperatorStack($element);
      if ($self->{debug}) {
        print "   Push $value into the operator stack\n";
      }
      next;
    }

    if ($type eq 'PARAM_SEPARATOR') {
      while (1) {
        my $operator = $self->peekTopOfOperatorStack();

        unless (defined($operator)) {
          $self->{status} = 0;
          $self->{message} = 'Could not find closing bracket (line ' . __LINE__ . ')';
          return 0;
        }
        if ($self->{debug}) {
          print "   Poped = " . $operator->{value} . "\n";
        }
        if ('OPEN_BRACKET' eq $operator->{type}) { last; }
        $operator = $self->popOffOperatorStack();
        if ($self->{debug}) {
          print "   Push " . $operator->{value} . " into the output queue\n";
        }
        $self->pushToOutputQueue($operator);
      }
      next;
    }

    if ('OPERATOR' eq $type) {

      my $operatorPrecedence = $precedences{$value};
      my $operatorAssociativity = $associativities{$value};

      if ($self->{debug}) {
        print "   Got an operator $value ($operatorPrecedence, $operatorAssociativity)\n";
      }

      while (1) {
        my $stackElement = $self->peekTopOfOperatorStack();
        unless (defined($stackElement)) { last; }

        if ($self->{debug}) {
          print "   Peek " . $stackElement->{value} . "\n";
        }

        unless ($stackElement->{type} eq 'OPERATOR') { last; }
        my $stackElementPrecedence = $precedences{$stackElement->{value}};
        my $stackElementAssociativity = $associativities{$stackElement->{value}};

        if ($self->{debug}) {
          print "   This is an operator " . $stackElement->{value} . " ($stackElementPrecedence / $stackElementAssociativity)\n";
        }

        if (
             (
                ($operatorAssociativity eq 'left')
                &&
                ($operatorPrecedence <= $stackElementPrecedence)
             ) ||
             (
               ($operatorAssociativity eq 'right')
               &&
               ($operatorPrecedence < $stackElementPrecedence)
             )
           ) {
           my $operator = $self->popOffOperatorStack();
           if ($self->{debug}) {
             print "   Push " . $operator->{value} . " into the output queue\n";
           }
           $self->pushToOutputQueue($operator);
         } else {
           last;
         }

     };

     if ($self->{debug}) {
       print "   Push the operator $value to the stack\n";
     }
     $self->pushToOperatorStack($element);
     next;
    }

    if ('OPEN_BRACKET' eq $type) {
      $self->pushToOperatorStack($element);
      if ($self->{debug}) {
        print "   Push ( to the stack\n";
      }
      next;
    }

    if ('CLOSE_BRACKET' eq $type) {

      while (1) {
        my $operator = $self->popOffOperatorStack();
        unless (defined($operator)) {
          $self->{status} = 0;
          $self->{message} = 'Could not find closing bracket (line ' . __LINE__ . ')';
          return 0;
        }
        if ('OPEN_BRACKET' eq $operator->{type}) { last; }
        if ($self->{debug}) {
          print "   Push " . $operator->{value} . " into the output queue\n";
        }
        $self->pushToOutputQueue($operator);
      }

      my $operator = $self->peekTopOfOperatorStack();

      if (defined($operator)) {
        if ('FUNCTION' eq $operator->{type}) {
          if ($self->{debug}) {
            print "   Push " . $operator->{value} . " into the output queue\n";
          }
          $self->pushToOutputQueue($self->popOffOperatorStack());
        }
        next;
      }
    }
  }

  while (1) {
    my $operator = $self->popOffOperatorStack();
    unless (defined($operator)) { last; }
    if ($operator->{type} =~ m/^OPEN_BRACKET|CLOSE_BRACKET$/) {
      $self->{status} = 0;
      $self->{message} = 'Something is messed up with brackets (line ' . __LINE__ . ')';
      return 0;
    }
    if ($self->{debug}) {
      print "   Push " . $operator->{value} . " into the output queue\n";
    }
    $self->pushToOutputQueue($operator);
  }

  $self->{status} = 1;
  return 1;
}



1;
