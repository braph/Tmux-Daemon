#!/usr/bin/env perl

=begin COPYRIGHT

   tmux-daemon - extend tmux using perl
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

=head1 Tmux::Call

   Invoke tmux commands an get their results.

=cut

package Tmux::Call;

use strict;
use warnings;

use IPC::System::Simple qw(capturex);
use Data::Dump qw(dump);

our $TMUX_BIN = 'tmux';

# =============================================================================
=head2 Tmux::Call::void($arg, ...)

   Invoke tmux command, discarding all output.

   This should be the preferred method if no output is wanted at all, since it's the fastest.

   Example:

      Tmux::Call::void('display-message', 'Hey, there!')

=cut

sub void {
   exec($TMUX_BIN, @_) unless fork;
}
# =============================================================================

# =============================================================================
=head2 Tmux::Call::as_text($arg, ...)

   Invoke tmux command, returning the result as plain text.

   Example:

      Tmux::Call::as_text('list-sessions')

   Output:

      bg: 1 windows (created Mon Nov 26 14:17:27 2018) [80x24]
      main: 15 windows (created Mon Nov 26 14:17:27 2018) [159x39] (attached)

=cut

sub as_text{
   capturex($TMUX_BIN, @_);
}
# =============================================================================

# =============================================================================
=head2 Tmux::Call::as_lines($arg, ...)

   Invoke Tmux command, returning the result as an array of lines (with newline removed.)

   Example:

      Tmux::Call::as_lines('list-sessions')

   Output:

      (
         "bg: 1 windows (created Mon Nov 26 14:17:27 2018) [80x24]",
         "main: 15 windows (created Mon Nov 26 14:17:27 2018) [159x39] (attached)"
      )

=cut

sub as_lines {
   map { chomp; $_ } as_text(@_);
}
# =============================================================================
      
# =============================================================================
=head2 Tmux::Call::as_hash($args..., '-F', [$key, $value]) 

   Invoke a tmux command using the format option (-F), returning the result as a hash.

   Example:

      Tmux::Call::as_hash('list-sessions', '-F', ['window_index', 'window_name'])

   Output:

=cut

sub as_hash {
   my $parsed = parse_args(@_);
   my @format = @{ $parsed->{format} };

   die "Tmux::Call::as_hash: format array must contain exact two fields"
      unless scalar @format == 2;

   my @lines = as_lines(@{ $parsed->{args} });

   my %return;
   for my $line (@lines) {
      my @fields = explode_line($line);
      $return{ $fields[0] } = $fields[1];
   }
   %return;
}
# =============================================================================

# =============================================================================
=head2 Tmux::Call::as_array_of_hashes(args..., '-F', [$field, ...])

   Invoke a tmux command using the format option (-F), returning the result as an array of hashes.

   Example:

      Tmux::Call::as_array_of_hases('list-windows', '-F', ['window_index', 'window_name'])

   Output:

=cut

sub as_array_of_hashes {
   my $parsed = parse_args(@_);

   die "Tmux::Call::as_array_of_hases: missing format fields array"
      unless $parsed->{format};

   my @format = @{ $parsed->{format} };

   map {
      { parse_format($_, @format) }
   } as_lines(@{ $parsed->{args} })
}
# =============================================================================

# =============================================================================
=head2 Tmux::Call::as_hash_of_hashes(args..., '-F', [$field_key, $field...])

   Invoke a tmux command using the format option (-F), returning the result as a hash of hashes
   using first field ($field_key) as key.

   Example

=cut

sub as_hash_of_hashes {
   my $parsed = parse_args(@_);

   die "Tmux::Call:as_hash_of_hashes: missing format fields array"
      unless $parsed->{format};

   my @format = @{ $parsed->{format} };

   my @lines = as_lines(@{ $parsed->{args} });

   my %return;
   for my $line (@lines) {
      #print $line, "\n";
      #dump(@format);
      my %parsed_result = parse_format($line, @format);

      $return{$parsed_result{$format[0]}} = { %parsed_result };
   }
   %return;
}
# =============================================================================

# =============================================================================
sub parse_args {
   my %result;

   $result{'args'} = [ map {
      if (ref $_ eq 'ARRAY') {
         $result{'format'} = $_;
         build_format(@$_)
      } else {
         $_
      }
   } @_ ];

   return \%result;
}
# =============================================================================

# =============================================================================
sub explode_line {
   split "\x01", $_[0];
}
# =============================================================================

# =============================================================================
=head2 [INTERNAL] build_format(@fields)

   Make format string out of given fields.

   Example:

      build_format('window_id', 'window_name')

   Return:

      "#{window_id}\0x1#{window_name}"

=cut

sub build_format {
   join "\x01", map { "#{$_}" } @_;
}
# =============================================================================

# =============================================================================
=head2 [INTERNAL] parse_format($result, @fields)

   Parse result line and return hash.
   
=cut

sub parse_format {
   my $line = shift;
   my %return;
   @return{@_} = split "\x01", $line;
   %return;
}
# =============================================================================

unless (caller) {
   my $text = as_text('list-sessions');
   dump($text);

   my @lines = as_lines('list-sessions');
   dump(@lines);

   my %hash = as_hash('list-sessions', '-F', [qw(window_id window_name)]);
   dump({%hash});

   my @array_of_hashes = as_array_of_hashes('list-sessions', '-F', [qw(window_id window_name)]);
   dump(@array_of_hashes);

   my %hash_of_hashes = as_hash_of_hashes('list-sessions', '-F', [qw(window_id window_name)]);
   dump({%hash_of_hashes});

   #my $test = parse_args('test', '-F', ['a', 'b']);
   #dump($test->{args});
   #dump($test->{format});

   #my %result;
   #%result = as_hash('list-windows', '-F', ['window_id', 'window_name']);
   #print $result{"\@22"}, "\n";
   #dump(%result);
   
   exit;
}




sub call_void {
   exec('tmux', @_) unless fork;
}

sub call_capture {
   capturex('tmux', @_);
}

sub build_argv {
   map {
      if (ref $_ eq 'ARRAY') {
         build_format(@$_)
      } else {
         $_
      }
   } @_;
}

sub call_capture_array {
   map { chomp; $_ } call_capture(@_);
}

sub call_capture_hash {
   my @format = build_argv(@_);
   die "tmux::call_capture_hash: field size has to be 2"
      unless scalar @format == 2;

   my @output_lines = map { chomp } call_capture(@format);

   my %return;
   my %parsed_result;
   for my $line (@output_lines) {
      %parsed_result = parse_format($line, @format);
      $return{$parsed_result{$format[0]}} = $parsed_result{$format[1]};
   }
   %return;
}

sub call_capture_array_of_hashes {
   my @format = build_argv(@_);
   die "tmux::call_capture_array_of_hashes: missing format fields array"
      unless @format;

   map {
      chomp;
      { parse_format($_, @format) };
   } call_capture(@format);
}

sub call_capture_hash_of_hashes {
   my @format = build_argv(@_);
   die "tmux::call_capture_format_hash_of_hashes: missing format fields array"
      unless @format;

   my @output_lines = map { chomp } call_capture(@format);

   my %return;
   for my $line (@output_lines) {
      my %parsed_result = parse_format($line, @format);
      $return{$parsed_result{$format[0]}} = { %parsed_result };
   }
   %return;
}

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

1;
