# Code Review for CONSUME

Perform a thorough code review of the CONSUME app codebase, focusing on:

## Review Checklist

### Flutter/Dart Quality
- [ ] Follows Dart style guide and analysis_options.yaml
- [ ] Proper use of `const` constructors
- [ ] No unnecessary widget rebuilds
- [ ] Correct Riverpod provider usage
- [ ] Proper error handling with try-catch
- [ ] No hardcoded strings (use constants)

### Architecture
- [ ] Clean Architecture layers respected
- [ ] Domain entities don't depend on data layer
- [ ] Repositories abstract data sources
- [ ] Providers are properly scoped
- [ ] No business logic in widgets

### Security
- [ ] No API keys in code (use api_constants.dart.example)
- [ ] Supabase RLS policies are sufficient
- [ ] User input is validated
- [ ] No SQL injection vulnerabilities
- [ ] Secure storage for sensitive data

### Performance
- [ ] Images are cached and sized appropriately
- [ ] Lists use ListView.builder for large datasets
- [ ] Expensive computations are memoized
- [ ] No unnecessary network calls
- [ ] Proper dispose() implementations

### UI/UX
- [ ] Consistent with design system
- [ ] Loading states for async operations
- [ ] Error states with retry options
- [ ] Empty states are informative
- [ ] Accessibility attributes present

### Cross-Platform
- [ ] Works on iOS, Android, and Web
- [ ] Platform-specific code is isolated
- [ ] Responsive layouts implemented
- [ ] Share intents configured correctly

## Review Focus

$ARGUMENTS

Provide:
1. Issues found with severity (Critical/Major/Minor)
2. Specific file:line references
3. Suggested fixes with code examples
4. Overall assessment and recommendations
