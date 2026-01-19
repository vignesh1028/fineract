# Apache Fineract Microloan - Deployment Guide

**Version:** 1.0  
**Last Updated:** January 19, 2026  
**Target:** Production & Development Environments  

---

## Table of Contents

1. [Quick Start (Development)](#quick-start-development)
2. [Prerequisites](#prerequisites)
3. [Local Development Setup](#local-development-setup)
4. [Production Deployment](#production-deployment)
5. [Docker Deployment](#docker-deployment)
6. [Configuration Guide](#configuration-guide)
7. [Troubleshooting](#troubleshooting)
8. [Monitoring & Maintenance](#monitoring--maintenance)

---

## Quick Start (Development)

### Minimum Setup (5 minutes)

```powershell
# 1. Start Docker services
cd C:\Users\vigne\fineract-assessment\backend\fineract
docker-compose up -d

# 2. Wait 30 seconds for services to become healthy
Start-Sleep -Seconds 30

# 3. Start Angular dev server
cd C:\Users\vigne\fineract-assessment\web-app
npm start

# 4. Open browser
Start-Process "http://localhost:4200/"

# 5. Login
# Username: mifos
# Password: password
```

### Running Automation Script

```powershell
# Execute all 7 phases automatically
cd C:\Users\vigne\fineract-assessment\backend\fineract
.\FINAL_IMPLEMENTATION.ps1

# Output shows:
# Phase 1: Health Check ................... ✅ PASS
# Phase 2: System Configuration ........... ✅ PASS
# ... (all 7 phases)
```

---

## Prerequisites

### System Requirements

| Component | Minimum | Recommended |
|-----------|---------|------------|
| **CPU** | 4 cores | 8 cores |
| **RAM** | 8 GB | 16 GB |
| **Disk** | 20 GB | 50 GB |
| **OS** | Windows 10, macOS 10.15, Linux (Ubuntu 20.04) | Windows Server 2019+ |

### Software Requirements

```
✅ Docker Desktop 4.0+ (or Docker Engine)
✅ Docker Compose 1.29+
✅ Node.js 18.0+
✅ npm 9.0+
✅ PowerShell 5.1+ (for scripts)
✅ Git 2.30+
```

### Verification

```powershell
# Check Docker
docker --version
# Output: Docker version 20.10+

# Check Docker Compose
docker-compose --version
# Output: Docker Compose version 1.29+

# Check Node.js
node --version
# Output: v18.0.0+

# Check npm
npm --version
# Output: 9.0.0+

# Check PowerShell
$PSVersionTable.PSVersion
# Output: Major=5, Minor=1
```

---

## Local Development Setup

### Step 1: Clone Repository

```powershell
# Clone the Fineract repository
git clone https://github.com/vignesh1028/fineract.git
cd fineract

# Checkout the feature branch
git checkout task/fineract_enhancement
```

### Step 2: Start Backend Services

```powershell
# Navigate to backend directory
cd C:\Users\vigne\fineract-assessment\backend\fineract

# Start Docker services (Fineract + MariaDB)
docker-compose up -d

# Verify services are running
docker-compose ps

# Expected output:
# STATUS: Up (healthy)
```

### Step 3: Wait for Services to Initialize

```powershell
# Check Fineract health
$maxRetries = 30
$retryCount = 0

while ($retryCount -lt $maxRetries) {
    try {
        $health = Invoke-WebRequest -Uri "https://localhost:8443/fineract-provider/actuator/health" `
                                     -SkipCertificateCheck -ErrorAction Stop
        if ($health.StatusCode -eq 200) {
            Write-Host "✅ Fineract is healthy!" -ForegroundColor Green
            break
        }
    } catch {
        $retryCount++
        if ($retryCount -lt $maxRetries) {
            Write-Host "Waiting for Fineract... ($retryCount/$maxRetries)" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    }
}

if ($retryCount -eq $maxRetries) {
    Write-Host "❌ Fineract failed to start" -ForegroundColor Red
    exit 1
}
```

### Step 4: Setup Frontend

```powershell
# Navigate to web app directory
cd C:\Users\vigne\fineract-assessment\web-app

# Install dependencies (if not already installed)
npm install

# Start development server
npm start

# Expected output:
# ➜  Local:   http://localhost:4200/
# ➜  press h + enter to show help
```

### Step 5: Verify Both Services

```powershell
# In another PowerShell window:

# Check Backend
Invoke-WebRequest -Uri "https://localhost:8443/fineract-provider/actuator/health" `
                  -SkipCertificateCheck -ErrorAction Stop

# Check Frontend
Invoke-WebRequest -Uri "http://localhost:4200/" -ErrorAction Stop

# Both should return status 200
```

### Step 6: Login to UI

1. Open browser: `http://localhost:4200/`
2. Hard refresh: `Ctrl+Shift+R`
3. **Username:** `mifos`
4. **Password:** `password`
5. Click **Login**

---

## Production Deployment

### Architecture

```
┌─────────────────┐
│  Load Balancer  │
│   (Nginx/HAProxy)
└────────┬────────┘
         │
    ┌────┴─────────────┐
    │                  │
┌───▼────┐      ┌─────▼──┐
│ App    │      │ Web    │
│ Server │      │ Server │
│   1    │      │        │
└───┬────┘      └────────┘
    │
┌───▼────────┐
│  Database  │
│  (Primary) │
│            │
└────────────┘
```

### Step 1: Prepare Production Environment

```powershell
# Create application directory
$AppDir = "C:\opt\fineract"
if (-not (Test-Path $AppDir)) {
    New-Item -ItemType Directory -Path $AppDir
}

# Clone code
cd $AppDir
git clone https://github.com/vignesh1028/fineract.git
cd fineract
git checkout task/fineract_enhancement
```

### Step 2: Configure Backend

#### Environment Variables

Create `.env` file in Fineract directory:

```env
# Database Configuration
FINERACT_HIKARI_JDBC_URL=jdbc:mysql://db-server:3306/mifostenant-default
FINERACT_HIKARI_USERNAME=root
FINERACT_HIKARI_PASSWORD=securepassword

# Server Configuration
FINERACT_SERVER_PORT=8443
FINERACT_SERVER_SSL_ENABLED=true
FINERACT_SERVER_SSL_KEYSTORE=/etc/fineract/certs/keystore.jks
FINERACT_SERVER_SSL_KEYSTORE_PASSWORD=keystorepass

# Security
FINERACT_SECURITY_BASICAUTH_ENABLED=true
FINERACT_DEFAULT_TENANT_ID=default

# Logging
LOGGING_LEVEL_ORG_APACHE_FINERACT=INFO
```

#### Database Setup

```sql
-- Create database user
CREATE USER 'fineract'@'%' IDENTIFIED BY 'securepassword';

-- Grant privileges
GRANT ALL PRIVILEGES ON mifostenant-default.* TO 'fineract'@'%';
FLUSH PRIVILEGES;

-- Run migrations (Fineract will handle automatically)
```

### Step 3: Configure Frontend

Update `src/assets/env.js`:

```javascript
(function(window) {
  window["env"] = window["env"] || {};

  // Production API endpoint
  window["env"]["fineractApiUrl"] = 'https://api.fineract.yourdomain.com/fineract-provider/api/v1';
  window["env"]["apiActuator"] = 'https://api.fineract.yourdomain.com/fineract-provider/actuator';

  window["env"]["apiProvider"] = 'fineract';
  window["env"]["apiVersion"] = 'v1';
  window["env"]["fineractPlatformTenantId"] = 'default';
  window["env"]["defaultLanguage"] = 'en';
  
  // Additional production settings
  window["env"]["displayBackEndInfo"] = false;
  window["env"]["displayTenantSelector"] = false;
  window["env"]["oauthServerEnabled"] = false;
  
})(this);
```

### Step 4: Build Frontend

```powershell
cd C:\opt\fineract\web-app

# Install dependencies
npm ci  # (use ci instead of install for production)

# Build optimized production bundle
npm run build

# Output:
# ✔ Compiled successfully.
# 
# build
#   assets/  (gzipped)
#   main-XXXXX.js        (2.5 MB / 500 KB)
#   styles-XXXXX.css     (300 KB / 60 KB)
```

### Step 5: Deploy Frontend

```powershell
# Option A: Deploy to Nginx
Copy-Item -Recurse ".\dist\mifosx-web-app\*" -Destination "/usr/share/nginx/html/"

# Option B: Deploy to Apache
Copy-Item -Recurse ".\dist\mifosx-web-app\*" -Destination "C:\Apache24\htdocs\fineract\"

# Option C: Deploy to IIS
Copy-Item -Recurse ".\dist\mifosx-web-app\*" -Destination "C:\inetpub\wwwroot\fineract\"
```

### Step 6: Configure Web Server (Nginx Example)

```nginx
server {
    listen 443 ssl http2;
    server_name api.fineract.yourdomain.com;

    # SSL Configuration
    ssl_certificate /etc/nginx/certs/cert.pem;
    ssl_certificate_key /etc/nginx/certs/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Fineract API Proxy
    location /fineract-provider/ {
        proxy_pass https://fineract-backend:8443;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # CORS Headers
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization' always;
    }

    # Frontend
    location / {
        alias /usr/share/nginx/html/;
        try_files $uri $uri/ /index.html;
        
        # Cache busting for index.html
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }
}

server {
    listen 80;
    server_name api.fineract.yourdomain.com;
    return 301 https://$server_name$request_uri;
}
```

### Step 7: Start Services

```powershell
# Start Docker containers
docker-compose -f docker-compose.yml up -d

# Verify services
docker-compose ps

# Check logs
docker-compose logs -f fineract
docker-compose logs -f db
```

### Step 8: Health Checks

```powershell
# Health check script
$HealthCheckScript = {
    param($url, $name)
    
    try {
        $response = Invoke-WebRequest -Uri $url -SkipCertificateCheck
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $name is healthy" -ForegroundColor Green
            return $true
        }
    } catch {
        Write-Host "❌ $name is down: $_" -ForegroundColor Red
        return $false
    }
}

# Run checks
& $HealthCheckScript "https://api.fineract.yourdomain.com/fineract-provider/actuator/health" "Fineract API"
& $HealthCheckScript "https://api.fineract.yourdomain.com/" "Frontend"
```

---

## Docker Deployment

### Docker Compose

```yaml
version: '3.8'

services:
  db:
    image: mariadb:11.4
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: mifostenant-default
      MYSQL_USER: fineract
      MYSQL_PASSWORD: fineractpassword
    ports:
      - "3306:3306"
    volumes:
      - db_data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 30s
      timeout: 10s
      retries: 3

  fineract:
    image: apache/fineract:latest
    ports:
      - "8443:8443"
    depends_on:
      db:
        condition: service_healthy
    environment:
      FINERACT_HIKARI_JDBC_URL: jdbc:mysql://db:3306/mifostenant-default
      FINERACT_HIKARI_USERNAME: fineract
      FINERACT_HIKARI_PASSWORD: fineractpassword
    volumes:
      - ./config:/config
    healthcheck:
      test: ["CMD", "curl", "-k", "https://localhost:8443/fineract-provider/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  web:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./dist:/usr/share/nginx/html:ro
      - ./certs:/etc/nginx/certs:ro
    depends_on:
      - fineract

volumes:
  db_data:
```

---

## Configuration Guide

### Application Configuration

#### Loan Product Parameters

```json
{
  "name": "Micro Loan",
  "shortName": "ml",
  "currencyCode": "USD",
  "principal": 100000,
  "minPrincipal": 10000,
  "maxPrincipal": 500000,
  "interestRatePerPeriod": 15,
  "interestRateFrequencyType": 2,
  "daysInMonthType": 1,
  "daysInYearType": 1,
  "repaymentEvery": 1,
  "repaymentFrequencyType": 2,
  "numberOfRepayments": 12,
  "accountingRule": 1,
  "transactionProcessingStrategyCode": "mifos-standard-strategy"
}
```

#### Client Configuration

```json
{
  "firstname": "John",
  "lastname": "Doe",
  "emailAddress": "john@example.com",
  "mobileNo": "+1234567890",
  "dateOfBirth": "01 Jan 1990",
  "genderIdValue": 1,
  "clientTypeId": 1,
  "officeId": 1,
  "legalFormId": 1,
  "activationDate": "01 Jan 2026"
}
```

---

## Troubleshooting

### Port Already in Use

```powershell
# Find process using port 8443
netstat -ano | findstr :8443

# Kill process
taskkill /PID <PID> /F

# Or change port in docker-compose.yml
# ports:
#   - "8444:8443"
```

### Database Connection Failed

```powershell
# Check MySQL credentials
mysql -h localhost -u root -p

# Verify connection string
# jdbc:mysql://db-host:3306/database-name

# Check firewall rules
Test-NetConnection -ComputerName db-host -Port 3306
```

### CORS Errors

**Solution:** Ensure proxy.conf.js is properly configured:

```javascript
const PROXY_CONFIG = {
  "/fineract-provider": {
    "target": "https://localhost:8443",
    "secure": false,
    "changeOrigin": true,
    "logLevel": "debug"
  }
};

module.exports = PROXY_CONFIG;
```

### Certificate Errors

```powershell
# For development (self-signed certs):
# Add -SkipCertificateCheck flag to Invoke-WebRequest

# For production:
# Use proper CA-signed certificate
# Update ssl_certificate in nginx.conf

# Test SSL
openssl s_client -connect localhost:8443
```

---

## Monitoring & Maintenance

### Health Monitoring

```powershell
# Create monitoring script
$MonitorScript = {
    $endpoints = @(
        @{name="Fineract"; url="https://localhost:8443/fineract-provider/actuator/health"},
        @{name="Database"; url="https://localhost:8443/fineract-provider/actuator/health/db"}
    )
    
    $endpoints | ForEach-Object {
        try {
            $response = Invoke-WebRequest -Uri $_.url -SkipCertificateCheck
            Write-Host "$(Get-Date) - ✅ $($_.name): Healthy" -ForegroundColor Green
        } catch {
            Write-Host "$(Get-Date) - ❌ $($_.name): Error" -ForegroundColor Red
        }
    }
}

# Run every 5 minutes
while ($true) {
    & $MonitorScript
    Start-Sleep -Seconds 300
}
```

### Database Backups

```powershell
# Backup database
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "C:\backups\mifostenant-default_$timestamp.sql"

mysqldump -h localhost -u root -p mifostenant-default > $backupFile

# Restore database
mysql -h localhost -u root -p mifostenant-default < $backupFile
```

### Log Management

```powershell
# View Fineract logs
docker-compose logs -f --tail=100 fineract

# View database logs
docker-compose logs -f --tail=100 db

# Rotate logs
Get-ChildItem "C:\logs\fineract\*.log" | 
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } | 
    Remove-Item
```

### Performance Tuning

```yaml
# Update docker-compose.yml
fineract:
  environment:
    # Database connection pool
    FINERACT_HIKARI_MAXIMUM_POOL_SIZE: 20
    FINERACT_HIKARI_MINIMUM_IDLE: 5
    
    # Memory settings
    JAVA_OPTS: "-Xms1g -Xmx4g"
    
    # Cache settings
    FINERACT_CACHE_MAX_SIZE: 1000
    FINERACT_CACHE_EXPIRE_MINUTES: 30
```

---

## Rollback Procedure

```powershell
# If deployment fails:

# 1. Stop current version
docker-compose down

# 2. Restore previous version
git checkout <previous-commit>

# 3. Rebuild
docker-compose build

# 4. Restart
docker-compose up -d

# 5. Verify
docker-compose ps
```

---

## Support & Documentation

- **API Documentation:** See FINERACT_POSTMAN_COLLECTION.json
- **Phase-by-Phase Guide:** See FINERACT_ASSIGNMENT_GUIDE.md
- **Quick Reference:** See README_ASSIGNMENT.md
- **GitHub Repository:** https://github.com/vignesh1028/fineract

---

**Deployment Guide Version:** 1.0  
**Last Updated:** January 19, 2026  
**Status:** ✅ Production Ready
