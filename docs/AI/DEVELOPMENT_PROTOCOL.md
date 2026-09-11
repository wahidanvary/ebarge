# Ebarge Development Protocol

## Core Principles

### READ → UNDERSTAND → PLAN → CHANGE → VERIFY

This protocol enforces a disciplined approach to development that minimizes risk and maximizes code quality in the Ebarge codebase.

## Development Workflow

### 1. Task Analysis
Before beginning any development work:

#### Identify Affected Module
- Consult `docs/AI/CHANGE_IMPACT_MAP.md` to understand system relationships
- Review module-specific documentation in `docs/AI/`
- Understand the module's role in the overall architecture

#### Read Relevant Documentation
- Start with `AGENTS.md` for project overview and rules
- Read module-specific documentation in `docs/AI/`
- Check architectural documentation in `docs/Architecture/`
- Review security considerations in `docs/AI/SECURITY.md`
- Check existing issues in `docs/AI/KNOWN_ISSUES.md`

#### Understand Requirements
- Clarify task objectives with stakeholders if needed
- Identify success criteria and acceptance conditions
- Determine impact on existing functionality
- Consider edge cases and error scenarios

### 2. Implementation Planning

#### Create a Small Plan
- Break task into minimal, logical steps
- Identify files that need modification
- Determine dependencies and potential conflicts
- Estimate effort and complexity

#### Risk Assessment
- Check for security implications using `docs/AI/SECURITY.md`
- Identify potential technical debt creation
- Consider database migration requirements
- Evaluate testing needs

### 3. Targeted Implementation

#### Read Relevant Source Files
- Focus only on files directly related to your change
- Understand data flow and dependencies
- Identify existing patterns and conventions
- Check for similar implementations elsewhere

#### Make Minimal Changes
- Modify only required files for the specific task
- Preserve existing functionality unless explicitly directed to change it
- Follow existing code patterns and conventions
- Document complex changes with comments

#### Follow Change Guidelines
- Adhere to rules in `AGENTS.md` and `docs/AI/CHANGE_GUIDELINES.md`
- Respect security protocols in `docs/AI/SECURITY.md`
- Maintain database safety as outlined in change guidelines
- Preserve API compatibility

### 4. Verification Process

#### Run Targeted Testing
- Test specific functionality related to changes
- Verify no regressions in existing features
- Check database and API interactions
- Validate security considerations

##### For Authentication Changes
- Test login flow, registration, logout
- Verify session management and persistence
- Check deep linking with authentication
- Validate credential storage and security

##### For Payment Changes
- Test purchase flow and verification
- Verify wallet balance updates
- Check transaction history integrity
- Validate error handling and edge cases

##### For Game System Changes
- Test game loading and question display
- Verify scoring and result calculation
- Check achievement tracking
- Validate multiplayer and social features

##### For Content System Changes
- Test book loading and navigation
- Verify note-taking and annotation features
- Check content search and filtering
- Validate offline access and sync

#### Inspect Git Diff
- Review changes for unintended modifications
- Ensure only intended files were modified
- Check for accidental secret exposure
- Verify code style consistency

### 5. Documentation and Reporting

#### Summarize Changes
- Document exactly what was changed
- Explain why changes were necessary
- Identify any remaining issues or warnings
- Note any follow-up work required

#### Update Documentation
- Update module-specific documentation if behavior changed
- Modify architectural documentation if architecture affected
- Update security documentation if relevant
- Cross-reference related documentation changes

## Code Review Process

### Self-Review Checklist

#### Security Review
- [ ] No hardcoded secrets or passwords
- [ ] No modification to SSL certificate validation
- [ ] Proper input validation and sanitization
- [ ] Secure storage usage appropriate for data type
- [ ] Session management follows existing patterns

#### Architecture Review
- [ ] Changes follow existing patterns and conventions
- [ ] No unnecessary duplication of existing code
- [ ] Dependencies properly managed
- [ ] No violation of separation of concerns

#### Database Review
- [ ] Schema changes reviewed for safety
- [ ] Data integrity maintained
- [ ] No orphaned or inconsistent data
- [ ] Migration considerations addressed

#### API Review
- [ ] API contracts preserved
- [ ] Error handling consistent
- [ ] Authentication patterns followed
- [ ] No breaking changes to existing endpoints

#### Testing Review
- [ ] Related functionality tested
- [ ] No regressions introduced
- [ ] Edge cases considered
- [ ] Error scenarios handled

## Quality Assurance Process

### Before Committing Changes
1. Run formatting if appropriate (`flutter format`)
2. Run static analysis (`flutter analyze`)
3. Run relevant tests (see `docs/AI/TESTING.md`)
4. Inspect `git diff` for unintended changes
5. Verify no secrets or sensitive information exposed
6. Confirm changes align with requirements

### After Committing Changes
1. Push changes to appropriate branch
2. Create pull request with clear description
3. Request review from appropriate team members
4. Address feedback promptly and professionally
5. Merge only after approval and successful CI checks

## Collaboration Guidelines

### Communication
- Provide clear, concise commit messages
- Document complex changes in PR descriptions
- Ask questions early and often
- Share knowledge and context freely

### Code Ownership
- Respect existing code authorship and expertise
- Seek guidance from experienced team members
- Contribute to shared understanding through documentation
- Help maintain code quality and consistency

### Continuous Improvement
- Learn from code reviews and feedback
- Stay updated on project developments and changes
- Contribute to documentation and knowledge base
- Share insights and improvements with team

## Emergency Procedures

### Critical Bug Response
1. Immediately assess impact and severity
2. Identify recent changes that may have caused issue
3. Implement temporary workaround if available
4. Fix root cause with proper testing
5. Communicate status to stakeholders

### Security Incident Response
1. Immediately report to security team
2. Do not commit fixes publicly
3. Follow responsible disclosure protocols
4. Coordinate with server-side team if needed
5. Document incident and lessons learned

### Database Recovery
1. Stop all database operations immediately
2. Backup current database state
3. Identify cause of issue
4. Restore from last known good backup
5. Implement prevention measures
6. Document incident and recovery process

## Knowledge Management

### Documentation Updates
- Keep documentation accurate and current
- Update documentation alongside code changes
- Use clear, concise language focused on facts
- Cross-reference related documentation

### Knowledge Sharing
- Conduct regular knowledge sharing sessions
- Document solutions to common problems
- Maintain a catalog of best practices
- Share insights from completed tasks

### Learning and Growth
- Encourage continuous learning and skill development
- Provide mentoring and guidance to team members
- Celebrate successes and learn from failures
- Foster a culture of curiosity and improvement