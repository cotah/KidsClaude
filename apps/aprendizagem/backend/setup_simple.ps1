param(
    [switch]$SkipMigrations,
    [switch]$SkipTests
)

$ErrorActionPreference = 'Stop'

function Write-Step {
    param([string]$Message)
    Write-Host "[SETUP] $Message" -ForegroundColor Green
}

function Test-PythonVersion {
    Write-Step "Checking Python version requirement (3.11+)"

    try {
        $pyOutput = & py -3.11 --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Found Python via py launcher"
            return "py", "-3.11"
        }
    } catch {
        # Continue to next option
    }

    try {
        $pythonOutput = & python --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Found Python via python command"
            return "python", $null
        }
    } catch {
        Write-Error "Python not found"
        exit 1
    }

    Write-Error "Python 3.11+ not found"
    exit 1
}

function Setup-VirtualEnvironment {
    param([string]$PythonCmd, [string]$PythonArgs)

    Write-Step "Setting up virtual environment"

    if (Test-Path ".venv") {
        Write-Host "Virtual environment already exists"
    } else {
        Write-Host "Creating virtual environment..."
        if ($PythonArgs) {
            & $PythonCmd $PythonArgs -m venv .venv
        } else {
            & $PythonCmd -m venv .venv
        }
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to create virtual environment"
            exit 1
        }
    }

    $activateScript = ".\.venv\Scripts\Activate.ps1"
    if (Test-Path $activateScript) {
        & $activateScript
        Write-Host "Virtual environment activated"
    } else {
        Write-Error "Activation script not found"
        exit 1
    }
}

function Install-Dependencies {
    Write-Step "Installing dependencies"

    python -m pip install --upgrade pip
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to upgrade pip"
        exit 1
    }

    if (Test-Path "requirements.txt") {
        python -m pip install -r requirements.txt
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to install dependencies"
            exit 1
        }
        Write-Host "Dependencies installed"
    } else {
        Write-Error "requirements.txt not found"
        exit 1
    }
}

function Run-Tests {
    Write-Step "Running test suite"

    python -c "import pytest" 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "pytest not found"
        exit 1
    }

    Write-Host "Running pytest..."
    python -m pytest -q --tb=short
    return $LASTEXITCODE
}

function Show-Summary {
    Write-Step "Environment Summary"

    python --version
    python -c "import fastapi; print('FastAPI installed')" 2>$null
    python -c "import pytest; print('Pytest installed')" 2>$null

    Write-Host "Working Directory: $((Get-Location).Path)"
}

# Main execution
try {
    Write-Host "FastAPI Backend Setup" -ForegroundColor Cyan

    if (-not (Test-Path "requirements.txt")) {
        Write-Error "Must run from backend directory"
        exit 1
    }

    $pythonCmd, $pythonArgs = Test-PythonVersion
    Setup-VirtualEnvironment -PythonCmd $pythonCmd -PythonArgs $pythonArgs
    Install-Dependencies

    if (-not $SkipMigrations) {
        Write-Step "Skipping migrations (no database configured)"
    }

    $testExitCode = 0
    if (-not $SkipTests) {
        $testExitCode = Run-Tests
    }

    Show-Summary

    if ($testExitCode -eq 0) {
        Write-Host "Setup completed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Tests failed" -ForegroundColor Red
    }

    exit $testExitCode

} catch {
    Write-Host "Setup failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}