# How to Add API Response Screenshots to Documentation

**Version:** 1.0  
**Date:** January 20, 2026  

---

## Overview

This guide explains how to capture API response screenshots and integrate them into your project documentation. Screenshots should be included for all major API endpoints covered in the 7 phases.

---

## Step 1: Create Screenshots Directory Structure

### Directory Organization

```
fineract/
├── docs/
│   ├── screenshots/
│   │   ├── phase-1-health-check/
│   │   │   └── health-response.png
│   │   ├── phase-2-system-config/
│   │   │   ├── office-list.png
│   │   │   └── staff-created.png
│   │   ├── phase-3-loan-product/
│   │   │   └── loan-product-created.png
│   │   ├── phase-4-customer/
│   │   │   └── client-created.png
│   │   ├── phase-5-loan-app/
│   │   │   ├── loan-applied.png
│   │   │   ├── loan-approved.png
│   │   │   └── loan-disbursed.png
│   │   ├── phase-6-repayment/
│   │   │   └── repayment-recorded.png
│   │   ├── phase-7-reports/
│   │   │   ├── portfolio-summary.png
│   │   │   └── client-statement.png
│   │   └── ui/
│   │       ├── login-page.png
│   │       ├── dashboard.png
│   │       └── create-client.png
```

### Create the Directory Structure

**PowerShell:**
```powershell
# Create docs directory structure
$directories = @(
    "docs/screenshots/phase-1-health-check",
    "docs/screenshots/phase-2-system-config",
    "docs/screenshots/phase-3-loan-product",
    "docs/screenshots/phase-4-customer",
    "docs/screenshots/phase-5-loan-app",
    "docs/screenshots/phase-6-repayment",
    "docs/screenshots/phase-7-reports",
    "docs/screenshots/ui"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force
        Write-Host "✅ Created: $dir"
    }
}
```

---

## Step 2: Capture API Response Screenshots

### Option A: Using Postman (Recommended for API Responses)

**Steps:**
1. **Open Postman** (or import FINERACT_POSTMAN_COLLECTION.json)
2. **For each API endpoint:**
   - Select the request from the collection
   - Click **Send**
   - Wait for response
   - Take screenshot of the **Response panel**
   - Save as `endpoint-name.png`

**Screenshots to Capture:**

| Phase | Endpoint | Screenshot Name | Status Code |
|-------|----------|-----------------|------------|
| **Phase 1** | GET /actuator/health | health-response.png | 200 |
| **Phase 2** | GET /offices | office-list.png | 200 |
| **Phase 2** | POST /staff | staff-created.png | 200 |
| **Phase 3** | POST /loanproducts | loan-product-created.png | 200 |
| **Phase 4** | POST /clients | client-created.png | 200 |
| **Phase 5** | POST /loans | loan-applied.png | 200 |
| **Phase 5** | POST /loans/{id}/approve | loan-approved.png | 200 |
| **Phase 5** | POST /loans/{id}/disburse | loan-disbursed.png | 200 |
| **Phase 6** | POST /loans/{id}/transactions | repayment-recorded.png | 200 |
| **Phase 7** | GET /loans/portfolio | portfolio-summary.png | 200 |
| **Phase 7** | GET /clients/{id}/statements | client-statement.png | 200 |

**Postman Screenshot Tips:**
- Set zoom to 100% for clarity
- Include the entire response panel
- Show status code and response time
- Capture request headers in a separate screenshot if needed

### Option B: Using Browser Developer Tools

**Steps:**
1. Open browser to `http://localhost:4200/`
2. Open **Developer Tools** (F12)
3. Go to **Network tab**
4. Perform action (login, create client, etc.)
5. Click on the request in Network tab
6. View **Response tab**
7. Take screenshot

**For UI Screenshots:**
- Element Inspector mode (Ctrl+Shift+C)
- Show relevant UI sections
- Capture form inputs and outputs
- Include success/error messages

### Option C: Using PowerShell Script Output

**For API automation results:**
```powershell
# Run script and capture output
$output = .\FINAL_IMPLEMENTATION.ps1 2>&1

# Save to file
$output | Out-File "docs/screenshots/automation-output.txt"

# Or capture console with screenshot tool
# Alt+Print Screen to copy active window
# Then paste into Paint and save as PNG
```

---

## Step 3: How to Include Screenshots in Markdown

### Basic Markdown Image Syntax

```markdown
![Alt Text](path/to/image.png)
```

### With Size Control

```markdown
![Alt Text](path/to/image.png){width="80%"}

<!-- Or using HTML -->
<img src="path/to/image.png" width="600" alt="Alt Text">
```

### With Captions

```markdown
**Figure 1: Health Check Response**
![Health Check Response](docs/screenshots/phase-1-health-check/health-response.png)
*This shows the Fineract API is running and healthy*
```

### Full Example Structure

```markdown
## Phase 1: Environment Verification

### Health Check Endpoint

The first step is to verify that Fineract is running and healthy.

**Endpoint:** `GET /fineract-provider/actuator/health`

**Response:**

![Health Check Response](docs/screenshots/phase-1-health-check/health-response.png)
*Expected Response: HTTP 200 with status: UP*

**Key Fields:**
- `status`: "UP" - Indicates service is healthy
- `components`: Database and other component health
```

---

## Step 4: Update Documentation Files with Screenshots

### Files to Update

1. **FINERACT_ASSIGNMENT_GUIDE.md** - Add for each phase
2. **EXECUTION_SUMMARY.md** - Add expected outputs
3. **README_ASSIGNMENT.md** - Add quick reference screenshots
4. **PROJECT_COMPLETION_REPORT.md** - Add in testing section
5. New file: **API_SCREENSHOTS.md** - Dedicated gallery

### Example Update for FINERACT_ASSIGNMENT_GUIDE.md

```markdown
## Phase 1: Environment Verification

### Health Check API

**Objective:** Verify Fineract is running and healthy

**Endpoint:** 
```
GET https://localhost:8443/fineract-provider/actuator/health
```

**Headers:**
```
Authorization: Basic bWlmb3M6cGFzc3dvcmQ=
```

**Response Screenshot:**

![Fineract Health Check](docs/screenshots/phase-1-health-check/health-response.png)

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

**Verification:**
- ✅ Status code: 200
- ✅ Response contains "status": "UP"
- ✅ Database component healthy
```

---

## Step 5: Create API Screenshots Gallery Document

### Create new file: docs/API_SCREENSHOTS.md

```markdown
# API Response Screenshots

This document contains screenshots of all major API responses for the 7-phase Fineract implementation.

## Table of Contents
- [Phase 1: Health Check](#phase-1-health-check)
- [Phase 2: System Configuration](#phase-2-system-configuration)
- [Phase 3: Loan Product](#phase-3-loan-product)
- [Phase 4: Customer Onboarding](#phase-4-customer-onboarding)
- [Phase 5: Loan Processing](#phase-5-loan-processing)
- [Phase 6: Repayment](#phase-6-repayment)
- [Phase 7: Reports](#phase-7-reports)
- [UI Screenshots](#ui-screenshots)

## Phase 1: Health Check

### Health Check Endpoint
![Health Check](docs/screenshots/phase-1-health-check/health-response.png)
**Status:** 200 OK  
**Shows:** Fineract service is healthy with all components running

---

## Phase 2: System Configuration

### Get Offices
![Get Offices](docs/screenshots/phase-2-system-config/office-list.png)

### Create Staff
![Create Staff](docs/screenshots/phase-2-system-config/staff-created.png)

---

[Continue for all phases...]
```

---

## Step 6: Tools for Taking Screenshots

### Recommended Tools

| Tool | Use Case | Platform |
|------|----------|----------|
| **Postman** | API responses | All |
| **Browser DevTools** | Network requests, UI | All |
| **Snagit** | Professional screenshots | Windows/Mac |
| **ShareX** | Free screenshot tool | Windows |
| **Greenshot** | Free, lightweight | Windows |
| **Built-in Screenshot** | Simple option | All (Win+Shift+S) |
| **Paint/Paint.NET** | Edit screenshots | Windows |

### Windows Screenshot Shortcuts

```
Win + Shift + S     → Snip & Sketch (select area)
Alt + Print Screen  → Copy active window
Print Screen        → Copy entire screen
Win + Print Screen  → Save screenshot to Pictures
```

---

## Step 7: Postman-Specific Instructions

### Export Responses from Postman

**Method 1: Manual Screenshot**
1. Click **Send** on request
2. Response appears below
3. Right-click → **Screenshot** (some versions)
4. Or use Alt+Print Screen to capture window

**Method 2: Save Response to File**
1. Click response
2. Click **Save Response** button
3. Choose **Save as File**
4. Select JSON format
5. Name: `endpoint-response.json`

**Method 3: Copy Response**
1. Click response body
2. Ctrl+A to select all
3. Ctrl+C to copy
4. Paste into text editor
5. Save as JSON

---

## Step 8: Organizing Screenshots

### Naming Convention

```
{phase}-{endpoint-or-action}.png

Examples:
- phase-1-health-check.png
- phase-2-create-staff.png
- phase-3-loan-product-created.png
- phase-4-client-onboarded.png
- phase-5-loan-approved.png
- phase-6-repayment-processed.png
- phase-7-portfolio-report.png
- ui-login-success.png
```

### File Size Optimization

**Before Committing:**
```powershell
# Compress images (Windows)
# Using Paint: Open → Resize → Save as JPEG (quality 80%)

# Or use ImageMagick (if installed)
magick convert input.png -quality 85 output.png

# Recommended: Keep below 500KB per image
# Height: 600-800px for readability
```

---

## Step 9: Create Images README

### Create: docs/screenshots/README.md

```markdown
# API Response Screenshots

All screenshots showing API responses for the 7-phase Fineract Microloan implementation.

## Organization

- **phase-1-health-check/** - Environment verification responses
- **phase-2-system-config/** - Office and staff creation responses
- **phase-3-loan-product/** - Loan product configuration responses
- **phase-4-customer/** - Client onboarding responses
- **phase-5-loan-app/** - Loan application, approval, disbursement
- **phase-6-repayment/** - Repayment recording responses
- **phase-7-reports/** - Report generation responses
- **ui/** - Web UI screenshots

## Capture Method

All API response screenshots were captured using Postman collection with the following:
- Fineract API running on https://localhost:8443
- Authentication: Basic Auth (mifos:password)
- Status codes and response bodies visible
- Request/response headers included where relevant

## Last Updated

- Date: January 20, 2026
- Total Screenshots: [Count]
- Total Size: [Size in MB]
```

---

## Step 10: Quick Capture Workflow

### Fastest Method: Use Postman + Screenshots

```powershell
# 1. Import Postman collection (if not already imported)
# File → Import → FINERACT_POSTMAN_COLLECTION.json

# 2. For each folder/request:
#    - Click request
#    - Click Send
#    - Take screenshot of response
#    - Save to appropriate folder

# 3. Create markdown files with screenshots
# 4. Commit to git

# Example for Phase 1:
# - Open Health Check request
# - Click Send
# - Wait for 200 response
# - Alt+Print Screen
# - Paste into Paint
# - Save to: docs/screenshots/phase-1-health-check/health-response.png
```

---

## Step 11: Add Screenshots to Git

### Commit Screenshots

```powershell
cd C:\Users\vigne\fineract-assessment\backend\fineract

# Add all screenshots
git add docs/screenshots/

# Commit with message
git commit -m "docs: Add API response screenshots for all 7 phases

- Screenshots of health check, staff creation, loan product creation
- Client onboarding, loan application, approval, disbursement
- Repayment processing and report generation
- UI login, dashboard, and client creation screens
- Total: 15+ API response screenshots with annotations"

# Push to GitHub
git push origin task/fineract_enhancement
```

---

## Step 12: Example Screenshot Markdown Templates

### Template 1: Simple API Response

```markdown
### Create Client Response

![Create Client Response](docs/screenshots/phase-4-customer/client-created.png)

**Details:**
- Status Code: 200
- Response Time: 45ms
- Client ID: 2
- Name: Amina Ahmed
- Status: Active
```

### Template 2: Detailed API Response with Explanation

```markdown
### Loan Application Response

![Loan Application](docs/screenshots/phase-5-loan-app/loan-applied.png)

**API Call:**
```
POST /fineract-provider/api/v1/loans
```

**Request Body:**
```json
{
  "clientId": 2,
  "productId": 1,
  "principal": 100000,
  "loanTermFrequency": 12,
  "loanTermFrequencyType": 2,
  "numberOfRepayments": 12,
  "repaymentEvery": 1,
  "repaymentFrequencyType": 2,
  "interestRatePerPeriod": 15,
  "amortizationType": 1,
  "interestType": 0,
  "interestCalculationPeriodType": 1,
  "submittedOnDate": "01 Jan 2026",
  "expectedDisbursementDate": "01 Jan 2026"
}
```

**Response:**
- Status Code: 200
- Loan ID: 1
- Resource Location: /loans/1
- Status: Submitted (awaiting approval)

**Next Step:** Approve the loan using Phase 5 approval endpoint
```

### Template 3: Before/After Comparison

```markdown
### Loan Status Progression

**Before (Submitted):**
![Loan Submitted](docs/screenshots/phase-5-loan-app/loan-applied.png)

**After (Approved):**
![Loan Approved](docs/screenshots/phase-5-loan-app/loan-approved.png)

**After (Disbursed):**
![Loan Disbursed](docs/screenshots/phase-5-loan-app/loan-disbursed.png)

Notice how the status field changes from "Submitted" → "Approved" → "Active (Disbursed)"
```

---

## Complete Checklist

### Screenshots to Capture

- [ ] Phase 1: Health Check (1 screenshot)
- [ ] Phase 2: Get Offices (1 screenshot)
- [ ] Phase 2: Create Staff (1 screenshot)
- [ ] Phase 3: Create Loan Product (1 screenshot)
- [ ] Phase 4: Create Client (1 screenshot)
- [ ] Phase 5: Apply for Loan (1 screenshot)
- [ ] Phase 5: Approve Loan (1 screenshot)
- [ ] Phase 5: Disburse Loan (1 screenshot)
- [ ] Phase 6: Record Repayment (1 screenshot)
- [ ] Phase 7: Get Portfolio (1 screenshot)
- [ ] Phase 7: Get Client Statement (1 screenshot)
- [ ] UI: Login Page (1 screenshot)
- [ ] UI: Dashboard (1 screenshot)
- [ ] UI: Create Client Form (1 screenshot)
- [ ] UI: Loan Details (1 screenshot)

**Total: 15+ screenshots**

### Documentation Updates

- [ ] Create docs/screenshots/ directory structure
- [ ] Capture all API response screenshots
- [ ] Create docs/API_SCREENSHOTS.md gallery
- [ ] Update FINERACT_ASSIGNMENT_GUIDE.md with screenshots
- [ ] Update EXECUTION_SUMMARY.md with expected outputs
- [ ] Update README_ASSIGNMENT.md with quick reference screenshots
- [ ] Create docs/screenshots/README.md index
- [ ] Optimize image file sizes
- [ ] Add to git and commit
- [ ] Push to GitHub

---

## Markdown Image Tips

### Responsive Images
```markdown
<img src="docs/screenshots/phase-1/health-check.png" width="600" alt="Health Check">
```

### Centered Images
```markdown
<div align="center">
  <img src="docs/screenshots/phase-1/health-check.png" width="600" alt="Health Check">
  <p><em>Health Check Response</em></p>
</div>
```

### Image with Caption
```markdown
**Figure 1: Fineract Health Check Response**
![Health Check](docs/screenshots/phase-1/health-check.png)
*Response shows all components are healthy (UP)*
```

---

## Next Steps

1. ✅ Create directory structure for screenshots
2. ✅ Capture API responses using Postman
3. ✅ Capture UI screenshots from browser
4. ✅ Optimize image sizes
5. ✅ Create gallery document (API_SCREENSHOTS.md)
6. ✅ Update existing guides with screenshots
7. ✅ Commit and push to GitHub
8. ✅ Share with team

---

**Guide Version:** 1.0  
**Created:** January 20, 2026  
**Status:** Ready to Use
