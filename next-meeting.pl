#!/usr/bin/env perl --
use strict;
use warnings;
use Date::Calc qw/Today Add_Delta_YM Day_of_Week Day_of_Week_to_Text Month_to_Text/;

# Glasgow.pm meets on "The day after the second Wednesday of the month"
sub next_meeting_from {
    my ($y,$m,$d) = @_;

    # First of the month
    my @next_month = ( Add_Delta_YM( $y, $m, $d, 0, 1 ) )[ 0, 1 ];

    # Need to find the second Wednesday
    my $found_wednesdays = 0;
    my $day = 1;
    while ( $found_wednesdays < 2 ) {
        $found_wednesdays++ if ( Day_of_Week(@next_month,$day) == 3 );
        $day++;
    }

    # The day after the second Wednesday is the day!
    push @next_month, $day;
    return @next_month;
}

# Our next meeting..
my $today                 = sprintf( "%04d-%02d-%02d", Today() );
my @next_meeting          = next_meeting_from( Today() );
my $next_meeting_month    = Month_to_Text( $next_meeting[1] );
my $next_meeting_yyyymmdd = sprintf( "%04d-%02d-%02d", @next_meeting );
printf(
    "Our next meeting will be in %s, when we'll meet on %s %s\n",
    $next_meeting_month, Day_of_Week_to_Text( Day_of_Week(@next_meeting) ),
    $next_meeting_yyyymmdd
);

# The one after that..
my @next_next_meeting          = next_meeting_from(@next_meeting);
my $next_next_meeting_month    = Month_to_Text( $next_next_meeting[1] );
my $next_next_meeting_yyyymmdd = sprintf( "%04d-%02d-%02d", @next_next_meeting );
printf(
    "The one after that will be in %s, when we'll meet on %s %s\n",
    $next_next_meeting_month, Day_of_Week_to_Text( Day_of_Week(@next_next_meeting) ),
    $next_next_meeting_yyyymmdd
);

# Create bare page for next meeting, mentioning the one after that
{
    my $ftemplate = "templates/meetings/$next_meeting_yyyymmdd.tx";
    open my $f, '>', $ftemplate or die "Cannot open $ftemplate for writing: $!";
    print $f <<"BAREPAGE";
: cascade "page.tx" { current_page => 'Meetings', last_updated => '$today', }
: around body -> {

    <h1>Glasgow Perl Mongers Technical</h1>
    <h2>Thursday $next_meeting_yyyymmdd</h2>

    <hr />

    <div>
        On Thursday $next_meeting_yyyymmdd, the day after the second Wednesday of $next_meeting_month,
        the <a href="http://glasgow.pm.org/">Glasgow Perl Mongers</a> will
        meet for their next technical meeting, at
        <a href="http://www.s1thecompany.com/">S1</a>'s offices, in Glasgow.
    </div>

    <div class="divider">&nbsp;</div>
    <h2>Technical meetings location:</h2>
    <div>
        200 Renfield Street - G2 3PR<br />
        Google maps link (street view): <a href="http://bit.ly/bTFAFK">http://bit.ly/bTFAFK</a>.
        The appointment is for 18:15 in front of the main entrance of the glass building.<br />
        If you're late, give Marco a call on 07841-538170.
    </div>

    <div class="divider">&nbsp;</div>
    <h2>Topics for this technical meeting</h2>
    <div>
        FIXME

        There will be a <a href="http://en.wikipedia.org/wiki/Lightning_Talk">lightning talks</a>
        session right after the talks, and the group will then likely go to a pub
        for the &quot;local meeting&quot; of Drinkers.pm (the social event).
    </div>

    <div class="divider">&nbsp;</div>
    <h2>The next meeting</h2>
    <div>
        Our next gathering will be on the second Thursday of $next_next_meeting_month ($next_next_meeting_yyyymmdd),
        at the same venue.
    </div>

: }
BAREPAGE
    close $f;
    warn "Created $ftemplate\n";
}

# Update homepage as well, with new link
{
    open my $f, '<', 'templates/index.tx' or die "Cannot open templates/index.tx for reading: $!";
    my @lines = <$f>;
    close $f;

    foreach (@lines) {
        /last_updated => '(\d{4}-\d{2}-\d{2})'/ and do {
            s/$1/$today/;
        };
        m!href="/meetings/(\d{4}-\d{2}-\d{2})\.html">Thursday \1</a>! and do {
            my $last_meeting  = $1;
            s/$last_meeting/$next_meeting_yyyymmdd/g;
        }
    }

    {
        open my $f, '>', 'templates/index.tx' or die "Cannot open templates/index.tx for writing: $!";
        print $f $_ for @lines;
        close $f;
        warn "Updated templates/index.tx";
    }
}

# Update meetings page
{
    my @lines = do {
        open my $f, '<', 'templates/meetings.tx' or die "Cannot open templates/meetings.tx: $!";
        <$f>;
    };

    my $last_meeting;
    foreach (@lines) {
        /last_updated => '(\d{4}-\d{2}-\d{2})'/ and do {
            s/$1/$today/;
        };
        m!be on <a href="/meetings/(\d{4}-\d{2}-\d{2})\.html">Thursday \1</a> at! and do {
            $last_meeting = $1;
            s/$last_meeting/$next_meeting_yyyymmdd/g;
        };
        m!<ul>! and do {
            if ( !$last_meeting ) {
                warn "Ouch, could not get last meeting!";
                last;
            }
            $_ = qq{          <ul>\n              <li><a href="/meetings/$last_meeting.html">$last_meeting</a> - technical meeting</li>\n};
            last;
        };
    }
    if ( $last_meeting ) {
        open my $f, '>', 'templates/meetings.tx' or die "Cannot open templates/meetings.tx for writing: $!";
        for my $line (@lines) { print $f $line }
        close $f;
        warn "Updated templates/meetings.tx";
    }
}

