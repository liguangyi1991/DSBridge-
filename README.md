# iOS 使用DSBridge

DSBridge是一个用来用来原生和h5交互的轻量级框架,下面我说一下在iOS端DSBridge的使用

### 安装

使用cocoapods来进行安装

```
pod "dsBridge"
```

### 使用

1.  新建一个用于和JavaScript交互的类

   ```objective-c
   #import "JsApiTest.h"
   #import "dsbridge.h"
    
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
   @end
   
   ```

   
   

2. 初始化DWKWebView,并将此View添加到控制器的View上,同时向DWKWebView中注册自JsApiTest

   ```
   self.dwebview = [[DWKWebView alloc] initWithFrame:self.view.bounds];
   [self.dwebview addJavascriptObject:[[JsApiTest alloc] init] namespace:nil];
   [self.view addSubview:self.dwebview];
   ```

 3. 在js代码中引入dsbridge.js,可以采用cdn方式引入,也可通过npm方式引入,我这边采用的是cdn的方式引入

    ```html
    <!DOCTYPE html>
    <html lang="en">
    
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <title>Document</title>
        <style>
            .box1 {
                width: 100px;
                height: 100px;
                background-color: yellow
            }
        </style>
        <script src="https://cdn.jsdelivr.net/npm/dsbridge@3.1.4/dist/dsbridge.js"> </script>
        <script>
            window.onload = function () {
                var button1 = document.getElementById("test1");
                var button2 = document.getElementById("test2");
                button1.onclick = function () {
                    //同步调用
                    var str = bridge.call("testSyn", "testSyn");
                }
                button2.onclick = function () {
                    //异步调用
                    bridge.call("testAsyn", "testAsyn", function (v) {
                        alert(v);
                    })
                }
                //注册 javascript API 
                bridge.register('addValue', function (l, r) {
                    return l + r;
                })
            }
        </script>
    </head>
    
    <body>
        <button id="test1">同步调用原生方法</button>
        <button id="test2">异步调用原生方法</button>
    
    </body>
    
    </html>
    ```

    同时我在js中注册了addValue方法来供原生的调用,在iOS代码中可以通过callHandler来调用js中的注册的方法

    ```
    [self.dwebview callHandler:@"addValue" arguments:@[@3,@4] completionHandler:^(NSNumber* value){
         NSLog(@"%@",value);
    }];
    ```

    

### 支持进度的回调

通常情况下，调用一个方法结束后会返回一个结果，是一一对应的。但是有时会遇到一次调用需要多次返回的场景，比如在javascript钟调用端上的一个下载文件功能，端上在下载过程中会多次通知javascript进度, 然后javascript将进度信息展示在h5页面上，这是一个典型的一次调用，多次返回的场景，如果使用其它Javascript bridge, 你将会发现要实现这个功能会比较麻烦，而DSBridge本省支持进度回调，你可以非常简单方便的实现一次调用需要多次返回的场景，下面我们实现一个倒计时的例子：

oc中的代码:

```objective-c
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
```

JavaScript中的代码的实现:

```
button3.onclick = function () {
      bridge.call("callProgress", function (value) {
            ocument.getElementById("progress").innerText = value
        })
}
```

### OC中的方法签名

**注意: DSBridge对OC中的方法有严格的要求必须符合以下格式**

1.  同步api

   ```
   (id) handler:(id) msg
   ```

   **参数可以是任何类型, 但是返回值类型不能为 void。 如果不需要参数，也必须声明，声明后不使用就行**。

2. ```
   (void) handler:(id)arg :(void (^)( id result,BOOL complete))completionHandler）
   ```

### js中通过命名空间来调用OC中的方法

示例如下:

```
            // 通过命名空间来调用
            button4.onclick = function () {
                var ret = dsBridge.call("echo.syn", {
                    msg: " I am echoSyn call",
                    tag: 1
                })
                alert(JSON.stringify(ret))
                // call echo.asyn
                dsBridge.call("echo.asyn", {
                    msg: " I am echoAsyn call",
                    tag: 2
                }, function (ret) {
                    alert(JSON.stringify(ret));
                })
            }
```

### js中可以注册一个对象，指定一个命名空间供OC来进行调用

```
dsBridge.register("test",{
  tag:"test",
  test1:function(){
	return this.tag+"1"
  },
  test2:function(){
	return this.tag+"2"
  }
})
  
//namespace test1 for asynchronous calls  
dsBridge.registerAsyn("test1",{
  tag:"test1",
  test1:function(responseCallback){
	return responseCallback(this.tag+"1")
  },
  test2:function(responseCallback){
	return responseCallback(this.tag+"2")
  }
})
```

以上就是使用DSBridge用来JavaScript和原生iOS之间的交互

