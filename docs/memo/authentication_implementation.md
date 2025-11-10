# Authentication Implementation TODOs

## Critical Implementation Gaps

### User Authentication Logic
- **Location**: `app/controllers/auth/app/application_controller.rb:12`
- **Issue**: User authentication logic is completely unimplemented
- **Current State**: Returns `false` always
- **Priority**: CRITICAL
- **Impact**: Authentication system is non-functional

### Staff Authentication Logic
- **Location**: `app/controllers/auth/org/application_controller.rb:12`
- **Issue**: Staff authentication logic is completely unimplemented
- **Current State**: Returns `false` always  
- **Priority**: CRITICAL
- **Impact**: Staff authentication system is non-functional

### Current Staff Logic
- **Location**: `app/controllers/auth/org/setting/passkeys_controller.rb:53`
- **Issue**: `current_staff` method returns `nil`
- **Priority**: HIGH
- **Impact**: Staff-related functionality cannot work

## Security Vulnerabilities

### Hardcoded User ID
- **Location**: `app/controllers/auth/app/setting/recoveries_controller.rb:36`
- **Issue**: Using `User.first.id` as hardcoded user_id
- **Priority**: CRITICAL
- **Security Risk**: Data exposure and incorrect user association
- **Details**: Recovery codes are assigned to random users

## Required Actions

### Immediate (CRITICAL)
1. Implement proper user authentication logic in auth/app controllers
2. Implement proper staff authentication logic in auth/org controllers  
3. Fix hardcoded user ID in recovery controller
4. Implement current_staff method properly

### Short Term (HIGH)
1. Add proper session management
2. Implement role-based access control
3. Add authentication middleware
4. Create comprehensive authentication tests

### Notes
- Current authentication system is completely broken
- No user can actually authenticate successfully
- All protected routes are likely accessible without authentication
- This represents a critical security vulnerability

## Additional TODOs

1. Implement the contact page.
2. Implement the functionality that relies on JWT.
3. Implement the login-related features.
4. Fix the asset pipeline so CSP no longer blocks it.
5. Configure OpenAPI now that Rswag has been added.
6. Reconfigure the Rails → Cloud Run → Cloud Load Balancer → Fastly path.
7. Add functionality that lets users fix email issues without requiring a login.
