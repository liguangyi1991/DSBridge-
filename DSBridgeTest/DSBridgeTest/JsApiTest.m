#import "JsApiTest.h"
#import "dsbridge.h"
@interface JsApiTest()
@property (nonatomic, assign) NSInteger value;
@property (nonatomic, strong) JSCallback hanlder;
@property (nonatomic, strong) NSTimer *timer;
@end
@implementation JsApiTest
 //  同步
- (NSString *)testSyn: (NSString *) msg
{
    NSLog(@"我被同步调用了");
    return [msg stringByAppendingString:@"[ syn call]"];
}
 // 异步
- (void)testAsyn:(NSString *) msg :(JSCallback) completionHandler
{
    NSLog(@"我被异步调用了");
    completionHandler([msg stringByAppendingString:@" [ asyn call]"],YES);
}
- (void)callProgress:(NSDictionary *)args callback:(JSCallback)completionHandler
{
    self.value=10;
    self.hanlder=completionHandler;
    self.timer =  [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(onTimer)
                                            userInfo:nil
                                             repeats:YES];
}
-(void)onTimer{
    NSLog(@"开始调用");
    if(self.value!=-1){
        self.hanlder([NSNumber numberWithInt:self.value--],NO);
    }else{
        self.hanlder(@"",YES);
        [self.timer invalidate];
    }
}
@end
