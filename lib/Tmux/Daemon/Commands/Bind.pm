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

package Tmux::Daemon::Commands::Bind;

use strict;
use warnings;
use Getopt::Long qw(:config gnu_getopt);
use Data::Dump qw(dump);

use constant OPTIONS => ('n', 'r', 'T=s');

my ($plugin_system, $config);

sub init {
   ($plugin_system, $config) = @_;
}

sub parse {
   my @args = (@_);
   my %opts = ('T' => 'prefix');

   Getopt::Long::Configure qw(pass_through require_order no_auto_version);
   Getopt::Long::GetOptionsFromArray(\@args, \%opts, OPTIONS);

   if ($opts{n}) {
      $opts{T} = 'root';
      delete $opts{n};
   }

   return (\%opts, @args);
}

# TODO: Tmux::hashopts_to_argv
sub hashopts_to_argv {
   my $opts = shift;

   map {
      my $opt = substr($_, 0, 1);

      if (exists $opts->{$opt}) {
         if (length == 1) {
            "-$opt" # return
         } else {
            ("-$opt", "$opts->{$opt}") # return
         }
      } else {
         () # return
      }
   } @_
}


sub bind {
   my ($options, $key, @args) = parse(@_);

   @args = map {
      if (s/^plugin-call\((.*)\)/$1/) {
         ('run-shell', '-b', "echo 'TMUX=\"#{socket_path},#{pid},#{s/\$//:session_id}\" $_'>'$config->{fifo}';:");
      } else {
         $_
      }
   } @args;

   my @args_opts = hashopts_to_argv($options, OPTIONS);
   Tmux::Call::void('bind', @args_opts, $key, @args);
}

1;
