#!/bin/bash


NOTIFICATION="krishna.wattamwar@XXX.com" #ENTER MAIL ID
REPORT="/home/krishna/out.log" # ENTER OUTPUT LOG FILE PATH
CERTIFICATE_FILE=$(mktemp)
WEBSITE_LIST=`cat /home/krishna/website` #WEBSITE LIST
MAX_DAYS=32 #MAXIMUM NUMBERS OF DAYS
MIN_DAYS=02 #MINIMUM NUMBERS OF DAYS

for CERT in ${WEBSITE_LIST}
do
echo -n | openssl s_client -servername "${CERT}" -connect "${CERT}":443 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $CERTIFICATE_FILE
date=$(openssl x509 -in $CERTIFICATE_FILE -enddate -noout | sed "s/.*=\(.*\)/\1/")
date_s=$(date -d "${date}" +%s)
now_s=$(date -d now +%s)
date_diff=$(( (date_s - now_s) / 86400 ))
if [[ $date_diff -lt $MAX_DAYS && $date_diff -gt $MIN_DAYS ]];
then
        echo "${CERT} SSL certificate will expire in $date_diff days" >> $REPORT
        else
echo "${CERT} will expire in $date_diff days which is okay now" > /dev/null  2>&1
fi
done

echo -e "Hello Team, \n`cat $REPORT` \n\nThanks and Regards,\nDevOps Team" |  mail -s "RE: SSL Certificate of Websites" $NOTIFICATION
echo "" > $REPORT
