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

package Tmux::Daemon::Plugins::RestoreBindings;

use strict;
use warnings;

use Text::ParseWords qw(shellwords quotewords);
use File::Temp qw(tempfile);
use Data::Dump qw(dump);

use Tmux::Call;
use Tmux::Daemon::PluginCommand;
use base 'Tmux::Daemon::PluginCommand';

sub new {
   my $class = shift;
   my $self = bless $class->SUPER::new(@_), $class;

   (my $fh, $self->{bindings_file}) = tempfile();
   print $fh Tmux::Call::as_text('list-keys');
   close $fh;

   $self;
}

sub del {
   my $self = shift;
   open(my $fh, '<', $self->{bindings_file});
   while(<$fh>) {
      chomp;
      #next if /copy-mode-vi/;
      #s/\\\\/\\/g;
      #s/;/\\\\;/g;
      my @cmds = quotewords(qr/\s+/, 1, $_);
      @cmds = map { 
         if (/^[;"']$/) {
            "\\$_";
         }
         else {
            $_;
         }
      } @cmds;
      #dump(@cmds);
      print $_, "\n";
      print join(' ', @cmds), "\n";
      eval { Tmux::Call::void(@cmds) };
   }
}

1;
