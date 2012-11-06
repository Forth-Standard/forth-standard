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

	if ( $#params > 18 ) {
		$name = join("",@params[7,9]);
	}
	
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

	print "\n" if $SORT;

	# Word name
	$ans = $a_name cmp $b_name;
	if ($SORT) {
		print "  ", $a_name, " ", substr("<=>", $ans+1, 1), " ", $b_name;
	}
	return $ans if $ans != 0;

	# Word Number (num)
	local($a) = substr($a_num, 12, 4);
	local($b) = substr($b_num, 12, 4);

	$ans = $a <=> $b;
	if ($SORT) {
		print "  ", $a, " ", substr("<=>", $ans+1, 1), " ", $b;
	}

	return $ans if $ans != 0;

	# Sub Number (sub)
	$a = substr($a_num, 16, 4);
	$b = substr($b_num, 16, 4);

	$ans = $a <=> $b;
	if ($SORT) {
		print "  ", $a, " ", substr("<=>", $ans+1, 1), " ", $b;
	}

	return $ans if $ans != 0;	

	# So same word number, sub-word number and word name.
	# We only the the wordlist number to go. (sec)

	$a = substr($a_num, 0, 4);
	$b = substr($b_num, 0, 4);

	$ans = $a <=> $b;
	if ($SORT) {
		print "  ", $a, " ", substr("<=>", $ans+1, 1), " ", $b;
	}

	return $ans;
}

__END__
