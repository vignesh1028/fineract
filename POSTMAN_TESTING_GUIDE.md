# Postman Testing Guide for Apache Fineract

**Purpose:** Test all Fineract API endpoints for user, loan, and client management  
**Prerequisites:** Postman installed, Fineract running on `https://localhost:8443`  
**Authentication:** HTTP Basic Auth (mifos / password)

---

## 1. Postman Setup

### Step 1: Create New Request

1. Open **Postman**
2. Click **+ New** → **Request**
3. Name it: `Fineract API Tests`
4. Choose Collection or create new

### Step 2: Set Base URL

1. Click **Variables** (top right)
2. Click **Edit** (pencil icon)
3. Add Variable:
   - **Variable Name:** `base_url`
   - **Initial Value:** `https://localhost:8443/fineract-provider/api/v1`
   - **Current Value:** `https://localhost:8443/fineract-provider/api/v1`
4. Click **Save**

Now use `{{base_url}}` in all requests!

### Step 3: Setup Authentication

1. In request, click **Auth** tab
2. Select **Basic Auth**
3. **Username:** `mifos`
4. **Password:** `password`
5. Click **Save**

This applies to all requests in the collection.

### Step 4: Handle SSL Certificate (Required!)

Since Fineract uses self-signed certificate:

1. Click **Settings** (gear icon, top right)
2. Scroll down to **SSL certificate verification**
3. Toggle to **OFF**
4. Click **Update**

---

## 2. Test Order (Follow This Sequence)

### Phase 1: Health Check (Verify API is Running)

**Method:** `GET`  
**URL:** `{{base_url}}/actuator/health`

**Expected Response:**
```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP"
    },
    "diskSpace": {
      "status": "UP"
    }
  }
}
```

✅ **If Status 200 and "UP"** → Fineract is healthy!

---

### Phase 2: Create Staff Member

**Method:** `POST`  
**URL:** `{{base_url}}/staff`

**Headers:**
```
Content-Type: application/json
Fineract-Platform-TenantId: default
```

**Body (raw JSON):**
```json
{
  "officeId": 1,
  "firstName": "John",
  "lastName": "Doe",
  "isLoanOfficer": true,
  "mobileNo": "+254712345678",
  "joiningDate": "01 Jan 2024"
}
```

**Expected Response (Status 200):**
```json
{
  "resourceId": 1,
  "resourceIdentifier": "JohnDoe"
}
```

✅ **Save the staff ID (1) for later**

---

### Phase 3: Create Loan Product

**Method:** `POST`  
**URL:** `{{base_url}}/loanproducts`

**Headers:**
```
Content-Type: application/json
Fineract-Platform-TenantId: default
```

**Body (raw JSON):**
```json
{
  "name": "Micro Loan",
  "shortName": "ML",
  "description": "Microloan Product",
  "fundId": 1,
  "transactionProcessingStrategyCode": "mifos-standard-strategy",
  "currencyCode": "USD",
  "digitsAfterDecimal": 2,
  "principal": 10000,
  "minPrincipal": 1000,
  "maxPrincipal": 50000,
  "numberOfRepayments": 12,
  "minNumberOfRepayments": 6,
  "maxNumberOfRepayments": 24,
  "repaymentEvery": 1,
  "repaymentFrequencyType": 2,
  "interestRatePerPeriod": 5,
  "minInterestRatePerPeriod": 0,
  "maxInterestRatePerPeriod": 10,
  "interestType": 0,
  "interestCalculationPeriodType": 0,
  "accountingRule": 2,
  "daysInYearType": 360,
  "isLinkedToOfficeIncentives": false,
  "canUseForTopup": false,
  "installmentAmountInMultiplesOf": 1000
}
```

**Expected Response (Status 200):**
```json
{
  "resourceId": 1,
  "resourceIdentifier": "Micro Loan"
}
```

✅ **Save the product ID (1) for later**

---

### Phase 4: Create Client/Customer

**Method:** `POST`  
**URL:** `{{base_url}}/clients`

**Headers:**
```
Content-Type: application/json
Fineract-Platform-TenantId: default
```

**Body (raw JSON):**
```json
{
  "firstName": "Amina",
  "lastName": "Hassan",
  "email": "amina@example.com",
  "mobileNo": "+254712345678",
  "officeId": 1,
  "legalFormId": 1,
  "dateOfBirth": "01 Jan 1990",
  "submittedOnDate": "01 Jan 2024"
}
```

**Expected Response (Status 200):**
```json
{
  "resourceId": 2,
  "resourceIdentifier": "Amina Hassan"
}
```

✅ **Save the client ID (2) for later**

---

### Phase 5: Apply for Loan

**Method:** `POST`  
**URL:** `{{base_url}}/loans`

**Headers:**
```
Content-Type: application/json
Fineract-Platform-TenantId: default
```

**Body (raw JSON):**
```json
{
  "clientId": 2,
  "loanProductId": 1,
  "loanOfficerId": 1,
  "principal": 5000,
  "loanTermFrequency": 12,
  "loanTermFrequencyType": 2,
  "numberOfRepayments": 12,
  "repaymentEvery": 1,
  "repaymentFrequencyType": 2,
  "interestRatePerPeriod": 5,
  "amortizationType": 0,
  "interestType": 0,
  "interestCalculationPeriodType": 0,
  "transactionProcessingStrategyCode": "mifos-standard-strategy",
  "expectedDisbursementDate": "15 Jan 2024",
  "submittedOnDate": "01 Jan 2024",
  "locale": "en"
}
```

**Expected Response (Status 200):**
```json
{
  "resourceId": 1,
  "loanId": 1,
  "status": {
    "id": 100,
    "code": "loanStatusType.submitted.and.pending.approval",
    "value": "Submitted and pending approval"
  }
}
```

✅ **Save the loan ID (1) for later**

---

### Phase 6: Approve Loan

**Method:** `POST`  
**URL:** `{{base_url}}/loans/1/approve`

**Headers:**
```
Content-Type: application/json
Fineract-Platform-TenantId: default
```

**Body (raw JSON):**
```json
{
  "approvedOnDate": "10 Jan 2024",
  "note": "Loan approved"
}
```

**Expected Response (Status 200):**
```json
{
  "resourceId": 1,
  "loanId": 1,
  "status": {
    "id": 200,
    "code": "loanStatusType.approved",
    "value": "Approved"
  }
}
```

✅ **Loan is now Approved**

---

### Phase 7: Disburse Loan

**Method:** `POST`  
**URL:** `{{base_url}}/loans/1/disburse`

**Headers:**
```
Content-Type: application/json
Fineract-Platform-TenantId: default
```

**Body (raw JSON):**
```json
{
  "actualDisbursementDate": "15 Jan 2024",
  "transactionAmount": 5000,
  "note": "Loan disbursed"
}
```

**Expected Response (Status 200):**
```json
{
  "resourceId": 1,
  "loanId": 1,
  "status": {
    "id": 300,
    "code": "loanStatusType.active",
    "value": "Active"
  }
}
```

✅ **Loan is now Active and Disbursed**

---

### Phase 8: Record Repayment

**Method:** `POST`  
**URL:** `{{base_url}}/loans/1/transactions`

**Headers:**
```
Content-Type: application/json
Fineract-Platform-TenantId: default
```

**Body (raw JSON):**
```json
{
  "transactionDate": "20 Jan 2024",
  "transactionAmount": 500,
  "transactionType": 2,
  "paymentTypeId": 1,
  "note": "Monthly repayment"
}
```

**Expected Response (Status 200):**
```json
{
  "resourceId": 1,
  "transactionId": 2,
  "transactionAmount": 500
}
```

✅ **Repayment recorded**

---

### Phase 9: Get Portfolio Summary (Reports)

**Method:** `GET`  
**URL:** `{{base_url}}/loans/portfolio`

**Expected Response:**
```json
{
  "loans": [
    {
      "id": 1,
      "clientId": 2,
      "clientName": "Amina Hassan",
      "loanProductName": "Micro Loan",
      "principal": 5000,
      "status": "Active",
      "disbursedDate": "15 Jan 2024"
    }
  ]
}
```

✅ **Portfolio retrieved successfully**

---

### Phase 10: Get Client Statement

**Method:** `GET`  
**URL:** `{{base_url}}/clients/2/statements`

**Expected Response:**
```json
{
  "clientId": 2,
  "clientName": "Amina Hassan",
  "statements": [
    {
      "date": "15 Jan 2024",
      "type": "Disbursement",
      "amount": 5000
    },
    {
      "date": "20 Jan 2024",
      "type": "Repayment",
      "amount": 500
    }
  ]
}
```

✅ **Client statement retrieved**

---

## 3. Quick Reference - All Endpoints

| Phase | Method | Endpoint | Body |
|-------|--------|----------|------|
| 1 | GET | `/actuator/health` | None |
| 2 | POST | `/staff` | Create staff |
| 3 | POST | `/loanproducts` | Create product |
| 4 | POST | `/clients` | Create client |
| 5 | POST | `/loans` | Apply loan |
| 6 | POST | `/loans/{id}/approve` | Approve loan |
| 7 | POST | `/loans/{id}/disburse` | Disburse loan |
| 8 | POST | `/loans/{id}/transactions` | Record repayment |
| 9 | GET | `/loans/portfolio` | None |
| 10 | GET | `/clients/{id}/statements` | None |

---

## 4. Common Errors & Solutions

### Error 1: "Unauthorized" (401)
**Problem:** Authentication failed  
**Solution:**
- Check Basic Auth: Username `mifos`, Password `password`
- Check header: `Fineract-Platform-TenantId: default`

### Error 2: "SSL Certificate Error"
**Problem:** Can't connect to HTTPS  
**Solution:**
- Go to **Settings** → Disable **SSL certificate verification**

### Error 3: "No such field" (400)
**Problem:** Missing mandatory field in request  
**Solution:**
- Check all required fields in body
- Verify JSON syntax is correct

### Error 4: "Resource not found" (404)
**Problem:** ID doesn't exist (e.g., staff ID 1 not found)  
**Solution:**
- Create staff first
- Use returned ID from previous request

### Error 5: "Invalid state"
**Problem:** Loan in wrong state (e.g., trying to approve already approved loan)  
**Solution:**
- Follow exact order: Submit → Approve → Disburse
- Check loan status first

---

## 5. Testing Workflow

### Step-by-Step Process

1. **Start:** Test Health Check (Phase 1)
   - Verify Fineract is running
   - Status should be 200 with "UP"

2. **Setup:** Create Staff (Phase 2)
   - Save staff ID (usually 1)
   - Note it down

3. **Configure:** Create Loan Product (Phase 3)
   - Save product ID (usually 1)
   - All parameters required

4. **Customer:** Create Client (Phase 4)
   - Save client ID (usually 2)
   - Verify email and mobile

5. **Application:** Apply for Loan (Phase 5)
   - Use staff ID (1) and product ID (1)
   - Use client ID (2)
   - Save loan ID

6. **Approval:** Approve Loan (Phase 6)
   - Use loan ID from Phase 5
   - Add approval date

7. **Disbursement:** Disburse Loan (Phase 7)
   - Use loan ID from Phase 5
   - Confirm amount matches

8. **Repayment:** Record Payment (Phase 8)
   - Use loan ID from Phase 5
   - Amount should be principal payment

9. **Reporting:** Get Portfolio (Phase 9)
   - Verify loan shows in portfolio
   - Check status is "Active"

10. **Statements:** Get Client Statement (Phase 10)
    - Verify all transactions show
    - Check dates and amounts

---

## 6. Postman Collection Import (Optional)

If you have `FINERACT_POSTMAN_COLLECTION.json`:

1. Click **Import** (top left)
2. Select the JSON file
3. All requests pre-configured!
4. Just click and test

---

## 7. Tips & Tricks

### Tip 1: Use Variables
```
{{base_url}}      - Base API URL
{{staff_id}}      - Staff ID from Phase 2
{{product_id}}    - Product ID from Phase 3
{{client_id}}     - Client ID from Phase 4
{{loan_id}}       - Loan ID from Phase 5
```

### Tip 2: Set Variables from Response
1. In request, go to **Tests** tab
2. Add script:
```javascript
var jsonData = pm.response.json();
pm.environment.set("loan_id", jsonData.resourceId);
```

### Tip 3: Use Raw Body
- Always select **Body** → **raw** → **JSON**
- Not form data!

### Tip 4: Check Status Codes
- 200 = Success ✅
- 400 = Bad request ❌
- 401 = Unauthorized ❌
- 404 = Not found ❌
- 409 = Conflict ❌

### Tip 5: Pretty Print Response
1. After sending request
2. Click **Pretty** button (below response)
3. Much easier to read!

---

## 8. Expected IDs

After running in order, expect these IDs:

```
Staff ID:      1 (or incrementing)
Product ID:    1 (or incrementing)
Client ID:     2 (starts at 2, office is 1)
Loan ID:       1 (or incrementing)
Office ID:     1 (default)
```

⚠️ **IDs may differ if testing multiple times. Always use IDs from response!**

---

## 9. Full Testing Timeline

```
⏱️ Time Estimate: 5-10 minutes total

Health Check:          1 min   ✅
Create Staff:          1 min   ✅
Create Product:        1 min   ✅
Create Client:         1 min   ✅
Apply Loan:            1 min   ✅
Approve Loan:          30 sec  ✅
Disburse Loan:         30 sec  ✅
Record Repayment:      30 sec  ✅
Get Portfolio:         30 sec  ✅
Get Statement:         30 sec  ✅
```

**Total: ~8 minutes to complete full cycle**

---

## 10. Verification Checklist

After testing, verify:

- [ ] Health Check returns "UP"
- [ ] Staff created with ID 1
- [ ] Loan Product created with ID 1
- [ ] Client created with ID 2
- [ ] Loan applied with ID 1
- [ ] Loan approved (status = Approved)
- [ ] Loan disbursed (status = Active)
- [ ] Repayment recorded (amount = 500)
- [ ] Portfolio shows active loan
- [ ] Client statement shows all transactions

---

**Ready to Test!** 🚀

Start with Health Check, then follow the phases in order.
Each request depends on the previous one, so don't skip!

