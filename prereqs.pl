#!/usr/bin/env perl

my (@found, @not_found);
sub warn_if_not_found {
    my $module = shift;
    eval "require $module";
    if ( $@ ) { push @not_found, $module } else { push @found, $module }
}

warn_if_not_found $_ for qw/Text::Xslate/;

if (@found)     { print "### Prerequisites found:\n";     print "# $_\n" for @found };
if (@not_found) { print "### Prerequisites not found:\n"; print "$_\n"   for @not_found; }
