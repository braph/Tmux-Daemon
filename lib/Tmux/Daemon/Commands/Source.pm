package Tmux::Daemon::Commands::Source;

use strict;
use warnings;
use Getopt::Long qw(:config gnu_getopt);
use Data::Dump qw(dump);
use Text::ParseWords qw(shellwords);

my ($plugin_system, $config);

sub init {
   ($plugin_system, $config) = @_;
}

sub source {
   my $file = shift;
   #OPTIONS = -q

   open(my $fh, '<', $file) or die "$!: $file\n";
   while(<$fh>) {
      chomp;
      s/^\s+//;
      next unless $_;
      next if /^#/;

      my ($cmd, @args) = shellwords($_);
      $plugin_system->call_command($cmd, @args);
   }
   close($fh);
}

1;
