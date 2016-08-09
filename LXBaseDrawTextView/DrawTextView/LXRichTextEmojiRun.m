

#import "LXRichTextEmojiRun.h"

@interface LXRichTextEmojiRun ()
{
    LXHelpClass *helpClass;
}

@end

@implementation LXRichTextEmojiRun

- (id)init
{
    self = [super init];
    if (self) {
        self.type = richTextEmojiRunType;
        self.isResponseTouch = NO;
        helpClass = [LXHelpClass sharedLXHelpClass];
    }
    return self;
}

- (BOOL)drawRunWithRect:(CGRect)rect
{
    if ([helpClass.keyArrAll containsObject:self.originalText]) {
        NSInteger idex = [helpClass.keyArrAll indexOfObject:self.originalText];
        NSString *str00 = helpClass.valueArrAll[idex];
        CGContextRef context = UIGraphicsGetCurrentContext();
        NSString *emojiString = [NSString stringWithFormat:@"%@",str00];
        UIImage *image = [UIImage imageNamed:emojiString];
        if (image)
        {
            CGContextDrawImage(context, rect, image.CGImage);
        }
    }

    return YES;
}

+ (NSArray *) emojiStringArray
{
    return [NSArray arrayWithObjects:@"[微笑]", @"[撇嘴]", @"[色]", @"[发呆]", @"[得意]", @"[流泪]", @"[害羞]", @"[闭嘴]", @"[睡]", @"[大哭]", @"[尴尬]", @"[发怒]", @"[调皮]", @"[呲牙]", @"[惊讶]", @"[难过]", @"[酷]", @"[冷汗]", @"[抓狂]", @"[吐]", @"[偷笑]", @"[可爱]", @"[白眼]", @"[傲慢]", @"[饥饿]", @"[困]", @"[惊恐]", @"[流汗]", @"[憨笑]", @"[大兵]", @"[奋斗]", @"[咒骂]", @"[疑问]", @"[嘘]", @"[晕]", @"[折磨]", @"[衰]", @"[骷髅]", @"[敲打]", @"[再见]", @"[糗大了]", @"[委屈]", @"[吓]", @"[阴险]", @"[右哼哼]", @"[左哼哼]", @"[鄙视]", @"[擦汗]", @"[鼓掌]", @"[哈欠]", @"[坏笑]", @"[可怜]", @"[亲亲]", @"[扣鼻]", @"[快哭了]", @"[足球]", @"[爱你]", @"[爱心]", @"[抱拳]", @"[菜刀]", @"[NO]", @"[OK]", @"[瓢虫]", @"[啤酒]", @"[乒乓]", @"[强]", @"[拳头]", @"[弱]", @"[闪电]", @"[胜利]", @"[示爱]", @"[太阳]", @"[握手]", @"[西瓜]", @"[拥抱]", @"[月亮]", @"[便便]", @"[炸弹]", @"[猪头]", @"[玫瑰]", @"[差劲]", @"[蛋糕]", @"[刀]", @"[凋谢]", @"[饭]", @"[勾引]", @"[咖啡]", @"[篮球]", @"[礼物]", @"[心碎]", nil];
}

+ (NSString *)analyzeText:(NSString *)string runsArray:(NSMutableArray **)runArray
{
    NSInteger length;
    if ([string isKindOfClass:[NSString class]]) {
        length = string.length;
    } else {
        length = 0;
    }
    NSString *markL = @"[";
    NSString *markR = @"]";
    NSMutableArray *stack = [[NSMutableArray alloc] init];
    NSMutableString *newString = [[NSMutableString alloc] initWithCapacity:length];
    
    //偏移索引 由于会把长度大于1的字符串替换成一个空白字符。这里要记录每次的偏移了索引。以便简历下一次替换的正确索引
    int offsetIndex = 0;
    
    for (int i = 0; i < length; i++)
    {
        NSString *s = [string substringWithRange:NSMakeRange(i, 1)];
        
        if (([s isEqualToString:markL]) || ((stack.count > 0) && [stack[0] isEqualToString:markL]))
        {
            if (([s isEqualToString:markL]) && ((stack.count > 0) && [stack[0] isEqualToString:markL]))
            {
                for (NSString *c in stack)
                {
                    [newString appendString:c];
                }
                [stack removeAllObjects];
            }
            
            [stack addObject:s];
            
            if ([s isEqualToString:markR] || (i == string.length - 1))
            {
                NSMutableString *emojiStr = [[NSMutableString alloc] init];
                for (NSString *c in stack)
                {
                    [emojiStr appendString:c];
                }
                
                if ([[LXRichTextEmojiRun emojiStringArray] containsObject:emojiStr])
                {
                    LXRichTextEmojiRun *emoji = [[LXRichTextEmojiRun alloc] init];
                    emoji.range = NSMakeRange(i + 1 - emojiStr.length - offsetIndex, 1);
                    emoji.originalText = emojiStr;
                    [*runArray addObject:emoji];
                    [newString appendString:@" "];
                    
                    offsetIndex += emojiStr.length - 1;
                }
                else
                {
                    [newString appendString:emojiStr];
                }
                
                [stack removeAllObjects];
            }
        }
        else
        {
            [newString appendString:s];
        }
    }

    return newString;
}

@end
