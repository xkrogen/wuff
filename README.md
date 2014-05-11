Wuff
=======================
iOS frontend and Rails backend app for event creation + management.
![Screenshot-1](images/screenshot-1.png?raw=true)
![Screenshot-1](images/screenshot-2.png?raw=true)
![Gif-1](images/gif-1.gif?raw=true)
![Gif-2](images/gif-2.gif?raw=true)

## Dependencies

 * Cocoapods
 * Rails modules (bundle install)

## Build

 * Make sure you open the .xcworkspace instead of the .xcodeproj with XCode.
 * To run tests for the Rails server: simply run rspec from within the wuff\_backend folder, 
which is where the Rails server is located. Note that the auth\_facebook test may fail;
this is normal, as currently you must manually create a token from facebook which is
only valid for one hour. Functional tests can be run by running testLib.py within functional\_tests folder,
but it is configured to access the heroku server and the server's database must be manually cleared 
beforehand so this is not recommended. 

 * You can start the server as you would any other rails server from within the wuff\_backend folder.
