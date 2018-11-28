#!/usr/bin/env perl

# TODO ...

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

package Tmux::Daemon::Plugins::AutoWindowRename;

use strict;
use warnings;
use Getopt::Long qw(GetOptionsFromArray :config gnu_getopt);

use Tmux::Call;
use Tmux::Daemon::PluginCommand;
use base 'Tmux::Daemon::PluginCommand';

#use constant OPTIONS => ( 'l', 'n', 'p', 'T', 't=s' );

sub new {
   my $class = shift;
   my $self = bless $class->SUPER::new(@_), $class;

   $self->register_command('auto-window-rename', \&auto_window_rename);
   #$self->register_hook('changed', \&window_name_changed);
   $self;
}

sub window_name_changed {

}

sub auto_window_rename {
   #GetOptionsFromArray(\@_, \my %opts, OPTIONS);

   #unless (exists $opts{t}) {
   #   warn 'Option "-t" is missing, won\'t call select_window_fuzzy, calling original select-window instead';
   #   return Tmux::Call::void('select-window', @_);
   #}
   #
   #my $win = $opts{t};
   #my @windows = Tmux::Call::as_lines('list-windows', '-F', '#I');
   #Tmux::Call::void('select-window', '-t', window_approx($win, @windows));
}

1;
