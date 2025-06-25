#!/bin/bash
#Thank you u/ropid from reddit i did not write this code
news() {
    echo $'\e[0;34m:: \e[1;37mArch Linux News:\e[m'
    perl << 'EOF'
use Date::Parse;
$_ = qx{curl -s "https://archlinux.org/feeds/news/"};
for (m{<item>(.*?)</item>}sg) {
    ($t) = m{<title>(.*?)</title>};
    ($d) = m{<pubDate>(.*?)</pubDate>};
    $t =~ s/&amp;/&/g;
    $t =~ s/&lt;/</g;
    $t =~ s/&gt;/>/g;
    $d = (time - str2time($d)) / (60 * 60 * 24);
    if ($d < 7.5) {
        $c = "\e[0;30;41m X \e[1;31;40m";
    } elsif ($d < 14.5) {
        $c = "\e[0;30;43m X \e[1;33;40m";
    } else {
        $c = "   ";
    }
    print $c, sprintf("%6.1f", $d), " days ago\e[m | ", $t, "\n";
    last if ++$n == 5;
}
EOF
}

news
