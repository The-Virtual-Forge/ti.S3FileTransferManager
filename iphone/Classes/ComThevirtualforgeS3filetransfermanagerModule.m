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
    // Make sure to release the callback objects
    RELEASE_TO_NIL(successCallback);
    RELEASE_TO_NIL(cancelledCallback);
    RELEASE_TO_NIL(pausedCallback);
    RELEASE_TO_NIL(errorCallback);
    RELEASE_TO_NIL(progressCallback);
    
    [super _destroy];
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];

    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:AWSRegionEUWest1
                                                          identityPoolId:@"eu-west-1:583f3dc8-b32f-42b8-a78f-61fd019d96e8"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionEUWest1 credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
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

//#pragma mark Listener Notifications

//-(void)_listenerAdded:(NSString *)type count:(int)count
//{
//	if (count == 1 && [type isEqualToString:@"my_event"])
//	{
//		// the first (of potentially many) listener is being added
//		// for event named 'my_event'
//	}
//}
//
//-(void)_listenerRemoved:(NSString *)type count:(int)count
//{
//	if (count == 0 && [type isEqualToString:@"my_event"])
//	{
//		// the last listener called for event named 'my_event' has
//		// been removed, we can optionally clean up any resources
//		// since no body is listening at this point for that event
//	}
//}

#pragma Public APIs

-(void)initialize:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    
    successCallback = [[args objectForKey:@"success"] retain];
    cancelledCallback = [[args objectForKey:@"cancelled"] retain];
    errorCallback = [[args objectForKey:@"error"] retain];
    pausedCallback = [[args objectForKey:@"paused"] retain];
    progressCallback = [[args objectForKey:@"progress"] retain];
}

-(void)setRegion:(id)value
{
    ENSURE_STRING(value);
    region = [value retain];
}

-(NSString *)region
{
    return region;
}

-(void)setIdentityPoolId:(id)value
{
    ENSURE_STRING(value);
    identityPoolId = [value retain];
}

-(NSString *)identityPoolId
{
    return identityPoolId;
}

-(void)upload:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = [[args objectForKey:@"bucket"] retain];
    uploadRequest.key = [[args objectForKey:@"key"] retain];
    NSURL *fileURL = [NSURL URLWithString:[[args objectForKey:@"body"] retain]];
    NSLog(@"body = %@", [[args objectForKey:@"body"] retain]);
    uploadRequest.body = fileURL;
//    uploadRequest.contentLength = fileBlob.size;
    
    NSLog(@"Starting upload request");
    
    [[transferManager upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"Upload cancelled");
//                            id result = [cancelledCallback call:args thisObject:nil];
                        });
                    }
                        break;
                    case AWSS3TransferManagerErrorPaused:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"Upload paused");
//                            id result = [pausedCallback call:args thisObject:nil];
                        });
                    }
                        break;
                        
                    default:
                        NSLog(@"Upload failed: [%@]", task.error);
//                        id result = [errorCallback call:args thisObject:nil];
                        break;
                }
            } else {
                NSLog(@"Upload failed: [%@]", task.error);
//                id result = [errorCallback call:args thisObject:nil];
            }
        }
        
        if (task.result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Upload success: [%@]", task.result);
//                id result = [successCallback call:args thisObject:nil];
            });
        }
        
        return nil;
    }];
}

-(void)pause:(id)args
{
    
}

-(void)resume:(id)args
{
    
}

-(void)pauseAll:(id)args
{
    
}

-(void)resumeAll:(id)args
{
    
}

@end
