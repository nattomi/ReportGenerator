# Report Generator - performance report generator

This library is used as a pdf report generator for the [otu.lea](http://otulea.uni-bremen.de/) project. Currently it is pretty much attached to the parent project but the same idea can be used just as well to generate pdf reports of other nature too.

## for end users
git clone git://github.com/nattomi/ReportGenerator.git 
## for developers
git clone git@github.com:nattomi/ReportGenerator.git
## to get the current stable release, cd to project folder then issue
git checkout tags/v.1.2.1
## to get the current testing release, cd to project folder then issue
git checkout tags/v.1.3.3


## CHANGELOG
v1.3.3
======
* An obsolete folder removed.
* Correct evaluation of interrupted tests.

v1.3.2
======
* Confusing line refering to a formerly existed but now unused R script removed from the configuration file. 

v1.3.1
======
* Changed the order in which alpha IDs are reported in eval monde A1 from increasing to decreasing.

v1.3
====
* The student report has been migrated to php completely.
* Messages such as "Sehr gut, Sie haben alle Aufgaben gelöscht!" were not displayed at all in the online report. Therefore, a new subnode called 'message' has been added to the 'eval' nodes. With the help of this, it is now possible to resolve the above mentioned issue.
* Object-oriented approach.

v1.2.1
======
* Bug in evalMarking.R (related to eval mode A2) was fixed. 

v1.2
====
* Ability to trace the "prev" attributes in the test nodes of the users' global xml file. That was the main purpose of this release, because it was a very essential missing feature.
* A new step has been made towards the R->PHP migration. In the frame of this, some tasks  that has been formerly done by the script evalUser.R are now migrated into student.php. Instead of evalUser.R, student.php calls a new script called evalMarking.R (this script is very similar to evalUser.R, but it is more simplistic and works from a different input).
* student.php has been split into 3 parts: student.php, conf_student.php and functions.php. The latter contains function definitions (currently only one). All the configuration is now done in conf_student.php, in the main script (student.php) there is 
only 1 or 2 lines that need to be edited.
