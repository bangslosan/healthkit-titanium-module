/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "HealthkitModuleModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#include "TiApp.h"
#import "AAPLProfileViewController.h"




@interface HealthkitModuleModule()

@property (nonatomic) HKHealthStore *healthStore;

@end

@implementation HealthkitModuleModule


#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{

	return @"ed03bc0b-18de-4ab6-a392-b15d81a9db68";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"healthkitModule";
}

#pragma mark Lifecycle

-(NSArray*)getPermisssions{
    
    NSArray* a = [NSArray init];
    
    return a;
}



- (NSSet *)dataTypesToWrite {

    HKQuantityType *workoutType = [HKObjectType quantityTypeForIdentifier:HKWorkoutTypeIdentifier];
    HKQuantityType *steps = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    return [NSSet setWithObjects: steps, workoutType, nil];
}

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead {
 
    HKQuantityType *workoutType = [HKObjectType quantityTypeForIdentifier:HKWorkoutTypeIdentifier];
    
    
    HKQuantityType *steps = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    return [NSSet setWithObjects:steps, workoutType, nil];
}


-(void)startup
{
    [super startup];
    
    if (![HKHealthStore isHealthDataAvailable]) return;


   
    
    
    self.healthStore = [[HKHealthStore alloc] init];
    
      [self.healthStore requestAuthorizationToShareTypes: [self dataTypesToRead] readTypes: [self dataTypesToRead] completion:^(BOOL success, NSError *error) {
        if (!success) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Permission status"
                                                            message:error.localizedDescription
                                                           delegate:self cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"OK", nil];
            [alert show];

            
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Permission status"
                                                            message:@"Allowed" delegate:self cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the user interface based on the current user's health information.
           //   [[TiApp app] hideModalController: controller animated: YES];
        });
    }];

    
   
    NSArray *keys = [NSArray arrayWithObjects:@"key1", @"key2", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"value1", @"value2", nil];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects
                                                           forKeys:keys];
    
    
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

-(id)example:(id)args
{
	// example method
	return @"hello world example method";
}


-(NSString *)stringify:(id)args {
    
    __block NSString *data = nil;
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        data = [args objectAtIndex:0];
    });
    
    return data;
}


-(id)exampleProp
{
	// example property getter
	//return @"returned from module method EXAMPLEPROP";
}

-(void)setExampleProp:(id)value
{
	// example property setter
}

@end
