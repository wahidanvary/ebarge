# Ebarge Data Flow

## Authentication Flow
```
User Input (Login Screen) 
    ↓
UserProvider.sendLoginRequest()
    ↓
Dio HTTP Client + FormData
    ↓
API Endpoint: /index.php?option=com_jbackend&view=request
    ↓
Server Response (User Data)
    ↓
UserModel.fromJson() → Local Storage (FlutterSecureStorage)
    ↓
UserQueries.saveUserToDB() → SQLite Database
    ↓
UI Update (Authenticated State)
```

## Book Content Flow
```
BookProvider.getBooksData()
    ↓
Check Local Database (booksQueries.getBooks())
    ↓
If Online Available:
  → API Request: /index.php?option=com_jbackend&view=request&module=books&resource=getbooks
    ↓
Server Response (Books Data)
    ↓
BookModel.fromJson() → booksQueries.saveUserBooksToDB()
    ↓
UI Update (Book List)
```

## Azbazi Game Flow
```
Game Selection (Landing Page)
    ↓
AzbaziProvider.getAzbaziData()
    ↓
Check Local Database (azbaziQueries.getAzbazies())
    ↓
If Online Available:
  → API Request: /index.php?option=com_jbackend&view=request&module=books&resource=getazbaziqs
    ↓
Server Response (Game Questions)
    ↓
QuestionModel.fromJson() → questionsQueries.saveQuestionsToDB()
    ↓
Game Initialization (Game Page)
    ↓
Question Presentation → User Interaction
    ↓
Answer Submission:
  → API Request: /index.php?option=com_jbackend&view=request&module=books&resource=azscorerate
    ↓
Score Update → Local Database
    ↓
Results Display (Result Page)
```

## Payment Flow
```
Gold Shop Selection (UI)
    ↓
GoldShopScreen.purchaseProduct()
    ↓
FlutterPoolakey.purchase() (CafeBazaar)
    ↓
Payment Processing (External)
    ↓
Purchase Verification:
  → FlutterPoolakey.consume()
    ↓
API Request: /index.php?option=com_jbackend&view=request&module=user&resource=goldpurchase
    ↓
Server Response (Transaction Status)
    ↓
UserModel Update (Wallet Balance)
    ↓
UI Update (Gold Amount)
```

## Note-taking Flow
```
Content Viewing (Page Screen)
    ↓
User Annotation (Image Painter)
    ↓
Note Data Storage:
  → Local State Management
    ↓
Save Notes:
  → API Request: /index.php?option=com_jbackend&view=request&module=pages&resource=usernotes
    ↓
Server Response (Note Status)
    ↓
Local Database Storage (If Applicable)
```

## Deep Linking Flow
```
External Link (ebarge://azbazi/{id})
    ↓
AppLinks.getInitialLink() or uriLinkStream
    ↓
Main._handleUri()
    ↓
Check Authentication Status
    ↓
If Authenticated:
  → Navigate to LinkLoaderPage
    ↓
Process Game Request
    ↓
Load Azbazi Game
    ↓
If Unauthenticated:
  → Store Pending Link
    ↓
Show Login Screen
    ↓
After Login:
  → Process Pending Link
```

## Data Synchronization Pattern
```
Provider Initialization
    ↓
Check Local Database
    ↓
If Data Exists:
  → Load from Database
    ↓
UI Update
    ↓
If Online:
  → API Request for Updates
    ↓
If New Data:
    → Update Local Database
    ↓
UI Refresh
```

## Session Management Flow
```
App Startup
    ↓
UserProvider.onStartUp()
    ↓
Check FlutterSecureStorage for Credentials
    ↓
If Credentials Found:
  → API Session Check: /index.php?option=com_jbackend&view=request&module=user&resource=status
    ↓
If Valid Session:
  → Load User Data from Database
    ↓
Authenticated State
    ↓
If Invalid Session:
  → Send Login Request with Stored Credentials
    ↓
New Session or Logout
```

## Error Handling Flow
```
API Request
    ↓
Try-Catch Block
    ↓
If Exception:
  → Log Error
    ↓
Show User-Friendly Message
    ↓
Fallback to Cached Data (If Available)
    ↓
UI Update with Error State
```

## Offline Support Pattern
```
Feature Request
    ↓
Check Network Connectivity (GlobalKeys.checkInternetConnection())
    ↓
If Online:
  → Proceed with API Request
    ↓
If Offline:
  → Check Local Database for Cached Data
    ↓
If Data Available:
    → Use Cached Data
    ↓
If No Data:
    → Show Offline Message
```