#!/bin/sh

##pdfDir=/var/www/feedback/pdf

find /var/www/feedback/ -not -path *template* -mmin +10 -exec rm -rf {} \;
