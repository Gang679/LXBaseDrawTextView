
#import "LXRichTextURLRun.h"

@implementation LXRichTextURLRun


- (id)init
{
    self = [super init];
    if (self) {
        self.type = richTextURLRunType;
        self.isResponseTouch = YES;
    }
    return self;
}

//-- 替换基础文本
- (void)replaceTextWithAttributedString:(NSMutableAttributedString*) attributedString
{
    if (self.range.location + self.range.length > attributedString.length) {
        return;
    }
    [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor colorWithRed:245/255.0 green:179/255.0 blue:96/255.0 alpha:1].CGColor range:self.range];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:self.originalFont.pointSize + 2.0] range:self.range];
    [super replaceTextWithAttributedString:attributedString];
}

//-- 绘制内容
- (BOOL)drawRunWithRect:(CGRect)rect
{
    return NO;
}

//-- 解析文本内容
+ (NSString *)analyzeText:(NSString *)string runsArray:(NSMutableArray **)runArray andUrlName:(NSDictionary *)urlNameDic
{
    NSError *error;
    
    //适用于任何网址
    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    NSInteger deviation = 0;
    NSInteger rate = 0;
    NSString *strLink = [NSString stringWithString:string];
    
    NSString *urlType = [urlNameDic objectForKey:@"type"];
//    for (NSTextCheckingResult *match in arrayOfAllMatches)
    for (int i = 0; i < arrayOfAllMatches.count; i++) {
        NSTextCheckingResult *match = arrayOfAllMatches[i];
        NSString* substringForMatch = [strLink substringWithRange:NSMakeRange(match.range.location - deviation, match.range.length)];
        
        LXRichTextURLRun *urlRun = [[LXRichTextURLRun alloc] init];
        urlRun.originalText = substringForMatch;
        
        if (i == arrayOfAllMatches.count-1 && [urlType isEqualToString:@"1"]) {
            NSString *urlName = [urlNameDic objectForKey:@"url"];
            if (urlName.length > 0) {
                urlRun.range = NSMakeRange(match.range.location - deviation - (rate++ * urlName.length), urlName.length);
                strLink = [strLink stringByReplacingCharactersInRange:NSMakeRange(match.range.location - deviation, match.range.length) withString:urlName];
                deviation += match.range.length - urlName.length;
            }
        } else {
            urlRun.range = match.range;
        }
        [*runArray addObject:urlRun];
    }
    
    if ([urlType isEqualToString:@"2"]) {
        NSDictionary *urlDic = [urlNameDic objectForKey:@"url"];
        NSArray *vailArr = [urlDic allKeys];
        for (NSString *str in vailArr) {
            if ([strLink rangeOfString:str].length == str.length) {
                
                LXRichTextURLRun *urlRun = [[LXRichTextURLRun alloc] init];
                urlRun.originalText = [urlDic objectForKey:str];
                NSRange range = [strLink rangeOfString:str];
                urlRun.range = range;
                strLink = [strLink stringByReplacingCharactersInRange:range withString:str];
                [*runArray addObject:urlRun];
            }
        }
    }
    
    return [strLink copy];
}

@end






