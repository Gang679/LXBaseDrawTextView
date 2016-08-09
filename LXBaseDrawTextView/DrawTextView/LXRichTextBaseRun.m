

#import "LXRichTextBaseRun.h"

@implementation LXRichTextBaseRun

- (id)init
{
    self = [super init];
    if (self) {
        self.isResponseTouch = NO;
    }
    return self;
}

//-- 替换基础文本
- (void)replaceTextWithAttributedString:(NSMutableAttributedString*) attributedString
{
    [attributedString addAttribute:@"TQRichTextAttribute" value:self range:self.range];
    CTParagraphStyleSetting lineBreakMode;
    CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping; //换行模式
    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakMode.value = &lineBreak;
    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
    CTParagraphStyleSetting settings[] = {lineBreakMode};
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 1);   //第二个参数为settings的长度
    [attributedString addAttribute:(NSString *)kCTParagraphStyleAttributeName
                      value:(id)paragraphStyle
                      range:self.range];
}

//-- 绘制内容
- (BOOL)drawRunWithRect:(CGRect)rect
{
    return NO;
}

@end
