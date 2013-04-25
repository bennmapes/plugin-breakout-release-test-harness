We're breaking out the API surface of Cordova into discreet plugins. This script helps test the support tooling for that.

Run the script, it should fail due to FooBar/FooBaz having accelerometer already (currenlty passing due to plugman bug).

For Android, go into FooBaz and edit res/xml/config.xml and remove the accelerometer line.

For iOS, go into FooBar and edit FooBar/config.xml and remove the accelerometer line. Also from FooBar/Classes, remove CDVAccelerometer.h & CDVAccelerometer.m.

Run script again, everything should pass and you can go run each project to test.

Currently the test folder includes mobile specs index.html, accelerometer tests, automatic tests for accelerometer and and index page for the automatic tests. I propose we provide custom index.html files and copy over mobile specs automatic accelerometer tests and its normal accelerometer tests.
