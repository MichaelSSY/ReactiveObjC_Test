//
//  SubjectView.h
//  ReactiveObjC_Test
//
//  Created by weiyun on 2018/1/19.
//  Copyright © 2018年 孙世玉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RACSubject.h>

@interface SubjectView : UIView

@property (nonatomic , strong) RACSubject *subject;

@end
