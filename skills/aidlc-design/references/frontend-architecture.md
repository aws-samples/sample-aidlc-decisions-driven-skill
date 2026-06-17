# Frontend Architecture Guide

Reference guide for frontend architecture patterns and component organization.

## Common Frontend Architectures

### Component-Based (React/Vue/Angular)
Organize by reusable UI components.

**Structure**:
```
src/
├── components/       # Reusable UI components
│   ├── common/      # Shared across features
│   └── features/    # Feature-specific
├── pages/           # Page/route components
├── hooks/           # Custom hooks (React)
├── services/        # API clients
├── store/           # State management
└── utils/           # Utilities
```

**When to use**: Modern SPAs, component reusability important

### Feature-Based
Organize by business features.

**Structure**:
```
src/
├── features/
│   ├── auth/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── services/
│   │   └── store/
│   └── products/
│       ├── components/
│       ├── hooks/
│       └── services/
└── shared/          # Shared across features
```

**When to use**: Large applications, clear feature boundaries

### Atomic Design
Organize by component hierarchy (atoms → molecules → organisms → templates → pages).

**Structure**:
```
src/
├── components/
│   ├── atoms/       # Basic building blocks (Button, Input)
│   ├── molecules/   # Simple combinations (SearchBar)
│   ├── organisms/   # Complex components (Header, ProductCard)
│   ├── templates/   # Page layouts
│   └── pages/       # Complete pages
```

**When to use**: Design system focus, consistent UI patterns

## State Management Approaches

### Local State (useState/data)
Component-level state, not shared.

**When to use**: Simple forms, UI toggles, component-specific data

### Context API / Provide/Inject
Share state across component tree without prop drilling.

**When to use**: Theme, auth, user preferences, moderate complexity

### Redux / Vuex / Pinia
Centralized state management with predictable updates.

**When to use**: Complex state, multiple sources of truth, time-travel debugging needed

### React Query / SWR / TanStack Query
Server state management with caching.

**When to use**: API data, automatic refetching, optimistic updates

### Zustand / Jotai / Recoil
Lightweight state management.

**When to use**: Simpler than Redux, more than Context API

## Routing Strategies

### Client-Side Routing
All routing handled in browser (React Router, Vue Router).

**Pros**: Fast navigation, smooth transitions
**Cons**: SEO challenges, larger initial bundle

### Server-Side Rendering (SSR)
Pages rendered on server (Next.js, Nuxt.js).

**Pros**: Better SEO, faster initial load
**Cons**: More complex, server costs

### Static Site Generation (SSG)
Pre-render pages at build time.

**Pros**: Best performance, great SEO
**Cons**: Rebuild needed for content changes

### Hybrid
Mix of SSR, SSG, and client-side.

**Pros**: Optimize per page, best of all worlds
**Cons**: Most complex

## Component Patterns

### Presentational vs Container
- **Presentational**: Pure UI, receive props, no business logic
- **Container**: Handle logic, data fetching, pass to presentational

### Compound Components
Components that work together (Tabs, TabList, Tab, TabPanel).

### Render Props / Slots
Pass rendering logic as props/slots for flexibility.

### Higher-Order Components (HOC)
Wrap components to add functionality (withAuth, withLoading).

### Custom Hooks (React)
Extract reusable logic into hooks.

## Form Handling

### Controlled Components
React controls form state via useState.

**When to use**: Simple forms, real-time validation

### Uncontrolled Components
DOM controls form state, React reads on submit.

**When to use**: Simple forms, performance critical

### Form Libraries
React Hook Form, Formik, VeeValidate.

**When to use**: Complex forms, validation, multiple steps

## Data Fetching

### Fetch on Mount
Load data when component mounts.

### Lazy Loading
Load data on demand (infinite scroll, pagination).

### Prefetching
Load data before user needs it.

### Optimistic Updates
Update UI immediately, sync with server later.

## Performance Optimization

### Code Splitting
Split bundle by route or feature.

### Lazy Loading
Load components/routes on demand.

### Memoization
Cache expensive computations (useMemo, React.memo).

### Virtual Scrolling
Render only visible items in long lists.

### Image Optimization
Lazy load images, use modern formats (WebP, AVIF).

## Best Practices

1. Keep components small and focused
2. Separate concerns (UI vs logic)
3. Use TypeScript for type safety
4. Implement error boundaries
5. Handle loading and error states
6. Optimize bundle size
7. Test components in isolation
8. Follow accessibility guidelines
