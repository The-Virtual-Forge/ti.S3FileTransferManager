/**
 * S3FileTransferManager
 *
 * Created by Terry Morgan
 * Copyright (c) 2015 The Virtual Forge. All rights reserved.
 */

#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>
//#import <AWSCognito/AWSCognito.h>

#import "ComThevirtualforgeS3filetransfermanagerModule.h"

#import "TiBase.h"
#import "TiBlob.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation ComThevirtualforgeS3filetransfermanagerModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"451adec7-56f8-4023-9653-5b922a703dca";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"com.thevirtualforge.s3filetransfermanager";
}

-(void)_destroy
{
    [super _destroy];
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
    
	NSLog(@"[INFO] %@ loaded",self);
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

@end
