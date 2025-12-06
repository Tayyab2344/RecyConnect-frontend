# Design System Implementation Guide

Quick-start guide for implementing the RecyConnect Design System

---

## Quick Start (5 Minutes)

### 1. Review the Design System
Read `DESIGN_SYSTEM.md` for complete specifications

### 2. Use Ready-Made Components

All components are ready to use. Import and implement:

```dart
// Page transitions
import 'package:recyconnect/core/navigation/page_transitions.dart';

// 3D effects
import 'package:recyconnect/presentation/widgets/effects/tilt_card.dart';

// Animated components
import 'package:recyconnect/presentation/widgets/common/animated_components.dart';
```

---

## Implementation Examples

### Example 1: Add 3D Tilt to Dashboard Cards

**Before:**
```dart
Container(
  child: StatCard(...),
);
```

**After:**
```dart
TiltCard(
  maxTilt: 0.05,  // ~3 degrees
  child: StatCard(...),
);
```

**Result:** Cards now tilt smoothly on hover with 3D depth

---

### Example 2: Use Modern Page Transitions

**Before:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NewScreen()),
);
```

**After:**
```dart
// Option 1: Direct route
Navigator.push(
  context,
  SlidePageRoute(page: NewScreen()),
);

// Option 2: Extension method (cleaner)
context.pushSlide(NewScreen());
```

**Result:** Smooth slide + fade transition (300ms)

---

### Example 3: Add Animated Button

**Before:**
```dart
ElevatedButton(
  onPressed: () => saveData(),
  child: Text('Save'),
);
```

**After:**
```dart
AnimatedGradientButton(
  text: 'Save Changes',
  icon: Icons.save,
  onPressed: () => saveData(),
  isLoading: _isLoading,
);
```

**Result:** Gradient button with hover effect, press animation, loading state

---

### Example 4: Animated Counter for Stats

**Before:**
```dart
Text(
  '1,234',
  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
);
```

**After:**
```dart
AnimatedCounter(
  value: 1234,
  prefix: '',
  suffix: '',
  decimals: 0,
  textStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
);
```

**Result:** Numbers animate from 0 to value (800ms smooth count-up)

---

### Example 5: Skeleton Loading

**Before:**
```dart
if (isLoading) {
  return CircularProgressIndicator();
} else {
  return DataTable(...);
}
```

**After:**
```dart
if (isLoading) {
  return Column(
    children: [
      SkeletonLoader(height: 100, borderRadius: 16),
      SizedBox(height: 16),
      SkeletonLoader(height: 100, borderRadius: 16),
      SizedBox(height: 16),
      SkeletonLoader(height: 100, borderRadius: 16),
    ],
  );
} else {
  return DataTable(...);
}
```

**Result:** Beautiful shimmer loading that matches content layout

---

### Example 6: Add Progress Bar

```dart
Column(
  children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Waste Collection Progress'),
        Text('${(progress * 100).toInt()}%'),
      ],
    ),
    SizedBox(height: 8),
    AnimatedProgressBar(
      value: progress,  // 0.0 to 1.0
      height: 8,
      borderRadius: 4,
    ),
  ],
);
```

---

## Desktop vs Mobile Considerations

### Desktop (Width > 900px)
- ✅ Use `TiltCard` for 3D hover effects
- ✅ Show detailed tooltips
- ✅ Enable complex animations
- ✅ Use multi-column layouts

### Mobile (Width < 600px)
- ✅ Use `LiftCard` instead of `TiltCard` (simpler)
- ✅ Larger touch targets (min 48x48)
- ✅ Simpler animations (faster)
- ✅ Single column layouts

**Example:**
```dart
final isMobile = MediaQuery.of(context).size.width < 600;

return isMobile
    ? LiftCard(child: StatCard(...))      // Simple scale on tap
    : TiltCard(child: StatCard(...));     // 3D tilt on hover
```

---

## Animation Performance Tips

### ✅ DO:
- Use `const` constructors wherever possible
- Wrap expensive widgets in `RepaintBoundary`
- Limit simultaneous animations to 3-4
- Use `AnimatedBuilder` for animation-only updates

```dart
// Good
RepaintBoundary(
  child: ExpensiveChart(...),
);
```

### ❌ DON'T:
- Nest too many animated widgets
- Use `setState` for animations
- Animate large images without caching
- Run multiple Lottie animations simultaneously

---

## Common Patterns

### Pattern 1: Card with Hover Effect

```dart
TiltCard(
  child: Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white, Color(0xFF10B981).withOpacity(0.05)],
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Color(0xFF10B981).withOpacity(0.2),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      children: [
        Icon(Icons.analytics, size: 48, color: Color(0xFF10B981)),
        SizedBox(height: 16),
        AnimatedCounter(value: 1234, textStyle: ...),
        Text('Total Users'),
      ],
    ),
  ),
);
```

### Pattern 2: Loading State with Skeleton

```dart
class DataScreen extends StatefulWidget {
  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  bool _isLoading = true;
  List<Data> _data = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await api.fetchData();
    setState(() {
      _data = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildSkeleton();
    }
    return _buildContent();
  }

  Widget _buildSkeleton() {
    return ListView(
      children: List.generate(
        5,
        (index) => Padding(
          padding: EdgeInsets.all(16),
          child: SkeletonLoader(height: 100, borderRadius: 16),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return ListView.builder(
      itemCount: _data.length,
      itemBuilder: (context, index) => DataCard(data: _data[index]),
    );
  }
}
```

### Pattern 3: Form with Animated Button

```dart
class FormScreen extends StatefulWidget {
  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await api.submitForm();
      // Show success
    } catch (e) {
      // Show error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(...),
          SizedBox(height: 16),
          TextFormField(...),
          SizedBox(height: 24),
          AnimatedGradientButton(
            text: 'Submit',
            icon: Icons.check,
            onPressed: _submit,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
```

---

## Accessibility Checklist

When implementing new screens, ensure:

- [ ] All interactive elements have minimum 48x48 touch target
- [ ] Color contrast meets WCAG AA (4.5:1 for text)
- [ ] All images have semantic labels
- [ ] Keyboard navigation works (tab through all elements)
- [ ] Focus indicators are visible
- [ ] Form errors are announced to screen readers
- [ ] Animations can be disabled (respect system preferences)

**Test with:**
```dart
// Check if animations should be disabled
final disableAnimations = MediaQuery.of(context).disableAnimations;

AnimatedContainer(
  duration: disableAnimations ? Duration.zero : Duration(milliseconds: 300),
  ...
);
```

---

## Color Usage Guide

### When to Use Each Color

**Primary Green (#10B981):**
- Main CTAs and primary actions
- Success states
- Brand elements
- Active navigation items

**Blue (#3B82F6):**
- Analytics and data visualization
- Info states
- Secondary actions
- Links

**Orange (#F59E0B):**
- Warnings
- Pending states
- Attention indicators

**Red (#EF4444):**
- Errors
- Destructive actions (delete)
- Critical alerts

**Purple (#8B5CF6):**
- Premium features
- Special highlights
- Alternative accents

---

## Typography Guide

### Heading Hierarchy

```dart
// H1: Page titles
Text(
  'Dashboard',
  style: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  ),
);

// H2: Section titles
Text(
  'Recent Activity',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
  ),
);

// H3: Card titles
Text(
  'Total Users',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  ),
);

// Body: Regular text
Text(
  'Description text here',
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  ),
);

// Caption: Metadata
Text(
  '5 min ago',
  style: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFF9CA3AF),
  ),
);
```

---

## Spacing Guide

Use consistent spacing for professional layouts:

```dart
// Tight spacing (4-8px): Between icon and label
Row(
  children: [
    Icon(...),
    SizedBox(width: 8),  // Spacing 8
    Text(...),
  ],
);

// Standard spacing (16px): Between elements
Column(
  children: [
    Widget1(),
    SizedBox(height: 16),  // Spacing 16
    Widget2(),
  ],
);

// Section spacing (24-32px): Between sections
Column(
  children: [
    Section1(),
    SizedBox(height: 32),  // Spacing 32
    Section2(),
  ],
);
```

---

## Troubleshooting

### Issue: Animations are janky
**Solution:**
1. Wrap expensive widgets in `RepaintBoundary`
2. Reduce number of simultaneous animations
3. Use `flutter run --profile` to check performance
4. Cache images with `cached_network_image`

### Issue: 3D tilt not working on mobile
**Solution:** `TiltCard` requires `MouseRegion` which doesn't work on mobile. Use `LiftCard` instead for mobile devices.

### Issue: Colors don't match design
**Solution:** Use exact hex codes from `DESIGN_SYSTEM.md` section 1.1. Double-check in your constants files.

### Issue: Text too small on some devices
**Solution:** Don't hardcode font sizes. Use relative sizing:
```dart
// Bad
Text('Title', style: TextStyle(fontSize: 24));

// Good
Text(
  'Title',
  style: Theme.of(context).textTheme.headlineMedium,
);
```

---

## Next Steps

1. **Phase 1 (Week 1-2):** Implement core components
   - Apply `TiltCard` to dashboard stat cards
   - Replace all `Navigator.push` with `SlidePageRoute`
   - Add skeleton loaders to all data screens
   - Implement `AnimatedGradientButton` for CTAs

2. **Phase 2 (Week 3):** Polish interactions
   - Add `AnimatedCounter` to all stat cards
   - Implement `AnimatedProgressBar` where needed
   - Add micro-animations to buttons and cards
   - Test on real devices

3. **Phase 3 (Week 4):** Advanced features
   - Integrate Lottie animations for empty states
   - Add glassmorphism to hero sections
   - Implement staggered list animations
   - Performance optimization

4. **Phase 4 (Week 5):** Accessibility & QA
   - Run accessibility audit
   - Test with screen readers
   - Verify keyboard navigation
   - Cross-browser testing

---

## Support

**Documentation:**
- Design System: `DESIGN_SYSTEM.md`
- Component Code: `lib/presentation/widgets/`
- Navigation: `lib/core/navigation/`
- Theme: `lib/core/theme/`

**Need Help?**
- Check existing implementations in `modern_widgets.dart`
- Review code comments in component files
- Test in Flutter DevTools Performance tab

---

**Good luck with implementation! 🚀**

The design system is production-ready and optimized for your admin panel.
Focus on Phase 1 first, then iterate through phases 2-4 for a polished result.
