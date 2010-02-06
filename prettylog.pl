#!/usr/bin/perl

# Usage: prettylog.pl <input.txt >output.txt
# Input text should be encoded as UTF-8 without BOM

# Copyright (c) 2009 Alexey Bobyakov

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

use strict;
use warnings;
use encoding 'utf8', STDOUT => 'utf8', STDIN => 'utf8';

my $message = "";
my $multiline = !1;
my $date = "";
my $template = "зж9";
my @months = qw(января февраля марта апреля мая июня июля августа сентября октября ноября декабря);

print "== Дискуссия ==\nВ дискуссии используется московское время.\n\n";
while (<STDIN>) {
    s#[\r\n]+$##;
    if (m#^\[(?:(\d+).(\d+).(\d+) )?\d+:\d+:\d+(?: \| Изменены \d+:\d+:\d+)?\]#) {
        my $newdate;
        my $day;
        my $year;
        my $month;
        if ($1) {
            $day = $1;
            $year = $3;
            $month = $2 - 1;
        }
        else {
            my @timeData = localtime();
            $month = $timeData[4];
            $day = $timeData[3];
            $year = 1900 + $timeData[5];
        }
        $newdate = "$day " . $months[$month] . " $year";
        $newdate =~ s#0(\d) #$1 #;
        
        $message =~ s#^\[(?:\d+.\d+.\d+ )?(\d+:\d+:\d+) \| Изменены (\d+:\d+:\d+)\] (.+?): (.+)$#{{$template|$1|$3|$2|текст=$4}}#s;
        $message =~ s#^\[(?:\d+.\d+.\d+ )?(\d+:\d+:\d+)\] (.+?): (.+)$#{{$template|$1|$2|текст=$3}}#s;
        $message =~ s#\|(\d:\d+:\d+)\|#|0$1|#s;
        print "$message\n" if ($message);
        $multiline = !1;
        
        if (not $newdate eq $date) {
            print "; $newdate\n\n";
            $date = $newdate;
        }
    }
    else {
        $multiline = 1;
    }
    
    if ($multiline) {
        $message = $message . "\n" . $_;
    }
    else {
        $message = $_;
    }
}

if ($message) {
    $message =~ s#^\[(?:\d+.\d+.\d+ )?(\d+:\d+:\d+) \| Изменены (\d+:\d+:\d+)\] (.+?): (.+)$#{{$template|$1|$3|$2|текст=$4}}#s;
    $message =~ s#^\[(?:\d+.\d+.\d+ )?(\d+:\d+:\d+)\] (.+?): (.+)$#{{$template|$1|$2|текст=$3}}#s;
    $message =~ s#\|(\d:\d+:\d+)\|#|0$1|#s;
    print "$message\n";
}