
Instructions for importing Landtype Association coverage from the CDROM:

The export directory contains one file  (r1ltas.z) which is the Unix-compressed version of the Arc Export 
file containing the Arc/Info  Landtype Association coverage.  This file will need to be handled differently 
if the user is importing the coverage on a DOS or NT based operating  system , or if
using a Unix based system such as the Forest Service IBM equiptment.

INSTRUCTIONS FOR IMPORTING THE LTA COVERAGE USING A DOS OR NT OPERATING 
SYSTEM:

1.  Copy the file called r1ltas.z to a directory on the hard drive with sufficient memory to manipulate a
      large Arc-Info coverage. The compressed export file is approximately 37 megabytes. The imported 
      coverage is approximately 123 megabytes.

2.  Using the WinZip utility, uncompress the file. This will restore the file called r1ltas.e00.

3.   The file is now ready to be imported using the Arc import command.


INSTRUCTIONS FOR IMPORTING THE LTA COVERAGE USING A UNIX OPERATING SYSTEM:

1.  Same as #1 above.

2.  Move the file called r1ltas.z to r1ltas.Z  (Unix uncompress will not recognize the lower case z).

3.  Use the Unix  uncompress  command to uncompress the file.

4.    The uncompressed file will NOT display the .e00 extension required by Arc/Info, so the
        uncompressed file (r1ltas) will need to be moved (mv) to r1ltas.e00.

5.    The file is now ready to be imported using the Arc import command.
