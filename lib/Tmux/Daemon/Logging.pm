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

package Tmux::Daemon::Logging;

use strict;
use warnings;
use feature 'say';
use parent 'Exporter';

our $level = 0;

sub info {
   say $_[0] if $level;
}

sub debug {
   say $_[0] if $level >= 2;
}

our @EXPORT = qw($level info debug);

1;
