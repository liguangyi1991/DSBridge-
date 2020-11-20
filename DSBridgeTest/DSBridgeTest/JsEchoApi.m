//
//  JsEchoApi.m
//  DSBridgeTest
//
//  Created by 段坤明 on 2020/11/20.
//

#import "JsEchoApi.h"
#import "dsbridge.h"

@implementation JsEchoApi
- (id)syn:(id) arg
{
    return arg;
}
- (void)asyn:(id)arg :(JSCallback)completionHandler
{
    completionHandler(arg,YES);
}
@end
