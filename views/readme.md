## Getting a list of all user id's

```
./lsUsers.php | less # browsing through user ids sorted in alphabetical order, showing one page at a time
./lsUsers.php | grep ^SD5 # list all user ids starting with *SD5*.
```

## Getting a summary of all tests a user has ever taken

```
./lsTests.php SD5AM # all tests of SD5AM in descending order by time
./lsTests.php SD5AM | less # same as before, but showing only one page at a time
./lsTests.php SD5AM 2014_10_7_11_53_58 # only list tests up to the specified timestamp
```

## Getting an overview of the last tests of a user

```
./lsLatestTests.php SD5AM # last tests of SD5AM in descending order by time
./lsLatestTests.php SD5AM 2014_10_7_11_53_58 # same as before, but only shows tests up the specified timestamp
```

## Getting a list of task-data files of a test

```
./lsTasks.php SD5AM 2014_10_7_11_53_58
```

## Getting an overview of the last marks a user has achieved

```
./getLatestMarks.php SD5AM # the list of marks SD5AM has achieved in his last test session
./getLatestMarks.php SD5AM 2014_10_7_11_53_58 # same as before, but only takes into account tests up the specified timestamp
``` 
