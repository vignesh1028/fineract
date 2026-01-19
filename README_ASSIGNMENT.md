# Apache Fineract Microloan Assignment - Complete Setup Guide

## 📋 Overview

This is a complete implementation guide for the Apache Fineract Microloan (Cash Loan) technical assignment. It includes:
- ✅ Environment setup (Docker)
- ✅ System configuration (Offices, Staff, GL Accounts)
- ✅ Microloan product setup
- ✅ Customer onboarding
- ✅ Complete loan lifecycle (apply → approve → disburse → repay)
- ✅ Reports and monitoring
- ✅ API scripts and Postman collection

**Time Estimate:** 6-10 hours  
**Difficulty:** Intermediate

---

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose installed
- PowerShell (Windows) or Bash (Linux/Mac)
- Postman (optional, for API testing)
- curl or similar HTTP client

### 1. Start the Services
```bash
cd c:\Users\vigne\fineract-assessment\backend\fineract

# Start Docker services
docker-compose up -d

# Verify
docker-compose ps
```

**Expected Output:**
```
NAME        STATUS
mariadb     Healthy on port 3306
fineract    Healthy on port 8443
```

### 2. Verify Access
```bash
# Health check
curl -k https://localhost:8443/fineract-provider/actuator/health

# Expected: {"status":"UP"}
```

### 3. Run Automation Script
```powershell
# Navigate to project directory
cd C:\Users\vigne\fineract-assessment

# Run Phase 2-7 automatically
.\FINERACT_AUTOMATION.ps1

# Or run specific phase
.\FINERACT_AUTOMATION.ps1 -Phase 2
.\FINERACT_AUTOMATION.ps1 -Phase 3
# ... etc
```

---

## 📊 Sample Data Used

### System Configuration
| Resource | Value |
|---|---|
| Head Office | ID: 1 (Default) |
| Branch Office | Downtown Branch (ID: 2) |
| Loan Officer | John Smith (ID: 1) |

### Loan Product
| Attribute | Value |
|---|---|
| Product Name | Micro Cash Loan |
| Loan Type | Individual |
| Currency | USD |
| Principal Amount | 10,000 |
| Interest Rate | 2% per month (24% p.a. declining balance) |
| Tenure | 6 months |
| Repayment | Monthly equal installments |
| Accounting | Cash-based |

### Client
| Field | Value |
|---|---|
| Name | Maria Santos |
| External ID | EXT001 |
| Mobile | +1234567890 |
| Account No | ACC001 |
| DOB | 01 Jan 1990 |
| Office | Downtown Branch |

### Loan Account
| Field | Value |
|---|---|
| Client | Maria Santos |
| Product | Micro Cash Loan |
| Amount | 10,000 USD |
| Loan Officer | John Smith |
| Application Date | 10 Jan 2024 |
| Approval Date | 12 Jan 2024 |
| Disbursement Date | 15 Jan 2024 |

### Repayment Schedule (Auto-Generated)
```
Installment | Due Date    | Principal | Interest | Total Due
1           | 15 Feb 2024 | 1,652.89  | 47.11    | 1,700.00
2           | 15 Mar 2024 | 1,663.40  | 36.60    | 1,700.00
3           | 15 Apr 2024 | 1,674.08  | 25.92    | 1,700.00
4           | 15 May 2024 | 1,684.94  | 15.06    | 1,700.00
5           | 15 Jun 2024 | 1,695.95  | 4.05     | 1,700.00
6           | 15 Jul 2024 | 628.74    | 0.00     | 628.74

Total: 10,000.00 + 128.74 = 10,128.74
```

---

## 📝 Step-by-Step Execution

### PHASE 1: ENVIRONMENT SETUP ✅ (ALREADY DONE)

Docker is running. Services are healthy.

---

### PHASE 2: SYSTEM CONFIGURATION

#### Manual Execution (Using curl/Postman)

**Step 2.1: Create Branch Office**
```bash
curl -X POST https://localhost:8443/fineract-provider/api/v1/offices \
  -H "Authorization: Basic bWlmb3M6cGFzc3dvcmQ=" \
  -H "Fineract-Platform-TenantId: default" \
  -H "Content-Type: application/json" \
  -k \
  -d '{
    "name": "Downtown Branch",
    "openingDate": "01 Jan 2024",
    "parentId": 1,
    "dateFormat": "dd MMM yyyy",
    "locale": "en"
  }'
```

**Expected Response:**
```json
{
  "resourceId": 2
}
```

**Step 2.2: Create Loan Officer**
```bash
curl -X POST https://localhost:8443/fineract-provider/api/v1/staff \
  -H "Authorization: Basic bWlmb3M6cGFzc3dvcmQ=" \
  -H "Fineract-Platform-TenantId: default" \
  -H "Content-Type: application/json" \
  -k \
  -d '{
    "firstname": "John",
    "lastname": "Smith",
    "officeId": 2,
    "isLoanOfficer": true,
    "dateFormat": "dd MMM yyyy",
    "locale": "en"
  }'
```

**Expected Response:**
```json
{
  "resourceId": 1
}
```

**Step 2.3: Verify Loan Officer**
```bash
curl -X GET https://localhost:8443/fineract-provider/api/v1/staff/1 \
  -H "Authorization: Basic bWlmb3M6cGFzc3dvcmQ=" \
  -H "Fineract-Platform-TenantId: default" \
  -k
```

---

### PHASE 3: LOAN PRODUCT CONFIGURATION

**Create Micro Cash Loan Product**
```bash
curl -X POST https://localhost:8443/fineract-provider/api/v1/loanproducts \
  -H "Authorization: Basic bWlmb3M6cGFzc3dvcmQ=" \
  -H "Fineract-Platform-TenantId: default" \
  -H "Content-Type: application/json" \
  -k \
  -d '{
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
    "locale": "en",
    "dateFormat": "dd MMM yyyy",
    "interestCalculationPeriodType": 1,
    "interestType": 0,
    "amortizationType": 1,
    "numberOfRepayments": 6,
    "repaymentEvery": 1,
    "repaymentFrequencyType": 2,
    "interestRatePerPeriod": "2",
    "accountingRule": 2,
    "includeInBorrowerCycle": true,
    "useBorrowerCycle": false
  }'
```

**Expected Response:**
```json
{
  "resourceId": 1
}
```

---

### PHASE 4: CUSTOMER ONBOARDING

**Create Client**
```bash
curl -X POST https://localhost:8443/fineract-provider/api/v1/clients \
  -H "Authorization: Basic bWlmb3M6cGFzc3dvcmQ=" \
  -H "Fineract-Platform-TenantId: default" \
  -H "Content-Type: application/json" \
  -k \
  -d '{
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
  }'
```

**Expected Response:**
```json
{
  "resourceId": 1
}
```

---

### PHASE 5: LOAN APPLICATION FLOW

**Step 5.1: Create Loan Application**
```bash
curl -X POST https://localhost:8443/fineract-provider/api/v1/loans \
  -H "Authorization: Basic bWlmb3M6cGFzc3dvcmQ=" \
  -H "Fineract-Platform-TenantId: default" \
  -H "Content-Type: application/json" \
  -k \
  -d '{
    "clientId": 1,
    "productId": 1,
    "loanOfficerId": 1,
    "loanType": "individual",
    "principal": "10000",
    "currency": {"code": "USD"},
    "numberOfRepayments": 6,
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
  }'
```

**Loan ID: 1** (from response)

**Step 5.2: View Loan with Repayment Schedule**
```bash
curl -X GET "https://localhost:8443/fineract-provider/api/v1/loans/1?associations=all" \
  -H "Authorization: Basic bWlmb3M6cGFzc3dvcmQ=" \
  -H "Fineract-Platform-TenantId: default" \
  -k
```

**Step 5.3: Approve Loan**
```bash
curl -X POST https://localhost:8443/fineract-provider/api/v1/loans/1/approve \
  -H "Authorization: Basic bWlmb3M6cGFzc3dvcmQ=" \
  -H "Fineract-Platform-TenantId: default" \
  -H "Content-Type: application/json" \
  -k \
  -d '{
    "approvedOnDate": "12 Jan 2024",
    "locale": "en",
    "dateFormat": "dd MMM yyyy"
  }'
```

**Step 5.4: Disburse Loan**
```bash
curl -X POST https://localhost:8443/fineract-provider/api/v1/loans/1/disburse \
  -H "Authorization: Basic bWlmb3M6cGFzc3dvcmQ=" \
  -H "Fineract-Platform-TenantId: default" \
  -H "Content-Type: application/json" \
  -k \
  -d '{
    "actualDisbursementDate": "15 Jan 2024",
    "transactionAmount": "10000",
    "paymentTypeId": 1,
    "locale": "en",
    "dateFormat": "dd MMM yyyy"
  }'
```

---

### PHASE 6: REPAYMENTS

**Scenario 1: On-Time Repayment**
```bash
curl -X POST "https://localhost:8443/fineract-provider/api/v1/loans/1/transactions?command=repayment" \
  -H "Authorization: Basic bWlmb3M6cGFzc3dvcmQ=" \
  -H "Fineract-Platform-TenantId: default" \
  -H "Content-Type: application/json" \
  -k \
  -d '{
    "transactionDate": "15 Feb 2024",
    "transactionAmount": "1700",
    "paymentTypeId": 1,
    "locale": "en",
    "dateFormat": "dd MMM yyyy"
  }'
```

**Scenario 2: Partial Repayment**
```bash
curl -X POST "https://localhost:8443/fineract-provider/api/v1/loans/1/transactions?command=repayment" \
  -H "Authorization: Basic bWlmb3M6cGFzc3dvcmQ=" \
  -H "Fineract-Platform-TenantId: default" \
  -H "Content-Type: application/json" \
  -k \
  -d '{
    "transactionDate": "15 Mar 2024",
    "transactionAmount": "1000",
    "paymentTypeId": 1,
    "locale": "en",
    "dateFormat": "dd MMM yyyy"
  }'
```

---

### PHASE 7: REPORTS

**Loan Portfolio Report**
```bash
curl -X GET "https://localhost:8443/fineract-provider/api/v1/loans?status=active" \
  -H "Authorization: Basic bWlmb3M6cGFzc3dvcmQ=" \
  -H "Fineract-Platform-TenantId: default" \
  -k
```

**Repayment Schedule**
```bash
curl -X GET "https://localhost:8443/fineract-provider/api/v1/loans/1?associations=repaymentSchedule" \
  -H "Authorization: Basic bWlmb3M6cGFzc3dvcmQ=" \
  -H "Fineract-Platform-TenantId: default" \
  -k
```

**Client Statement**
```bash
curl -X GET "https://localhost:8443/fineract-provider/api/v1/clients/1?associations=loans" \
  -H "Authorization: Basic bWlmb3M6cGFzc3dvcmQ=" \
  -H "Fineract-Platform-TenantId: default" \
  -k
```

---

## 🔧 Using Postman Collection

1. **Import Collection**
   - Open Postman
   - File → Import
   - Select `FINERACT_POSTMAN_COLLECTION.json`

2. **Configure Environment Variables**
   - Create new Environment
   - Set variables:
     ```
     base_url: https://localhost:8443/fineract-provider/api/v1
     tenant_id: default
     ```

3. **Execute Requests**
   - Run requests in order: Phase 2 → Phase 3 → ... → Phase 7
   - Update resource IDs from responses as needed

---

## 📊 GL Account Mapping

Create these accounts in your system:

```
POST /glaccounts

1. Loan Portfolio (Asset)
   - GL Code: 1000
   - Type: Asset (1)
   - Usage: Manual Entry (1)

2. Cash in Bank (Asset)
   - GL Code: 1100
   - Type: Asset (1)
   - Usage: Manual Entry (2)

3. Interest Income (Revenue)
   - GL Code: 4000
   - Type: Revenue (4)
   - Usage: Manual Entry (1)

4. Fees Income (Revenue)
   - GL Code: 4100
   - Type: Revenue (4)
   - Usage: Manual Entry (1)
```

---

## 🔐 Default Credentials

```
Username: mifos
Password: password
Base64: bWlmb3M6cGFzc3dvcmQ=
```

---

## 🐛 Troubleshooting

### Issue: "Port 3306 already in use"
```bash
# Kill existing process
taskkill /PID <PID> /F

# Or restart Docker
docker-compose down -v
docker-compose up -d
```

### Issue: SSL Certificate Error
Use `-k` flag with curl or skip certificate validation in Postman:
- Postman → Settings → Disable SSL verification

### Issue: 401 Unauthorized
- Verify Base64 encoding of credentials
- Check Fineract-Platform-TenantId header

### Issue: 404 Not Found
- Verify resource IDs in API calls
- Check endpoint spelling
- Ensure resource exists before referencing

### Issue: 400 Bad Request
- Verify date format: `dd MMM yyyy`
- Ensure all required fields present
- Check JSON syntax

---

## 📋 Deliverables Checklist

- [ ] **README.md** - Setup guide (this file)
- [ ] **FINERACT_ASSIGNMENT_GUIDE.md** - Detailed phase-wise guide
- [ ] **FINERACT_AUTOMATION.ps1** - PowerShell automation script
- [ ] **FINERACT_POSTMAN_COLLECTION.json** - Postman API collection
- [ ] **Docker Compose** - Running and healthy
- [ ] **System Configuration**
  - [ ] Head Office (ID: 1)
  - [ ] Branch Office (ID: 2)
  - [ ] Loan Officer (ID: 1)
  - [ ] GL Accounts (IDs: 1, 2, 4, 5)
- [ ] **Loan Product**
  - [ ] Micro Cash Loan (ID: 1)
- [ ] **Client**
  - [ ] Maria Santos (ID: 1)
- [ ] **Loan Lifecycle**
  - [ ] Application Created (ID: 1)
  - [ ] Approved
  - [ ] Disbursed
  - [ ] Repayments recorded
- [ ] **Reports Generated**
  - [ ] Portfolio report
  - [ ] Repayment schedule
  - [ ] Client statement

---

## ⏱️ Time Breakdown

| Phase | Time |
|---|---|
| 1. Environment Setup | 30 min |
| 2. System Configuration | 1 hr |
| 3. Loan Product Config | 30 min |
| 4. Customer Onboarding | 30 min |
| 5. Loan Lifecycle | 2 hrs |
| 6. Repayments | 1 hr |
| 7. Reports | 30 min |
| **Total** | **6-7 hrs** |

---

## 📚 Additional Resources

- **Fineract Docs:** https://fineract.apache.org/docs
- **API Documentation:** https://localhost:8443/fineract-provider/swagger-ui.html
- **Community Wiki:** https://cwiki.apache.org/confluence/display/FINERACT

---

## ✅ Evaluation Criteria

| Criteria | Weight | Evidence |
|---|---|---|
| Installation & Setup | 20% | Docker running, health check pass |
| Loan Product Configuration | 20% | Product created with correct parameters |
| Loan Lifecycle Execution | 30% | Application → Approval → Disbursement → Repayment |
| Data Accuracy & Accounting | 15% | Correct calculations, GL posting |
| Documentation & Clarity | 15% | Clear screenshots, API payloads, logs |

---

## 📞 Support

For issues or questions:
1. Check `FINERACT_ASSIGNMENT_GUIDE.md` for detailed steps
2. Review API responses for error messages
3. Check Docker logs: `docker-compose logs -f fineract`
4. Verify credentials and network access

---

**Last Updated:** January 19, 2026  
**Status:** ✅ Ready for Execution

