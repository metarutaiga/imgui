#import "ViewController.h"
#import "Renderer.h"
#include "imgui.h"

#if TARGET_OS_OSX
#include "imgui_impl_metal.h"
#include "imgui_impl_osx.h"
#endif

@interface ViewController ()
@property (nonatomic, readonly) MTKView *mtkView;
@property (nonatomic, strong) Renderer *renderer;
@end

@implementation ViewController

- (MTKView *)mtkView {
    return (MTKView *)self.view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mtkView.device = MTLCreateSystemDefaultDevice();

    if (!self.mtkView.device) {
        NSLog(@"Metal is not supported");
        abort();
    }

    self.renderer = [[Renderer alloc] initWithView:self.mtkView];

    [self.renderer mtkView:self.mtkView drawableSizeWillChange:self.mtkView.bounds.size];

    self.mtkView.delegate = self.renderer;

#if TARGET_OS_OSX
    ImGui_ImplOSX_AddTrackingArea(self);
#endif
}

#if TARGET_OS_OSX

- (void)viewWillAppear {
    [super viewWillAppear];
    self.view.window.delegate = self;
}

- (void)windowWillClose:(NSNotification *)notification {
    ImGui_ImplMetal_Shutdown();
    ImGui_ImplOSX_Shutdown();
    ImGui::DestroyContext();
}

- (void)mouseMoved:(NSEvent *)event {
    ImGui_ImplOSX_HandleEvent(event, self.view);
}

- (void)mouseDown:(NSEvent *)event {
    ImGui_ImplOSX_HandleEvent(event, self.view);
}

- (void)rightMouseDown:(NSEvent *)event {
    ImGui_ImplOSX_HandleEvent(event, self.view);
}

- (void)otherMouseDown:(NSEvent *)event {
    ImGui_ImplOSX_HandleEvent(event, self.view);
}

- (void)mouseUp:(NSEvent *)event {
    ImGui_ImplOSX_HandleEvent(event, self.view);
}

- (void)rightMouseUp:(NSEvent *)event {
    ImGui_ImplOSX_HandleEvent(event, self.view);
}

- (void)otherMouseUp:(NSEvent *)event {
    ImGui_ImplOSX_HandleEvent(event, self.view);
}

- (void)mouseDragged:(NSEvent *)event {
    ImGui_ImplOSX_HandleEvent(event, self.view);
}

- (void)rightMouseDragged:(NSEvent *)event {
    ImGui_ImplOSX_HandleEvent(event, self.view);
}

- (void)otherMouseDragged:(NSEvent *)event {
    ImGui_ImplOSX_HandleEvent(event, self.view);
}

- (void)scrollWheel:(NSEvent *)event {
    ImGui_ImplOSX_HandleEvent(event, self.view);
}

#elif TARGET_OS_IOS

// This touch mapping is super cheesy/hacky. We treat any touch on the screen
// as if it were a depressed left mouse button, and we don't bother handling
// multitouch correctly at all. This causes the "cursor" to behave very erratically
// when there are multiple active touches. But for demo purposes, single-touch
// interaction actually works surprisingly well.
- (void)updateIOWithTouchEvent:(UIEvent *)event {
    UITouch *anyTouch = event.allTouches.anyObject;
    CGPoint touchLocation = [anyTouch locationInView:self.view];
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(touchLocation.x, touchLocation.y);

    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches) {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled) {
            hasActiveTouch = YES;
            break;
        }
    }
    io.MouseDown[0] = hasActiveTouch;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

#endif

@end

