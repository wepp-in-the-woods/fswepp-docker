#! /fsapps/fssys/bin/perl

open MANAGE, ">200.man";

for $i (31..200) {

print MANAGE "#
#	Rotation $i : year $i to $i
#
	1	# `nycrop' - <plants/yr; Year of Rotation :  1 - OFE : 1>
                1       # `YEAR indx' - <ROAD>
	1	# `nycrop' - <plants/yr; Year of Rotation :  1 - OFE : 2>
                2       # `YEAR indx' - <FILL>
	1	# `nycrop' - <plants/yr; Year of Rotation :  1 - OFE : 3>
                3       # `YEAR indx' - <FOREST>
";
}
