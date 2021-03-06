## A New Post

Enter text in [Markdown](http://daringfireball.net/projects/markdown/). Use the toolbar above, or click the **?** button for formatting help.

INSTRUCTIONS
 
1. Clone or download project
2. In the root directory of the project run: python build.py
3. Then run either:
unzip -o gyh.shaperacehealthkit.com-iphone-1.0.zip -d ~/Library/Application\ Support/Titanium/
or:
mv gyh.shaperacehealthkit.com-iphone-1.0.zip ~/Library/Application\ Support/Titanium/

Then either:
1.Open the tiapp.xml and update the <modules/> element to include the module as a dependency to the project: 
<ti:app>
    <modules>
        <module platform="iphone">gyh.shaperacehealthkit.com</module>
    </modules>
</ti:app>

Or:
In Studio:
Open the tiapp.xml file located in the root directory of the project.
Under the Modules section, click the Add button.
Select gyh.shaperacehealthkit.com
Click OK.


Make sure that healthkit is enabled for your provisioning profile for your app
https://developer.apple.com/account/ios/profile/profileList.action


// Creates the module

var mod = require('gyh.shaperacehealthkit.com');


// checks if Healthkit is available on the device
var supported = mod.isSupported();


//  Array for types to read. Use any Healthkit constant identifier.
var readTypes = ["HKQuantityTypeIdentifierStepCount", "HKQuantityTypeIdentifierBodyMass"];


//  Array for types to write. Use any Healthkit constant identifier.
var writeTypes = ["HKQuantityTypeIdentifierBodyFatPercentage", "HKQuantityTypeIdentifierDietaryFatTotal"];


// Asks user for authorization and displays the Permissions Dialog (happens only once)
mod.authorize(writeTypes, readTypes, function(res){
	if (res.success == 1){
		// no error occured
	}else{
		// error occurred
	}
})


// Controls if the user gave all permissions. For write types this works fine, but for 
// read types Apple doesn't allow developers to query directly for permission (see documentation(. 
// However this method returns true if data is available for every read type 
// (which indicates the user gave read permission)
mod.controlPermssions(writeTypes, readTypes, function(res){
	if (res.success == 1){
		// all permissions given
	}
	else{
		// some permission were denied
	}
})



// Constructs dateobjects to use with query
var startDate = new Date(); 
startDate.setHours(00);
var endDate = new Date();


// Returns a date predicate
function datePredicate(startDate, endDate)
{
        return { "datePredicate": [xcodeDate(startDate),  xcodeDate(endDate)] };
}


// Example  predicate
var predicate = new datePredicate(startDate, endDate)


// Query object to use with  to query Healthkit for quantity types
 var Query = function(quantityType, limit, predicate){
            this.quantityType   	= quantityType;
            this.limit                  = limit;
            this.predicate              = predicate;
 };


 // Example query 
var query = new Query("HKQuantityTypeIdentifierStepCount", 0, predicate)

 
 // Queries Healthkit for data for  quantity types
 healthkit.getQuantityResult(query, function(res){
       if (res.success == 1){
       		// res.quantities - array with results
  			// res.sources - array with the source (app) that created each quantity
 	 		// res.quantityType - the type of the query 
       }else{
       		// Something has gone wrong
       }
));
 
 

 // Workout object for saving a workout to Healthkit
var Workout = function(calories, distance, startDate, endDate, HKWorkoutActivityTypes){
        this.calories   = calories;
        this.distance   = distance;
        this.startDate  = startDate;
        this.endDate    = endDate;
        this.HKWorkoutActivityTypes = HKWorkoutActivityTypes;
};


// Constructs date objects to use with workout
startDate = new Date(); 
startDate.setHours(00);
endDate = new Date();

// Sample workout 
var workout = new Workout(500, 2000, startDate, endDate, "HKWorkoutActivityTypes");


 // Saves a workout. 
healthKit.saveWorkout(workout, function(res){
	if (res.success == 1){
		// workout was saved correctly
	}else{
		// something went wrong, possibly due to no write permission 
	}
});



//  Javascript Support functions 

function xcodeDate(d)
{
        return d.getFullYear() + "-" + (d.getMonth() + 1) + "-" + d.getDate()  + " " + d.getHours() + ":" + d.getMinutes() + ":" + d.getSeconds();
}




Appcelerator Titanium iPhone Module Project
===========================================

This is a skeleton Titanium Mobile iPhone module project.  Modules can be 
used to extend the functionality of Titanium by providing additional native
code that is compiled into your application at build time and can expose certain
APIs into JavaScript. 

MODULE NAMING
--------------

Choose a unique module id for your module.  This ID usually follows a namespace
convention using DNS notation.  For example, com.appcelerator.module.test.  This
ID can only be used once by all public modules in Titanium.


COMPONENTS
-----------

Components that are exposed by your module must follow a special naming convention.
A component (widget, proxy, etc) must be named with the pattern:

	Ti<ModuleName><ComponentName>Proxy

For example, if you component was called Foo, your proxy would be named:

	TiMyfirstFooProxy
	
For view proxies or widgets, you must create both a view proxy and a view implementation. 
If you widget was named proxy, you would create the following files:

	TiMyfirstFooProxy.h
	TiMyfirstFooProxy.m
	TiMyfirstFoo.h
	TiMyfirstFoo.m
	
The view implementation is named the same except it does contain the suffix `Proxy`.  

View implementations extend the Titanium base class `TiUIView`.  View Proxies extend the
Titanium base class `TiUIViewProxy` or `TiUIWidgetProxy`.  

For proxies that are simply native objects that can be returned to JavaScript, you can 
simply extend `TiProxy` and no view implementation is required.


GET STARTED
------------

1. Edit manifest with the appropriate details about your module.
2. Edit LICENSE to add your license details.
3. Place any assets (such as PNG files) that are required in the assets folder.
4. Edit the titanium.xcconfig and make sure you're building for the right Titanium version.
5. Code and build.

BUILD TIME COMPILER CONFIG
--------------------------

You can edit the file `module.xcconfig` to include any build time settings that should be
set during application compilation that your module requires.  This file will automatically get `#include` in the main application project.  

For more information about this file, please see the Apple documentation at:

<http://developer.apple.com/mac/library/documentation/DeveloperTools/Conceptual/XcodeBuildSystem/400-Build_Configurations/build_configs.html>


DOCUMENTATION FOR YOUR MODULE
-----------------------------

You should provide at least minimal documentation for your module in `documentation` folder using the Markdown syntax.

For more information on the Markdown syntax, refer to this documentation at:

<http://daringfireball.net/projects/markdown/>


TEST HARNESS EXAMPLE FOR YOUR MODULE
------------------------------------

The `example` directory contains a skeleton application test harness that can be 
used for testing and providing an example of usage to the users of your module.


INSTALL YOUR MODULE
--------------------

1. Run `build.py` which creates your distribution
2. cd to `/Library/Application Support/Titanium`
3. copy this zip file into the folder of your Titanium SDK

REGISTER YOUR MODULE
---------------------

Register your module with your application by editing `tiapp.xml` and adding your module.
Example:

<modules>
	<module version="0.1">gyh.shaperacehealthkit.com</module>
</modules>

When you run your project, the compiler will know automatically compile in your module
dependencies and copy appropriate image assets into the application.

USING YOUR MODULE IN CODE
-------------------------

To use your module in code, you will need to require it. 

For example,

	var my_module = require('gyh.shaperacehealthkit.com');
	my_module.foo();

WRITING PURE JS NATIVE MODULES
------------------------------

You can write a pure JavaScript "natively compiled" module.  This is nice if you
want to distribute a JS module pre-compiled.

To create a module, create a file named gyh.shaperacehealthkit.com.js under the assets folder.
This file must be in the Common JS format.  For example:

	exports.echo = function(s)
	{
		return s;
	};
	
Any functions and properties that are exported will be made available as part of your
module.  All other code inside your JS will be private to your module.

For pure JS module, you don't need to modify any of the Objective-C module code. You
can leave it as-is and build.

TESTING YOUR MODULE
-------------------

Run the `titanium.py` script to test your module or test from within XCode.
To test with the script, execute:

	titanium run --dir=YOURMODULEDIR
	

This will execute the app.js in the example folder as a Titanium application.


DISTRIBUTING YOUR MODULE
-------------------------

Currently, you will need to manually distribution your module distribution zip file directly. However, in the near future, we will make module distribution and sharing built-in to Titanium Developer and in the Titanium Marketplace!


Cheers!
