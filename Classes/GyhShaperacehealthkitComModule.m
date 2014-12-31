/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "GyhShaperacehealthkitComModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

@interface GyhShaperacehealthkitComModule()

@property (nonatomic) HKHealthStore *healthStore;
@property (nonatomic) HKObserverQueryCompletionHandler compl;
@property (nonatomic) NSString* url;

struct stepsResults{
    int todayStepsCount;
    int yesterDayStepsCount;
};

@end


@implementation GyhShaperacehealthkitComModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"6ddb2898-e08e-4943-ba68-4f8dbdf85b0a";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"gyh.shaperacehealthkit.com";
}

#pragma mark Lifecycle



-(void)startup
{
    [super startup];

    // this method is called when the module is first loaded
    // you *must* call the superclass
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added 
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs




// START main API functions

-(id)init:(id)args
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil]];
    }
    
    NSLog(@"SHAPERACE LOG: Init method");
    
    NSDictionary* params = [args objectAtIndex:0];
    self.url = [[NSString alloc] initWithString:[params objectForKey:@"url"]];
    
    [self observeSteps];
    [self enableBackgroundDeliverySteps];
    
    [self executeTitaniumCallback:args withResult:@{@"success" :[NSNumber numberWithBool:1]}];
}


-(void) authorize:(id)args
{
    self.healthStore = [[HKHealthStore alloc] init];
    
    NSMutableSet* writeTypes = [self getTypes:[args objectAtIndex:0]];
    NSMutableSet* readTypes = [self getTypes:[args objectAtIndex:1]];
     NSDictionary* params = [args objectAtIndex:2];
    
    [self.healthStore requestAuthorizationToShareTypes: writeTypes
                                             readTypes: readTypes
                                            completion:^(BOOL success, NSError *error) {
                                                NSLog(@"SHAPERACE LOG: authorize method with error = %@", error);
                                                
                                                self.url = [[NSString alloc] initWithString:[params objectForKey:@"url"]];
                                                
                                                //      dispatch_async(dispatch_get_main_queue(), ^{
                                                [self observeSteps];
                                                [self enableBackgroundDeliverySteps];
                                                [self executeTitaniumCallback:args withResult:@{@"success" :[NSNumber numberWithBool:success]}];
                                                
                                                //     });
                                            }];
}


-(void) controlPermissions:(id)args{
    
    __block bool isAuthorized = true;
    if (![HKHealthStore isHealthDataAvailable]) isAuthorized = false;
    
    NSMutableSet* writeTypes = [self getTypes:[args objectAtIndex:0]];
    NSMutableSet* authorizedWriteTypes = [self authorizedWriteTypes:[args objectAtIndex:0]];
    NSMutableSet* readTypes = [self getTypes:[args objectAtIndex:1]];
    
    if ([writeTypes count] != [authorizedWriteTypes count]) isAuthorized = false;
    
    [self authorizedReadTypes:[args objectAtIndex:1] completion:^(NSMutableSet * authorizedReadTypes) {
        if ([readTypes count] != [authorizedReadTypes count]) isAuthorized = false;
        
         NSLog(@"SHAPERACE LOG: controlpermisson method");
        
        [self executeTitaniumCallback:args withResult:@{@"success" :[NSNumber numberWithBool:isAuthorized]}];
    }];
}


-(id)isSupported:(id)args{
    return [NSNumber numberWithBool:[HKHealthStore isHealthDataAvailable]];
}

// END main API functions




// START steps background activity functions

-(void)enableBackgroundDeliverySteps{
    [self.healthStore enableBackgroundDeliveryForType: [HKQuantityType quantityTypeForIdentifier: HKQuantityTypeIdentifierStepCount] frequency:HKUpdateFrequencyImmediate withCompletion:^(BOOL success, NSError *error) {
         NSLog(@"SHAPERACE LOG: enableBackgroundDelveriySteps method with error = %@", error);
    }];
}


-(void) disableBackgroundDeliverySteps:(id)args{
    [self.healthStore disableBackgroundDeliveryForType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount] withCompletion:^(BOOL success, NSError *error) {
        [self executeTitaniumCallback:args withResult:@{@"success" :[NSNumber numberWithBool:success]}];
    }];
}


-(void) observeSteps{
    
    HKSampleType *quantityType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    HKObserverQuery *query =
    [[HKObserverQuery alloc]
     initWithSampleType:quantityType
     predicate:nil
     updateHandler:^(HKObserverQuery *query,
                     HKObserverQueryCompletionHandler completionHandler,
                     NSError *error) {
          NSLog(@"SHAPERACE LOG: observeSteps method with error = %@", error);
         [self getSteps:completionHandler];
         
     }];
    [self.healthStore executeQuery:query];
}



-(void) getSteps:(HKObserverQueryCompletionHandler) completionHandler{
    
    NSInteger limit = 0;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *now = [NSDate date];
    
    NSDate *toDate = [NSDate date]; //
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    
    NSDateComponents *comps = [calendar components:unitFlags fromDate:toDate];
    comps.hour   = 00;
    comps.minute = 00;
    comps.second = 01;
    NSDate *tmpFromDate = [calendar dateFromComponents:comps];
    NSDate* fromDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:tmpFromDate options:0];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:fromDate endDate:toDate options:HKQueryOptionNone];
    NSString *endKey =  HKSampleSortIdentifierEndDate;
    NSSortDescriptor *endDateSort = [NSSortDescriptor sortDescriptorWithKey: endKey ascending: NO];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType: [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]
                                                           predicate: predicate
                                                               limit: limit
                                                     sortDescriptors: @[endDateSort]
                                                      resultsHandler:^(HKSampleQuery *query, NSArray* results, NSError *error){
                                                           NSLog(@"SHAPERACE LOG: getSteps method with error = %@", error);
                                                          [self sendStepsData: results];
                                                          if (completionHandler) completionHandler();
                                                          
                                                      }];
    [self.healthStore executeQuery:query];
}

// END steps background activity functions




// START sending steps related functions


-(void) sendStepsData: (NSArray*) results{
    
    struct stepsResults preparedResults = [self prepareStepsResultForTransmission:results];
    
    NSDate* now = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp = [calendar components:unitFlags fromDate:now];
    
    NSString* dateAsString = [NSString stringWithFormat:@"%li-%li-%li", (long)comp.year, (long)comp.month, (long)comp.day];
    
    NSString* parameters = [NSString stringWithFormat:@"&date=%@&steps=%i&steps_yesterday=%i", dateAsString, preparedResults.todayStepsCount, preparedResults.yesterDayStepsCount];
    
    NSString* addr = [self.url stringByAppendingString: parameters];
    
    UILocalNotification *notification=[UILocalNotification new];
    notification.fireDate=[NSDate dateWithTimeIntervalSinceNow:1];
    notification.alertBody= self.url;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:addr]];
    
    [request setHTTPMethod:@"GET"];
    
     NSLog(@"SHAPERACE LOG: sendStepsData method");
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
}



-(struct stepsResults) prepareStepsResultForTransmission:(NSArray*)results{
    
    struct stepsResults stepsRes;
    stepsRes.todayStepsCount = 0;
    stepsRes.yesterDayStepsCount = 0;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *now = [NSDate date];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    
    NSDateComponents *comps = [calendar components:unitFlags fromDate:now];
    comps.hour   = 23;
    comps.minute = 59;
    comps.second = 59;
    NSDate *tmpFromDate = [calendar dateFromComponents:comps];
    NSDate* fromDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:tmpFromDate options:0];
    
    for (HKQuantitySample *sample in results) {
        NSComparisonResult compareResult = [sample.startDate compare:fromDate];
        
     //   if ([sample.source.bundleIdentifier isEqualToString:@"com.apple.Health"]) continue;
        if (compareResult == NSOrderedDescending)
            stepsRes.todayStepsCount += [sample.quantity doubleValueForUnit:[HKUnit countUnit]];
        else
            stepsRes.yesterDayStepsCount += [sample.quantity doubleValueForUnit:[HKUnit countUnit]];
    }
    return stepsRes;
}


// END sending steps related functions





// START database interactions functions

-(void) getQuantityResult:(id)args{
    NSDictionary* queryObj = [args objectAtIndex:0];
    NSInteger limit = [queryObj objectForKey:@"limit"];
    NSDictionary* predicateDict = [queryObj objectForKey:@"predicate"];
    NSPredicate* predicate = nil;
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:[queryObj objectForKey:@"quantityType"]];
    
    if ([predicateDict objectForKey:@"datePredicate"] != nil)
        predicate = [self datePredicate:[predicateDict objectForKey:@"datePredicate"]];
    
    NSString *endKey =  HKSampleSortIdentifierEndDate;
    NSSortDescriptor *endDate = [NSSortDescriptor sortDescriptorWithKey: endKey ascending: NO];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType: quantityType
                                                           predicate: predicate
                                                               limit: limit
                                                     sortDescriptors: @[endDate]
                                                      resultsHandler:^(HKSampleQuery *query, NSArray* results, NSError *error){
                                                          
                                                          //    dispatch_async(dispatch_get_main_queue(), ^{
                                                          
   
                                                              bool success = (error == nil) ? true : false;
                                                              NSDictionary *res;
                                                              
                                                              if ([results lastObject] != nil && success){
                                                                  HKQuantitySample* sample = [results lastObject];
                                                                  HKSource* source = sample.source;
                                                                  
                                                                  res = @{
                                                                           @"quantities" : [self resultAsNumberArray:results],
                                                                           @"quantityType" : sample.quantityType,
                                                                           @"sources" : [self resultAsSourceArray:results],
                                                                           @"success" :[NSNumber numberWithBool: success]
                                                                           
                                                                           };
                                                              } else{
                                                                  res = @{
                                                                           @"quantities" : @"",
                                                                           @"quantityType" : @"",
                                                                           @"sources" : @"",
                                                                           @"success" :[NSNumber numberWithBool: success]
                                                                           
                                                                           };
                                                              }
                                                              [self executeTitaniumCallback:args withResult:res];
                                                          
                                                          
                                                          //    });
                                                      }];
    [self.healthStore executeQuery:query];
}



-(void)saveWorkout:(id)args{
    
    if ([self.healthStore authorizationStatusForType: [HKWorkoutType workoutType]] != HKAuthorizationStatusSharingAuthorized){
        KrollCallback* callback = [args objectAtIndex:1];
        if(callback){
            NSDictionary *dict = @{
                                   @"success": @"0"
                                   };
            NSArray* array = [NSArray arrayWithObjects: dict, nil];
            [callback call:array thisObject:nil];
        }
        return;
    }
    
    NSDictionary* props = [args objectAtIndex:0];
    NSString* strCals = [props objectForKey:@"calories"];
    NSString* strDist = [props objectForKey:@"distance"];
    double cals = [strCals doubleValue];
    double dist = [strDist doubleValue];
    
    HKQuantity* burned = [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit] doubleValue:cals];
    HKQuantity* distance = [HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue: dist];
    HKWorkout* workout = [HKWorkout workoutWithActivityType:[props objectForKey:@"HKWorkoheutActivityType"]
                                                  startDate:[self NSDateFromJavaScriptString:[props objectForKey:@"startDate"]]
                                                    endDate:[self NSDateFromJavaScriptString:[props objectForKey:@"endDate"]]
                                                   duration:[[NSDate date] timeIntervalSinceNow]
                                          totalEnergyBurned:burned
                                              totalDistance:distance metadata:nil];
    
    [self.healthStore saveObject:workout withCompletion:^(BOOL success, NSError *error) {
        
        NSArray* intervals =                    [[NSArray alloc] initWithObjects:[NSDate dateWithTimeIntervalSinceNow: -1200], [NSDate date], nil];
        NSMutableArray *samples =               [NSMutableArray array];
        HKQuantityType *energyBurnedType =      [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierActiveEnergyBurned];
        //     HKQuantity *energyBurnedPerInterval =   [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit] doubleValue:15.5];
        
        HKQuantitySample *energyBurnedPerIntervalSample = [HKQuantitySample quantitySampleWithType: energyBurnedType
                                                                                          quantity: [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit] doubleValue:cals]
                                                                                         startDate: intervals[0]
                                                                                           endDate: intervals[1]];
        [samples addObject:energyBurnedPerIntervalSample];
        
        [self.healthStore
         addSamples:samples
         toWorkout:workout
         completion:^(BOOL success, NSError *error) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self executeTitaniumCallback:args withResult:@{@"success" :[NSNumber numberWithBool:success]}];
             });
         }];
    }];
}



-(void)getWorkout:(id)args{
    
    HKWorkoutType *workouts = [HKWorkoutType workoutType ];
    NSString *endKey =  HKSampleSortIdentifierEndDate;
    NSSortDescriptor *endDate = [NSSortDescriptor sortDescriptorWithKey: endKey ascending: NO];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType: workouts
                                                           predicate:nil
                                                               limit:1
                                                     sortDescriptors: @[endDate]
                                                      resultsHandler:^(HKSampleQuery *query, NSArray* results, NSError *error){
                                                          
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              HKWorkout *sample = [results lastObject];
                                                              
                                                              // krashar appen ibland om nil
                                                              HKQuantity *d = sample.workoutActivityType;
                                                              int d1 = [d doubleValueForUnit:HKUnit.countUnit];
                                                              
                                                              [self executeTitaniumCallback:args withResult:@{@"success" :[NSNumber numberWithBool:1]}];
                                                              
                                                          });
                                                      }];
    [self.healthStore executeQuery:query];
}



// END database interactions functions





// START general helper functions


-(NSDate*) NSDateFromJavaScriptString:(NSString*) dateStr{
    NSTimeZone *currentDateTimeZone = [NSTimeZone defaultTimeZone];
    NSDateFormatter *currentDateFormat = [[NSDateFormatter alloc]init];
    [currentDateFormat setTimeZone:currentDateTimeZone];
    [currentDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [currentDateFormat dateFromString:dateStr];
}


-(NSPredicate*) datePredicate:(NSArray*) array{
    NSDate *startDate = [self NSDateFromJavaScriptString:[array objectAtIndex:0]];
    NSDate *endDate = [self NSDateFromJavaScriptString:[array objectAtIndex:1]];

    return [NSPredicate predicateWithFormat:@"startDate >= %@ AND endDate <= %@", startDate, endDate];
}


-(NSMutableArray*)resultAsNumberArray:(NSArray*)result{
    NSMutableArray* numberArray = [[NSMutableArray alloc] init];
    
    for (HKQuantitySample* sample in result){
        [numberArray addObject:[NSNumber numberWithInt:[sample.quantity doubleValueForUnit:[HKUnit countUnit]]]];
    }
    return numberArray;
}


-(NSMutableArray*)resultAsSourceArray:(NSArray*)result{
    NSMutableArray* sourceArray = [[NSMutableArray alloc] init];
    
    for (HKQuantitySample* sample in result){
        [sourceArray addObject: sample.source.bundleIdentifier];
    }
    return sourceArray;
}

-(void) executeTitaniumCallback:(id)args withResult: (NSDictionary*) res{
    
    KrollCallback* callback = [[KrollCallback alloc] init];
    int i = 0;
    while (i < [args count] ){
        if([[args objectAtIndex:i] isKindOfClass:[KrollCallback class]]){
            callback = [args objectAtIndex:i];
            break;
        }
        i++;
    }
    if (callback){
        NSArray* array = [NSArray arrayWithObjects: res, nil];
        [callback call:array thisObject:nil];
    }
}



// END general helper functions



// START check permissions for write types

-(NSMutableSet*) authorizedWriteCategoryTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    
    for (NSString* type in types){
        if ([self.healthStore authorizationStatusForType: [HKQuantityType categoryTypeForIdentifier: type]] == HKAuthorizationStatusSharingAuthorized){
            [set addObject:type];
        }
    }
    return set;
}


-(NSMutableSet*) authorizedWriteCharacteristicTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
   
    for (NSString* type in types){
        if ([self.healthStore authorizationStatusForType: [HKCharacteristicType characteristicTypeForIdentifier: type]] == HKAuthorizationStatusSharingAuthorized){
            [set addObject:type];
        }
    }
    return set;
}


-(NSMutableSet*) authorizedWriteCorrelationTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    
    for (NSString* type in types){
        if ([self.healthStore authorizationStatusForType: [HKQuantityType correlationTypeForIdentifier: type]] == HKAuthorizationStatusSharingAuthorized){
            [set addObject:type];
        }
    }
    return set;
}


-(NSMutableSet*) authorizedWriteQuantityTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    
    for (NSString* type in types){
        if ([self.healthStore authorizationStatusForType: [HKQuantityType quantityTypeForIdentifier: type]] == HKAuthorizationStatusSharingAuthorized){
            [set addObject:type];
        }
    }
    return set;
}


-(NSMutableSet*) authorizedWriteWorkoutTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    for (NSString* type in types){
        if ([self.healthStore authorizationStatusForType: [HKWorkoutType workoutType]] == HKAuthorizationStatusSharingAuthorized){
            [set addObject:type];
        }
    }
    return set;
}


-(NSMutableSet*) authorizedWriteTypes:(NSDictionary*) types{
    NSMutableSet* set = [[NSMutableSet alloc] init];
    
    [set unionSet: [self authorizedWriteCategoryTypes:[types objectForKey:@"HKCategoryType"]]];
    [set unionSet: [self authorizedWriteCharacteristicTypes:[types objectForKey:@"HKCharacteristicType"]]];
    [set unionSet: [self authorizedWriteCorrelationTypes:[types objectForKey:@"HKCorrelationType"]]];
    [set unionSet: [self authorizedWriteQuantityTypes:[types objectForKey:@"HKQuantityType"]]];
    [set unionSet: [self authorizedWriteWorkoutTypes:[types objectForKey:@"HKWorkoutType"]]];
    
    return set;
}

// END check permissions for write types


// START check permissions for read types

-(void) authorizedReadCategoryTypes:(NSArray*) types completion: (void (^)(NSMutableSet*))completion{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    if ([types count] == 0) completion(set);
        for (NSString* type in types){
            [self readDataAvailableForType:@"HKCategoryType" WithIdentifier:type completion:^(bool successful) {
                if (successful) [set addObject:type];
                if ([type isEqualToString: [types lastObject]]) completion(set);
            }];
        }
}



-(void) authorizedReadCharacteristicTypes:(NSArray*) types completion: (void (^)(NSMutableSet*))completion{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    if ([types count] == 0) completion(set);
        for (NSString* type in types){
            [self readDataAvailableForType:@"HKCharacteristicType" WithIdentifier:type completion:^(bool successful) {
                if (successful) [set addObject:type];
                if ([type isEqualToString: [types lastObject]]) completion(set);
            }];
        }
}


-(void) authorizedReadCorrelationTypes:(NSArray*) types completion: (void (^)(NSMutableSet*))completion{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    if ([types count] == 0) completion(set);
        for (NSString* type in types){
            [self readDataAvailableForType:@"HKCorrelationType" WithIdentifier:type completion:^(bool successful) {
                if (successful) [set addObject:type];
                if ([type isEqualToString: [types lastObject]]) completion(set);
            }];
        }
}



-(void) authorizedReadQuantityTypes:(NSArray*) types completion: (void (^)(NSMutableSet*))completion{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    if ([types count] == 0) completion(set);
    for (NSString* type in types){
        [self readDataAvailableForType:@"HKQuantityType" WithIdentifier:type completion:^(bool successful) {
            if (successful) [set addObject:type];
            if ([type isEqualToString: [types lastObject]]) completion(set);
        }];
    }
    
}


-(void) authorizedReadWorkoutTypes:(NSArray*) types completion: (void (^)(NSMutableSet*))completion{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    if ([types count] == 0) completion(set);
        for (NSString* type in types){
            [self readDataAvailableForType:@"HKWorkoutType" WithIdentifier:type completion:^(bool successful) {
                if (successful) [set addObject:type];
                if ([type isEqualToString: [types lastObject]]) completion(set);
            }];
        }
}


-(void) readDataAvailableForType: (NSString*)type WithIdentifier: (NSString*)identifier completion: (void (^)(bool))completion{
    
    NSMutableArray* sampleType = [[NSMutableArray alloc] init];
    
    if ([type isEqualToString:@"HKCharacteristicType"]){
        completion([HKCharacteristicType characteristicTypeForIdentifier:identifier] != 0);
        return;
    }
    
    if ([type isEqualToString:@"HKCategoryType"]) [sampleType addObject: [HKCategoryType categoryTypeForIdentifier: identifier]];
    else if ([type isEqualToString:@"HKCorrelationType"]) [sampleType addObject: [HKCorrelationType correlationTypeForIdentifier: identifier]];
    else if ([type isEqualToString:@"HKQuantityType"]) [sampleType addObject: [HKQuantityType quantityTypeForIdentifier: identifier]];
    else if ([type isEqualToString:@"HKWorkoutType"]) [sampleType addObject: [HKWorkoutType workoutType]];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType: [sampleType firstObject]
                                                           predicate: nil
                                                               limit: 1
                                                     sortDescriptors: nil
                                                      resultsHandler:^(HKSampleQuery *query, NSArray* results, NSError *error){
                                                          
                                                          if (completion) completion([results lastObject] != nil);

                                                      }];
    [self.healthStore executeQuery:query];
}


-(void) authorizedReadTypes:(NSDictionary*) types completion: (void (^)(NSMutableSet*))completion{
    NSMutableSet* set = [[NSMutableSet alloc] init];
    __block int returnedSets = 0;
    
    [self authorizedReadCategoryTypes:[types objectForKey:@"HKCategoryType"] completion:^(NSMutableSet * resultSet) {
        [set unionSet: resultSet];
        if (++returnedSets == 5) completion(set);
    }];
    
    [self authorizedReadCharacteristicTypes:[types objectForKey:@"HKCharacteristicType"] completion:^(NSMutableSet * resultSet) {
        [set unionSet: resultSet];
        if (++returnedSets == 5) completion(set);
    }];
    
    [self authorizedReadCorrelationTypes:[types objectForKey:@"HKCorrelationType"] completion:^(NSMutableSet * resultSet) {
        [set unionSet: resultSet];
        if (++returnedSets == 5) completion(set);
    }];
    
    [self authorizedReadQuantityTypes:[types objectForKey:@"HKQuantityType"] completion:^(NSMutableSet * resultSet) {
        [set unionSet: resultSet];
        if (++returnedSets == 5) completion(set);
    }];
    
    [self authorizedReadWorkoutTypes:[types objectForKey:@"HKWorkoutType"] completion:^(NSMutableSet * resultSet) {
        [set unionSet: resultSet];
        if (++returnedSets == 5) completion(set);
    }];
}

// END check permissions for read types





// START extract types from JS-object

-(NSMutableSet*) categoryTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    for (int i = 0; i < types.count; i++) [set addObject:[HKObjectType categoryTypeForIdentifier:types[i]]];
    return set;
}

-(NSMutableSet*) charateristicsTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    for (int i = 0; i < types.count; i++) [set addObject:[HKObjectType characteristicTypeForIdentifier:types[i]]];
    return set;
}

-(NSMutableSet*) correlationTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    for (int i = 0; i < types.count; i++) [set addObject:[HKObjectType correlationTypeForIdentifier:types[i]]];
    return set;
}

-(NSMutableSet*) quantityTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    for (int i = 0; i < types.count; i++) [set addObject:[HKObjectType quantityTypeForIdentifier:types[i]]];
    return set;
}

-(NSMutableSet*) workoutTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    if (types.count > 0)
        [set addObject:[HKObjectType workoutType]];
    return set;
}

-(NSMutableSet*) getTypes:(NSDictionary*) types{
    NSMutableSet* set = [[NSMutableSet alloc] init];
    
    [set unionSet: [self categoryTypes:[types objectForKey:@"HKCategoryType"]]];
    [set unionSet: [self charateristicsTypes:[types objectForKey:@"HKCharacteristicType"]]];
    [set unionSet: [self correlationTypes:[types objectForKey:@"HKCorrelationType"]]];
    [set unionSet: [self quantityTypes:[types objectForKey:@"HKQuantityType"]]];
    [set unionSet: [self workoutTypes:[types objectForKey:@"HKWorkoutType"]]];
    
    return set;
}


// END extract types from JS-object





// START out commented
/*
 
 -(void)enableBackgroundDeliveryForQuantityType:(id)args{
 [self.healthStore enableBackgroundDeliveryForType: [HKQuantityType quantityTypeForIdentifier: [args objectAtIndex:0]] frequency:[args objectAtIndex:1] withCompletion:^(BOOL success, NSError *error) {
 
 //   dispatch_async(dispatch_get_main_queue(), ^{
 
 KrollCallback* callback = [args objectAtIndex:2];
 if(callback){
 NSDictionary *res = @{
 @"success" :[NSNumber numberWithBool:success]
 };
 NSArray* array = [NSArray arrayWithObjects: res, nil];
 [callback call:array thisObject:nil];
 }
 //  });
 }];
 }
 */

/*
 -(void) controlPermissions:(id)args{
 
 bool isAuthorized = true;
 if (![HKHealthStore isHealthDataAvailable]) isAuthorized = false;
 
 // [self readDataAvailableForType:@"" WithIdentifier:@""];
 
 NSMutableSet* writeTypes = [self getTypes:[args objectAtIndex:0]];
 NSMutableSet* authorizedWriteTypes = [self authorizedWriteTypes:[args objectAtIndex:0]];
 NSMutableSet* readTypes = [self getTypes:[args objectAtIndex:1]];
 //NSMutableSet* authorizedReadTypes = [self authorizedReadTypes:[args objectAtIndex:1]];
 
 [self authorizedReadTypes:[args objectAtIndex:1]completion:^(NSMutableSet* authorizedReadTypes) {
 
 }];
 
 NSDictionary* params = [args objectAtIndex:2];
 
 
 if ([writeTypes count] != [authorizedWriteTypes count]) isAuthorized = false;
 
 
 [self stepDataAvailable:args currentState: isAuthorized];
 }

 
-(bool) stepDataAvailable: (id) args currentState: (bool) state{
    
    __block BOOL _state = state;
    
    NSString *endKey =  HKSampleSortIdentifierEndDate;
    NSSortDescriptor *endDateSort = [NSSortDescriptor sortDescriptorWithKey: endKey ascending: NO];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType: [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]
                                                           predicate: nil
                                                               limit: 0
                                                     sortDescriptors: @[endDateSort]
                                                      resultsHandler:^(HKSampleQuery *query, NSArray* results, NSError *error){
                                                          if (_state == true)
                                                              _state = [results lastObject] != nil ? true : false;
                                                          
                                                          KrollCallback* callback = [args objectAtIndex:2];
                                                          if(callback){
                                                              NSDictionary *res = @{
                                                                                    @"success" :[NSNumber numberWithBool:_state]
                                                                                    };
                                                              NSArray* array = [NSArray arrayWithObjects: res, nil];
                                                              [callback call:array thisObject:nil];
                                                          }
                                                      }];
    [self.healthStore executeQuery:query];
    
}



-(void) observeQuantityType:(id)args{
    
    NSDictionary* queryObj = [args objectAtIndex:0];
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:[queryObj objectForKey:@"quantityType"]];
    
    HKObserverQuery *query =
    [[HKObserverQuery alloc]
     initWithSampleType: quantityType
     predicate: nil
     updateHandler:^(HKObserverQuery *query,
                     HKObserverQueryCompletionHandler completionHandler,
                     NSError *error) {
         //   dispatch_async(dispatch_get_main_queue(), ^{
         
         //  bool success = (error == nil) ? true : false;
         self.compl = completionHandler;
         
         // if (!error) [self getQuantityResult:args withCompletion:completionHandler];
         //     });
     }];
    [self.healthStore executeQuery:query];
}
*/

// END out commented


@end

