//
//  SubjectView.m
//  ReactiveObjC_Test
//
//  Created by weiyun on 2018/1/19.
//  Copyright © 2018年 孙世玉. All rights reserved.
//

#import "SubjectView.h"

// 类拓展
@interface SubjectView ()

@end

@implementation SubjectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor orangeColor];
        
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        button1.frame = CGRectMake(0, 0, 30, 30);
        button1.backgroundColor = [UIColor yellowColor];
        [button1 addTarget:self action:@selector(buttonClick1) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button1];
        
        UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        button2.frame = CGRectMake(40, 0, 30, 30);
        button2.backgroundColor = [UIColor yellowColor];
        [button2 addTarget:self action:@selector(buttonClick2) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button2];
    }
    return self;
}

- (RACSubject *)subject
{
    if (_subject == nil) {
        _subject = [RACSubject subject];
    }
    return _subject;
}

- (void)look:(NSString *)string{
   
}

- (void)buttonClick1
{
    NSLog(@"按钮1被点了");
}
- (void)buttonClick2
{
     [self.subject sendNext:@"汉堡"];
     [self look:@"haha"];
}
@end
