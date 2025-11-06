# Installing Foundry on Windows

## Quick Installation Guide

### Option 1: Using Git Bash (Recommended for Windows)

1. **Install Git for Windows** (if not already installed):
   - Download from: https://git-scm.com/download/win
   - Install with default settings

2. **Open Git Bash** (not PowerShell)

3. **Install Foundry**:
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

4. **Verify installation**:
   ```bash
   forge --version
   ```

5. **Use Git Bash for deployment** instead of PowerShell

### Option 2: Using WSL (Windows Subsystem for Linux)

1. **Install WSL**:
   ```powershell
   wsl --install
   ```
   (Run PowerShell as Administrator)

2. **Open WSL** and install Foundry:
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

3. **Use WSL** for all Foundry commands

### Option 3: Manual Installation (Advanced)

1. **Download Foundry binaries**:
   - Visit: https://github.com/foundry-rs/foundry/releases
   - Download the latest `foundry_nightly_windows_amd64.zip`

2. **Extract** to a folder (e.g., `C:\foundry`)

3. **Add to PATH**:
   - Open System Properties → Environment Variables
   - Add `C:\foundry` to your PATH
   - Restart terminal

4. **Verify**:
   ```powershell
   forge --version
   ```

## After Installation

### If Using Git Bash:
Deploy using bash commands from `DEPLOY_TESTNET.md`

### If Using PowerShell:
Use the `deploy.ps1` script or single-line commands from `DEPLOY_POWERSHELL.md`

## Troubleshooting

### "forge: command not found"
- Make sure Foundry is installed
- Restart your terminal after installation
- Check PATH environment variable

### "curl: command not found" (PowerShell)
- Use Git Bash instead
- Or download manually from GitHub releases

### Still Having Issues?
Use Git Bash - it's the easiest way to use Foundry on Windows!

