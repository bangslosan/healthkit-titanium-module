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

-(NSMutableSet*) getTypes:(NSDictionary*) dict{
    NSMutableSet* set = [[NSMutableSet alloc] init];
    
    [set unionSet: [self categoryTypes:[dict objectForKey:@"HKCategoryType"]]];
    [set unionSet: [self charateristicsTypes:[dict objectForKey:@"HKCharacteristicType"]]];
    [set unionSet: [self correlationTypes:[dict objectForKey:@"HKCorrelationType"]]];
    [set unionSet: [self quantityTypes:[dict objectForKey:@"HKQuantityType"]]];
    [set unionSet: [self workoutTypes:[dict objectForKey:@"HKWorkoutType"]]];
    
    return set;
}




// OVAN ÄR KLART
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

-(id)init:(id)args
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil]];
    }
    
    self.healthStore = [[HKHealthStore alloc] init];
    
    NSMutableSet* writeTypes = [self getTypes:[args objectAtIndex:0]];
    NSMutableSet* readTypes = [self getTypes:[args objectAtIndex:1]];
    self.url = [args objectAtIndex:2];
    
    [self.healthStore requestAuthorizationToShareTypes: writeTypes
                                             readTypes: readTypes
                                            completion:^(BOOL success, NSError *error) {
                                                
                                          //      dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                [self observeSteps];
                                                [self enableBackgroundDeliveryForQuantityType];
                
                                                    KrollCallback* callback = [args objectAtIndex:3];
                                                    if(callback){
                                                        
                                                        NSDictionary *res = @{
                                                                               @"success" :[NSNumber numberWithBool:success]
                                                                               };
                                                        NSArray* array = [NSArray arrayWithObjects: res, nil];
                                                        [callback call:array thisObject:nil];
                                                    }
                                           //     });
                                            }];
}


-(id)isSupported:(id)args{
    return [NSNumber numberWithBool:[HKHealthStore isHealthDataAvailable]];
}


-(void) sendData: (NSArray*) results{
    
    struct stepsResults preparedResults = [self prepareStepsResult:results];
    
    NSDate* now = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp = [calendar components:unitFlags fromDate:now];
    
    NSString* dateAsString = [NSString stringWithFormat:@"%li-%li-%li", (long)comp.year, (long)comp.month, (long)comp.day];
    
    NSString* addr = [NSString stringWithFormat: [self url], preparedResults.todayStepsCount, preparedResults.yesterDayStepsCount, dateAsString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL
                                                 URLWithString:addr]];
    
    [request setHTTPMethod:@"GET"];
    // [request setValue:@"text/xml" forHTTPHeaderField:@"Content-type"];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    //   [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}




-(void) setTypes
{
    self.healthStore = [[HKHealthStore alloc] init];
    
    NSMutableSet* types = [[NSMutableSet alloc]init];
    [types addObject:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    
    [self.healthStore requestAuthorizationToShareTypes: types
                                             readTypes: types
                                            completion:^(BOOL success, NSError *error) {
                                                if (error == nil) {
                                                    
                                                    
                                                }
                                                else {
                                                    NSLog(@"Error=%@",error);
                                                }
                                            }];
}

-(void)enableBackgroundDeliveryForQuantityType{
    [self.healthStore enableBackgroundDeliveryForType: [HKQuantityType quantityTypeForIdentifier: HKQuantityTypeIdentifierStepCount] frequency:HKUpdateFrequencyImmediate withCompletion:^(BOOL success, NSError *error) {
        NSLog(@"Observation registered error=%@",error);
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
   
         [self getSteps:completionHandler];
         
     }];
    [self.healthStore executeQuery:query];
}

-(struct stepsResults) prepareStepsResult:(NSArray*)results{
    
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
        NSComparisonResult compateResult = [sample.startDate compare:fromDate];
        if (compateResult == NSOrderedAscending)
            stepsRes.todayStepsCount +=[sample.quantity doubleValueForUnit:[HKUnit countUnit]];
        else
            stepsRes.yesterDayStepsCount +=[sample.quantity doubleValueForUnit:[HKUnit countUnit]];
    }
    return stepsRes;
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
    
    //NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:now options:0];
    
    //NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:fromDate endDate:toDate options:HKQueryOptionNone];
    
    
    NSString *endKey =  HKSampleSortIdentifierEndDate;
    NSSortDescriptor *endDateSort = [NSSortDescriptor sortDescriptorWithKey: endKey ascending: NO];
    
    NSLog(@"Requesting step data");
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType: [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]
                                                           predicate: predicate
                                                               limit: limit
                                                     sortDescriptors: @[endDateSort]
                                                      resultsHandler:^(HKSampleQuery *query, NSArray* results, NSError *error){
                                                          
                                                          NSLog(@"Query completed. error=%@",error);
                                                          
                                                          
                                                          NSInteger totalSteps=0;
                                                          
                                                          for (HKQuantitySample *sample in results) {
                                                              totalSteps+=[sample.quantity doubleValueForUnit:[HKUnit countUnit]];
                                                          }
                                                          NSLog(@"Sending step data");
                                                          UILocalNotification *notification=[UILocalNotification new];
                                                          notification.fireDate=[NSDate dateWithTimeIntervalSinceNow:1];
                                                          notification.alertBody=[NSString stringWithFormat:@"Received step count %ld",(long)totalSteps];
                                                          [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                                                          // sends the data using HTTP
                                                              [self sendData: results];
                                                          if (completionHandler) completionHandler();
                                                          
                                                      }];
    [self.healthStore executeQuery:query];
}



/*

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
 
             if (!error) [self getQuantityResult:args withCompletion:completionHandler];
    //     });
     }];
    [self.healthStore executeQuery:query];
}


-(NSPredicate*) datePredicate:(NSArray*) array{
    NSDate *startDate = [self NSDateFromJavaScriptString:[array objectAtIndex:0]];
    NSDate *endDate = [self NSDateFromJavaScriptString:[array objectAtIndex:1]];

    return [NSPredicate predicateWithFormat:@"startDate >= %@ AND endDate <= %@", startDate, endDate];
}
*/

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




-(NSMutableSet*) authorizedCategoryTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    
    for (NSString* type in types){
        if ([self.healthStore authorizationStatusForType: [HKQuantityType categoryTypeForIdentifier: type]] == HKAuthorizationStatusSharingAuthorized){
            [set addObject:type];
        }
    }
    
    return set;
}

-(NSMutableSet*) authorizedCharateristicsTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
   
    for (NSString* type in types){
        if ([self.healthStore authorizationStatusForType: [HKQuantityType characteristicTypeForIdentifier: type]] == HKAuthorizationStatusSharingAuthorized){
            [set addObject:type];
        }
    }
    
    return set;
}

-(NSMutableSet*) authorizedCorrelationTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    
    for (NSString* type in types){
        if ([self.healthStore authorizationStatusForType: [HKQuantityType correlationTypeForIdentifier: type]] == HKAuthorizationStatusSharingAuthorized){
            [set addObject:type];
        }
    }
    
    return set;
}

-(NSMutableSet*) authorizedQuantityTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    
    for (NSString* type in types){
        if ([self.healthStore authorizationStatusForType: [HKQuantityType quantityTypeForIdentifier: type]] == HKAuthorizationStatusSharingAuthorized){
            [set addObject:type];
        }
    }
    
    return set;
}

-(NSMutableSet*) authorizedWorkoutTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    for (NSString* type in types){
        if ([self.healthStore authorizationStatusForType: [HKWorkoutType workoutType]] == HKAuthorizationStatusSharingAuthorized){
            [set addObject:type];
        }
    }
    return set;
}

-(NSMutableSet*) authorizedWriteTypes:(NSDictionary*) dict{
    NSMutableSet* set = [[NSMutableSet alloc] init];
    
    [set unionSet: [self authorizedCategoryTypes:[dict objectForKey:@"HKCategoryType"]]];
    [set unionSet: [self authorizedCharateristicsTypes:[dict objectForKey:@"HKCharacteristicType"]]];
    [set unionSet: [self authorizedCorrelationTypes:[dict objectForKey:@"HKCorrelationType"]]];
    [set unionSet: [self authorizedQuantityTypes:[dict objectForKey:@"HKQuantityType"]]];
    [set unionSet: [self authorizedWorkoutTypes:[dict objectForKey:@"HKWorkoutType"]]];
    
    return set;
}



-(void) authorize:(id)args{
    bool isAuthorized = true;
    NSMutableSet* writeTypes = [self getTypes:[args objectAtIndex:0]];
    NSMutableSet* authorizedWriteTypes = [self authorizedWriteTypes:[args objectAtIndex:0]];
    
    if ([writeTypes count] != [authorizedWriteTypes count]) isAuthorized = false;
    
    NSMutableSet* readTypes = [self getTypes:[args objectAtIndex:1]];
    
 
    
}

/*
-(void) getQuantityResult:(id)args withCompletion: (HKObserverQueryCompletionHandler) completionHandler{
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

                                                              KrollCallback* callback = [args objectAtIndex:1];
                                                              if(callback){
                                                                  bool success = (error == nil) ? true : false;
                                                                  NSDictionary *dict;
   
                                                                  if ([results lastObject] != nil && success){
                                                                      HKQuantitySample* sample = [results lastObject];
                                                                      HKSource* source = sample.source;
                                                                      
                                                                  dict = @{
                                                                                         @"quantities" : [self resultAsNumberArray:results],
                                                                                         @"quantityType" : sample.quantityType,
                                                                                         @"sources" : [self resultAsSourceArray:results],
                                                                                         @"success" :[NSNumber numberWithBool: success]
                                                                                         
                                                                                         };
                                                                  }
                                                                  else
                                                                  {
                                                                          
                                                                      dict = @{
                                                                                             @"quantities" : @"",
                                                                                             @"quantityType" : @"",
                                                                                             @"sources" : @"",
                                                                                             @"success" :[NSNumber numberWithBool: success]
                                                                                        
                                                                                             };
                                                                      }
                                                                      NSArray* array = [NSArray arrayWithObjects: dict, nil];
                                                                    [callback call:array thisObject:nil];
                                                                  }
                                                          
                                                      //    });
                                                      }];
    [self.healthStore executeQuery:query];
}


-(void)completion:(id)args{
    [self compl];
}
  */

-(NSDate*) NSDateFromJavaScriptString:(NSString*) dateStr{
    NSTimeZone *currentDateTimeZone = [NSTimeZone defaultTimeZone];
    NSDateFormatter *currentDateFormat = [[NSDateFormatter alloc]init];
    [currentDateFormat setTimeZone:currentDateTimeZone];
    [currentDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [currentDateFormat dateFromString:dateStr];
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
       
                 KrollCallback* callback = [args objectAtIndex:1];
                 if(callback){
                     NSDictionary *dict = @{
                                            @"success":[NSNumber numberWithBool:success]
                                            };
                     NSArray* array = [NSArray arrayWithObjects: dict, nil];
                     [callback call:array thisObject:nil];
                 }
             });
         }];
    }];
}



-(void)getWorkout:(id)args{
    
    HKWorkoutType *workouts = [HKObjectType workoutType ];
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
                              
                              
                              KrollCallback* callback = [args objectAtIndex:0];
                              if(callback){
                                  NSDictionary *dict = @{
                                                         @"workout" : [NSNumber numberWithInt:1]
                                                         };
                                  NSArray* array = [NSArray arrayWithObjects: dict, nil];
                                  [callback call:array thisObject:nil];
                          }
                          });
                      }];
    [self.healthStore executeQuery:query];
}



@end

