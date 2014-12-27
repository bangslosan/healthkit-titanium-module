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


-(id)init:(id)args
{
    self.healthStore = [[HKHealthStore alloc] init];
    
    NSMutableSet* writeTypes = [self getTypes:[args objectAtIndex:0]];
    NSMutableSet* readTypes = [self getTypes:[args objectAtIndex:1]];
    
    [self.healthStore requestAuthorizationToShareTypes: writeTypes
                                             readTypes: readTypes
                                            completion:^(BOOL success, NSError *error) {
                                                
                                          //      dispatch_async(dispatch_get_main_queue(), ^{
                
                                                    KrollCallback* callback = [args objectAtIndex:2];
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

