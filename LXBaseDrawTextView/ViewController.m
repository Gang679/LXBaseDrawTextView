//
//  ViewController.m
//  LXBaseDrawTextView
//
//  Created by 李旭 on 16/8/9.
//  Copyright © 2016年 LX. All rights reserved.
//

#import "ViewController.h"
#import "LXHelpClass.h"
#import "LXRichTextView.h"

@interface ViewController () <LXRichTextViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *text = @"[健身]我下载demo啊test[大哭]lms在https://github.com/SoftProgramLX?tab=repositories测试[微笑]选打11111我的github";
    
    LXRichTextView *view = [[LXRichTextView alloc] init];
    view.text = text;
    view.isUrl = YES;//设置为NO则不匹配链接。
    view.backgroundColor = [UIColor greenColor];
    view.font = [UIFont systemFontOfSize:18];
    view.delegage = self;
    view.urlDic = @{@"我的github": @"https://github.com/SoftProgramLX?tab=repositories", @"下载demo": @"https://github.com/SoftProgramLX/LXDrawTextView"};
    [self.view addSubview:view];
    
    view.frame = CGRectMake(20, 40, 300, [LXHelpClass calculateLabelighWithText:text withMaxSize:CGSizeMake(300, MAXFLOAT) withFont:18 withSpaceRH:0]);
}

- (void)richTextView:(LXRichTextView *)view touchBeginRun:(LXRichTextBaseRun *)run
{
    NSLog(@"%@", run.originalText);
}

@end


