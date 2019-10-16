#import "NSBundle+MJRefresh.h"
#import "MJRefreshComponent.h"
#import "MJRefreshConfig.h"
@implementation NSBundle (MJRefresh)
+ (instancetype)mj_refreshBundle
{
    static NSBundle *refreshBundle = nil;
    if (refreshBundle == nil) {
        refreshBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[MJRefreshComponent class]] pathForResource:@"MJRefresh" ofType:@"bundle"]];
    }
    return refreshBundle;
}
+ (UIImage *)mj_arrowImage
{
    static UIImage *arrowImage = nil;
    if (arrowImage == nil) {
        arrowImage = [[UIImage imageWithContentsOfFile:[[self mj_refreshBundle] pathForResource:@"arrow@2x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return arrowImage;
}
+ (NSString *)mj_localizedStringForKey:(NSString *)key
{
    return [self mj_localizedStringForKey:key value:nil];
}
+ (NSString *)mj_localizedStringForKey:(NSString *)key value:(NSString *)value
{
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        NSString *language = MJRefreshConfig.defaultConfig.languageCode;
        if (!language) {
            language = [NSLocale preferredLanguages].firstObject;
        }
        if ([language hasPrefix:@"en"]) {
            language = @"en";
        } else if ([language hasPrefix:@"zh"]) {
            if ([language rangeOfString:@"Hans"].location != NSNotFound) {
                language = @"zh-Hans"; 
            } else { 
                language = @"zh-Hant"; 
            }
        } else if ([language hasPrefix:@"ko"]) {
            language = @"ko";
        } else {
            language = @"en";
        }
        bundle = [NSBundle bundleWithPath:[[NSBundle mj_refreshBundle] pathForResource:language ofType:@"lproj"]];
    }
    value = [bundle localizedStringForKey:key value:value table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}
@end
