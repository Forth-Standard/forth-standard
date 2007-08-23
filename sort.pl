#! /bin/perl
$DEBUG = 0;
$SORT = 0;

%words = ();

foreach $line (<STDIN>) {
	if ($DEBUG) {
		print $line;
	}

	@params = (split(/[\{\}]/,$line));
	($sec,$num,$sub,$name) = @params[1,3,5,7];

	$name =~ s/\\char \"([0-9A-F]{2})/pack('C', hex($1))/seg;
	$sec = "6.$sec" if ( (split(/\./, $sec))[0] == 6);
	$num = 0 unless $num;
	$sub = 0 unless $sub;

	if ($DEBUG) {
		print "Name($name) Sec($sec) Num($num) Sub($sub)\n";
	}

	if ($SORT) {
		$len = length($name);
		$length = $len if $len > $length;
	}

	$key = $name . " ";
	foreach $val (split(/\./, "$sec.$num.$sub")) {
		$key .= substr("0000" . $val, -4);
	}

	if ($DEBUG) {
		print "Key: ", $key, "\n";
		print "\n";
	}

	$words{$key} = $line;
}

if ($DEBUG) {
	foreach $key (keys %words) {
		@list = (split(" ",$key));
		print $list[1], " ", $list[0], "\n";
	}
	print "\n";
}

foreach $key (sort wordcomp keys %words) {
	if ($SORT) {
		print "\n";
		$SORT = 0;
	}
	print $words{$key};
}

sub wordcomp {
	local $ans;
	local ($a_name,$a_num) = split(" ", $a);
	local ($b_name,$b_num) = split(" ", $b);

	# Word names
	$ans = $a_name cmp $b_name;
	if ($SORT) {
		print "\n";
		print $a_name, " " x ($length - length($a_name));
		print "  ", substr("<=>", $ans+1, 1), "  ";
		print $b_name, " " x ($length - length($b_name));
	}

	if ( $ans == 0 ) {
		# Word section (number)
		$ans = $a_num <=> $b_num;
		if ($SORT) {
			print "  ", $a_num, " ", substr("<=>", $ans+1, 1), " ", $b_num;
		}
	}
	return $ans;
}

__END__
