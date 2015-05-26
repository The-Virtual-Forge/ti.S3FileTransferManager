/**
 * S3FileTransferManagerAWSS3TransferManagerUploadRequestProxy
 *
 * Created by Terry Morgan
 * Copyright (c) 2015 The Virtual Forge. All rights reserved.
 */
#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>

#import "ComThevirtualforgeS3filetransfermanagerAWSS3TransferManagerUploadRequestProxy.h"
#import "TiUtils.h"

@implementation ComThevirtualforgeS3filetransfermanagerAWSS3TransferManagerUploadRequestProxy

#pragma mark Internal

-(void)_initWithProperties:(NSDictionary *)properties
{
    NSLog(@"_initWithProperties");
    AWSS3TransferManagerUploadRequest *ur =[AWSS3TransferManagerUploadRequest new];
    
    ur.bucket = [properties objectForKey:@"bucket"];
    ur.key = [properties objectForKey:@"key"];
    ur.body = [NSURL URLWithString:[properties objectForKey:@"body"]];
    
    KrollCallback* progressCallback = [properties objectForKey:@"progressCallback"];

    NSLog(@"Setting uploadProgress callback");
    
    ur.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (progressCallback) {
                NSDictionary *eventData = @{
                                           @"bytesSent": [NSNumber numberWithLongLong:bytesSent],
                                           @"totalBytesSent": [NSNumber numberWithLongLong:totalBytesSent],
                                           @"totalBytesExpectedToSend": [NSNumber numberWithLongLong:totalBytesExpectedToSend],
                                           @"bucket": bucket,
                                           @"key": key
                                           };
                NSArray* arrayOfValues = [NSArray arrayWithObjects: eventData, nil];
                [progressCallback call:arrayOfValues thisObject:nil];
            }
        });
    };
    
    [self setUploadRequest:ur];
    [super _initWithProperties:properties];
}

-(void)_destroy
{
    NSLog(@"_destroy");
    [super _destroy];
}

#pragma mark Cleanup

-(void)dealloc
{
    NSLog(@"dealloc");
    // release any resources that have been retained by the module
    [uploadRequest release];
    [key release];
    [bucket release];
    [body release];
    [successCallback release];
    [errorCallback release];
    [cancelledCallback release];
    [pausedCallback release];
    [super dealloc];
}

#pragma Public APIs

- (AWSS3TransferManagerUploadRequest *)uploadRequest;
{
    return uploadRequest;
}

-(NSString *)state
{
    NSString *uploadState;
    
    if (uploadRequest) {
        switch (uploadRequest.state) {
            case AWSS3TransferManagerRequestStateNotStarted:
                uploadState = @"Not started";
                break;
                
            case AWSS3TransferManagerRequestStateRunning:
                uploadState = @"Running";
                break;
                
            case AWSS3TransferManagerRequestStatePaused:
                uploadState = @"Paused";
                break;

            case AWSS3TransferManagerRequestStateCanceling:
                uploadState = @"Canceling";
                break;
                
            case AWSS3TransferManagerRequestStateCompleted:
                uploadState = @"Completed";
                break;
                
            default:
                uploadState = @"Unknown";
                break;
        }
    } else {
        uploadState = @"Invalid";
    }

    return uploadState;
}

-(NSString *)key
{
    return key;
}

-(NSURL *)body
{
    return body;
}

-(NSString *)bucket
{
    return bucket;
}

-(KrollCallback *)successCallback
{
    return successCallback;
}

-(KrollCallback *)errorCallback
{
    return errorCallback;
}

-(KrollCallback *)pausedCallback
{
    return pausedCallback;
}

-(KrollCallback *)cancelledCallback
{
    return cancelledCallback;
}

- (void)setUploadRequest:(AWSS3TransferManagerUploadRequest *)ur
{
    [uploadRequest autorelease];
    uploadRequest = [ur retain];
}

-(void)setKey:(id)_key
{
    [key autorelease];
    key = [TiUtils stringValue:_key];
}

-(void)setBody:(id)_body
{
    [body autorelease];
    body = [NSURL URLWithString:[TiUtils stringValue:_body]];
}

-(void)setBucket:(id)_bucket
{
    [bucket autorelease];
    bucket = [TiUtils stringValue:_bucket];
}

-(void)setSuccessCallback:(KrollCallback *)_successCallback
{
    [successCallback autorelease];
    successCallback = [_successCallback retain];
}

-(void)setErrorCallback:(KrollCallback *)_errorCallback
{
    [errorCallback autorelease];
    errorCallback = [_errorCallback retain];
}

-(void)setPausedCallback:(KrollCallback *)_pausedCallback
{
    [pausedCallback autorelease];
    pausedCallback = [_pausedCallback retain];
}

-(void)setCancelledCallback:(KrollCallback *)_cancelledCallback
{
    [cancelledCallback autorelease];
    cancelledCallback = [_cancelledCallback retain];
}

-(void)pauseUpload:(id)args
{
    NSLog(@"Requesting pause...");
    NSLog(@"%@", uploadRequest);
    [[uploadRequest pause] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"The pause request failed: [%@]", task.error);
        }
        return nil;
    }];
}

-(void)cancel:(id)args

{
    NSLog(@"cancel");
    [[uploadRequest cancel] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"The cancel request failed: [%@]", task.error);
        }
        return nil;
    }];
}

-(void)onPaused
{
    NSLog(@"onPaused");
    if (pausedCallback) {
        NSDictionary *eventPayload = @{
                                       @"success": @false,
                                       @"cancelled": @false,
                                       @"paused": @true,
                                       @"bucket": bucket,
                                       @"key": key
                                       };
        NSArray* arrayOfValues = [NSArray arrayWithObjects: eventPayload, nil];
        NSLog(@"Calling pausedCallback");
        [pausedCallback call:arrayOfValues thisObject:nil];
    }
}

-(void)onCancelled
{
    NSLog(@"onCancelled");
    if (cancelledCallback) {
        NSDictionary *eventPayload = @{
                                       @"success": @false,
                                       @"cancelled": @true,
                                       @"paused": @false,
                                       @"bucket": bucket,
                                       @"key": key
                                       };
        NSArray* arrayOfValues = [NSArray arrayWithObjects: eventPayload, nil];
        [cancelledCallback call:arrayOfValues thisObject:nil];
    }
}

-(void)onSuccess:(AWSS3TransferManagerUploadOutput *)result
{
    if (successCallback) {
        NSDictionary *eventPayload = @{
                                       @"success": @true,
                                       @"cancelled": @false,
                                       @"paused": @false,
                                       @"bucket": bucket,
                                       @"key": key,
                                       @"result": @{
                                               @"ETAG": result.ETag
                                               }
                                       };
        
        NSArray* arrayOfValues = [NSArray arrayWithObjects: eventPayload, nil];
        [successCallback call:arrayOfValues thisObject:nil];
    }
}

-(void)onError:(NSError *)error
{
    NSLog(@"onError");
    if (errorCallback) {
        NSDictionary *eventPayload = @{
                                       @"success": @false,
                                       @"cancelled": @false,
                                       @"paused": @false,
                                       @"bucket": bucket,
                                       @"key": key,
                                       @"error": @{
                                               @"code": NUMLONG(error.code),
                                               @"domain": error.domain,
                                               @"userInfo": error.userInfo
                                               }
                                       };
        NSArray* arrayOfValues = [NSArray arrayWithObjects: eventPayload, nil];
        [errorCallback call:arrayOfValues thisObject:nil];
    }
}


@end