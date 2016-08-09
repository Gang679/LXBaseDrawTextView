
#import "LXRichTextBaseRun.h"

@interface LXRichTextURLRun : LXRichTextBaseRun
{
    NSInteger deviation;
    NSInteger rate;
    NSString *strLink;
}

+ (NSString *)analyzeText:(NSString *)string runsArray:(NSMutableArray **)runArray andUrlName:(NSDictionary *)urlNameDic;

@end
