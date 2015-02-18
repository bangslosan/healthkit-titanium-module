

INSTRUCTIONS
-----------

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


API
-----------

**General**

Creates the module:
	
    var mod = require('gyh.shaperacehealthkit.com');
	
 
 
Checks if Healthkit is available on the device:

	var supported = mod.isSupported();



Array for types to **read**. Use any Healthkit constant identifier:



    var readTypes = {
        HKCategoryType: [],
        HKCharacteristicType : [],
        HKCorrelationType : [],
        HKQuantityType : ["HKQuantityTypeIdentifierStepCount", "HKQuantityTypeIdentifierActiveEnergyBurned"],
        HKWorkoutType: ["HKWorkoutType"]
    };



Array for types to **write**. Use any Healthkit constant identifier:

    var writeTypes = {
      HKCategoryType: [],
      HKCharacteristicType : [],
      HKCorrelationType : [],
      HKQuantityType : ["HKQuantityTypeIdentifierStepCount", "HKQuantityTypeIdentifierActiveEnergyBurned"],
      HKWorkoutType: ["HKWorkoutType"]
    };



Asks user for authorization and displays the Permissions Dialog (happens only once):

	mod.authorize(writeTypes, readTypes, function(res){
      	if (res.success == 1){
       	   // no error occured
     	 }else{
     	     // error occurred
     	 }
	  });


Controls if the user gave all permissions. For write types this works fine, but for  read types Apple doesn't allow developers to query directly for permission (see documentation). 
However this method returns true if data is available for every read type 
(which indicates the user gave read permission):

	mod.controlPermissions(writeTypes, readTypes, function(res){
     	 if (res.success == 1){
         	 // all permissions given
    	  }
     	 else{
          // some permission were denied
     		 }
 		});

-----
**Query quantity types**


Date predicate to use with query:

    function datePredicate(startDate, endDate)
    {
        return { "datePredicate": [xcodeDate(startDate), xcodeDate(endDate)] };
    }

Use ordinary JavaScript date objects with the query

    var startDate = new Date(); 
    startDate.setHours(00);
    var endDate = new Date();


Example  predicate

	var predicate = new datePredicate(startDate, endDate);


Query object to use to query Healthkit for quantity types

     var Query = function(quantityType, limit, predicate){
            this.quantityType   	= quantityType;
            this.limit              = limit;
            this.predicate          = predicate;
     }


Example query 

	var query = new Query("HKQuantityTypeIdentifierStepCount", 0, predicate)

 
 Queries Healthkit for data for quantity types
 
 	mod.getQuantityResult(query, function(res){
       if (res.success == 1){
       		// res.quantities - array with results
  			// res.sources - array with the src/app that created each quantity
 	 		// res.quantityType - the type of the query 
       }else{
       		// Something has gone wrong
       }
	));
 
---- 
**Save a workout**


Workout object for saving a workout to Healthkit

	var Workout = function(calories, distance, startDate, endDate, HKWorkoutActivityTypes){
        this.calories   = calories;
        this.distance   = distance;
        this.startDate  = startDate;
        this.endDate    = endDate;
        this.HKWorkoutActivityTypes = HKWorkoutActivityTypes;
	};


Constructs ordinary JavaScript date object to use with workout

    startDate = new Date(); 
    startDate.setHours(00);
    endDate = new Date();


Sample workout 

    var workout = new Workout(500, 2000, startDate, endDate, "HKWorkoutActivityTypes");


Saves a workout. 

	mod.saveWorkout(workout, function(res){
		if (res.success == 1){
			// workout was saved correctly
		}else{
			// something went wrong, possibly due to no write permission 
		}
	});

-----
### **Misc**


Javascript Support functions 

	function xcodeDate(d){
        return d.getFullYear() + "-" + (d.getMonth() + 1) + "-" + d.getDate() + " " + d.getHours() + ":" + d.getMinutes() + ":" + d.getSeconds();
	}


Cheers!
