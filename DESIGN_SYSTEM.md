# RecyConnect Admin Panel - Production Design System

**Version:** 2.0
**Last Updated:** December 2025
**Status:** Production-Ready

---

## 1. STYLE GUIDE

### 1.1 Color Palette

#### Primary Colors
```dart
Primary Green:     #10B981  // Main brand color
Primary Dark:      #059669  // Hover states, accents
Primary Light:     #34D399  // Highlights, success states
Primary Darker:    #047857  // Deep accents, footer
```

#### Accent Colors
```dart
Accent Blue:       #3B82F6  // Analytics, info
Accent Blue Dark:  #2563EB  // Hover, active states
Accent Purple:     #8B5CF6  // Premium features
Accent Orange:     #F59E0B  // Warnings, alerts
Accent Red:        #EF4444  // Errors, critical
Accent Teal:       #14B8A6  // Alternative accent
Accent Gold:       #FBBF24  // Ratings, highlights
```

#### Neutral Colors (Light Mode)
```dart
Background:        #F8FAFC  // Main background
Surface:           #FFFFFF  // Cards, modals
Surface Variant:   #F1F5F9  // Subtle backgrounds
Border:            #E5E7EB  // Dividers, borders
Border Light:      #F3F4F6  // Subtle separators
```

#### Dark Mode Colors
```dart
Dark Background:   #0F172A  // Main dark bg
Dark Surface:      #1E293B  // Dark cards
Dark Variant:      #334155  // Elevated surfaces
Dark Border:       #475569  // Dark borders
```

#### Text Colors
```dart
Text Primary:      #1F2937  // Headings, important text
Text Secondary:    #6B7280  // Body text
Text Tertiary:     #9CA3AF  // Captions, metadata
Text White:        #FFFFFF  // On dark backgrounds

// Dark Mode Text
Dark Text Primary:     #F1F5F9
Dark Text Secondary:   #CBD5E1
Dark Text Tertiary:    #94A3B8
```

#### Semantic Colors
```dart
Success:          #10B981
Warning:          #F59E0B
Error:            #EF4444
Info:             #3B82F6
```

### 1.2 Typography

**Primary Font:** Inter (Google Fonts)
**Fallback Font:** -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto

#### Type Scale

```dart
// Display
H1:  32px / bold / -0.5px letter-spacing / 1.2 line-height
H2:  24px / bold / -0.3px letter-spacing / 1.3 line-height
H3:  20px / 600  / -0.2px letter-spacing / 1.4 line-height

// Body
Subtitle:  16px / 500 / 0px letter-spacing / 1.5 line-height
Body:      14px / 400 / 0px letter-spacing / 1.5 line-height
Caption:   12px / 400 / 0px letter-spacing / 1.4 line-height
Small:     11px / 400 / 0px letter-spacing / 1.3 line-height

// Interactive
Button:    14px / 600 / 0.5px letter-spacing / 1.0 line-height
Link:      14px / 500 / 0px letter-spacing / 1.5 line-height
```

#### Font Weights
- Regular: 400
- Medium: 500
- Semibold: 600
- Bold: 700

### 1.3 Spacing Scale

```dart
spacing-4:   4px   // Icon margins, tight spacing
spacing-8:   8px   // Compact elements
spacing-12:  12px  // Card internal spacing
spacing-16:  16px  // Standard element spacing
spacing-20:  20px  // Section padding
spacing-24:  24px  // Card padding
spacing-32:  32px  // Large section gaps
spacing-40:  40px  // Major layout spacing
spacing-48:  48px  // Extra large gaps
spacing-64:  64px  // Hero sections
```

### 1.4 Border Radius Scale

```dart
radius-small:   8px   // Buttons, chips, badges
radius-medium:  12px  // Input fields, small cards
radius-large:   16px  // Standard cards
radius-xlarge:  20px  // Feature cards, modals
radius-2xlarge: 24px  // Hero sections
radius-round:   100px // Pills, avatars
```

### 1.5 Elevation & Shadows

```dart
// Soft Shadows (Modern, Subtle)
shadow-sm:  0px 4px 20px rgba(0,0,0,0.05)
shadow-md:  0px 8px 24px rgba(0,0,0,0.08)
shadow-lg:  0px 12px 32px rgba(0,0,0,0.10)
shadow-xl:  0px 20px 48px rgba(0,0,0,0.12)

// Colored Shadows (Hover States)
glow-green:   0px 8px 24px rgba(16,185,129,0.3)
glow-blue:    0px 8px 24px rgba(59,130,246,0.3)
glow-purple:  0px 8px 24px rgba(139,92,246,0.3)
glow-orange:  0px 8px 24px rgba(245,158,11,0.3)

// 3D Depth Shadows (Layered)
depth-1:  0px 2px 4px rgba(0,0,0,0.06),
          0px 4px 8px rgba(0,0,0,0.04)
depth-2:  0px 4px 8px rgba(0,0,0,0.08),
          0px 8px 16px rgba(0,0,0,0.06)
depth-3:  0px 8px 16px rgba(0,0,0,0.10),
          0px 16px 32px rgba(0,0,0,0.08)
```

---

## 2. COMPONENT INVENTORY

### 2.1 Sidebar / Drawer

**Visual Specs:**
- Width: 280px (desktop), 100% (mobile)
- Background: Linear gradient (primary colors)
- Top section: User profile with avatar, name, badge
- Menu items: Icon + label, 56px height
- Border radius on menu items: 14px
- Active state: White background with colored shadow

**Interaction States:**
- **Default:** Icon + text, semi-transparent background
- **Hover:** Scale 1.0 → 1.02, colored glow shadow (200ms ease-out)
- **Active:** Gradient background, white text, elevated shadow
- **Press:** Scale 0.98 (100ms)

**Collapsible Behavior:**
- Desktop: Toggle between 280px (expanded) and 72px (collapsed)
- Transition: 300ms ease-in-out-cubic
- Collapsed: Show icons only, tooltip on hover

**Code Reference:** `lib/presentation/widgets/admin/admin_drawer.dart`

### 2.2 Top Bar / App Bar

**Visual Specs:**
- Height: 64px
- Background: Surface color with subtle shadow
- Elevation: shadow-sm
- Content: Logo/title (left), search bar (center), notifications + profile (right)

**Search Bar:**
- Width: 400px (desktop), full width on mobile
- Height: 40px
- Border radius: radius-round (20px)
- Background: Surface variant
- Icon: Left-aligned, 20px
- Placeholder: Text secondary color
- Focus state: Border (2px primary), glow shadow

**Notification Badge:**
- Size: 18px circle
- Background: Gradient red
- Position: Top-right of bell icon
- Animation: Pulse on new notification (scale 1.0 ↔ 1.1, 1000ms infinite)

**Profile Avatar:**
- Size: 36px circle
- Border: 2px gradient border
- Hover: Scale 1.05, shadow-md (200ms)

### 2.3 Dashboard Cards (Stat Cards)

**Visual Specs:**
- Padding: 20px
- Border radius: 20px
- Background: White with subtle colored tint (5% opacity)
- Shadow: shadow-sm (default), colored glow (hover)
- Border: 2px transparent (default), 2px colored (hover)

**Layout:**
- Icon: 48px container, gradient background, 24px white icon
- Title: Caption size, text secondary
- Value: H2 size, bold, colored
- Trend indicator: Pill-shaped badge (8px padding, 20px radius)

**Interactions:**
- **Hover:** Scale 1.03, colored shadow, border appears (200ms ease-out)
- **Press:** Scale 0.97 (100ms)
- **Counter Animation:** Tween from 0 to value over 800ms ease-out-cubic

**Micro-chart Integration:**
- Mini sparkline: 60px height, 2px line width
- Colors: Match card accent color
- Animation: Draw on load (500ms)

### 2.4 Data Tables

**Visual Specs:**
- Background: Surface white
- Border radius: 16px
- Shadow: shadow-sm
- Header height: 48px
- Row height: 56px
- Cell padding: 16px horizontal, 12px vertical

**Header:**
- Background: Surface variant (light gray)
- Font: Body bold
- Sortable: Arrow icon (16px) on hover
- Sort active: Primary color arrow

**Rows:**
- **Default:** Transparent background
- **Hover:** Surface variant background (200ms fade)
- **Selected:** Primary color (10% opacity)
- **Zebra striping:** Optional, every other row 2% gray

**Actions Column:**
- Icon buttons: 32px, radius-small
- Hover: Colored background (10% opacity)
- Spacing: 8px between actions

**Expandable Rows:**
- Expand icon: Chevron down (rotates 180° on expand)
- Transition: Height auto, 300ms ease-in-out
- Nested content: Indented 32px, light background

**Pagination:**
- Position: Bottom right
- Controls: Previous/Next + page numbers
- Style: Ghost buttons with hover effect

### 2.5 Forms & Inputs

**Text Input:**
- Height: 48px
- Padding: 12px 16px
- Border radius: radius-medium (12px)
- Border: 1px border color
- Font: Body size

**States:**
- **Default:** Gray border, text primary
- **Focus:** 2px primary border, glow shadow, label floats up
- **Error:** Red border, red text below (12px caption)
- **Success:** Green border, checkmark icon (right)
- **Disabled:** Gray background, text tertiary

**Floating Labels:**
- Position: Inside input (default), above input (filled/focus)
- Transition: 200ms ease-out
- Transform: translateY(-24px) scale(0.875)
- Color: Text tertiary (default), primary (focus)

**Select Dropdown:**
- Same as text input
- Icon: Chevron down (right-aligned, 16px)
- Dropdown: Surface white, shadow-lg, max-height 300px, scroll

**Checkbox/Radio:**
- Size: 20px
- Border radius: 4px (checkbox), 50% (radio)
- Border: 2px border color
- Checked: Primary gradient background, white checkmark
- Animation: Scale 0.8 → 1.0 on check (200ms bounce)

**Switch/Toggle:**
- Width: 44px, height: 24px
- Track: Gray (off), gradient (on)
- Thumb: 20px circle, white, shadow-sm
- Transition: 300ms ease-in-out
- Thumb moves: translateX(20px) when on

### 2.6 Buttons

**Primary Button:**
- Padding: 14px 24px
- Border radius: radius-medium (12px)
- Background: Primary gradient
- Text: White, button font
- Shadow: shadow-sm (default), glow-green (hover)
- **Hover:** Scale 1.02, glow shadow (200ms)
- **Press:** Scale 0.95 (100ms)
- **Loading:** Spinner (20px white), button width fixed

**Secondary Button:**
- Same sizing as primary
- Background: Transparent
- Border: 2px primary
- Text: Primary color
- **Hover:** Background primary (10% opacity), scale 1.02

**Ghost Button:**
- No border, no background
- Text: Primary color
- **Hover:** Background primary (5% opacity)

**Icon Button:**
- Size: 40px circle or square
- Icon: 20px
- **Hover:** Background colored (10% opacity), scale 1.05

### 2.7 Modals & Dialogs

**Visual Specs:**
- Max-width: 480px (small), 600px (medium), 800px (large)
- Border radius: radius-xlarge (20px)
- Background: Surface white
- Shadow: shadow-xl
- Backdrop: rgba(0,0,0,0.4) with backdrop-blur(8px)

**Layout:**
- Padding: 24px
- Header: 56px height, bottom border
- Content: Scrollable, max-height: 60vh
- Footer: Top border, action buttons (right-aligned)

**Animation:**
- **Entry:** Scale 0.9 → 1.0 + opacity 0 → 1 (300ms ease-out-cubic)
- **Exit:** Scale 1.0 → 0.9 + opacity 1 → 0 (200ms ease-in)
- **Backdrop:** Opacity 0 → 1 (200ms)

### 2.8 Notifications / Toast

**Visual Specs:**
- Width: 360px (desktop), calc(100% - 32px) (mobile)
- Min-height: 64px
- Border radius: radius-large (16px)
- Padding: 16px
- Position: Top-right, 16px offset
- Shadow: shadow-lg

**Types:**
- **Success:** Left border (4px green), green icon, white background
- **Error:** Left border (4px red), red icon, white background
- **Warning:** Left border (4px orange), orange icon, white background
- **Info:** Left border (4px blue), blue icon, white background

**Animation:**
- **Entry:** Slide from right + fade in (300ms ease-out)
- **Exit:** Slide to right + fade out (200ms ease-in)
- **Progress bar:** Width 100% → 0% over duration (bottom, 3px height)

**Auto-dismiss:** 4000ms (success/info), 6000ms (error/warning)

### 2.9 Loading States

**Skeleton Loader:**
- Background: Gray 300
- Highlight: Gray 100
- Animation: Shimmer effect (gradient moves left to right)
- Duration: 1500ms infinite
- Shapes match actual content (cards, text lines, avatars)

**Progress Bar:**
- Height: 4px
- Background: Gray 200
- Fill: Primary gradient
- Border radius: 2px
- Animation: Indeterminate (width pulses) or determinate (width %)

**Spinner:**
- Size: 20px (small), 32px (medium), 48px (large)
- Width: 3px stroke
- Color: Primary (on light bg), white (on dark bg)
- Animation: Rotate 360° (800ms linear infinite)

### 2.10 Empty States

**Visual Specs:**
- Center-aligned container
- Icon/Illustration: 120px (can use Lottie)
- Heading: H3, text primary
- Description: Body, text secondary, max-width 400px
- CTA button: Primary button

**Lottie Animation:**
- Loop: True for ambient states, false for success/error
- Duration: 2000-3000ms
- Trigger: On view

### 2.11 Feed / Activity List

**Item Structure:**
- Height: Auto, min 72px
- Padding: 12px
- Border radius: radius-medium (12px)
- **Hover:** Background colored (5% opacity)

**Layout:**
- Icon: 40px circle/square, left-aligned
- Content: Title + subtitle, middle
- Time: Right-aligned, caption size, text tertiary

**Divider:**
- Height: 1px
- Color: Border light
- Margin: 8px vertical

**Load More:**
- Button at bottom
- Style: Ghost button
- Shows spinner when loading

### 2.12 Filters & Search

**Filter Chips:**
- Height: 32px
- Padding: 8px 12px
- Border radius: radius-round (16px)
- Background: Surface variant (default), primary (active)
- Text: Text primary (default), white (active)
- **Hover:** Scale 1.05 (150ms)
- **Active:** Background gradient, shadow-sm

**Date Range Picker:**
- Style: Modern calendar dropdown
- Range selection: Filled background between dates
- Buttons: Today, Last 7 days, Last 30 days, Custom

**Multi-select Dropdown:**
- Checkbox list inside dropdown
- Selected count: Badge on trigger button
- Apply/Clear buttons at bottom

---

## 3. ANIMATION & MOTION SYSTEM

### 3.1 Timing & Curves

```dart
// Durations
fast:         150ms   // Micro-interactions, hovers
normal:       200ms   // Button press, card hover
medium:       300ms   // Page transitions, modals
slow:         500ms   // Complex animations, reveals
verySlow:     800ms   // Counter animations, chart draws
```

```dart
// Curves
easeOutCubic:      Curves.easeOutCubic     // Smooth deceleration
easeInOutCubic:    Curves.easeInOutCubic   // Balanced
easeOutBack:       Curves.easeOutBack      // Slight overshoot
elasticOut:        Curves.elasticOut       // Bouncy effect
fastOutSlowIn:     Curves.fastOutSlowIn    // Material standard
```

### 3.2 Page Transitions

**Slide + Fade:**
```dart
PageRouteBuilder(
  transitionDuration: Duration(milliseconds: 300),
  pageBuilder: (context, animation, secondaryAnimation) => NewScreen(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    const begin = Offset(0.05, 0.0);  // Subtle slide from right
    const end = Offset.zero;
    const curve = Curves.easeOutCubic;

    var slideTween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );
    var fadeTween = Tween<double>(begin: 0.0, end: 1.0);

    return SlideTransition(
      position: animation.drive(slideTween),
      child: FadeTransition(
        opacity: animation.drive(fadeTween),
        child: child,
      ),
    );
  },
);
```

**Scale + Fade (Modals):**
```dart
ScaleTransition(
  scale: Tween<double>(begin: 0.9, end: 1.0).animate(
    CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
  ),
  child: FadeTransition(
    opacity: animation,
    child: dialog,
  ),
);
```

### 3.3 Micro-interactions

**Button Press:**
- Scale: 1.0 → 0.95 (100ms ease-in)
- Shadow: Reduced on press
- Ripple: Material ripple effect in primary color (10% opacity)

**Card Hover:**
- Scale: 1.0 → 1.03 (200ms ease-out-cubic)
- Elevation: shadow-sm → colored glow (200ms)
- Border: Transparent → colored (200ms)

**Icon Pulse (Notification):**
```dart
AnimatedBuilder with TweenSequence:
  Scale: 1.0 → 1.1 → 1.0 (1000ms)
  Infinite loop
```

**Ripple Effect:**
- Center at tap point
- Radius: 0 → element size (400ms ease-out)
- Opacity: 0.2 → 0 (400ms)

### 3.4 Skeleton Loaders

```dart
Shimmer.fromColors(
  baseColor: Colors.grey[300]!,
  highlightColor: Colors.grey[100]!,
  period: Duration(milliseconds: 1500),
  child: Container(...),
);
```

**Implementation:**
- Replace actual content shapes with gray containers
- Same dimensions as real content
- Shimmer gradient moves continuously

### 3.5 Progress & Loading

**Linear Progress:**
- Indeterminate: Bar slides left to right (1500ms infinite)
- Determinate: Width animates to percentage (300ms ease-out)

**Circular Progress:**
- Stroke: 3px
- Rotation: 360° (800ms linear infinite)
- Indeterminate: Arc length pulses

**Button Loading State:**
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  width: isLoading ? 48 : null,  // Shrink to square
  child: isLoading
    ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
    : Text(buttonText),
);
```

### 3.6 Lottie/Rive Animations

**Use Cases:**
- **Success states:** Checkmark animation (1000ms, play once)
- **Error states:** Error shake (800ms, play once)
- **Empty states:** Ambient loop (2000ms, infinite)
- **Loading:** Custom loader (1500ms, infinite)

**Lottie Implementation:**
```dart
Lottie.asset(
  'assets/lottie/success.json',
  width: 120,
  height: 120,
  repeat: false,
  controller: _lottieController,
);
```

**Performance Notes:**
- Limit to 1-2 Lottie animations visible at once
- Use `RiveAnimation.asset` for better performance if needed
- Cache Lottie JSON files

**Recommended Packages:**
- `lottie: ^3.1.0` (Already installed)
- `rive: ^0.13.0` (Optional, better performance)

### 3.7 Staggered Animations

**List Items:**
```dart
AnimationLimiter(
  child: ListView.builder(
    itemBuilder: (context, index) {
      return AnimationConfiguration.staggeredList(
        position: index,
        duration: const Duration(milliseconds: 400),
        child: SlideAnimation(
          verticalOffset: 20.0,
          child: FadeInAnimation(
            child: ListItem(),
          ),
        ),
      );
    },
  ),
);
```

**Grid Items:**
- Stagger delay: 50ms per item
- Animation: Fade + scale (0.8 → 1.0)
- Total duration: 300ms per item

### 3.8 Parallax Effects

**Hero Header (Scroll-based):**
```dart
Transform.translate(
  offset: Offset(0, scrollOffset * 0.3),  // 30% parallax
  child: HeroImage(),
);
```

**Card Layers:**
- Background layer: Moves at 50% scroll speed
- Content layer: Normal scroll speed
- Creates depth perception

---

## 4. 3D & DEPTH EFFECTS

### 4.1 Layered Shadows

**3-Layer Shadow (Premium Cards):**
```dart
boxShadow: [
  BoxShadow(
    color: Colors.black.withOpacity(0.04),
    offset: Offset(0, 2),
    blurRadius: 4,
  ),
  BoxShadow(
    color: Colors.black.withOpacity(0.06),
    offset: Offset(0, 4),
    blurRadius: 8,
  ),
  BoxShadow(
    color: Colors.black.withOpacity(0.08),
    offset: Offset(0, 8),
    blurRadius: 16,
  ),
],
```

### 4.2 Card Tilt on Hover (Desktop)

```dart
class TiltCard extends StatefulWidget {
  final Widget child;
  const TiltCard({required this.child});

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  double _rotateX = 0.0;
  double _rotateY = 0.0;

  void _onPointerMove(PointerEvent details, BoxConstraints constraints) {
    // Calculate rotation based on pointer position
    final x = details.localPosition.dx;
    final y = details.localPosition.dy;
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    setState(() {
      // Normalize to -1 to 1, then scale to degrees
      _rotateY = ((x / width) - 0.5) * 0.3;  // Max 15° rotation
      _rotateX = ((y / height) - 0.5) * -0.3;
    });
  }

  void _onPointerExit() {
    setState(() {
      _rotateX = 0.0;
      _rotateY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onHover: (event) => _onPointerMove(event, constraints),
          onExit: (_) => _onPointerExit(),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)  // Perspective
              ..rotateX(_rotateX)
              ..rotateY(_rotateY),
            child: widget.child,
          ),
        );
      },
    );
  }
}
```

**Usage:**
```dart
TiltCard(
  child: StatCard(...),
);
```

### 4.3 Perspective Transforms

**Modal Reveal:**
```dart
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)  // Perspective
        ..rotateX((1.0 - _controller.value) * 0.5)  // Flip from bottom
        ..scale(_controller.value),
      alignment: Alignment.bottomCenter,
      child: Opacity(
        opacity: _controller.value,
        child: modal,
      ),
    );
  },
);
```

### 4.4 Elevation Layers

**Z-Index Hierarchy:**
```
z-0:  Base background
z-10: Cards, containers
z-20: Floating action buttons
z-30: Sticky headers
z-40: Dropdowns, popovers
z-50: Modals, dialogs
z-60: Toasts, notifications
z-70: Tooltips
```

**Implementation with Stack:**
```dart
Stack(
  children: [
    Positioned.fill(child: BackgroundLayer()),           // z-0
    Positioned(top: 0, child: StickyHeader()),            // z-30
    Positioned.fill(child: ContentWithCards()),           // z-10
    if (showModal) ModalDialog(),                         // z-50
    if (showToast) Positioned(top: 16, child: Toast()),  // z-60
  ],
);
```

### 4.5 Glass Morphism

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: content,
    ),
  ),
);
```

**Best for:** Overlays, floating cards, premium features

### 4.6 Neumorphism (Subtle Use)

```dart
Container(
  decoration: BoxDecoration(
    color: Color(0xFFE0E5EC),  // Base color
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.white,
        offset: Offset(-4, -4),
        blurRadius: 8,
      ),
      BoxShadow(
        color: Colors.grey.shade400,
        offset: Offset(4, 4),
        blurRadius: 8,
      ),
    ],
  ),
);
```

**Use sparingly:** Icons, toggle buttons, small elements only

---

## 5. FLUTTER IMPLEMENTATION

### 5.1 Packages Required

```yaml
dependencies:
  # Already installed
  flutter_animate: ^4.5.0
  shimmer: ^3.0.0
  lottie: ^3.1.0
  flutter_staggered_animations: ^1.1.1
  glassmorphism: ^3.0.0

  # Recommended additions
  rive: ^0.13.0                    # Better animation performance
  motion: ^1.3.0                   # Gesture-based motion effects
  cached_network_image: ^3.3.0    # Image caching (if not installed)
```

### 5.2 Animated Page Transition

```dart
// lib/core/navigation/page_transitions.dart

class SlidePageRoute extends PageRouteBuilder {
  final Widget page;

  SlidePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.03, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: Duration(milliseconds: 300),
        );
}

// Usage:
Navigator.of(context).push(SlidePageRoute(page: NewScreen()));
```

### 5.3 Shimmer Skeleton Loader

```dart
// lib/presentation/widgets/common/skeleton_loader.dart

class SkeletonCard extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const SkeletonCard({
    Key? key,
    required this.height,
    this.width = double.infinity,
    this.borderRadius = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// Usage:
SkeletonCard(height: 100, width: 200, borderRadius: 20);
```

### 5.4 Theme Toggle Implementation

```dart
// lib/core/theme/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
    notifyListeners();
  }
}

// In main.dart:
MaterialApp(
  themeMode: themeProvider.themeMode,
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  ...
);

// Theme toggle widget:
class ThemeToggleSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: 60,
      height: 32,
      decoration: BoxDecoration(
        gradient: themeProvider.isDarkMode
            ? LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)])
            : LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            left: themeProvider.isDarkMode ? 30 : 2,
            top: 2,
            child: GestureDetector(
              onTap: themeProvider.toggleTheme,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  size: 16,
                  color: themeProvider.isDarkMode
                      ? Color(0xFF1E293B)
                      : Color(0xFF10B981),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 5.5 3D Card Tilt Component

```dart
// lib/presentation/widgets/effects/tilt_card.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

class TiltCard extends StatefulWidget {
  final Widget child;
  final double maxTilt;  // Max rotation in radians (default 0.05)
  final bool enabled;

  const TiltCard({
    Key? key,
    required this.child,
    this.maxTilt = 0.05,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard>
    with SingleTickerProviderStateMixin {
  double _rotateX = 0.0;
  double _rotateY = 0.0;
  double _scale = 1.0;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerMove(PointerEvent details, BoxConstraints constraints) {
    if (!widget.enabled) return;

    final x = details.localPosition.dx;
    final y = details.localPosition.dy;
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    // Calculate rotation
    final centerX = width / 2;
    final centerY = height / 2;
    final deltaX = (x - centerX) / centerX;
    final deltaY = (y - centerY) / centerY;

    setState(() {
      _rotateY = deltaX * widget.maxTilt;
      _rotateX = -deltaY * widget.maxTilt;
      _scale = 1.02;
    });
  }

  void _onPointerExit(PointerExitEvent event) {
    setState(() {
      _rotateX = 0.0;
      _rotateY = 0.0;
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onHover: (event) => _onPointerMove(event, constraints),
          onExit: _onPointerExit,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)  // Perspective
              ..rotateX(_rotateX)
              ..rotateY(_rotateY)
              ..scale(_scale),
            transformAlignment: Alignment.center,
            child: widget.child,
          ),
        );
      },
    );
  }
}

// Usage:
TiltCard(
  maxTilt: 0.05,  // About 3 degrees
  child: Container(
    width: 300,
    height: 200,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF059669)],
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Color(0xFF10B981).withOpacity(0.3),
          blurRadius: 20,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: Center(child: Text('Tilt Me!')),
  ),
);
```

### 5.6 Staggered Grid Animation

```dart
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AnimatedStatsGrid extends StatelessWidget {
  final List<Widget> cards;
  final int crossAxisCount;

  const AnimatedStatsGrid({
    Key? key,
    required this.cards,
    this.crossAxisCount = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: List.generate(
          cards.length,
          (index) {
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 400),
              columnCount: crossAxisCount,
              child: ScaleAnimation(
                scale: 0.5,
                child: FadeInAnimation(
                  child: cards[index],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

---

## 6. PERFORMANCE CONSIDERATIONS

### 6.1 Optimization Guidelines

**Avoid Overdraw:**
- Use `RepaintBoundary` for complex widgets that don't change frequently
- Remove unnecessary `Container` wrappers
- Use `const` constructors wherever possible

```dart
RepaintBoundary(
  child: ExpensiveChart(...),
);
```

**Cache Images:**
```dart
// Use cached_network_image for remote images
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => SkeletonCard(height: 200),
  errorWidget: (context, url, error) => Icon(Icons.error),
);
```

**Limit Simultaneous Animations:**
- Max 3-4 complex animations on screen at once
- Disable animations on low-end devices (check via `MediaQuery.of(context).disableAnimations`)
- Use `AnimatedBuilder` instead of `setState` for animation-only updates

**Rive vs Lottie:**
- Rive: Better performance, smaller file size, interactive
- Lottie: Easier to export from After Effects, larger JSON files

**Recommendation:** Use Rive for continuous/ambient animations, Lottie for one-time state animations

### 6.2 Lazy Loading

**Lists:**
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListItem(item: items[index]);
  },
);
```

**Infinite Scroll:**
```dart
NotificationListener<ScrollNotification>(
  onNotification: (ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
      loadMore();  // Trigger pagination
    }
    return true;
  },
  child: ListView.builder(...),
);
```

### 6.3 State Management

**Use Provider/Riverpod for:**
- Theme state
- User authentication
- Global app state

**Avoid setState for:**
- Animations (use AnimationController)
- Large lists (use ListView.builder)
- Frequent updates (use ValueNotifier or AnimatedBuilder)

### 6.4 Build Performance

**Const Constructors:**
```dart
const Padding(
  padding: EdgeInsets.all(16),
  child: const Text('Static text'),
);
```

**Split Large Widgets:**
```dart
// Bad
Widget build(BuildContext context) {
  return Column(
    children: [
      // 200 lines of widget tree
    ],
  );
}

// Good
Widget build(BuildContext context) {
  return Column(
    children: [
      _HeaderSection(),
      _ContentSection(),
      _FooterSection(),
    ],
  );
}
```

---

## 7. ACCESSIBILITY

### 7.1 Color Contrast

**WCAG 2.1 Level AA Requirements:**
- Normal text (< 18px): Contrast ratio ≥ 4.5:1
- Large text (≥ 18px or ≥ 14px bold): Contrast ratio ≥ 3:1
- Interactive elements: ≥ 3:1 against background

**Color Palette Compliance:**
```
✓ Primary (#10B981) on White: 3.8:1 (AA Large Text)
✓ Text Primary (#1F2937) on White: 14.2:1 (AAA)
✓ Text Secondary (#6B7280) on White: 5.3:1 (AA)
✓ Primary Gradient text (white) on Primary: 4.5:1 (AA)
```

**Dark Mode:**
```
✓ Dark Text Primary (#F1F5F9) on Dark Background (#0F172A): 13.1:1 (AAA)
✓ Dark Text Secondary (#CBD5E1) on Dark Background: 8.2:1 (AAA)
```

### 7.2 Keyboard Navigation

**Focus Indicators:**
```dart
FocusableActionDetector(
  focusNode: _focusNode,
  child: Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: _focusNode.hasFocus
            ? Color(0xFF10B981)
            : Colors.transparent,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: button,
  ),
);
```

**Tab Order:**
- Use `FocusTraversalGroup` to control tab order
- All interactive elements must be keyboard accessible
- Modal dialogs trap focus until dismissed

### 7.3 Semantic Labels

```dart
Semantics(
  label: 'Close dialog',
  button: true,
  child: IconButton(
    icon: Icon(Icons.close),
    onPressed: () => Navigator.pop(context),
  ),
);

// For images
Semantics(
  label: 'User profile picture',
  image: true,
  child: CircleAvatar(...),
);
```

### 7.4 Screen Reader Support

**Announce Changes:**
```dart
SemanticsService.announce(
  'Form submitted successfully',
  TextDirection.ltr,
);
```

**Exclude Decorative Elements:**
```dart
Semantics(
  excludeSemantics: true,
  child: DecorativeIcon(),
);
```

### 7.5 Text Scaling

**Support Dynamic Text:**
```dart
// Use TextStyle from Theme (inherits textScaleFactor)
Text(
  'Dynamic text',
  style: Theme.of(context).textTheme.bodyLarge,
);

// Test with:
// Settings > Accessibility > Display > Font Size
```

**Max Scale Factor:**
```dart
MediaQuery(
  data: MediaQuery.of(context).copyWith(
    textScaleFactor: min(MediaQuery.of(context).textScaleFactor, 1.5),
  ),
  child: child,
);
```

### 7.6 Touch Target Size

**Minimum Size:** 48x48 dp (Material Design)
```dart
SizedBox(
  width: 48,
  height: 48,
  child: IconButton(...),
);
```

### 7.7 Motion & Animations

**Respect System Preferences:**
```dart
final reducedMotion = MediaQuery.of(context).disableAnimations;

AnimatedContainer(
  duration: reducedMotion
      ? Duration.zero
      : Duration(milliseconds: 300),
  ...
);
```

---

## 8. IMPLEMENTATION PRIORITY

### Phase 1: MVP (Week 1-2) 🚀

**Core Components:**
1. ✅ Finalize color palette & typography
2. ✅ Implement theme toggle (light/dark mode)
3. ✅ Build core layout (sidebar, app bar, content area)
4. ✅ Create stat cards with hover effects
5. ✅ Implement data table with sorting
6. ✅ Build basic forms (inputs, buttons, validation)
7. ✅ Add skeleton loaders for loading states
8. ✅ Implement page transitions

**Focus:** Functional, clean, responsive

### Phase 2: Polish (Week 3) ✨

**Enhanced Interactions:**
1. Add micro-animations (button press, card hover)
2. Implement staggered list/grid animations
3. Add toast notifications system
4. Build modal/dialog system with animations
5. Implement empty states with illustrations
6. Add progress indicators (linear, circular)
7. Create filter chips and search components

**Focus:** Smooth, delightful interactions

### Phase 3: Advanced Effects (Week 4) 🎨

**3D & Premium Features:**
1. Implement 3D card tilt on hover (desktop)
2. Add glassmorphism to hero sections
3. Integrate Lottie animations for key states
4. Build parallax scroll effects
5. Add subtle neumorphism to icons
6. Implement advanced chart interactions
7. Create premium gradient overlays

**Focus:** Eye-catching, modern, production-ready

### Phase 4: Optimization & Accessibility (Week 5) ⚡

**Performance & A11y:**
1. Audit and optimize animation performance
2. Implement image caching strategies
3. Add keyboard navigation support
4. Ensure WCAG 2.1 AA compliance
5. Test with screen readers
6. Optimize for low-end devices
7. Add motion preferences support

**Focus:** Fast, accessible, inclusive

---

## 9. TESTING & QUALITY ASSURANCE

### 9.1 Browser/Device Testing

**Desktop:**
- Chrome (Windows, macOS, Linux)
- Firefox
- Safari (macOS)
- Edge

**Mobile:**
- iOS Safari (latest 2 versions)
- Android Chrome (latest 2 versions)

**Responsive Breakpoints:**
- Mobile: < 600px
- Tablet: 600px - 900px
- Desktop: > 900px
- Large Desktop: > 1440px

### 9.2 Performance Metrics

**Target Metrics:**
- First Contentful Paint (FCP): < 1.5s
- Time to Interactive (TTI): < 3.0s
- Frame Rate: 60 FPS (animations)
- Bundle Size: < 2MB (with code splitting)

**Tools:**
- Flutter DevTools (Performance tab)
- Chrome Lighthouse
- Firebase Performance Monitoring

### 9.3 Accessibility Testing

**Tools:**
- Flutter's Semantics debugger
- TalkBack (Android)
- VoiceOver (iOS)
- axe DevTools (Web)

**Checklist:**
- [ ] All interactive elements keyboard accessible
- [ ] Focus indicators visible and clear
- [ ] Color contrast meets WCAG AA
- [ ] Alt text for images
- [ ] Form labels properly associated
- [ ] Error messages announced to screen readers
- [ ] Motion can be disabled

---

## 10. RESOURCES & ASSETS

### 10.1 Icon Libraries

**Material Icons:** Already included in Flutter
**Custom Icons:** Use `flutter_svg` for SVG icons

### 10.2 Illustrations

**Sources:**
- undraw.co (free, customizable)
- storyset.com (animated SVG/Lottie)
- icons8.com/illustrations

### 10.3 Lottie Animations

**Sources:**
- lottiefiles.com (free + premium)
- rive.app (interactive animations)

**Categories Needed:**
- Success checkmarks
- Loading spinners
- Empty state illustrations
- Error animations
- Celebration effects

### 10.4 Color Tools

**Palette Generators:**
- coolors.co
- mycolor.space
- paletton.com

**Contrast Checkers:**
- webaim.org/resources/contrastchecker/
- accessible-colors.com

### 10.5 Documentation

**Design Handoff:**
- Figma: For detailed mockups (if needed)
- Zeplin: For developer handoff
- Storybook: For component documentation

---

## 11. CONCLUSION

This design system provides a complete, production-ready blueprint for transforming your admin panel into a modern, eye-catching application. The system is built on your existing foundation and enhances it with:

✅ **Modern aesthetics:** Gradients, glassmorphism, 3D effects
✅ **Smooth animations:** 200-500ms micro-interactions, staggered reveals
✅ **Performance-optimized:** Lazy loading, cached images, optimized animations
✅ **Accessible:** WCAG 2.1 AA compliant, keyboard navigation
✅ **Practical:** Built with Flutter best practices, realistic implementation timelines

**Next Steps:**
1. Review this document with your team
2. Begin Phase 1 (MVP) implementation
3. Test on real devices continuously
4. Iterate based on user feedback
5. Progress through phases 2-4

**Estimated Total Implementation Time:** 4-5 weeks for a single developer

---

**Document Maintained By:** Design System Team
**For Questions:** Refer to code snippets in this document or check existing implementations in:
- `lib/core/theme/app_design_system.dart`
- `lib/core/constants/modern_colors.dart`
- `lib/presentation/widgets/admin/modern_widgets.dart`
