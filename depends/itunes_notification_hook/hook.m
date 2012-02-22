//
//  main.m
//  PlayQueueClean
//
//  Created by Julius Parishy on 2/20/12.
//  Copyright (c) 2012 Dad Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

int main (int argc, const char * argv[])
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	printf("Badass Play iTunes Notification Hook v0.0.1 (Obj-C edition)\n");
	
	char currentDirectoryBuffer[PATH_MAX];
	getcwd(currentDirectoryBuffer, PATH_MAX);
	if(currentDirectoryBuffer)
	{
		NSLog(@"Working in: %s\n", currentDirectoryBuffer);
	}

	NSString* playQueueCleanPath = nil;
	if(argc > 1)
	{
	    playQueueCleanPath = [[NSString stringWithUTF8String:argv[1]] stringByExpandingTildeInPath];
	}

	if(!playQueueCleanPath)
	{
	    NSLog(@"Please pass a valid path to the play clean script as the first argument to this script.");
	    exit(1);
	}
	
	NSLog(@"Path to script: %@", playQueueCleanPath);

	NSDistributedNotificationCenter* notificationCenter = [NSDistributedNotificationCenter defaultCenter];

	NSString* notificationName = @"com.apple.iTunes.playerInfo";

	[notificationCenter addObserverForName:notificationName object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
    
	    NSTask* task = [[NSTask alloc] init];
	    [task setLaunchPath:playQueueCleanPath];
    
	    NSPipe* outputPipe = [NSPipe pipe];
	    [task setStandardOutput:outputPipe];
    
	    [task launch];
		[task waitUntilExit];

	    NSFileHandle* outputPipeFileHandle = [outputPipe fileHandleForReading];
	    NSData* outputData = [outputPipeFileHandle readDataToEndOfFile];
	    if(outputData)
	    {            
	        NSString* output = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
			printf("%s", [output UTF8String]);

			[output release];
	    }
	
		[task release];
	}];

	[[NSApplication sharedApplication] run];

	[pool drain];
	return 0;
}