

#import <UIKit/UIKit.h>
#import "LXRichTextBaseRun.h"

@class LXRichTextView;

@protocol LXRichTextViewDelegate<NSObject>

@optional
- (void)richTextView:(LXRichTextView *)view touchBeginRun:(LXRichTextBaseRun *)run;
- (void)richTextView:(LXRichTextView *)view touchEndRun:(LXRichTextBaseRun *)run;

@end

@interface LXRichTextView : UIView

@property (nonatomic, assign) BOOL isUrl;
@property (nonatomic, copy) NSString *urlName;
@property (nonatomic, copy) NSDictionary *urlDic;
@property (nonatomic, assign) NSInteger index;

@property(nonatomic,copy)   NSString           *text;            // default is @""
@property(nonatomic,strong) UIFont             *font;            // default is [UIFont systemFontOfSize:12.0]
@property(nonatomic,strong) UIColor            *textColor;       // default is [UIColor blackColor]
@property(nonatomic)        float               lineSpacing;     // default is 1.5 行间距

//-- 特殊的文本数组。在绘制的时候绘制
@property(nonatomic,readonly)       NSMutableArray *richTextRunsArray;
//-- 特熟文本的绘图边界字典。用来做点击处理定位
@property(nonatomic,readonly)       NSMutableDictionary *richTextRunRectDic;
//-- 原文本通过解析后的文本
@property(nonatomic,readonly,copy)  NSString        *textAnalyzed;

@property(nonatomic,weak) id<LXRichTextViewDelegate> delegage;

@end
