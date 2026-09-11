# Ebarge Change Guidelines

## Golden Rules for Modifications

### 1. Understand Before Changing
Always inspect the relevant files and understand existing architecture before making any changes:
- Read related documentation in `docs/AI/` and `docs/Architecture/`
- Identify dependencies and data flow
- Understand database and API implications
- Check for security considerations in `docs/AI/SECURITY.md`

### 2. Preserve Existing Functionality
Ebarge is a production-oriented application. Do not remove or rewrite existing functionality without explicit request:
- Prefer small changes over large refactors
- Maintain backward compatibility when possible
- Reuse existing components and patterns
- Test changes thoroughly before submitting

### 3. Security First
Follow strict security protocols outlined in `docs/AI/SECURITY.md`:
- Never hard-code API keys or passwords
- Do not commit secrets or sensitive credentials
- Validate and sanitize all user inputs
- Maintain SSL certificate validation (do not modify MyHttpOverrides)
- Implement proper session management

### 4. Database Safety
Database changes are high-risk and require careful consideration:
- Inspect all usages before modifying schemas
- Never delete existing data structures without migration strategy
- Understand relationships between tables
- Test data integrity after modifications

### 5. API Compatibility
Respect existing API contracts and error handling patterns:
- Do not invent new API endpoints
- Maintain existing request/response structures
- Follow established authentication patterns
- Preserve error handling consistency

## Change Impact Map

### Authentication System
**IF YOU CHANGE**: `UserProvider`, login, registration, session management
**YOU SHOULD INSPECT**: 
- `lib/providers/userProvider.dart`
- `lib/screens/login/`
- `lib/services/GlobalKeys.dart`
- `lib/database/userQueries.dart`
**YOU MAY AFFECT**: User login, registration, session persistence, deep linking
**YOU SHOULD TEST**: Login flow, registration, logout, session validation

### Payment System
**IF YOU CHANGE**: GoldShop, purchase flow, wallet management
**YOU SHOULD INSPECT**: 
- `lib/screens/books/goldShop.dart`
- `flutter_poolakey/` plugin
- `lib/providers/userProvider.dart` (goldShopData method)
- `lib/models/shopModel.dart`
**YOU MAY AFFECT**: Purchase processing, wallet balance, transaction history
**YOU SHOULD TEST**: Purchase flow, payment verification, balance updates

### Azbazi Game System
**IF YOU CHANGE**: Game logic, questions, scoring, results
**YOU SHOULD INSPECT**: 
- `lib/azbazi/` directory
- `lib/providers/azbaziProvider.dart`
- `lib/providers/questionProvider.dart`
- `lib/database/questionsQueries.dart`
- `lib/database/azbaziQueries.dart`
**YOU MAY AFFECT**: Game availability, question loading, scoring calculations
**YOU SHOULD TEST**: Game loading, question display, answer submission, scoring

### Book Content System
**IF YOU CHANGE**: Books, pages, content viewing, notes
**YOU SHOULD INSPECT**: 
- `lib/providers/bookProvider.dart`
- `lib/screens/pageScreen/`
- `lib/database/booksQueries.dart`
- `image_painter/` package
- `lib/services/GlobalKeys.dart` (getOnePageData, addUpUView)
**YOU MAY AFFECT**: Book browsing, content loading, note-taking, page tracking
**YOU SHOULD TEST**: Book loading, page viewing, note creation, content navigation

### Database Layer
**IF YOU CHANGE**: Database schema, queries, models
**YOU SHOULD INSPECT**: 
- `lib/database/ebargeDBHelper.dart`
- All `*Queries.dart` files
- All `*Model.dart` files in `lib/models/`
- Provider files that use database operations
**YOU MAY AFFECT**: Data persistence, user profiles, content storage, game data
**YOU SHOULD TEST**: Data saving, data retrieval, data integrity, migration scenarios

### API Layer
**IF YOU CHANGE**: API endpoints, request/response handling, error handling
**YOU SHOULD INSPECT**: 
- `lib/services/GlobalKeys.dart`
- All provider files with API calls
- Session management in providers
- Cookie handling patterns
**YOU MAY AFFECT**: Network communication, authentication, data synchronization
**YOU SHOULD TEST**: API connectivity, error handling, session management, data sync

## Development Protocol

### READ → UNDERSTAND → PLAN → CHANGE → VERIFY

#### 1. Identify Affected Module
- Consult `docs/AI/CHANGE_IMPACT_MAP.md` for change impact
- Review related documentation in `docs/AI/`
- Understand the module's role in the overall architecture

#### 2. Read Relevant Documentation
- Start with `AGENTS.md` for project overview
- Read module-specific documentation in `docs/AI/`
- Check architectural documentation in `docs/Architecture/`
- Review security considerations in `docs/AI/SECURITY.md`

#### 3. Read Only Relevant Source Files
- Focus on files directly related to your change
- Understand data flow and dependencies
- Identify existing patterns and conventions
- Check for similar implementations elsewhere

#### 4. Determine Dependencies
- Identify files that depend on your changes
- Check for cascading effects
- Understand database and API implications
- Consider security and performance impacts

#### 5. Make Minimal Changes
- Modify only required files
- Preserve existing functionality
- Follow existing code patterns
- Document complex changes

#### 6. Run Targeted Verification
- Test specific functionality related to changes
- Verify no regressions in existing features
- Check database and API interactions
- Validate security considerations

#### 7. Inspect Git Diff
- Review changes for unintended modifications
- Ensure only intended files were modified
- Check for accidental secret exposure
- Verify code style consistency

#### 8. Summarize Changes
- Document exactly what was changed
- Explain why changes were necessary
- Identify any remaining issues or warnings
- Note any follow-up work required

## Testing Requirements

### Before Making Changes
- Understand existing test coverage (limited - see `docs/AI/TESTING.md`)
- Plan how to verify your changes work correctly
- Consider manual testing if automated tests don't exist

### After Making Changes
- Test related functionality manually
- Verify no existing features were broken
- Check database and API interactions
- Validate security implications

### For Critical Changes
- Test authentication and session management
- Verify payment and transaction processing
- Check content access and data integrity
- Validate error handling and edge cases

## Code Review Checklist

### Security Review
- [ ] No hardcoded secrets or passwords
- [ ] No modification to SSL certificate validation
- [ ] Proper input validation and sanitization
- [ ] Secure storage usage appropriate for data type
- [ ] Session management follows existing patterns

### Architecture Review
- [ ] Changes follow existing patterns and conventions
- [ ] No unnecessary duplication of existing code
- [ ] Dependencies properly managed
- [ ] No violation of separation of concerns

### Database Review
- [ ] Schema changes reviewed for safety
- [ ] Data integrity maintained
- [ ] No orphaned or inconsistent data
- [ ] Migration considerations addressed

### API Review
- [ ] API contracts preserved
- [ ] Error handling consistent
- [ ] Authentication patterns followed
- [ ] No breaking changes to existing endpoints

### Testing Review
- [ ] Related functionality tested
- [ ] No regressions introduced
- [ ] Edge cases considered
- [ ] Error scenarios handled

## Documentation Updates

### When to Update Documentation
- When changing system behavior
- When adding new features
- When modifying APIs or data structures
- When addressing security issues

### Which Documentation to Update
- Module-specific documentation in `docs/AI/`
- Architectural documentation if significant changes
- Security documentation if relevant
- README files if user-facing changes

### How to Update Documentation
- Keep documentation factual and concise
- Focus on what changed and why
- Update diagrams if architecture affected
- Cross-reference related documentation

## Emergency Procedures

### If Something Breaks
1. Identify the scope of the issue
2. Check recent changes using git history
3. Revert changes if necessary to restore functionality
4. Document the issue and solution
5. Implement proper fix with adequate testing

### If Security Issue Discovered
1. Immediately report to security team
2. Do not commit fixes publicly
3. Follow responsible disclosure protocols
4. Coordinate with server-side team if needed
5. Document in security documentation

### If Database Corruption Occurs
1. Stop all database operations
2. Backup current database state
3. Identify cause of corruption
4. Restore from last known good backup
5. Implement prevention measures