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

package Tmux::Daemon::Bindings

my %keytable;

sub bind_fill {
   my ($key, $table, $options, @args) = parse_bind(@_);
   
   $keytable{$table}{$key} = [$options, \@args];
}

sub get_binding {
   my ($key, $table) = @_;

   $keytable{$table}{$key};
}

sub list_keys {
   my $output = $command_dispatcher->call_command('list-keys');
   open my $fh, '<', \$output or die $!;
   while (<$fh>) {
      chomp;
      next unless $_;
      my ($cmd, @args) = shellwords($_);
      if ($cmd ne 'bind-key') {
         warn "not bind-key: $cmd";
      }
      else {
         bind_fill(@args);
      }
   }
}

1;
