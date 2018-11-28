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

package Tmux::Daemon::PluginSystem;

use strict;
use warnings;

use Tmux::Call;

use constant TMUX_EXITED => 1;

sub new {
   bless { 
      plugins => {},
      commands => {},
      #hooks => {},
      exit_reason => undef
   };
}

sub load {
   my ($self, $plugin) = @_;
   require "Tmux/Daemon/Plugins/$plugin.pm";
   $self->{plugins}{$plugin} = "Tmux::Daemon::Plugins::$plugin"->new($self);
}

sub register_command {
   my ($self, $command, $code_ref) = @_;
   $self->{commands}{$command} = $code_ref;
}

# TODO: for ControlMode
#sub register_hook {
#   my ($self, $hook, $code_ref) = @_;
#   if (! exists $self->{hooks}{$hook}) {
#      $self->{hooks}{$hook} = [];
#   }
#   push @{ $self->{hooks}{$hook} }, $code_ref;
#}

# TODO: for ControlMode
#sub call_hook {
#   my ($self, $hook, $args) = @_;
#   if (exists $self->{hooks}{$hook}) {
#      for my $callback (@{ $self->{hooks}{$hook} }) {
#         $callback->($args);
#      }
#   }
#}

sub call_command {
   my ($self, $command, @args) = @_;

   #if (! fork) {
   #   $plugin_system->call_command($cmd, @args);
   #   exit;
   #}

   my $command_callback = $self->{commands}{$command} or do {
      Tmux::Call::void('display-message', "tmux-daemon: no such command: $command");
   };

   $command_callback->(@args);
}

sub del {
   for (values %{ $_[0]->{plugins} }) {
      $_->del();
   }
}

#sub plugin_option {
#   my ($plugin, $option, $value) = @_;
#}


1;
