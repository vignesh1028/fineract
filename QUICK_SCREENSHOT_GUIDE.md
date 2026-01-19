# Quick Screenshot Capture Guide - 5 Minutes

**Purpose:** Add API response screenshots to your project documentation  
**Time Required:** 30 minutes to 1 hour total  
**Tools Needed:** Postman, Screenshot tool, Paint  

---

## 🚀 Quick Start - 5 Easy Steps

### Step 1: Create Screenshot Folders (2 minutes)

```powershell
cd C:\Users\vigne\fineract-assessment\backend\fineract

# Create directories
mkdir -p docs\screenshots\phase-1-health-check
mkdir -p docs\screenshots\phase-2-system-config
mkdir -p docs\screenshots\phase-3-loan-product
mkdir -p docs\screenshots\phase-4-customer
mkdir -p docs\screenshots\phase-5-loan-app
mkdir -p docs\screenshots\phase-6-repayment
mkdir -p docs\screenshots\phase-7-reports
mkdir -p docs\screenshots\ui

Write-Host "✅ Screenshot directories created" -ForegroundColor Green
```

---

### Step 2: Capture Health Check (2 minutes)

**In Postman:**
1. Open Postman
2. Locate: **Health Check** request (or create: GET `https://localhost:8443/fineract-provider/actuator/health`)
3. Click **Send**
4. Wait for response (green 200)
5. Press **Alt+Print Screen** (captures active window)
6. Open Paint: **Win+R** → type `mspaint` → Enter
7. **Ctrl+V** to paste
8. **File** → **Save As**
9. Save as: `C:\Users\vigne\fineract-assessment\backend\fineract\docs\screenshots\phase-1-health-check\health-response.png`
10. Close Paint

✅ **First screenshot done!**

---

### Step 3: Capture Remaining API Responses (20 minutes)

**Quick capture sequence:**

```
1. PHASE 2: Get Offices
   - Endpoint: GET /offices
   - File: docs/screenshots/phase-2-system-config/office-list.png
   - Expected: List of offices with ID 1

2. PHASE 2: Create Staff
   - Endpoint: POST /staff
   - File: docs/screenshots/phase-2-system-config/staff-created.png
   - Expected: "resourceId": 1

3. PHASE 3: Create Loan Product
   - Endpoint: POST /loanproducts
   - File: docs/screenshots/phase-3-loan-product/loan-product-created.png
   - Expected: "resourceId": 1, "name": "Micro Loan"

4. PHASE 4: Create Client
   - Endpoint: POST /clients
   - File: docs/screenshots/phase-4-customer/client-created.png
   - Expected: "resourceId": 2, "firstName": "Amina"

5. PHASE 5: Apply Loan
   - Endpoint: POST /loans
   - File: docs/screenshots/phase-5-loan-app/loan-applied.png
   - Expected: "resourceId": 1, "status": "Submitted"

6. PHASE 5: Approve Loan
   - Endpoint: POST /loans/{id}/approve
   - File: docs/screenshots/phase-5-loan-app/loan-approved.png
   - Expected: "status": "Approved"

7. PHASE 5: Disburse Loan
   - Endpoint: POST /loans/{id}/disburse
   - File: docs/screenshots/phase-5-loan-app/loan-disbursed.png
   - Expected: "status": "Active"

8. PHASE 6: Record Repayment
   - Endpoint: POST /loans/{id}/transactions
   - File: docs/screenshots/phase-6-repayment/repayment-recorded.png
   - Expected: "transactionAmount": 50000

9. PHASE 7: Portfolio Report
   - Endpoint: GET /loans/portfolio
   - File: docs/screenshots/phase-7-reports/portfolio-summary.png
   - Expected: Loan details array

10. PHASE 7: Client Statement
    - Endpoint: GET /clients/{id}/statements
    - File: docs/screenshots/phase-7-reports/client-statement.png
    - Expected: Transaction history
```

**For Each Screenshot:**
1. In Postman: Click request → **Send**
2. Wait for response
3. Press **Alt+Print Screen**
4. Open Paint → **Ctrl+V**
5. **File** → **Save As**
6. Copy filename from list above
7. Save to appropriate folder
8. Close Paint
9. Move to next request

---

### Step 4: Capture UI Screenshots (5 minutes)

**Login Screen:**
1. Open browser: `http://localhost:4200/`
2. You see login form
3. Press **Win+Shift+S** (Windows Snip)
4. Select the login area
5. Automatically copies to clipboard
6. Open Paint → **Ctrl+V**
7. Save to: `docs/screenshots/ui/login-page.png`

**Dashboard:**
1. After logging in, press **Win+Shift+S**
2. Select dashboard area
3. Save to: `docs/screenshots/ui/dashboard.png`

---

### Step 5: Add Screenshots to Documentation (5 minutes)

**Update FINERACT_ASSIGNMENT_GUIDE.md:**

Find section: "## Phase 1: Environment Verification"

Add below the endpoint description:

```markdown
### Screenshot

![Fineract Health Check Response](docs/screenshots/phase-1-health-check/health-response.png)

*Health check response showing Fineract is healthy and running*
```

**Do this for all phases**, using the pattern:
- Phase number
- Screenshot filename
- Brief description

**Example for Phase 2:**
```markdown
### Screenshot

![Office List Response](docs/screenshots/phase-2-system-config/office-list.png)

*Response showing default office (ID: 1)*
```

---

## 📋 Simple Checklist

- [ ] Create `docs/screenshots/` directories
- [ ] Capture Phase 1: Health Check (1 screenshot)
- [ ] Capture Phase 2: Offices & Staff (2 screenshots)
- [ ] Capture Phase 3: Loan Product (1 screenshot)
- [ ] Capture Phase 4: Client (1 screenshot)
- [ ] Capture Phase 5: Loan Apply/Approve/Disburse (3 screenshots)
- [ ] Capture Phase 6: Repayment (1 screenshot)
- [ ] Capture Phase 7: Reports (2 screenshots)
- [ ] Capture UI: Login & Dashboard (2 screenshots)
- [ ] Update FINERACT_ASSIGNMENT_GUIDE.md with screenshots
- [ ] Test that images display correctly
- [ ] Commit to git: `git add docs/screenshots/`
- [ ] Push to GitHub

---

## 🎯 Fastest Workflow

**Total Time: 30 minutes**

```powershell
# 1. Create folders (1 min)
mkdir -p docs\screenshots\{phase-1,phase-2,phase-3,phase-4,phase-5,phase-6,phase-7,ui}

# 2. Open Postman and Browser side-by-side

# 3. For each of 10 endpoints: (20 min)
#    - Send in Postman
#    - Alt+Print Screen
#    - Paste in Paint
#    - Save to folder
#    - Close Paint
#    - 2 minutes per screenshot × 10 = 20 minutes

# 4. Update one markdown file with all screenshots (8 min)

# 5. Git commit (1 min)
git add docs/screenshots/
git commit -m "Add API response screenshots for all phases"
git push origin task/fineract_enhancement
```

---

## 🖼️ Adding Screenshots to Markdown

### Simplest Format
```markdown
![Description](docs/screenshots/phase-1-health-check/health-response.png)
```

### With Caption
```markdown
**Screenshot: Health Check Response**

![Health Check Response](docs/screenshots/phase-1-health-check/health-response.png)

*Shows Fineract API is healthy with all components running*
```

### Full Integration Example

Find this in FINERACT_ASSIGNMENT_GUIDE.md:
```markdown
## Phase 1: Environment Verification

The health check endpoint verifies that Fineract is running and healthy.

### Health Check Request

```
GET https://localhost:8443/fineract-provider/actuator/health
```

### Health Check Response
```

Then add your screenshot:
```markdown
## Phase 1: Environment Verification

The health check endpoint verifies that Fineract is running and healthy.

### Health Check Request

```
GET https://localhost:8443/fineract-provider/actuator/health
```

### Health Check Response Screenshot

![Fineract Health Check Response](docs/screenshots/phase-1-health-check/health-response.png)

*API Response: HTTP 200 with status UP - Fineract is healthy*

### Expected Response

```json
{
  "status": "UP",
  "components": {
    "db": {"status": "UP"},
    "diskSpace": {"status": "UP"}
  }
}
```
```

---

## 💡 Pro Tips

### Tip 1: Use Postman's Built-in Screenshot
- Some Postman versions have **Save Response → Save as Image**
- Look for camera icon or three-dots menu

### Tip 2: Crop Before Saving
- In Paint: Select → Free-form selection
- Select just the response area
- Image → Crop to selection
- Saves space and looks better

### Tip 3: Add Annotations
- Use Paint to add arrows/circles
- Highlight important fields
- Add red boxes around key responses

### Tip 4: Batch Capture
- Run FINAL_IMPLEMENTATION.ps1 script
- Capture console output showing all phases passing
- Save as `docs/screenshots/automation-output.txt`

### Tip 5: Check File Sizes
```powershell
# Check size of screenshot
Get-Item "docs\screenshots\phase-1-health-check\health-response.png" | 
  Select-Object Name, @{Name="Size(KB)";Expression={[math]::Round($_.Length/1KB,2)}}

# Ideal: Under 500KB per image
# If larger, compress in Paint (Save As JPEG, quality 80%)
```

---

## ❌ Common Mistakes to Avoid

| Mistake | Fix |
|---------|-----|
| **Screenshot too large** | Crop in Paint before saving |
| **Wrong resolution** | Windows 100% zoom, Postman full window |
| **Image path wrong** | Use: `docs/screenshots/phase-1/file.png` |
| **Not committed to git** | `git add docs/` before commit |
| **Markdown link broken** | Test by opening in browser |
| **File name has spaces** | Use hyphens: `health-check.png` not `health check.png` |

---

## 🔗 Complete File Path Reference

```
docs/
├── screenshots/
│   ├── phase-1-health-check/
│   │   └── health-response.png
│   ├── phase-2-system-config/
│   │   ├── office-list.png
│   │   └── staff-created.png
│   ├── phase-3-loan-product/
│   │   └── loan-product-created.png
│   ├── phase-4-customer/
│   │   └── client-created.png
│   ├── phase-5-loan-app/
│   │   ├── loan-applied.png
│   │   ├── loan-approved.png
│   │   └── loan-disbursed.png
│   ├── phase-6-repayment/
│   │   └── repayment-recorded.png
│   ├── phase-7-reports/
│   │   ├── portfolio-summary.png
│   │   └── client-statement.png
│   └── ui/
│       ├── login-page.png
│       └── dashboard.png
```

---

## ✅ Verification

**After adding screenshots, verify:**

1. All 10 API screenshots captured ✅
2. All 2-3 UI screenshots captured ✅
3. Markdown files updated with image links ✅
4. Images display correctly when viewing markdown ✅
5. File sizes reasonable (< 500KB each) ✅
6. Committed to git ✅
7. Pushed to GitHub ✅

---

## 🚀 Run These Commands

```powershell
# 1. Create directories
cd C:\Users\vigne\fineract-assessment\backend\fineract
mkdir -p docs\screenshots\{phase-1-health-check,phase-2-system-config,phase-3-loan-product,phase-4-customer,phase-5-loan-app,phase-6-repayment,phase-7-reports,ui}

# 2. After saving screenshots, verify count
(Get-ChildItem -Recurse docs\screenshots\ -Filter *.png).Count

# 3. Check total size
$size = (Get-ChildItem -Recurse docs\screenshots\).Length
Write-Host "Total screenshot size: $([math]::Round($size/1MB, 2)) MB"

# 4. Commit and push
git add docs/screenshots/
git commit -m "docs: Add API response screenshots for all 7 phases"
git push origin task/fineract_enhancement
```

---

**Time Estimate: 30-45 minutes total**  
**Effort: Easy - Just Alt+Print Screen + Save**  
**Value: High - Visual documentation is invaluable**

Start with Phase 1 (health check) - takes 2 minutes and you'll understand the process!

---

**Last Updated:** January 20, 2026  
**Status:** Ready to Use
