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

package Tmux::Daemon::Plugins::FuzzySelect;

use strict;
use warnings;
use Getopt::Long qw(GetOptionsFromArray :config gnu_getopt);

use Tmux::Call;
use Tmux::Daemon::PluginCommand;
use base 'Tmux::Daemon::PluginCommand';

use constant OPTIONS => ( 'l', 'n', 'p', 'T', 't=s' );

sub new {
   my $class = shift;
   my $self = bless $class->SUPER::new(@_), $class;

   $self->register_command('select-window-fuzzy', \&select_window_fuzzy);
   $self;
}

sub select_window_fuzzy {
   GetOptionsFromArray(\@_, \my %opts, OPTIONS);

   unless (exists $opts{t}) {
      warn 'Option "-t" is missing, won\'t call select_window_fuzzy, calling original select-window instead';
      return Tmux::Call::void('select-window', @_);
   }

   my $win = $opts{t};
   my @windows = Tmux::Call::as_lines('list-windows', '-F', '#I');
   Tmux::Call::void('select-window', '-t', window_approx($win, @windows));
}

#
# Return approximiate window
#
sub window_approx {
   my ($win, @windows) = @_;
   @windows = sort {$a <=> $b} @windows;

   return 0 if ($#windows == -1);
   return $windows[0] if ($#windows == 0);

   if ($win <= $windows[0]) {
      return $windows[0];
   }
   elsif ($win >= $windows[$#windows]) {
      return $windows[$#windows];
   }

   my $approx_left;

   for (@windows) {
      # wanted window is available
      return $win if ($win == $_);

      if ($_ > $win) {
         # check if right or left window is closed to the wanted window
         if ($win - $approx_left < $_ - $win) {
            return $approx_left;
         }
         else {
            return $_;
         }
      }

      $approx_left = $_;
   }

   return -1;
}

1;
