# iOS Build Instructions for Windows Users

Since you're on Windows and iOS development requires macOS, here are your options to build and deploy to your iPhone:

## Option 1: Codemagic CI/CD (Recommended - Easiest)

### Step 1: Set up Codemagic Account
1. Go to [codemagic.io](https://codemagic.io)
2. Sign up with your GitHub account
3. Connect your repository

### Step 2: Configure iOS Build
1. In Codemagic dashboard, click "Add application"
2. Select your repository
3. Choose "iOS" as platform
4. The `codemagic.yaml` file I created will be automatically detected

### Step 3: Set up Code Signing
You'll need:
- Apple Developer Account ($99/year)
- Distribution Certificate
- Provisioning Profile for your device

#### Get Certificates:
1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Navigate to "Certificates, Identifiers & Profiles"
3. Create a new Distribution Certificate
4. Create a new App ID (use bundle identifier from your app)
5. Create a new Provisioning Profile

#### Add to Codemagic:
1. In Codemagic, go to "Code signing identities"
2. Upload your certificate (.p12 file)
3. Add your provisioning profile (.mobileprovision file)
4. Update the `codemagic.yaml` with your certificate details

### Step 4: Build and Deploy
1. Push your code to GitHub
2. Codemagic will automatically build your app
3. Download the .ipa file
4. Use Apple Configurator 2 or Xcode to install on your device

## Option 2: macOS Virtual Machine

### Requirements:
- VMware Workstation Pro or VirtualBox
- macOS installer (legal options only)
- 8GB+ RAM, 100GB+ storage
- Apple Developer Account

### Setup Steps:
1. Install VMware/VirtualBox
2. Create macOS VM
3. Install Xcode from Mac App Store
4. Install Flutter in VM
5. Build and deploy from VM

## Option 3: Cloud Mac Services

### MacStadium:
- Cloud Mac rental
- Pay per hour
- Full macOS environment

### AWS EC2 Mac:
- Amazon's cloud Mac instances
- More expensive but reliable

## Quick Start with Codemagic

1. **Update your bundle identifier** in `ios/Runner/Info.plist` if needed
2. **Get Apple Developer Account** (required for device deployment)
3. **Set up certificates** in Apple Developer Portal
4. **Configure Codemagic** with your certificates
5. **Push code** and let Codemagic build it
6. **Download .ipa** and install on your iPhone

## Important Notes

- **Bundle Identifier**: Make sure it's unique (e.g., `com.yourname.bibleapp`)
- **Team ID**: You'll need your Apple Developer Team ID
- **Device UDID**: Add your iPhone's UDID to the provisioning profile
- **Code Signing**: Required for any device installation

## Getting Your iPhone's UDID

1. Connect iPhone to Windows
2. Open iTunes (or Finder on newer Windows)
3. Select your device
4. Click on the device name/serial number to show UDID
5. Copy the UDID

## Troubleshooting

- **Build fails**: Check Flutter version compatibility
- **Signing issues**: Verify certificate and provisioning profile match
- **Installation fails**: Ensure device UDID is in provisioning profile
- **App crashes**: Check iOS deployment target compatibility

Need help with any specific step? Let me know!
