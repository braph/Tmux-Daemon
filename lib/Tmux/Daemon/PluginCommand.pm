#!/usr/bin/env perl

eval 'exit'
    if 0; # not running under some shell

=begin COPYRIGHT

   tmux_perl.pl - extend tmux using perl
   Copyright (C) 2016 Benjamin Abendroth
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.

=end COPYRIGHT

=cut

package Tmux::Daemon::PluginCommand;

use strict;
use warnings;
use feature 'say';
use Data::Dump qw(dump);

sub new {
   my ($class, $command_dispatcher) = @_;

   bless {
      command_dispatcher => $command_dispatcher
   }
}

sub register_command {
   # ($self, $command, $callback) = @_
   my $self = shift;
   $self->{command_dispatcher}->register_command(@_);
}

sub call_command {
   my $self = shift;
   return $self->{command_dispatcher}->call_command(@_);
}

sub del {
}

1;
