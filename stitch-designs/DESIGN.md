---
name: Kinetic Campus
colors:
  surface: '#faf8ff'
  surface-dim: '#dad9e0'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f4f3fa'
  surface-container: '#efedf4'
  surface-container-high: '#e9e7ee'
  surface-container-highest: '#e3e1e9'
  on-surface: '#1a1b20'
  on-surface-variant: '#444651'
  inverse-surface: '#2f3035'
  inverse-on-surface: '#f1f0f7'
  outline: '#757682'
  outline-variant: '#c5c5d3'
  surface-tint: '#425aa6'
  primary: '#001142'
  on-primary: '#ffffff'
  primary-container: '#00236f'
  on-primary-container: '#778ede'
  inverse-primary: '#b5c4ff'
  secondary: '#4059aa'
  on-secondary: '#ffffff'
  secondary-container: '#8fa7fe'
  on-secondary-container: '#1d3989'
  tertiary: '#2a0d00'
  on-tertiary: '#ffffff'
  tertiary-container: '#4b1c00'
  on-tertiary-container: '#ed6a08'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dce1ff'
  primary-fixed-dim: '#b5c4ff'
  on-primary-fixed: '#00164e'
  on-primary-fixed-variant: '#29428c'
  secondary-fixed: '#dce1ff'
  secondary-fixed-dim: '#b6c4ff'
  on-secondary-fixed: '#00164e'
  on-secondary-fixed-variant: '#264191'
  tertiary-fixed: '#ffdbca'
  tertiary-fixed-dim: '#ffb690'
  on-tertiary-fixed: '#341100'
  on-tertiary-fixed-variant: '#783200'
  background: '#faf8ff'
  on-background: '#1a1b20'
  surface-variant: '#e3e1e9'
typography:
  display-lg:
    fontFamily: Spline Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Spline Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  title-sm:
    fontFamily: Lexend
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Lexend
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Lexend
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-bold:
    fontFamily: Lexend
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin: 20px
---

## Brand & Style

The design system is built on a **Corporate-Modern** foundation infused with **High-Contrast** accents to resonate with an active student demographic. The aesthetic is "Logistics-Chic"—combining the reliability of a campus institution with the high-energy pulse of student life. 

The visual language prioritizes clarity and rapid information scanning. It utilizes a structured "Information-Rich" density that avoids clutter through generous white space and a strict typographic hierarchy. The emotional response is one of organized excitement: the app feels like a dependable tool that ensures you never miss a moment of the campus experience.

## Colors

The palette leverages a deep "Logistics Navy" for core branding and navigational elements, providing a grounded, academic feel. This is contrasted by "Safety Orange," used sparingly as a high-signal highlight for urgent notifications, call-to-action buttons, or live event statuses.

- **Primary & Secondary:** Used for headers, primary buttons, and active navigation icons.
- **Surface & Background:** A subtle "Mist" background differentiates the layout from the "Card White" interactive surfaces.
- **Functional Colors:** "Pale Signal Blue" is reserved strictly for selected states and soft backgrounds of active chips. "Critical Red" is used for alerts or cancelled events.

## Typography

This design system utilizes **Spline Sans** for headlines to inject a youthful, geometric energy into the interface. For body text and functional labels, **Lexend** is employed; its design is specifically optimized for readability and reducing visual stress, making it ideal for students scanning long lists of events.

- **Headlines:** Always bold and tight-tracked to create a sense of urgency and importance.
- **Body:** Set at a comfortable 14-16px range with generous line-height to ensure legibility on mobile devices.
- **Labels:** Used for metadata (time, location, tags), often employing a semi-bold weight to distinguish them from descriptive text.

## Layout & Spacing

The layout follows a **Fluid Grid** model with a focus on mobile-first interaction. A 4-column grid is used for mobile, while an 8-column grid is used for tablet views.

- **Rhythm:** An 8px linear scale governs all spatial relationships. 
- **Margins:** A consistent 20px outer margin ensures content does not feel cramped against the bezel.
- **Grouping:** Use 12px (sm) for internal card padding and 16px (md) for vertical spacing between separate layout blocks.

## Elevation & Depth

Hierarchy in the design system is achieved through **Tonal Layers** and **Ambient Shadows**.

- **Level 0 (Background):** #F7F9FB. Flat.
- **Level 1 (Cards/Surface):** #FFFFFF. High-diffusion, 10% opacity shadows with a 4px Y-offset and 12px blur.
- **Level 2 (Floating Actions/Modals):** #FFFFFF. 15% opacity shadows with an 8px Y-offset and 20px blur.

Edges are defined by a subtle 1px inner stroke (#E2E8F0) on surface elements to maintain crispness in high-light environments.

## Shapes

The shape language balances approachability with structural integrity.

- **Cards:** 16px (rounded-lg) corner radius to create a friendly, "hand-held" feel.
- **Action Buttons:** 24px corner radius, providing a distinct, "contained" look that differs from the card geometry.
- **Chips/Tags:** Fully pill-shaped (rounded-full) to represent modular, clickable categories.
- **Inputs:** 12px corner radius for a modern, soft-rectangle appearance.

## Components

### Buttons
- **Primary:** Logistics Navy (#00236F) background, white text, 24px radius. 
- **Secondary:** Safety Orange (#FD761A) background for high-priority actions like "Register Now."
- **Ghost:** Transparent background with Logistics Navy border for low-priority actions.

### Chips & Tags
- **Category Chips:** Pill-shaped, Pale Signal Blue (#DCE1FF) background with Command Blue (#1E3A8A) text.
- **Live Indicators:** Safety Orange background with a pulsing dot icon.

### Cards
- **Event Card:** Card White (#FFFFFF) surface, 16px radius, containing a high-contrast headline, a Lexend body-md for details, and a bottom row for chips.
- **State:** On press, the card should scale down slightly (98%) and increase shadow depth.

### Input Fields
- **Search Bar:** Mist Background (#F7F9FB) with a 1px border. Iconography should be Muted Operational Ink (#444651).

### Lists
- Use a 1px divider (#E2E8F0) between list items, or preferably, use card-based containers with 8px vertical spacing to emphasize modularity.