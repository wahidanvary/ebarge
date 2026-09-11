# Ebarge Payment System

## Overview
Ebarge implements in-app purchases through CafeBazaar's Poolakey payment system. The payment flow enables users to purchase virtual gold currency that can be used within the application for various features like game hints, premium content access, and other virtual goods.

## Core Components

### Payment Provider
- **Plugin**: flutter_poolakey (local implementation)
- **Market**: CafeBazaar (Iranian Android market)
- **Currency**: Iranian Rial (IRR)
- **Products**: Tiered gold packages with bonus incentives

### Key Models
- `ShopModel` - Product information and pricing
- `UserModel` - Wallet balance and transaction history
- `BargModel` - Transaction records and purchase history

## Payment Flow

### 1. Product Display
- Users navigate to Gold Shop screen
- Available products are fetched from server
- Products displayed with pricing and bonus information
- User wallet balance shown

### 2. Purchase Initiation
- User selects desired gold package
- Product ID and payload generated
- Connection to CafeBazaar established
- Purchase dialog displayed

### 3. Payment Processing
- CafeBazaar handles payment processing
- User completes transaction through market interface
- Purchase token generated upon successful payment
- Local confirmation received

### 4. Purchase Verification
- Purchase token consumed to prevent duplication
- Server-side verification request sent
- Transaction recorded in user's wallet
- Gold balance updated

### 5. Transaction Completion
- UI updated with new gold balance
- Transaction recorded in local database
- User notified of successful purchase
- Navigation to previous screen or main menu

## Technical Implementation

### UI Layer
- `goldShop.dart` contains all payment logic (ANTI-PATTERN)
- State management for connection status
- Product display grid with package information
- Purchase initiation and result handling
- User feedback through Flushbar notifications

### Payment Service
- `flutter_poolakey` plugin integration
- RSA key for secure communication
- Purchase and consumption methods
- Connection management and status reporting

### Verification Process
- Server-side API call to verify purchase
- Transaction data sent to Ebarge backend
- Response validation and error handling
- Wallet balance synchronization

## Data Flow
```
Gold Shop Display
    ↓
ShopModel Data Fetch (API)
    ↓
User Product Selection
    ↓
FlutterPoolakey.connect()
    ↓
FlutterPoolakey.purchase()
    ↓
Payment Processing (External)
    ↓
Purchase Token Received
    ↓
FlutterPoolakey.consume()
    ↓
API Verification: goldpurchase
    ↓
Server Response Processing
    ↓
UserModel Wallet Update
    ↓
UI Balance Update
```

## Security Issues

### Critical Anti-Patterns
1. **Payment Logic in UI Layer**: All payment processing occurs in `goldShop.dart` widget
2. **No Centralized Payment Service**: No dedicated service layer for payment operations
3. **Client-Side Trust**: UI layer trusted to properly process payments
4. **No Server-Side Validation**: Limited backend verification of purchases

### Vulnerabilities
1. **Token Manipulation**: Purchase tokens could potentially be intercepted
2. **Balance Modification**: Client-side balance updates without proper verification
3. **Session Inconsistency**: Multiple cookie jars may affect transaction integrity
4. **No Receipt Validation**: Limited validation of successful transactions

## Technical Debt

### Code Structure Issues
- Payment logic mixed with UI rendering
- No separation of concerns between presentation and business logic
- Direct API calls without centralized service
- Error handling inconsistencies

### Session Management
- Multiple cookie jar instances created per API call
- No unified session handling for payment flows
- WebView cookie synchronization complexity

### Error Handling
- Basic error messages without detailed logging
- No retry mechanisms for failed verifications
- Limited rollback procedures for failed transactions

## Product Structure

### ShopModel Attributes
- `productId`: Unique identifier for CafeBazaar product
- `goldAmount`: Base gold amount for package
- `priceAmount`: Price in Iranian Rial
- `bonusPercent`: Percentage bonus for purchase
- `bonusZafran`: Additional Zafran currency bonus
- `sellStatus`: Availability status of product

### User Wallet Integration
- Gold balance stored in `UserModel.gold_amount`
- Wallet ID tracked for transaction history
- Time balance and Zafran currency integration
- Transaction history through `BargModel`

## Verification Process

### Server-Side API
- **Endpoint**: `/index.php?option=com_jbackend&view=request&action=get&module=user&resource=goldpurchase`
- **Method**: POST with FormData
- **Parameters**: `product_id`, `purchase_token`
- **Response**: Status confirmation and balance update

### Validation Steps
1. Token consumption to prevent reuse
2. Server verification of purchase authenticity
3. Wallet balance calculation and update
4. Transaction recording in database
5. UI synchronization with new balance

## Error Handling

### Connection Issues
- CafeBazaar connection failure notifications
- Retry mechanisms for connection establishment
- Fallback to offline mode when necessary

### Purchase Failures
- Payment cancellation handling
- Insufficient funds scenarios
- Network timeout during purchase
- Server verification failures

### Recovery Procedures
- Pending transaction tracking
- Manual retry options
- Customer support escalation paths
- Balance reconciliation procedures

## Future Enhancement Opportunities

### Architecture Improvements
1. **Centralized Payment Service**: Dedicated service layer for all payment operations
2. **Repository Pattern**: Separation of payment data access from business logic
3. **Improved Error Handling**: Comprehensive error categorization and handling
4. **Transaction Logging**: Detailed audit trail for all payment activities

### Security Enhancements
1. **Server-Side Validation**: Enhanced backend verification of all transactions
2. **Receipt Validation**: Improved purchase receipt handling and validation
3. **CSRF Protection**: Implementation of CSRF tokens for payment APIs
4. **Encryption**: Enhanced encryption for sensitive payment data

### Feature Improvements
1. **Subscription Model**: Recurring payment options for premium features
2. **Multi-Currency Support**: Support for additional virtual currencies
3. **Purchase History**: Enhanced transaction history and reporting
4. **Refund Management**: Automated refund processing and notification