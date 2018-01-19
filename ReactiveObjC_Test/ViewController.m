//
//  ViewController.m
//  ReactiveObjC_Test
//
//  Created by weiyun on 2018/1/19.
//  Copyright © 2018年 孙世玉. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC.h>
#import "SubjectView.h"

@interface ViewController ()

@property (nonatomic , strong) SubjectView *subView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendBtton;

@property(nonatomic , strong) RACDisposable *disposable;
@property (nonatomic , assign) int count;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self timerMethod];

}
#pragma mark - 10. 代替 NSTimer 计时器
- (void)timerMethod
{
    // 注意：RAC的定时器，其实是封装GCD的定时器。
    // [RACScheduler scheduler]
    [[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate * _Nullable x) {
        NSLog(@"当前时间：%@",x);
    }];
}
#pragma mark - 9. 代替 KVO 监听
// 可以代替 KVO 监听，下面表示把监听 view 的 frame 属性改变转换成信号，只要值改变就会发送信号。
- (void)KVOMethod
{
    [self addSubjectView];
    
    [[self.subView rac_valuesForKeyPath:@"frame" observer:self] subscribeNext:^(id  _Nullable x) {
        NSLog(@"哎呀，subView的frame变了：%@",x);
    }];
    
    /**  这里的KVO是不是省去了好多代码呀！！！ */
}

#pragma mark - 8. 代替 Delegate 代理方法
- (void)delegateMethod
{
    [self addSubjectView];
    
    // 这里的SEL要和按钮定义的方法一样
    [[self.subView rac_signalForSelector:@selector(buttonClick1)] subscribeNext:^(id  _Nullable x) {
        NSLog(@"不要代理，有我就够了呀！");
    }];
    
    // 我们来看能不能监听到方法调用
    [[self.subView rac_signalForSelector:@selector(look:)] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark - 7. 监听 Notification 通知事件
// 可省去在 -(void)dealloc {} 中清除通知和监听通知创建方法的步骤。
- (void)notificationMethod
{
    // 这里我们监听下键盘的弹出
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardDidShowNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"哎呀，键盘弹出来了");
    }];
}

#pragma mark - 6. 监听 Button 点击事件
- (void)buttonClickMethod
{
    [[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"我被点击了");
    }];
    
    // 实现当输入框有内容的时候button才能点击，用下面方法就可实现
    // RAC() 这个宏可以研究下，有好多用法！！！
    RAC(_loginBtn, enabled) =  [RACSignal combineLatest:@[_textField.rac_textSignal] reduce:^id _Nullable(NSString *username){
        return @(username.length);
    }];
}
- (IBAction)buttonClick:(UIButton *)sender {
    // 改变状态
    self.sendBtton.enabled = NO;
    // 倒计时10秒
    self.count = 10;
    
   _disposable = [[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate * _Nullable x) {
        // 回到主线程刷新UI
        NSString *btnText = self.count > 0?[NSString stringWithFormat:@"请稍等%d秒",self.count]:@"重新发送";
        [_sendBtton setTitle:btnText forState:_count > 0?(UIControlStateDisabled):(UIControlStateNormal)];
        _sendBtton.enabled = _count > 0 ? NO : YES;
       
       if (_count == 0) {
           [_disposable dispose];
       }
       
        // 减去时间
        _count -- ;
    }];
}

#pragma mark - 5. 监听 TextField 的输入改变
- (void)TextFieldChangeMethod
{
    // 监听textField的内容输入，当内容改变就会调用
    [[self.textField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"输入框内容：%@", x);
    }];
    
    /** 是不是很方便啊，不需要你声明代理和实现方法，通过监听就可以实现，这就是响应式的魅力*/
    
}

#pragma mark - 4. 便利 Array 数组和 Dictionary 字典
// 可以省去使用 for 循环来遍历。
- (void)traverseDictionaryMethod
{
    // 1.遍历数组
    RACTuple *tuple = [RACTuple tupleWithObjects:@"a",@"b",@"c", nil];
    [tuple.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"tuple：%@",x);
    }];
    
    // 这个是不是有点像OC数组的block遍历方式，我们来对比一下
    NSArray *array = @[@"a",@"b",@"c"];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"array：%@",obj);
    }];
    
    // 2.遍历字典
    NSDictionary *dictionary = @{@"1":@"a",@"2":@"b",@"3":@"c",};
    [dictionary.rac_sequence.signal subscribeNext:^(RACTuple * _Nullable x) {
        // Unpack：拆分，我么可以看到每个键值对都被拆都被拆分为了一个数组，这个x是个元组类型，这个宏能够将key和value拆分开
        // 大家若是不理解，可以点RACTupleUnpack进去看看它们的例子就明台，只是一种语法而已
        RACTupleUnpack(NSString *key, NSString *value) = x;
        NSLog(@"键值对：%@:%@", key, value);
    }];
    
    
    // 3.数组内元素替换
    
    // 下面两个方法都是将数组内容全部换为 0 ，第一个是单个操作，，第二个是一次性全部替换，两个方法都不会改变原数组内容，操作完后都会生成一个新的数组，省去了创建可变数组然后遍历出来单个添加的步骤。
    
    NSArray *newArray1 = [[array.rac_sequence map:^id _Nullable(id  _Nullable value) {
        NSLog(@"数组内容：%@", value);
        return @"0"; // 将所有内容替换为 0
    }] array];
    NSLog(@"新数组：%@   老数组：%@",newArray1,array);
    
    // 内容快速替换
    //NSArray *newArray2 = [[array.rac_sequence mapReplace:@"0"] array]; // 将所有内容替换为 0
    //NSLog(@"新数组：%@",newArray2);
    
    // 4.筛选数组中你想要的元素
    NSArray *newArray3 = [[array.rac_sequence filter:^BOOL(id  _Nullable value) {
        if ([value isEqualToString:@"a"] || [value isEqualToString:@"b"]) {
            return YES;
        }else{
            return NO;
        }
    }] array];
    
    // 5.删除数组中的某个元素
    NSArray *newArray4 = [[array.rac_sequence ignore:@"a"] array];
    NSLog(@"newArray3：%@",newArray3);
    NSLog(@"newArray4：%@",newArray4);
    
    
    
    /** 说明：更多的操作你们可以到接口中去看看，在这里就不一一列举了！！！*/
    
    
}

#pragma mark - 3. RACTuple 元组
// 类似于我们 OC 的数组
- (void)RACTupleMethod
{
    /* 这个没啥讲的，很简单 */
    // 创建元组
    RACTuple *tuple1 = [RACTuple tupleWithObjects:@"a",@"b",@"c", nil];
 
    // 从别的数组中获取内容
    RACTuple *tuple2 = [RACTuple tupleWithObjectsFromArray:@[@"a",@"b",@"c"]];
    
    // 利用RAC宏快速封装
    RACTuple *tuple3 = RACTuplePack(@"a",@"b",@"c");
    
    NSLog(@" tuple1：%@ \n tuple2：%@ \n tuple3：%@",tuple1,tuple2,tuple3);
    NSLog(@"%@  %@  %@",tuple1[0],tuple2[0],tuple3[0]);
}

#pragma mark - 2.RACSubject 信号
// 继承自RACSignal，和代理的用法类似，通常用来代替代理，有了它，就不必要定义代理了。
- (void)RACSubjectMethod
{
    // 创建信号
    // 其实内部实现就是创建一个数组，还创建了一个RACDisposable，所以下面订阅的时候不需要你在返回一个RACDisposable了
    RACSubject *subject = [RACSubject subject];
    
    // 订阅信号（通常在别的视图控制器中订阅，与代理的用法类似）;
    // 这个地方是函数式编程思想
    // 创建订阅者，将block保存到订阅者对象，将订阅者保存到数组中
    [subject subscribeNext:^(id  _Nullable x) {
        // 回调
         NSLog(@"我晚上吃：%@",x);
    }];
    
    // 发送信号
    [subject sendNext:@"汉堡"];
    
    // 注意：具体的代理用法我这里已经举了例子，不过最好自己去敲一边代码，这样理解的比我说的要深刻得多！
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.subView.frame = CGRectMake(0, 0, 100, 100);
    // [self addSubjectView];
}
// 代理功能测试
- (void)addSubjectView
{    
    self.subView = [[SubjectView alloc]initWithFrame:CGRectMake(70, 20, 100, 100)];
    [self.view addSubview:self.subView];
    [self.subView.subject sendNext:@"点了！"];
    
    // 看看控制台响应了吗！！
    
}
#pragma mark - 1.RACSignal 信号
- (void)RACSignalMethod
{
    // 创建信号
    RACSignal *single = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"汉堡"];
        return nil;
    }];
    
    // 订阅信号
    RACDisposable *dispos = [single subscribeNext:^(id  _Nullable x) {
        NSLog(@"我晚上吃：%@",x);
    }];
    
    // 取消订阅
    [dispos dispose];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
