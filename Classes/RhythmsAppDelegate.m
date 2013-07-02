//
//  RhythmsAppDelegate.m
//  Rhythms
//
//  Created by Julio Barros on 7/16/08.
//  Copyright E-String Technologies, Inc. 2008. All rights reserved.
//

#import "RhythmsAppDelegate.h"
#import "UserListController.h"
#import "GameController.h"
#import "IntroController.h"
#import "RhythmEngine.h"
#import "Rhythm.h"
#import "Level.h"
#import	"Stage.h"
#import "ModelConstants.h"
#import "User.h"
#import "UpdateChecker.h"

#define unless(stmt) if(!(stmt))

@implementation RhythmsAppDelegate

@synthesize window;

@synthesize rhythmEngine;

-(void) populateDabaseIfNeeded{

	if ([[Rhythm findAll] count])
		return;
	
	NSLog(@"No rhythms found. Populating databse");

	NSString *dataPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"rhythm_data"];
	NSLog(@"dataPath = %@",dataPath);
	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *rhythmDirs = [fileManager contentsOfDirectoryAtPath:dataPath error:NULL];
	for (NSString *rhythmDir in rhythmDirs){
		NSLog(@"Potential rhythm: %@",rhythmDir);
		Rhythm *rhythm = [[Rhythm alloc] init];
		[rhythm setAttributeNamed:kName value:[rhythmDir stringByReplacingOccurrencesOfString:@"-" withString:@"/"]];
		[rhythm setAttributeNamed:kDirectoryName value:rhythmDir];
		[rhythm save];
		NSLog(@"Created rhythm: %@",rhythm);
		NSString *rhythmPath = [dataPath stringByAppendingPathComponent:rhythmDir];        
        NSArray *levels = [fileManager contentsOfDirectoryAtPath:rhythmPath error:NULL];
		for (NSString *levelDir in levels){
			NSLog(@"Looking at level: %@",levelDir);
			Level *level = [[Level alloc] init];
			NSRange evelPos = [levelDir rangeOfString:@"evel_"];
			NSString *levelName = [levelDir	substringFromIndex:(evelPos.location + evelPos.length)];
			[level setAttributeNamed:kName	value:levelName];
			[level setAttributeNamed:kDirectoryName	value:levelDir];
			[level setAttributeNamed:kRhythmId value:[NSNumber numberWithInt:[rhythm primaryKey]]];
			
			NSString *infoPath = [[rhythmPath stringByAppendingPathComponent:levelDir] stringByAppendingPathComponent:@"info"];
			NSLog(@"***** Looking for info at %@",infoPath);
			NSString *description = [NSString stringWithContentsOfFile:infoPath encoding:NSASCIIStringEncoding error:NULL];
			if (description != nil){
				[level setAttributeNamed:kDescription value:description];
			}
			
			[level save];
			NSLog(@"Created level: %@",level);
			
			NSString *stagePath = [rhythmPath stringByAppendingPathComponent:levelDir];
			NSArray *stages = [fileManager contentsOfDirectoryAtPath:stagePath error:NULL];
            
			for (NSString *stageFile in stages){
				NSLog(@"Looking at stage: %@",stageFile);
				if (![stageFile hasSuffix:@".gif"])
					continue;
				stageFile = [stageFile stringByReplacingOccurrencesOfString:@".gif" withString:@""];
				NSLog(@"Stagefile is now: %@",stageFile);
				Stage *stage = [[Stage alloc] init];
				[stage setAttributeNamed:kName value:stageFile];
				[stage setAttributeNamed:kFileName value:stageFile];
				[stage setAttributeNamed:kLevelId value:[NSNumber numberWithInt:[level primaryKey]]];
				NSLog(@"about to save stage");
				[stage save];
				NSLog(@"Created stage: %@ %@",stage);
				[stage release];
			}
			[level release];
		}
		[rhythm release];
	}
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	srandom(time(NULL));
	self.rhythmEngine = [[[RhythmEngine alloc] init] autorelease];
	
	/* These were used during testing only to get a feeling for good values
	double maxDiffAtStart = [[NSUserDefaults standardUserDefaults] doubleForKey:kMaxDiffAtStart];
	double minPercentageForStop = [[NSUserDefaults standardUserDefaults] doubleForKey:kMinPercentageForStop];
	
	if (maxDiffAtStart > 0 && minPercentageForStop > 0){
		rhythmEngine.maxDiffAtStart = maxDiffAtStart;
		rhythmEngine.minPercentageForStop = minPercentageForStop;
	}
	 */
	
	int selectedSpeed = [[NSUserDefaults standardUserDefaults] integerForKey:kSelectedSpeed];
	if (selectedSpeed != 0)
		[rhythmEngine setSpeedAndBPM:selectedSpeed];
	

	bool standardCountdown = YES;
	id exists = [[NSUserDefaults standardUserDefaults] objectForKey:kStandardCountdown];
	if (exists != nil)
		standardCountdown = [[NSUserDefaults standardUserDefaults] boolForKey:kStandardCountdown];
	rhythmEngine.standardCountDown = standardCountdown;
	
	int difficulty = [[NSUserDefaults standardUserDefaults] integerForKey:kDifficulty];
	rhythmEngine.difficulty = difficulty;
	
	[self populateDabaseIfNeeded];
   
   unless ([User count]) {
      User *user = [[User alloc] init];
      [user setAttributeNamed:kUserName value: @"You"];
      [user save];         
      [user release];
   }
		
	[window addSubview:navigationController.view];
    [window makeKeyAndVisible];
    
    [[UpdateChecker instance] startCheck];
}

- (void)dealloc {
	self.rhythmEngine = nil;
    [UpdateChecker release_instance];
	[window release];
	[super dealloc];
}


@end
