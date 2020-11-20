//
//  ViewController.m
//  DSBridgeTest
//
//  Created by 段坤明 on 2020/11/20.
//

#import "ViewController.h"
#import "dsbridge.h"
#import "JsApiTest.h"
#import "JsEchoApi.h"

@interface ViewController ()
@property (nonatomic, strong) DWKWebView *dwebview;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dwebview = [[DWKWebView alloc] initWithFrame:self.view.bounds];
    [self.dwebview addJavascriptObject:[[JsApiTest alloc] init] namespace:nil];
    [self.dwebview addJavascriptObject:[[JsEchoApi alloc] init] namespace:@"echo"];

    [self.view addSubview:self.dwebview];
    //获取bundlePath 路径
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    
    //获取本地html目录 basePath
    NSString *basePath = [NSString stringWithFormat: @"%@/", bundlePath];
    
    //获取本地html目录 baseUrl
    NSURL *baseUrl = [NSURL fileURLWithPath: basePath isDirectory: YES];
    
    NSLog(@"%@", baseUrl);
    //html 路径
    
    NSString *indexPath = [NSString stringWithFormat: @"%@/index.html", basePath];
    //html 文件中内容
    NSString *indexContent = [NSString stringWithContentsOfFile: indexPath encoding: NSUTF8StringEncoding error:nil];
    //显示内容
    [self.dwebview loadHTMLString: indexContent baseURL: baseUrl];
    
    
    UIButton *testButton = [UIButton buttonWithType:UIButtonTypeCustom];
    testButton.frame = CGRectMake(100, 100, 50, 50);
    testButton.backgroundColor = [UIColor redColor];
    [testButton setTitle:@"测试" forState:UIControlStateNormal];
    [testButton addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testButton];
}

- (void)test{
//    [self.dwebview callHandler:@"addValue" arguments:@[@3,@4] completionHandler:^(NSNumber* value){
//             NSLog(@"%@",value);
//      }];
    
    NSLog(@"开始测试");
    [self.dwebview callHandler:@"test.test1" completionHandler:^(NSString * _Nullable value) {
            NSLog(@"Namespace test.test1: %@",value);
    }];

    [self.dwebview callHandler:@"test1.test1" completionHandler:^(NSString * _Nullable value) {
            NSLog(@"Namespace test1.test1: %@",value);
    }];
}


@end
