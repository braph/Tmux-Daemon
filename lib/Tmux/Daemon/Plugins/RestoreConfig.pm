#!/usr/bin/env perl

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

package Tmux::Daemon::Plugins::RestoreConfig;

use strict;
use warnings;

use Tmux::Call;
use Tmux::Daemon::Logging qw(info debug);
use Tmux::Daemon::PluginCommand;
use base 'Tmux::Daemon::PluginCommand';

sub new {
   my $class = shift;
   my $self = bless $class->SUPER::new(@_), $class;

   chomp(my $dont_start =
      Tmux::Call::as_text('show-opt', '-gqv', '@TMUX_DAEMON_DONT_START'));
   if ('1' eq $dont_start) {
      info('wont start: @TMUX_DAEMON_DONT_START is set');
      Tmux::Call::void('set-option', '-g', '@TMUX_DAEMON_DONT_START', '');
      exit;
   }

   $self;
}

sub del {
   Tmux::Call::void('set-option', '-g', '@TMUX_DAEMON_DONT_START', '1');
   Tmux::Call::void('source', '/home/braph/.tmux.conf');
}

1;
