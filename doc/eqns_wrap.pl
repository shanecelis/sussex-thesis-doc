#!/opt/local/bin/perl
# eqns_wrap.pl

while (<>) {
    s/\*/ /g;
    s/\+/ + /g;
    s/\-/ - /g;
    print; 
}
