//
//  Stage.m
//  Rhythms
//
//  Created by Julio Barros on 7/16/08.
//  Copyright 2008 E-String Technologies, Inc.. All rights reserved.
//

#import "Rhythm.h"
#import "Level.h"
#import "Stage.h"
#import "Note.h"
#import "ModelConstants.h"
#import "PackDownloader.h"

@implementation Stage

@synthesize level, timingSequence, notes;

-(NSString *) getDir{
	NSString *dir = [NSString stringWithFormat:@"rhythm_data/%@/%@",
					 [level.rhythm getAttributeNamed:kDirectoryName],
					 [level getAttributeNamed:kDirectoryName]];
	return dir;
}


-(NSString*) getResourcePath: (NSString*)fileType{
    NSString *path = nil;
    
    
    if ([[self getAttributeNamed:kDownloaded] isEqual:[NSNumber numberWithInt:1]])
    {
        NSString *downloadPath = [[PackDownloader instance] defaultDownloadPath];
        NSString *levelFullName = [level getAttributeNamed:kDirectoryName];
        NSString *stageName = [self getAttributeNamed:kFileName];
        NSScanner *scanner = [[[NSScanner alloc] initWithString:levelFullName] autorelease];
        NSString* rhythmName = [[[NSString alloc] init] autorelease];
        [scanner scanUpToString:@"_" intoString:&rhythmName];
        
        path = [NSString stringWithFormat:@"%@/%@/%@/%@.%@",downloadPath,rhythmName, levelFullName, stageName, fileType];                    
        
    }else {
        path = [[NSBundle mainBundle] pathForResource:[self getAttributeNamed:kFileName] ofType:fileType inDirectory:[self getDir]];
    }
	return path;    
}

-(NSString *) getImagePath{
    return [self getResourcePath:@"gif"];
    
}


-(NSArray *) loadTimingSequence {
	if (timingSequence == nil){
        NSString *path = [self getResourcePath:@"txt"];

		NSString *timingString = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:NULL];
		timingString = [timingString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
		timingString = [timingString stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
		timingString = [timingString stringByReplacingOccurrencesOfString:@"  " withString:@" "];

		timingString = [timingString lowercaseString];
		timingString = [timingString stringByReplacingOccurrencesOfString:@"p " withString:@"p"];
		timingString = [timingString stringByReplacingOccurrencesOfString:@"r " withString:@"r"];

		timingString = [timingString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		self.timingSequence = [timingString componentsSeparatedByString:@" "];
	}
	return timingSequence;
}


-(double) totalTicks {
	int ticks = 0;
	[self loadTimingSequence];
	for (int i = 0; i < [timingSequence count]; i++){
		NSString *part = [timingSequence objectAtIndex:i];
		part = [part stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		if ([part length] == 0)
			continue;
		ticks += [[part substringFromIndex:1] intValue];
	}
	return ticks;
}

-(void) parseNotes{
	double curTime = 0;
	[self loadTimingSequence];
	notes = [[NSMutableArray alloc] init];
	for (int i = 0; i < [timingSequence count]; i++){
		NSString *part = [timingSequence objectAtIndex:i];
		part = [part stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		if ([part length] == 0)
			continue;
		int duration = [[part substringFromIndex:1] intValue];
		// If it is not a rest add the note to the list
		if ([[timingSequence objectAtIndex:i] hasPrefix:@"p"]){
			Note * note =  [[Note alloc] initWithStartTime: curTime andStopTime: curTime + duration];
			note.ticks = duration;
			[notes addObject:note];
			[note release];
		}
		// Either way move up the current time.
		curTime += duration;
	}
}


-(NSMutableArray *)notes {
	if (notes == nil)
		[self parseNotes];
	return notes;
}

-(void) dealloc {
   self.level = nil;
   self.timingSequence = nil;
   self.notes = nil;
	[super dealloc];
}


@end
