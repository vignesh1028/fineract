# Apache Fineract Microloan (Cash Loan) - Technical Assignment Guide

## Overview
This guide provides phase-wise instructions to implement a complete Microloan product in Apache Fineract with end-to-end loan lifecycle management.

**Timeline:** 6-10 hours  
**Evaluation Weight:** Installation(20%) + Product Config(20%) + Loan Lifecycle(30%) + Data Accuracy(15%) + Documentation(15%)

---

## System Access Details

### Default Credentials
```
Username: mifos
Password: password
Tenant ID: default
```

### API Base URL
```
https://localhost:8443/fineract-provider/api/v1
```

### Authorization Header
```
Authorization: Basic bWlmb3M6cGFzc3dvcmQ=
(Base64 encoded: mifos:password)

Fineract-Platform-TenantId: default
```

---

## PHASE 1: ENVIRONMENT SETUP ✔

**Status:** COMPLETED (Docker running)

### Verification
```bash
# Verify services
docker-compose ps

# Expected output:
# mariadb: Healthy on port 3306
# fineract: Healthy on port 8443
```

### Access
- **API Base:** `https://localhost:8443/fineract-provider/api/v1`
- **Health Check:** `https://localhost:8443/fineract-provider/actuator/health`

---

## PHASE 2: INITIAL SYSTEM CONFIGURATION

### 2.1 Office Setup

#### Step 1: Get Default Head Office
```
GET /offices
Headers:
  - Authorization: Basic bWlmb3M6cGFzc3dvcmQ=
  - Fineract-Platform-TenantId: default
```

**Expected Response:**
```json
[
  {
    "id": 1,
    "name": "Head Office",
    "nameDecorated": "Head Office",
    "externalId": null,
    "openingDate": [2009, 1, 1],
    "hierarchy": ".",
    "parentId": null
  }
]
```

#### Step 2: Create Branch Office
```
POST /offices
Headers:
  - Authorization: Basic bWlmb3M6cGFzc3dvcmQ=
  - Fineract-Platform-TenantId: default
  - Content-Type: application/json

Body:
{
  "name": "Downtown Branch",
  "openingDate": "01 Jan 2024",
  "parentId": 1,
  "dateFormat": "dd MMM yyyy",
  "locale": "en"
}
```

**Expected Response:**
```json
{
  "resourceId": 2
}
```

### 2.2 Staff Setup

#### Step 1: Create Loan Officer
```
POST /staff
Headers:
  - Authorization: Basic bWlmb3M6cGFzc3dvcmQ=
  - Fineract-Platform-TenantId: default
  - Content-Type: application/json

Body:
{
  "firstname": "John",
  "lastname": "Smith",
  "officeId": 2,
  "isLoanOfficer": true,
  "dateFormat": "dd MMM yyyy",
  "locale": "en"
}
```

**Expected Response:**
```json
{
  "resourceId": 1
}
```

#### Step 2: Verify Loan Officer
```
GET /staff/1
Headers:
  - Authorization: Basic bWlmb3M6cGFzc3dvcmQ=
  - Fineract-Platform-TenantId: default
```

### 2.3 Chart of Accounts

#### Step 1: Get Existing GL Accounts
```
GET /glaccounts?type=1&usage=1
Headers:
  - Authorization: Basic bWlmb3M6cGFzc3dvcmQ=
  - Fineract-Platform-TenantId: default
```

#### Step 2: Create Required GL Accounts (if not exist)

**Loan Portfolio (Asset)**
```
POST /glaccounts
Headers:
  - Authorization: Basic bWlmb3M6cGFzc3dvcmQ=
  - Fineract-Platform-TenantId: default
  - Content-Type: application/json

Body:
{
  "name": "Loan Portfolio",
  "glCode": "1000",
  "type": 1,
  "usage": 1,
  "manualEntriesAllowed": false,
  "accountNumber": "1000",
  "description": "Individual loan accounts",
  "locale": "en"
}
```

**Interest Income (Revenue)**
```
POST /glaccounts
Body:
{
  "name": "Interest Income",
  "glCode": "4000",
  "type": 4,
  "usage": 1,
  "manualEntriesAllowed": false,
  "accountNumber": "4000",
  "description": "Interest income from loans",
  "locale": "en"
}
```

**Fees Income (Revenue)**
```
POST /glaccounts
Body:
{
  "name": "Fees Income",
  "glCode": "4100",
  "type": 4,
  "usage": 1,
  "manualEntriesAllowed": false,
  "accountNumber": "4100",
  "description": "Fee income from loans",
  "locale": "en"
}
```

**Cash/Bank (Asset)**
```
POST /glaccounts
Body:
{
  "name": "Cash in Bank",
  "glCode": "1100",
  "type": 1,
  "usage": 2,
  "manualEntriesAllowed": false,
  "accountNumber": "1100",
  "description": "Cash and bank accounts",
  "locale": "en"
}
```

---

## PHASE 3: MICROLOAN PRODUCT CONFIGURATION

### Step 1: Create Loan Product

```
POST /loanproducts
Headers:
  - Authorization: Basic bWlmb3M6cGFzc3dvcmQ=
  - Fineract-Platform-TenantId: default
  - Content-Type: application/json

Body:
{
  "name": "Micro Cash Loan",
  "description": "Cash loan for microfinance customers",
  "fundId": 1,
  "loanType": "individual",
  "currencyCode": "USD",
  "digitsAfterDecimal": 2,
  "principal": "10000",
  "minPrincipal": "5000",
  "maxPrincipal": "25000",
  "startDate": "01 Jan 2024",
  "closeDate": null,
  "submitedOnDate": "01 Jan 2024",
  "locale": "en",
  "dateFormat": "dd MMM yyyy",
  "interestCalculationPeriodType": "daily",
  "interestType": "declining_balance",
  "amortizationType": "equal_installments",
  "numberOfRepayments": "6",
  "repaymentEvery": 1,
  "repaymentFrequencyType": "months",
  "interestRatePerPeriod": "2",
  "accountingRule": "cash_based",
  "includeInBorrowerCycle": true,
  "useBorrowerCycle": false,
  "loanPortfolioAccountId": 1,
  "interestOnLoanAccountId": 4,
  "incomeFromFeeAccountId": 5,
  "incomeFromPenaltyAccountId": null,
  "overdueExpenseAccountId": null,
  "writeoffExpenseAccountId": null,
  "loanLossProvisionAccountId": null,
  "receivableInterestAccountId": null,
  "receivableFeeAccountId": null,
  "receivablePenaltyAccountId": null
}
```

**Expected Response:**
```json
{
  "resourceId": 1
}
```

### Step 2: Verify Loan Product
```
GET /loanproducts/1
Headers:
  - Authorization: Basic bWlmb3M6cGFzc3dvcmQ=
  - Fineract-Platform-TenantId: default
```

---

## PHASE 4: CUSTOMER ONBOARDING

### Step 1: Create Client

```
POST /clients
Headers:
  - Authorization: Basic bWlmb3M6cGFzc3dvcmQ=
  - Fineract-Platform-TenantId: default
  - Content-Type: application/json

Body:
{
  "firstname": "Maria",
  "lastname": "Santos",
  "externalId": "EXT001",
  "officeId": 2,
  "dateOfBirth": "01 Jan 1990",
  "dateFormat": "dd MMM yyyy",
  "locale": "en",
  "mobileNo": "+1234567890",
  "accountNo": "ACC001",
  "active": true,
  "activationDate": "01 Jan 2024",
  "submittedOnDate": "01 Jan 2024"
}
```

**Expected Response:**
```json
{
  "resourceId": 1
}
```

### Step 2: Verify Client
```
GET /clients/1
Headers:
  - Authorization: Basic bWlmb3M6cGFzc3dvcmQ=
  - Fineract-Platform-TenantId: default
```

---

## PHASE 5: LOAN APPLICATION FLOW

### Step 5.1: Create Loan Application

```
POST /loans
Headers:
  - Authorization: Basic bWlmb3M6cGFzc3dvcmQ=
  - Fineract-Platform-TenantId: default
  - Content-Type: application/json

Body:
{
  "clientId": 1,
  "productId": 1,
  "loanOfficerId": 1,
  "loanType": "individual",
  "principal": "10000",
  "currency": {
    "code": "USD"
  },
  "numberOfRepayments": "6",
  "repaymentEvery": 1,
  "repaymentFrequencyType": 2,
  "interestRatePerPeriod": "2",
  "amortizationType": 1,
  "interestType": 0,
  "interestCalculationPeriodType": 1,
  "expectedDisbursementDate": "15 Jan 2024",
  "submittedOnDate": "10 Jan 2024",
  "locale": "en",
  "dateFormat": "dd MMM yyyy"
}
```

**Expected Response:**
```json
{
  "resourceId": 1
}
```

### Step 5.2: Retrieve Loan Details & Repayment Schedule

```
GET /loans/1?associations=all
Headers:
  - Authorization: Basic bWlmb3M6cGFzc3dvcmQ=
  - Fineract-Platform-TenantId: default
```

**Check repayment schedule in response:**
- Installment dates
- Principal amount
- Interest amount
- Total due per installment

### Step 5.3: Approve Loan

```
POST /loans/1/approve
Headers:
  - Authorization: Basic bWlmb3M6cGFzc3dvcmQ=
  - Fineract-Platform-TenantId: default
  - Content-Type: application/json

Body:
{
  "approvedOnDate": "12 Jan 2024",
  "locale": "en",
  "dateFormat": "dd MMM yyyy"
}
```

**Expected Response:**
```json
{
  "resourceId": 1
}
```

### Step 5.4: Disburse Loan

```
POST /loans/1/disburse
Headers:
  - Authorization: Basic bWlmb3M6cGFzc3dvcmQ=
  - Fineract-Platform-TenantId: default
  - Content-Type: application/json

Body:
{
  "actualDisbursementDate": "15 Jan 2024",
  "transactionAmount": "10000",
  "paymentTypeId": 1,
  "locale": "en",
  "dateFormat": "dd MMM yyyy"
}
```

**Expected Response:**
```json
{
  "resourceId": 1,
  "changes": {
    "actualDisbursementDate": "15 Jan 2024"
  }
}
```

---

## PHASE 6: REPAYMENT & LOAN SERVICING

### Scenario 1: On-Time Repayment (First Installment)

```
POST /loans/1/transactions?command=repayment
Headers:
  - Authorization: Basic bWlmb3M6cGFzc3dvcmQ=
  - Fineract-Platform-TenantId: default
  - Content-Type: application/json

Body:
{
  "transactionDate": "15 Feb 2024",
  "transactionAmount": "1700",
  "paymentTypeId": 1,
  "locale": "en",
  "dateFormat": "dd MMM yyyy"
}
```

**Expected Breakdown:**
- Principal: ~1652.89
- Interest: ~47.11
- Total: 1700

### Scenario 2: Partial Repayment

```
POST /loans/1/transactions?command=repayment
Body:
{
  "transactionDate": "15 Mar 2024",
  "transactionAmount": "1000",
  "paymentTypeId": 1,
  "locale": "en",
  "dateFormat": "dd MMM yyyy"
}
```

**Note:** Partial payment is allocated to interest first, then principal.

### Scenario 3: Early Repayment (Pre-closure)

```
POST /loans/1/transactions?command=repayment
Body:
{
  "transactionDate": "01 Apr 2024",
  "transactionAmount": "8500",
  "paymentTypeId": 1,
  "locale": "en",
  "dateFormat": "dd MMM yyyy"
}
```

**Expected:** Loan closed with calculated interest savings.

---

## PHASE 7: REPORTS & MONITORING

### Report 1: Loan Portfolio Report

```
GET /loans?status=active&sortBy=approvedOnDate&sortOrder=desc
Headers:
  - Authorization: Basic bWlmb3M6cGFzc3dvcmQ=
  - Fineract-Platform-TenantId: default
```

### Report 2: Repayment Schedule

```
GET /loans/1?associations=repaymentSchedule
Headers:
  - Authorization: Basic bWlmb3M6cGFzc3dvcmQ=
  - Fineract-Platform-TenantId: default
```

### Report 3: Client Loan Statement

```
GET /clients/1?associations=loans,loanAccounts
Headers:
  - Authorization: Basic bWlmb3M6cGFzc3dvcmQ=
  - Fineract-Platform-TenantId: default
```

---

## PHASE 8: API COLLECTION (BONUS)

See separate `FINERACT_POSTMAN_COLLECTION.json` file for Postman collection.

---

## Quick Reference: Common GL Account IDs

| Account Name | GL Code | ID | Type |
|---|---|---|---|
| Loan Portfolio | 1000 | 1 | Asset |
| Cash in Bank | 1100 | 2 | Asset |
| Interest Income | 4000 | 4 | Revenue |
| Fees Income | 4100 | 5 | Revenue |

---

## Troubleshooting

### 400 Bad Request
- Check date format (dd MMM yyyy)
- Verify all required fields are present
- Ensure numeric values are strings in JSON

### 401 Unauthorized
- Verify Authorization header is correct
- Check Base64 encoding of credentials

### 404 Not Found
- Verify resource IDs exist
- Check API endpoint spelling

### Database Issues
```bash
# Restart services
docker-compose down -v
docker-compose up -d
```

---

## Expected Time Breakdown

| Phase | Time |
|---|---|
| Setup | 30 min |
| System Config | 1 hr |
| Product Config | 30 min |
| Onboarding | 30 min |
| Loan Lifecycle | 2 hrs |
| Repayments | 1 hr |
| Reports | 30 min |
| **Total** | **6-7 hrs** |

---

## Deliverables Checklist

- [ ] Environment running (Docker)
- [ ] Offices created
- [ ] Staff (Loan Officer) created
- [ ] GL Accounts configured
- [ ] Loan product created
- [ ] Client onboarded
- [ ] Loan application submitted
- [ ] Loan approved
- [ ] Loan disbursed
- [ ] Repayments recorded
- [ ] Reports generated
- [ ] Screenshots documented

---

## Next Steps

1. Follow Phase 2 instructions for system configuration
2. Use curl commands or Postman to execute API calls
3. Document screenshots for each major milestone
4. Keep API response payloads for reference
5. Maintain a summary of all resource IDs created

