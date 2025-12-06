# Design System Quick Reference

One-page cheat sheet for RecyConnect Design System

---

## Colors (Copy-Paste Ready)

```dart
// Primary
Color(0xFF10B981)  // Primary Green
Color(0xFF059669)  // Primary Dark
Color(0xFF34D399)  // Primary Light

// Accents
Color(0xFF3B82F6)  // Blue
Color(0xFF8B5CF6)  // Purple
Color(0xFFF59E0B)  // Orange
Color(0xFFEF4444)  // Red

// Text
Color(0xFF1F2937)  // Primary
Color(0xFF6B7280)  // Secondary
Color(0xFF9CA3AF)  // Tertiary

// Backgrounds
Color(0xFFF8FAFC)  // Light BG
Color(0xFFFFFFFF)  // Surface
Color(0xFF0F172A)  // Dark BG
```

---

## Gradients

```dart
// Primary Gradient
LinearGradient(
  colors: [Color(0xFF10B981), Color(0xFF059669)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)

// Blue Gradient
LinearGradient(
  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)

// Orange Gradient
LinearGradient(
  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

---

## Typography

```dart
// Headings
fontSize: 32, fontWeight: FontWeight.bold    // H1
fontSize: 24, fontWeight: FontWeight.bold    // H2
fontSize: 20, fontWeight: FontWeight.w600    // H3

// Body
fontSize: 16, fontWeight: FontWeight.w500    // Subtitle
fontSize: 14, fontWeight: FontWeight.w400    // Body
fontSize: 12, fontWeight: FontWeight.w400    // Caption
```

---

## Spacing

```dart
4px   // Tight
8px   // Compact
12px  // Small
16px  // Standard
20px  // Medium
24px  // Large
32px  // XLarge
48px  // XXLarge
```

---

## Border Radius

```dart
BorderRadius.circular(8)   // Small - Buttons
BorderRadius.circular(12)  // Medium - Inputs
BorderRadius.circular(16)  // Large - Cards
BorderRadius.circular(20)  // XLarge - Features
BorderRadius.circular(100) // Round - Pills
```

---

## Shadows

```dart
// Soft Shadow (Cards)
BoxShadow(
  color: Colors.black.withOpacity(0.08),
  offset: Offset(0, 8),
  blurRadius: 24,
)

// Colored Glow (Hover)
BoxShadow(
  color: Color(0xFF10B981).withOpacity(0.3),
  offset: Offset(0, 8),
  blurRadius: 24,
)

// 3D Depth (Layered)
[
  BoxShadow(
    color: Colors.black.withOpacity(0.08),
    offset: Offset(0, 4),
    blurRadius: 8,
  ),
  BoxShadow(
    color: Colors.black.withOpacity(0.06),
    offset: Offset(0, 8),
    blurRadius: 16,
  ),
]
```

---

## Animation Durations

```dart
Duration(milliseconds: 150)  // Fast - Hover
Duration(milliseconds: 200)  // Normal - Press
Duration(milliseconds: 300)  // Medium - Transition
Duration(milliseconds: 500)  // Slow - Complex
Duration(milliseconds: 800)  // Very Slow - Counter
```

---

## Animation Curves

```dart
Curves.easeOutCubic     // Default - Smooth stop
Curves.easeInOutCubic   // Balanced
Curves.easeOutBack      // Slight overshoot
Curves.elasticOut       // Bouncy
Curves.fastOutSlowIn    // Material standard
```

---

## Common Patterns

### 3D Tilt Card
```dart
TiltCard(
  maxTilt: 0.05,
  child: YourWidget(),
)
```

### Animated Button
```dart
AnimatedGradientButton(
  text: 'Save',
  icon: Icons.save,
  onPressed: () => save(),
  isLoading: isLoading,
)
```

### Page Transition
```dart
context.pushSlide(NewScreen());
```

### Counter Animation
```dart
AnimatedCounter(
  value: 1234,
  textStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
)
```

### Skeleton Loader
```dart
SkeletonLoader(height: 100, borderRadius: 16)
```

### Progress Bar
```dart
AnimatedProgressBar(
  value: 0.65,
  height: 6,
)
```

---

## Responsive Breakpoints

```dart
final screenWidth = MediaQuery.of(context).size.width;
final isMobile = screenWidth < 600;
final isTablet = screenWidth >= 600 && screenWidth < 900;
final isDesktop = screenWidth >= 900;
```

---

## Accessibility Minimums

- **Touch Target:** 48x48 dp
- **Text Contrast:** 4.5:1 (normal), 3:1 (large)
- **Focus Indicator:** 2px border
- **Font Scale:** Support up to 1.5x

---

## File Structure

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_design_system.dart     ← Theme constants
│   │   └── premium_design_system.dart
│   ├── constants/
│   │   ├── admin_colors.dart          ← Color palette
│   │   └── modern_colors.dart
│   └── navigation/
│       └── page_transitions.dart      ← NEW: Transitions
├── presentation/
│   ├── widgets/
│   │   ├── common/
│   │   │   └── animated_components.dart  ← NEW: Components
│   │   ├── effects/
│   │   │   └── tilt_card.dart           ← NEW: 3D effects
│   │   └── admin/
│   │       ├── admin_drawer.dart
│   │       └── modern_widgets.dart
│   └── screens/
│       └── admin/
│           ├── admin_dashboard_screen.dart
│           └── ...
```

---

## Imports Cheat Sheet

```dart
// Colors & Theme
import 'package:recyconnect/core/constants/admin_colors.dart';
import 'package:recyconnect/core/constants/modern_colors.dart';
import 'package:recyconnect/core/theme/app_design_system.dart';

// Navigation
import 'package:recyconnect/core/navigation/page_transitions.dart';

// Components
import 'package:recyconnect/presentation/widgets/common/animated_components.dart';
import 'package:recyconnect/presentation/widgets/effects/tilt_card.dart';
import 'package:recyconnect/presentation/widgets/admin/modern_widgets.dart';

// Packages (already installed)
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
```

---

## Common Tasks

### Add hover effect to card
```dart
MouseRegion(
  onEnter: (_) => setState(() => _isHovered = true),
  onExit: (_) => setState(() => _isHovered = false),
  child: AnimatedContainer(
    duration: Duration(milliseconds: 200),
    transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
    child: card,
  ),
)
```

### Add press effect to button
```dart
GestureDetector(
  onTapDown: (_) => setState(() => _isPressed = true),
  onTapUp: (_) => setState(() => _isPressed = false),
  onTapCancel: () => setState(() => _isPressed = false),
  child: AnimatedContainer(
    duration: Duration(milliseconds: 100),
    transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
    child: button,
  ),
)
```

### Fade in on load
```dart
TweenAnimationBuilder(
  duration: Duration(milliseconds: 500),
  tween: Tween<double>(begin: 0.0, end: 1.0),
  builder: (context, double value, child) {
    return Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - value)),
        child: YourWidget(),
      ),
    );
  },
)
```

---

## Performance Tips

✅ **DO:**
- Use `const` constructors
- Wrap expensive widgets in `RepaintBoundary`
- Limit simultaneous animations to 3-4
- Cache images

❌ **DON'T:**
- Nest too many animated widgets
- Use `setState` for animations
- Animate large images
- Run multiple Lottie animations at once

---

## Testing Checklist

- [ ] Animations smooth at 60 FPS
- [ ] Works on mobile (< 600px)
- [ ] Works on tablet (600-900px)
- [ ] Works on desktop (> 900px)
- [ ] All colors have sufficient contrast
- [ ] Touch targets are 48x48 minimum
- [ ] Keyboard navigation works
- [ ] Screen reader compatible
- [ ] Supports text scaling
- [ ] Dark mode works (if implemented)

---

## Resources

**Docs:**
- `DESIGN_SYSTEM.md` - Complete specifications
- `IMPLEMENTATION_GUIDE.md` - Step-by-step guide
- `DESIGN_QUICK_REFERENCE.md` - This file

**Code:**
- `lib/core/navigation/page_transitions.dart`
- `lib/presentation/widgets/effects/tilt_card.dart`
- `lib/presentation/widgets/common/animated_components.dart`

**Packages:**
- flutter_animate: ^4.5.0
- shimmer: ^3.0.0
- lottie: ^3.1.0
- flutter_staggered_animations: ^1.1.1

---

**Print this page for quick reference while coding! 📄**
