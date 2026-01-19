# Apache Fineract API Automation Script
# This script automates Phase 2-6 configuration and transactions

param(
    [string]$Phase = "all",
    [string]$BaseUrl = "https://localhost:8443/fineract-provider/api/v1",
    [string]$Username = "mifos",
    [string]$Password = "password",
    [string]$TenantId = "default"
)

# Helper function to make API calls
function Invoke-FineractAPI {
    param(
        [string]$Method,
        [string]$Endpoint,
        [object]$Body = $null
    )
    
    # Create auth header
    $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($Username):$($Password)"))
    
    # Ignore self-signed certificate
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    
    $headers = @{
        "Authorization" = "Basic $auth"
        "Fineract-Platform-TenantId" = $TenantId
        "Content-Type" = "application/json"
    }
    
    $uri = "$BaseUrl$Endpoint"
    
    try {
        if ($Body) {
            $bodyJson = $Body | ConvertTo-Json -Depth 10
            Write-Host "[API] $Method $Endpoint" -ForegroundColor Cyan
            Write-Host "[Body] $bodyJson" -ForegroundColor Gray
            
            $response = Invoke-WebRequest -Uri $uri -Method $Method -Headers $headers -Body $bodyJson -UseBasicParsing
        } else {
            Write-Host "[API] $Method $Endpoint" -ForegroundColor Cyan
            $response = Invoke-WebRequest -Uri $uri -Method $Method -Headers $headers -UseBasicParsing
        }
        
        $result = $response.Content | ConvertFrom-Json
        Write-Host "[Response] ResourceId: $($result.resourceId)" -ForegroundColor Green
        return $result
    } catch {
        Write-Host "[Error] $_" -ForegroundColor Red
        return $null
    }
}

# PHASE 2: SYSTEM CONFIGURATION
function Phase2-SystemConfiguration {
    Write-Host "========== PHASE 2: SYSTEM CONFIGURATION ==========" -ForegroundColor Yellow
    
    # 2.1 Create Branch Office
    Write-Host "`n[2.1] Creating Branch Office..." -ForegroundColor Cyan
    $office = Invoke-FineractAPI -Method POST -Endpoint "/offices" -Body @{
        name = "Downtown Branch"
        openingDate = "01 Jan 2024"
        parentId = 1
        dateFormat = "dd MMM yyyy"
        locale = "en"
    }
    $officeId = $office.resourceId
    Write-Host "Branch Office ID: $officeId" -ForegroundColor Green
    
    # 2.2 Create Loan Officer
    Write-Host "`n[2.2] Creating Loan Officer..." -ForegroundColor Cyan
    $staff = Invoke-FineractAPI -Method POST -Endpoint "/staff" -Body @{
        firstname = "John"
        lastname = "Smith"
        officeId = $officeId
        isLoanOfficer = $true
        dateFormat = "dd MMM yyyy"
        locale = "en"
    }
    $staffId = $staff.resourceId
    Write-Host "Loan Officer ID: $staffId" -ForegroundColor Green
    
    # 2.3 Get Existing GL Accounts (no creation, use defaults)
    Write-Host "`n[2.3] Fetching GL Accounts..." -ForegroundColor Cyan
    $glAccounts = Invoke-FineractAPI -Method GET -Endpoint "/glaccounts?type=1&usage=1"
    Write-Host "GL Accounts retrieved" -ForegroundColor Green
    
    return @{
        officeId = $officeId
        staffId = $staffId
    }
}

# PHASE 3: LOAN PRODUCT CONFIGURATION
function Phase3-LoanProductConfiguration {
    Write-Host "`n========== PHASE 3: LOAN PRODUCT CONFIGURATION ==========" -ForegroundColor Yellow
    
    Write-Host "`n[3.1] Creating Loan Product..." -ForegroundColor Cyan
    
    # Note: GL account IDs may vary. Adjust these based on your system
    $product = Invoke-FineractAPI -Method POST -Endpoint "/loanproducts" -Body @{
        name = "Micro Cash Loan"
        description = "Cash loan for microfinance customers"
        fundId = 1
        loanType = "individual"
        currencyCode = "USD"
        digitsAfterDecimal = 2
        principal = "10000"
        minPrincipal = "5000"
        maxPrincipal = "25000"
        startDate = "01 Jan 2024"
        locale = "en"
        dateFormat = "dd MMM yyyy"
        interestCalculationPeriodType = 1
        interestType = 0
        amortizationType = 1
        numberOfRepayments = 6
        repaymentEvery = 1
        repaymentFrequencyType = 2
        interestRatePerPeriod = "2"
        accountingRule = 2
        includeInBorrowerCycle = $true
        useBorrowerCycle = $false
    }
    
    $productId = $product.resourceId
    Write-Host "Loan Product ID: $productId" -ForegroundColor Green
    
    return $productId
}

# PHASE 4: CUSTOMER ONBOARDING
function Phase4-CustomerOnboarding {
    param([int]$OfficeId)
    
    Write-Host "`n========== PHASE 4: CUSTOMER ONBOARDING ==========" -ForegroundColor Yellow
    
    Write-Host "`n[4.1] Creating Client..." -ForegroundColor Cyan
    $client = Invoke-FineractAPI -Method POST -Endpoint "/clients" -Body @{
        firstname = "Maria"
        lastname = "Santos"
        externalId = "EXT001"
        officeId = $OfficeId
        dateOfBirth = "01 Jan 1990"
        dateFormat = "dd MMM yyyy"
        locale = "en"
        mobileNo = "+1234567890"
        accountNo = "ACC001"
        active = $true
        activationDate = "01 Jan 2024"
        submittedOnDate = "01 Jan 2024"
    }
    
    $clientId = $client.resourceId
    Write-Host "Client ID: $clientId" -ForegroundColor Green
    
    return $clientId
}

# PHASE 5: LOAN APPLICATION FLOW
function Phase5-LoanApplication {
    param(
        [int]$ClientId,
        [int]$ProductId,
        [int]$StaffId
    )
    
    Write-Host "`n========== PHASE 5: LOAN APPLICATION FLOW ==========" -ForegroundColor Yellow
    
    # 5.1 Create Loan
    Write-Host "`n[5.1] Creating Loan Application..." -ForegroundColor Cyan
    $loan = Invoke-FineractAPI -Method POST -Endpoint "/loans" -Body @{
        clientId = $ClientId
        productId = $ProductId
        loanOfficerId = $StaffId
        loanType = "individual"
        principal = "10000"
        currency = @{ code = "USD" }
        numberOfRepayments = 6
        repaymentEvery = 1
        repaymentFrequencyType = 2
        interestRatePerPeriod = "2"
        amortizationType = 1
        interestType = 0
        interestCalculationPeriodType = 1
        expectedDisbursementDate = "15 Jan 2024"
        submittedOnDate = "10 Jan 2024"
        locale = "en"
        dateFormat = "dd MMM yyyy"
    }
    
    $loanId = $loan.resourceId
    Write-Host "Loan ID: $loanId" -ForegroundColor Green
    
    # 5.2 Retrieve Loan Details
    Write-Host "`n[5.2] Fetching Loan Details..." -ForegroundColor Cyan
    $loanDetails = Invoke-FineractAPI -Method GET -Endpoint "/loans/$loanId?associations=all"
    Write-Host "Loan retrieved successfully" -ForegroundColor Green
    
    # 5.3 Approve Loan
    Write-Host "`n[5.3] Approving Loan..." -ForegroundColor Cyan
    $approval = Invoke-FineractAPI -Method POST -Endpoint "/loans/$loanId/approve" -Body @{
        approvedOnDate = "12 Jan 2024"
        locale = "en"
        dateFormat = "dd MMM yyyy"
    }
    Write-Host "Loan approved" -ForegroundColor Green
    
    # 5.4 Disburse Loan
    Write-Host "`n[5.4] Disbursing Loan..." -ForegroundColor Cyan
    $disbursement = Invoke-FineractAPI -Method POST -Endpoint "/loans/$loanId/disburse" -Body @{
        actualDisbursementDate = "15 Jan 2024"
        transactionAmount = "10000"
        paymentTypeId = 1
        locale = "en"
        dateFormat = "dd MMM yyyy"
    }
    Write-Host "Loan disbursed" -ForegroundColor Green
    
    return $loanId
}

# PHASE 6: REPAYMENTS
function Phase6-Repayments {
    param([int]$LoanId)
    
    Write-Host "`n========== PHASE 6: REPAYMENTS & LOAN SERVICING ==========" -ForegroundColor Yellow
    
    # Scenario 1: On-time repayment
    Write-Host "`n[6.1] On-Time Repayment (First Installment)..." -ForegroundColor Cyan
    $repay1 = Invoke-FineractAPI -Method POST -Endpoint "/loans/$LoanId/transactions?command=repayment" -Body @{
        transactionDate = "15 Feb 2024"
        transactionAmount = "1700"
        paymentTypeId = 1
        locale = "en"
        dateFormat = "dd MMM yyyy"
    }
    Write-Host "First repayment recorded" -ForegroundColor Green
    
    # Scenario 2: Partial repayment
    Write-Host "`n[6.2] Partial Repayment..." -ForegroundColor Cyan
    $repay2 = Invoke-FineractAPI -Method POST -Endpoint "/loans/$LoanId/transactions?command=repayment" -Body @{
        transactionDate = "15 Mar 2024"
        transactionAmount = "1000"
        paymentTypeId = 1
        locale = "en"
        dateFormat = "dd MMM yyyy"
    }
    Write-Host "Partial repayment recorded" -ForegroundColor Green
    
    Write-Host "`nRepayments completed!" -ForegroundColor Green
}

# PHASE 7: REPORTS
function Phase7-Reports {
    param([int]$LoanId, [int]$ClientId)
    
    Write-Host "`n========== PHASE 7: REPORTS & MONITORING ==========" -ForegroundColor Yellow
    
    # Report 1: Loan Portfolio
    Write-Host "`n[7.1] Generating Loan Portfolio Report..." -ForegroundColor Cyan
    $portfolio = Invoke-FineractAPI -Method GET -Endpoint "/loans?status=active"
    Write-Host "Portfolio report generated" -ForegroundColor Green
    
    # Report 2: Repayment Schedule
    Write-Host "`n[7.2] Fetching Repayment Schedule..." -ForegroundColor Cyan
    $schedule = Invoke-FineractAPI -Method GET -Endpoint "/loans/$LoanId?associations=repaymentSchedule"
    Write-Host "Repayment schedule retrieved" -ForegroundColor Green
    
    # Report 3: Client Loan Statement
    Write-Host "`n[7.3] Generating Client Statement..." -ForegroundColor Cyan
    $statement = Invoke-FineractAPI -Method GET -Endpoint "/clients/$ClientId?associations=loans"
    Write-Host "Client statement generated" -ForegroundColor Green
}

# MAIN EXECUTION
Write-Host "`n╔══════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║  Apache Fineract Microloan Assignment Automation    ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Magenta

if ($Phase -eq "all" -or $Phase -eq "2") {
    $config = Phase2-SystemConfiguration
    $officeId = $config.officeId
    $staffId = $config.staffId
}

if ($Phase -eq "all" -or $Phase -eq "3") {
    $productId = Phase3-LoanProductConfiguration
}

if ($Phase -eq "all" -or $Phase -eq "4") {
    if (-not $officeId) { $officeId = Read-Host "Enter Office ID" }
    $clientId = Phase4-CustomerOnboarding -OfficeId $officeId
}

if ($Phase -eq "all" -or $Phase -eq "5") {
    if (-not $clientId) { $clientId = Read-Host "Enter Client ID" }
    if (-not $productId) { $productId = Read-Host "Enter Product ID" }
    if (-not $staffId) { $staffId = Read-Host "Enter Staff ID" }
    
    $loanId = Phase5-LoanApplication -ClientId $clientId -ProductId $productId -StaffId $staffId
}

if ($Phase -eq "all" -or $Phase -eq "6") {
    if (-not $loanId) { $loanId = Read-Host "Enter Loan ID" }
    Phase6-Repayments -LoanId $loanId
}

if ($Phase -eq "all" -or $Phase -eq "7") {
    if (-not $loanId) { $loanId = Read-Host "Enter Loan ID" }
    if (-not $clientId) { $clientId = Read-Host "Enter Client ID" }
    Phase7-Reports -LoanId $loanId -ClientId $clientId
}

Write-Host "`n╔══════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║              Assignment Completed!                   ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Magenta

Write-Host "`n[Summary]" -ForegroundColor Yellow
Write-Host "Office ID: $officeId"
Write-Host "Staff ID: $staffId"
Write-Host "Product ID: $productId"
Write-Host "Client ID: $clientId"
Write-Host "Loan ID: $loanId"

