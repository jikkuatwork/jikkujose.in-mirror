---
layout: post
title: "Tailwind CSS v4 Typography Migration Guide"
excerpt: "Tailwind typography changes from v3.x to v4.x"
---

Tailwind CSS v4 dramatically reshapes plugin configuration, particularly for the
Typography plugin. This guide cuts through the complexity.

## Plugin Integration Shift

### V3.x Approach
```javascript
// Old way (v3.x)
module.exports = {
  plugins: [
    require("@tailwindcss/typography"),
  ],
}
```

### V4.x Approach
```css
/* New method (v4.x) */
@import "tailwindcss";
@plugin '@tailwindcss/typography';
```

## Key Migration Steps

- Remove `require('@tailwindcss/typography')` from config
- Add `@plugin '@tailwindcss/typography';` to main CSS file
- Migrate custom styles to CSS variables

## Typography Customization Transformation

### V3.x Custom Styles
```javascript
theme: {
  extend: {
    typography: theme => ({
      DEFAULT: {
        css: {
          color: theme("colors.gray.700"),
          a: {
            color: theme("colors.blue.500"),
          },
        },
      },
    }),
  },
}
```

### V4.x CSS Variable Approach
```css
@theme {
  --typography-default-color: theme(colors.gray.700);
  --typography-default-a-color: theme(colors.blue.500);
}
```

## Critical Implementation Notes

- Plugin integration now happens in CSS, not config
- CSS variables replace `theme.extend.typography`
- Direct utility class application remains possible

## Verification Checklist

```bash
# Confirm removal from config
grep -v "require('@tailwindcss/typography')" tailwind.config.js

# Verify CSS file update
cat globals.css | grep "@plugin '@tailwindcss/typography'"
```

## Potential Gotchas

- Existing `require()` calls will break builds
- Custom typography styles need complete CSS variable rewrite
- Test thoroughly after migration

## Update Strategy

1. Remove plugin from `tailwind.config.js`
2. Add `@plugin` directive to main CSS
3. Migrate custom styles to CSS variables
4. Run comprehensive visual regression tests

Migrations are never zero-effort, but Tailwind's v4 changes streamline future
plugin integrations.
