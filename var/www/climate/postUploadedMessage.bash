emailAddress=$1
ProjectDirectory=$2
answerFile=$3
mailx -t $emailAddress \
 -a "From: CustomDataRequest" \
 -a "Subject: Custom request completed" \
 -a "Reply-To: Nicholas Crookston <ncrookston.fs@gmail.com>" \
 -a "Cc: ncrookston.fs@gmail.com" <<!

Custom request completed. Get data from this link:

http://forest.moscowfsl.wsu.edu/climate/$ProjectDirectory/$answerFile

!
echo Message sent, emailAddress = $emailAddress, ProjectDirectory = $ProjectDirectory, answerFile = $answerFile

