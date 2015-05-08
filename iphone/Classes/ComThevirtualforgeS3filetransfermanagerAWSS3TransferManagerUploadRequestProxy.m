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
//    NSLog(@"Initializing upload request with properties: %@", properties);
    
    AWSS3TransferManagerUploadRequest *ur =[AWSS3TransferManagerUploadRequest new];
    
    ur.bucket = [properties objectForKey:@"bucket"];
    ur.key = [properties objectForKey:@"key"];
    ur.body = [NSURL URLWithString:[properties objectForKey:@"body"]];

//    NSLog(@"Setting uploadProgress callback");
    
// TODO: replace the progress event with a callback as consuming JS layer seems to choke on
// rapidly fired events
    
//    ur.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            if ([self _hasListeners:@"progress"]) {
//                
//                NSDictionary *eventPayload = @{
//                                               @"bytesSent": [NSNumber numberWithLongLong:bytesSent],
//                                               @"totalBytesSent": [NSNumber numberWithLongLong:totalBytesSent],
//                                               @"totalBytesExpectedToSend": [NSNumber numberWithLongLong:totalBytesExpectedToSend],
//                                               @"bucket": bucket,
//                                               @"key": key
//                                               };
//                NSLog(@"Firing progress event...");
//                [self fireEvent:@"progress" withObject:nil];
//            } else {
//                NSLog(@"Proxy has no progress listeners");
//            }
//        });
//    };
    
//    NSLog(@"ur = %@", ur);
    
    [self setUploadRequest:ur];
    
//    NSLog(@"uploadRequest = %@", uploadRequest);
    
//    NSLog(@"Calling super _initWithProperties");
    
    [super _initWithProperties:properties];
}

-(void)_destroy
{
    [super _destroy];
}

#pragma mark Cleanup

-(void)dealloc
{
    // release any resources that have been retained by the module
    [uploadRequest release];
    [key release];
    [bucket release];
    [body release];
    [super dealloc];
}

#pragma Public APIs

- (AWSS3TransferManagerUploadRequest *)uploadRequest;
{
//    NSLog(@"Getting uploadRequest");
    return uploadRequest;
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

- (void)setUploadRequest:(AWSS3TransferManagerUploadRequest *)ur;
{
//    NSLog(@"Setting uploadRequest to %@", ur);
    [uploadRequest autorelease];
    uploadRequest = [ur retain];
}

-(void)setKey:(id)_key
{
//    NSLog(@"Setting key to %@", _key);
    [key autorelease];
    key = [TiUtils stringValue:_key];
}

-(void)setBody:(id)_body
{
//    NSLog(@"Setting body to %@", _body);
    [body autorelease];
    body = [NSURL URLWithString:[TiUtils stringValue:_body]];
}

-(void)setBucket:(id)_bucket
{
//    NSLog(@"Setting bucket to %@", _bucket);
    [bucket autorelease];
    bucket = [TiUtils stringValue:_bucket];
}

-(void)pause
{
    
}

-(void)cancel
{
    
}

-(void)onPaused
{
//    NSLog(@"Paused event firing...");
    NSDictionary *eventPayload = @{
                                   @"success": @false,
                                   @"cancelled": @false,
                                   @"paused": @true,
                                   @"bucket": bucket,
                                   @"key": key
                                   };
    [self fireEvent:@"paused" withObject:eventPayload];
}

-(void)onCancelled
{
//    NSLog(@"Cancelled event firing...");
    NSDictionary *eventPayload = @{
                                   @"success": @false,
                                   @"cancelled": @true,
                                   @"paused": @false,
                                   @"bucket": bucket,
                                   @"key": key
                                   };
    [self fireEvent:@"cancelled" withObject:eventPayload];
}

-(void)onSuccess:(AWSS3TransferManagerUploadOutput *)result
{
    if ([self _hasListeners:@"success"]) {
        NSDictionary *eventPayload = @{
                                       @"success": @true,
                                       @"cancelled": @false,
                                       @"paused": @false,
                                       @"bucket": bucket,
                                       @"key": key,
                                       @"result": @{
                                            @"ETAG": result.ETag
//                                            @"serverSideEncryption": result.serverSideEncryption
                                            }
                                       };
        [self fireEvent:@"success" withObject:eventPayload];
    } else {
        NSLog(@"Proxy has no success listeners");
    }

}

-(void)onError:(NSError *)error
{
//    NSLog(@"Error event firing...");
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
    [self fireEvent:@"error" withObject:eventPayload];
}


@end