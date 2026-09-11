# Ebarge Database Map

## Database Technology
- **Engine**: SQLite
- **Package**: sqflite
- **File**: ebarge_db.db
- **Location**: Application documents directory
- **Version**: 1 (NO VERIFIED MIGRATION STRATEGY FOUND)

## Database Helper
- **File**: `lib/database/ebargeDBHelper.dart`
- **Pattern**: Singleton (`ebargeDBHelper.dbInstance`)
- **Initialization**: On app startup via `ebargeDBHelper().database`
- **Configuration**: Foreign keys enabled, version tracking

## Tables Structure

### User Table (`user_tbl`)
**Purpose**: Stores user profile information, authentication data, wallet information
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

### Books Table (`books_tbl`)
**Purpose**: Book metadata, content information, progress tracking
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

### Bargs Table (`bargs_tbl`)
**Purpose**: User transactions, currency history, purchase records
```sql
CREATE TABLE IF NOT EXISTS bargs_tbl (
  bargid TEXT NOT NULL,
  userid TEXT NOT NULL,
  amount TEXT NOT NULL,
  type TEXT,
  book_id TEXT,
  item_id TEXT,
  wdate TEXT,
  detail TEXT
)
```

### Questions Table (`questions_tbl`)
**Purpose**: Quiz questions, answers, difficulty classification, user performance
```sql
CREATE TABLE IF NOT EXISTS questions_tbl (
  "question_id" TEXT NOT NULL,
  "azbazi_id" TEXT NOT NULL,
  "book_id" TEXT NOT NULL,
  "page_id" TEXT NOT NULL,
  "user_id" TEXT NOT NULL,
  "editor_id" TEXT,
  "book_chapter" TEXT NOT NULL,
  "page_num" INTEGER NOT NULL,
  "que_content" TEXT NOT NULL,
  "answer_map" TEXT NOT NULL,
  "que_level" TEXT NOT NULL,
  "que_type" TEXT NOT NULL,
  "question_in" TEXT,
  "que_answer" TEXT,
  "testi_answer" TEXT,
  "que_score" TEXT,
  "que_answertime" TEXT,
  "que_rate" TEXT,
  "que_source" TEXT,
  "print_count" TEXT,
  "created_date" TEXT,
  "modified_date" TEXT,
  "qstate" TEXT NOT NULL,
  "guide" TEXT,
  "max_score" REAL,
  "qholes" INTEGER,
  "first_solver" TEXT,
  "myqscore" REAL,
  "qview_count" INTEGER NOT NULL,
  "myqrate" TEXT,
  "visit_date" TEXT,
  "solved_date" TEXT,
  "uvstate" INTEGER,
  "status" TEXT,
  "error_code" TEXT,
  "error_description" TEXT
)
```

### Azbazi Table (`azbazi_tbl`)
**Purpose**: Game metadata, progress tracking, score tracking
```sql
CREATE TABLE IF NOT EXISTS azbazi_tbl (
  "azbazi_id" TEXT NOT NULL,
  "book_id" TEXT,
  "book_name" TEXT,
  "owner_id" TEXT,
  "editor_id" TEXT,
  "owner_name" TEXT,
  "isteacher" TEXT,
  "thumb_link" TEXT,
  "title" TEXT,
  "note" TEXT,
  "qcount" TEXT,
  "allholes" INTEGER,
  "max_score" INTEGER,
  "first_pageq" TEXT,
  "until_pageq" TEXT,
  "average_scores" TEXT,
  "rate" TEXT,
  "rate_count" TEXT,
  "entrant_count" TEXT,
  "qview_count" INTEGER,
  "created_date" TEXT,
  "modified_date" TEXT,
  "state" TEXT,
  "rejectreasons" TEXT,
  "azbaziaccess" TEXT,
  "mycoins" INTEGER,
  "myscore" REAL,
  "myview_count" INTEGER,
  "mysolved_count" INTEGER,
  "myfsolved_count" INTEGER,
  "myfsolved_holes" INTEGER,
  "qs_try_streak" INTEGER,
  "myRate" TEXT,
  "myvisit_date" TEXT,
  "mystate" TEXT,
  "aiModels" TEXT,
  "status" TEXT,
  "error_code" TEXT,
  "error_description" TEXT
)
```

## Query Layer
Each entity has a dedicated query file implementing CRUD operations:

### User Queries (`userQueries.dart`)
- `getUser(username)` - Retrieve user by username
- `saveUserToDB(user)` - Save new user to database
- `updateUser(user)` - Update existing user data
- `deleteUser(username)` - Delete user from database

### Books Queries (`booksQueries.dart`)
- `getBooks()` - Retrieve all user books
- `getBook(bookId)` - Retrieve specific book
- `saveUserBooksToDB(books)` - Save multiple books
- `updateBook(book)` - Update book data
- `deleteBook(bookId)` - Delete specific book

### Bargs Queries (`bargesQueries.dart`)
- `getBargs()` - Retrieve user transactions
- `saveBargToDB(barg)` - Save transaction record
- `deleteBarg(bargId)` - Delete transaction

### Azbazi Queries (`azbaziQueries.dart`)
- `getAzbazies()` - Retrieve all games
- `getAzbazi(azbaziId)` - Retrieve specific game
- `saveAzbaziesToDB(azbazis)` - Save multiple games
- `updateAzbazi(azbazi)` - Update game data

### Questions Queries (`questionsQueries.dart`)
- `getQuestions()` - Retrieve all questions
- `getQuestion(questionId)` - Retrieve specific question
- `saveQuestionsToDB(questions)` - Save multiple questions
- `updateQuestion(question)` - Update question data

## Data Models
Each table has a corresponding model in `lib/models/`:
- `UserModel` ↔ `user_tbl`
- `BookModel` ↔ `books_tbl`
- `BargModel` ↔ `bargs_tbl`
- `QuestionModel` ↔ `questions_tbl`
- `AzbaziModel` ↔ `azbazi_tbl`

## Database Operations Flow
1. **Initialization**: Database helper creates tables on first access
2. **Data Access**: Providers request data through query services
3. **Query Execution**: Query services interact with database helper
4. **Data Mapping**: Results mapped to model objects
5. **State Update**: Data returned to provider for state management

## Performance Considerations
- Connection pooling through singleton pattern
- No identified indexing strategy
- No query optimization documentation
- No batch operation implementation

## Security Considerations
- User credentials NOT stored in database (stored in FlutterSecureStorage)
- No encryption of sensitive data in database
- No access control at database level
- No input validation for database operations

## Migration Strategy
⚠️ **CRITICAL TECHNICAL DEBT**: NO VERIFIED MIGRATION STRATEGY FOUND
- Only `onCreate` method exists in database helper
- No `onUpgrade` method implementation
- No version migration scripts
- No backward compatibility maintenance