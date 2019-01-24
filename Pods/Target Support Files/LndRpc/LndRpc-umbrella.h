#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "LndRpc.pbobjc.h"
#import "Macaroon.pbobjc.h"
#import "LndRpc.pbrpc.h"

FOUNDATION_EXPORT double LndRpcVersionNumber;
FOUNDATION_EXPORT const unsigned char LndRpcVersionString[];

