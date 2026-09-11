# Database Architecture in Ebarge

## Overview

Ebarge uses SQLite as its local database solution through the sqflite package. The database serves as a local cache for user data, books, questions, and game progress, enabling offline functionality and reducing network requests.

## Database Structure

### Database Helper (`lib/database/ebargeDBHelper.dart`)

The `ebargeDBHelper` class provides:
- Singleton pattern for database access
- Database initialization and version management
- Table creation and schema definition
- Database connection management

### Tables

1. **User Table (`user_tbl`)**
   - Stores user profile information
   - Authentication data
   - Wallet and currency information
   - App settings and preferences

2. **Books Table (`books_tbl`)**
   - Book metadata and content information
   - Chapter and section data
   - Progress tracking information

3. **Bargs Table (`bargs_tbl`)**
   - User transactions and currency history
   - Purchase and reward records
   - Time balance tracking

4. **Questions Table (`questions_tbl`)**
   - Quiz questions and answers
   - Question difficulty and type classification
   - User performance tracking
   - Question metadata

5. **Azbazi Table (`azbazi_tbl`)**
   - Game metadata and progress
   - Score tracking and achievements
   - Game-specific settings and configurations

## Schema Design

### User Table Schema

```sql
CREATE TABLE IF NOT EXISTS user_tbl (
  status TEXT,
  user_id TEXT NOT NULL,
  username TEXT NOT NULL,
  name TEXT,
  family TEXT,
  email TEXT,
  birthday TEXT,
  diploma TEXT,
  proficiency TEXT,
  edu_code TEXT,
  tell_mobile TEXT,
  zafran REAL,
  time_balance INTEGER,
  isactive_timebal INTEGER,
  app_streak INTEGER,
  max_app_streak INTEGER,
  parent_lock_pin TEXT,
  grade_lock INTEGER,
  state INTEGER,
  wallet_id INTEGER,
  gold_amount INTEGER,
  modified_date TEXT,
  detail TEXT,
  password TEXT,
  session_id TEXT,
  error_code TEXT,
  error_description TEXT,
  is_guest INTEGER,
  session_expire INTEGER
)
```

### Books Table Schema

```sql
CREATE TABLE IF NOT EXISTS books_tbl (
  book_id TEXT NOT NULL,
  tids TEXT,
  admin_id TEXT,
  admin_name TEXT,
  assistant_id TEXT,
  assistant_name TEXT,
  book_name TEXT NOT NULL,
  bchap_id TEXT,
  avatar TEXT,
  small_avatar TEXT,
  ebavatar TEXT,
  small_ebavatar TEXT,
  section_num TEXT,
  ref_link TEXT,
  bchap_pdf TEXT,
  ebarge_pdf TEXT,
  pdfsize TEXT,
  pages_count TEXT,
  gap_pages TEXT,
  rate TEXT,
  edu_year TEXT,
  state TEXT,
  azbazi_count TEXT,
  status TEXT,
  error_code TEXT,
  error_description TEXT
)
```

## Query Layer

### Separate Query Files

Each entity has its dedicated query file:
- `userQueries.dart` - User-related database operations
- `booksQueries.dart` - Book-related database operations
- `bargesQueries.dart` - Transaction-related database operations
- `azbaziQueries.dart` - Game-related database operations
- `questionsQueries.dart` - Question-related database operations

### Query Patterns

1. **Create Operations**
   - Insert new records
   - Batch insert for bulk operations
   - Conflict resolution strategies

2. **Read Operations**
   - Single record retrieval by ID
   - List retrieval with filtering
   - Pagination support
   - Search and sorting capabilities

3. **Update Operations**
   - Partial record updates
   - Batch updates for multiple records
   - Conditional updates based on criteria

4. **Delete Operations**
   - Single record deletion
   - Bulk deletion with conditions
   - Soft delete patterns where applicable

## Data Models

Each database table has a corresponding model class in `lib/models/`:
- `UserModel` for user data
- `BookModel` for book data
- `BargModel` for transaction data
- `QuestionModel` for question data
- `AzbaziModel` for game data

These models provide:
- Type-safe data representation
- JSON serialization/deserialization
- Data validation methods
- Business logic encapsulation

## Database Operations Flow

1. **Initialization**
   - Database helper creates tables on first access
   - Schema version management for upgrades
   - Foreign key constraint enforcement

2. **Data Access**
   - Provider requests data through query services
   - Query services interact with database helper
   - Results are mapped to model objects
   - Data returned to provider for state management

3. **Data Persistence**
   - Provider calls query services to save data
   - Query services format data for database storage
   - Database operations executed through helper
   - Results returned to provider for state updates

## Performance Considerations

### Indexing Strategy

- Primary keys on ID fields
- Indexes on frequently queried fields
- Composite indexes for complex queries

### Query Optimization

- Prepared statements for repeated queries
- Efficient WHERE clauses
- Proper use of LIMIT for pagination
- Batch operations for bulk data handling

### Memory Management

- Connection pooling through singleton pattern
- Proper cursor management
- Efficient data mapping to reduce memory footprint
- Cleanup of temporary data structures

## Security Considerations

### Data Protection

- User credentials stored securely (not in database)
- Sensitive data encrypted where appropriate
- Access control through application logic
- Input validation to prevent injection attacks

### Privacy

- User data stored locally with user control
- Clear data deletion mechanisms
- Compliance with privacy regulations
- Minimal data collection principles

## Synchronization Strategy

### Local-Server Sync

- Data synchronization with backend API
- Conflict resolution strategies
- Offline-first approach with eventual consistency
- Change tracking for efficient sync operations

### Data Freshness

- Timestamp-based data validation
- Cache invalidation strategies
- Periodic data refresh mechanisms
- User-triggered sync options

## Backup and Recovery

### Data Backup

- Automatic database backup mechanisms
- User-initiated backup options
- Cloud backup integration possibilities
- Export/import functionality

### Error Recovery

- Database corruption detection
- Automated recovery procedures
- Manual recovery options
- Data integrity checks

## Migration Strategy

### Version Management

- Database version tracking
- Migration scripts for schema changes
- Backward compatibility maintenance
- Rollback procedures for failed migrations

### Data Migration

- Data transformation during upgrades
- Lossless migration processes
- Validation of migrated data
- User notification of migration status

## Testing Considerations

### Database Testing

- Mock database for unit tests
- Integration tests for query operations
- Performance testing for complex queries
- Data integrity verification procedures

### Edge Cases

- Empty result handling
- Null value management
- Large dataset performance
- Concurrent access scenarios

## Future Enhancement Opportunities

### Advanced Features

- Full-text search capabilities
- Data analytics and reporting
- Advanced caching mechanisms
- Real-time synchronization

### Performance Improvements

- Query optimization techniques
- Indexing strategy enhancements
- Memory usage optimization
- Background sync improvements