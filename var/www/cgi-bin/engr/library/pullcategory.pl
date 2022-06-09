open DB, "<pubdb.txt";

while (<DB>) {

  if ($_ =~ /\$title=/i) {print $_};
  if ($_ =~ /\$category=/i) {print $_};

}
close DB;

