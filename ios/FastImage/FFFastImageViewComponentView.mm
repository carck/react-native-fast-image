#ifdef RCT_NEW_ARCH_ENABLED

#import "FFFastImageViewComponentView.h"
#import "RCTConvert+FFFastImage.h"
#import "FFFastImageView.h"

#import <React/RCTConversions.h>
#import <React/RCTFabricComponentsPlugins.h>
#import <react/renderer/components/RNFastImageSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNFastImageSpec/Props.h>
#import <react/renderer/components/RNFastImageSpec/EventEmitters.h>

using namespace facebook::react;

@implementation FFFastImageViewComponentView
{
    FFFastImageView *fastImageView;
}

// Define a shared default props instance
static const Props::Shared &sharedDefaultProps()
{
    static auto defaultProps = std::make_shared<FastImageViewProps>();
    return defaultProps;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<FastImageViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        fastImageView = [[FFFastImageView alloc] initWithFrame:self.bounds];
        self.contentView = fastImageView;
    }
    return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &newViewProps = *std::static_pointer_cast<FastImageViewProps const>(props);
    const auto &oldViewProps = oldProps 
        ? *std::static_pointer_cast<FastImageViewProps const>(oldProps) 
        : *std::static_pointer_cast<FastImageViewProps const>(sharedDefaultProps());

    // Only parse and set source if the URI has changed
    if (newViewProps.source.uri != oldViewProps.source.uri) {
        NSMutableDictionary *imageSourcePropsDict = [NSMutableDictionary new];
        imageSourcePropsDict[@"uri"] = RCTNSStringFromStringNilIfEmpty(newViewProps.source.uri);

        NSMutableDictionary* headers = [[NSMutableDictionary alloc] init];
        for (auto &element : newViewProps.source.headers) {
            [headers setValue:RCTNSStringFromString(element.value) forKey:RCTNSStringFromString(element.name)];
        }
        if (headers.count > 0) {
            imageSourcePropsDict[@"headers"] = headers;
        }

        NSString *cacheControl;
        switch (newViewProps.source.cache) {
            case FastImageViewCache::Web:
                cacheControl = @"web";
                break;
            case FastImageViewCache::CacheOnly:
                cacheControl = @"cacheOnly";
                break;
            case FastImageViewCache::Immutable:
            default:
                cacheControl = @"immutable";
                break;
        }
        imageSourcePropsDict[@"cache"] = cacheControl;

        NSString *priority;
        switch (newViewProps.source.priority) {
            case FastImageViewPriority::Low:
                priority = @"low";
                break;
            case FastImageViewPriority::Normal:
                priority = @"normal";
                break;
            case FastImageViewPriority::High:
            default:
                priority = @"high";
                break;
        }
        imageSourcePropsDict[@"priority"] = priority;

        FFFastImageSource *imageSource = [RCTConvert FFFastImageSource:imageSourcePropsDict];
        [fastImageView setSource:imageSource];
    }

    // Apply resizeMode only if it has changed
    if (newViewProps.resizeMode != oldViewProps.resizeMode) {
        RCTResizeMode resizeMode;
        switch (newViewProps.resizeMode) {
            case FastImageViewResizeMode::Contain:
                resizeMode = RCTResizeMode::RCTResizeModeContain;
                break;
            case FastImageViewResizeMode::Stretch:
                resizeMode = RCTResizeMode::RCTResizeModeStretch;
                break;
            case FastImageViewResizeMode::Center:
                resizeMode = RCTResizeMode::RCTResizeModeCenter;
                break;
            case FastImageViewResizeMode::Cover:
            default:
                resizeMode = RCTResizeMode::RCTResizeModeCover;
                break;
        }
        [fastImageView setResizeMode:resizeMode];
    }

    if (newViewProps.tintColor != oldViewProps.tintColor) {
        [fastImageView setImageColor:RCTUIColorFromSharedColor(newViewProps.tintColor)];
    }

    [super updateProps:props oldProps:oldProps];
  
    [fastImageView didSetProps:nil];
}

- (void)prepareForRecycle
{
    [super prepareForRecycle];
    //fastImageView = [[FFFastImageView alloc] initWithFrame:self.bounds];
    //self.contentView = fastImageView;
}

@end

Class<RCTComponentViewProtocol> FastImageViewCls(void)
{
    return FFFastImageViewComponentView.class;
}

#endif