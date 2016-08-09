

#import "LXRichTextBaseRun.h"
#import "LXRichTextImageRun.h"
#import "LXHelpClass.h"

@interface LXRichTextEmojiRun : LXRichTextImageRun

+ (NSString *)analyzeText:(NSString *)string runsArray:(NSMutableArray **)runArray;

@end
