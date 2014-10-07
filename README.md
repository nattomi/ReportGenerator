# OTULEA - performance report generator

# for end users
git clone git://github.com/nattomi/otulear.git 
# for developers
git clone git@github.com:nattomi/otulear.git
# to get the current stable release
cd otulear
git checkout tags/v.1.2.1

# CHANGELOG

v1.2.1
======
* Bug in evalMarking.R (related to eval mode A2) was fixed. 

v1.2
====
* Ability to trace the "prev" attributes in the test nodes of the users' global xml file. That was the main purpose of this release, because it was a very essential missing feature.
* A new step has been made towards the R->PHP migration. In the frame of this, some tasks  that has been formerly done by the script evalUser.R are now migrated into student.php. Instead of evalUser.R, student.php calls a new script called evalMarking.R (this script is very similar to evalUser.R, but it is more simplistic and works from a different input).
* student.php has been split into 3 parts: student.php, conf_student.php and functions.php. The latter contains function definitions (currently only one). All the configuration is now done in conf_student.php, in the main script (student.php) there is 
only 1 or 2 lines that need to be edited.