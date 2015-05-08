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
#import "ComThevirtualforgeS3filetransfermanagerAWSS3TransferManagerUploadRequestProxy.h"
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

    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:AWSRegionEUWest1
                                                          identityPoolId:@"eu-west-1:583f3dc8-b32f-42b8-a78f-61fd019d96e8"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionEUWest1 credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    currentUploads = [NSMutableArray new];
    
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

-(void)upload:(NSArray *)ur
{
    [currentUploads insertObject:ur atIndex:0];
    
//    NSLog(@"ur class = %@", [ur class]);
    
    ComThevirtualforgeS3filetransfermanagerAWSS3TransferManagerUploadRequestProxy *proxy = [ur objectAtIndex:0];
    
//    NSLog(@"proxy class = %@", [proxy class]);
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [proxy valueForKey:@"uploadRequest"];
    
//    NSLog(@"uploadRequest class = %@", [uploadRequest class]);
//    
//    NSLog(@"uploadRequest.bucket = %@", uploadRequest.bucket);
//    NSLog(@"uploadRequest.body = %@", uploadRequest.body);
//    NSLog(@"uploadRequest.key = %@", uploadRequest.key);
    
    [[transferManager upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
//        NSLog(@"Entering upload task block with task = %@", task);
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [proxy onCancelled];
                        });
                        break;
                        
                    case AWSS3TransferManagerErrorPaused:
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [proxy onError:task.error];
                        });
                        break;
                        
                    default:
//                        NSLog(@"Upload error: %@", task.error);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [proxy onError:task.error];
                        });
                }
            } else {
//                NSLog(@"Upload error: %@", task.error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [proxy onError:task.error];
                });
            }
        }
        
        if (task.result) {
//            NSLog(@"Upload success: %@", task.result);
            dispatch_async(dispatch_get_main_queue(), ^{
                [proxy onSuccess:task.result];
            });
        }
        
        return nil;
    }];
}

-(void)pauseAll
{
    [currentUploads enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[AWSS3TransferManagerUploadRequest class]]) {
            AWSS3TransferManagerUploadRequest *uploadRequest = obj;
            [[uploadRequest pause] continueWithBlock:^id(BFTask *task) {
                if (task.error) {
                    NSLog(@"The pause request failed: [%@]", task.error);
                }
                return nil;
            }];
        }
    }];
}

-(void)resumeAll
{
    [currentUploads enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[AWSS3TransferManagerUploadRequest class]]) {
            AWSS3TransferManagerUploadRequest *uploadRequest = obj;
            [[transferManager upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
                if (task.error) {
                    NSLog(@"The resume request failed: [%@]", task.error);
                }
                return nil;
            }];
        }
    }];
}

@end
