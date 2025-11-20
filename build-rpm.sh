#!/bin/bash
# Build RPM package for Fedora/RHEL

set -e

VERSION="1.0.0"
RELEASE="1"
ARCH="x86_64"

echo "========================================"
echo "  Building Verba RPM Package"
echo "  Version: $VERSION-$RELEASE"
echo "========================================"
echo ""

# Install rpm-build if not present
if ! command -v rpmbuild &> /dev/null; then
    echo "Installing rpm-build..."
    sudo dnf install -y rpm-build rpmdevtools
fi

# Setup RPM build environment
echo "Setting up RPM build environment..."
rpmdev-setuptree

# Create source tarball
echo "Creating source tarball..."
TARBALL_DIR="verba-$VERSION"
mkdir -p "/tmp/$TARBALL_DIR"

# Copy files excluding unnecessary items
rsync -av --exclude='node_modules' --exclude='venv' --exclude='.git' \
    --exclude='*.db' --exclude='*.log' --exclude='__pycache__' \
    . "/tmp/$TARBALL_DIR/"

cd /tmp
tar czf "$HOME/rpmbuild/SOURCES/verba-$VERSION.tar.gz" "$TARBALL_DIR"
cd -

# Create RPM spec file
echo "Creating RPM spec..."
cat > "$HOME/rpmbuild/SPECS/verba.spec" << 'SPEC_EOF'
Name:           verba
Version:        1.0.0
Release:        1%{?dist}
Summary:        Offline AI Meeting Assistant
License:        MIT
URL:            https://github.com/OP-88/Verba-mvp
Source0:        %{name}-%{version}.tar.gz

BuildArch:      x86_64
Requires:       python3 >= 3.11, nodejs >= 18, ffmpeg

%description
Verba is a 100% offline, privacy-first AI meeting assistant.
Record meetings, transcribe speech with OpenAI Whisper, and generate
structured notes—all locally on your device without cloud dependencies.

%prep
%setup -q

%build
# Build backend
cd backend
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
deactivate
cd ..

# Build frontend
cd frontend
npm install
npm run build
cd ..

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_datadir}/verba
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_datadir}/applications
mkdir -p %{buildroot}%{_datadir}/icons/hicolor/256x256/apps

# Copy application files
cp -r backend %{buildroot}%{_datadir}/verba/
cp -r frontend %{buildroot}%{_datadir}/verba/
cp start_verba.sh %{buildroot}%{_datadir}/verba/

# Create launcher script
cat > %{buildroot}%{_bindir}/verba << 'LAUNCHER'
#!/bin/bash
cd %{_datadir}/verba
exec ./start_verba.sh "$@"
LAUNCHER
chmod +x %{buildroot}%{_bindir}/verba

# Desktop entry
cat > %{buildroot}%{_datadir}/applications/verba.desktop << 'DESKTOP'
[Desktop Entry]
Version=1.0
Type=Application
Name=Verba
Comment=Offline AI Meeting Assistant
Exec=verba
Icon=verba
Terminal=true
Categories=Office;AudioVideo;Recorder;
Keywords=meeting;transcription;AI;notes;
DESKTOP

# Icon
if [ -f frontend/src-tauri/icons/128x128.png ]; then
    cp frontend/src-tauri/icons/128x128.png \
        %{buildroot}%{_datadir}/icons/hicolor/256x256/apps/verba.png
fi

%files
%{_datadir}/verba/
%{_bindir}/verba
%{_datadir}/applications/verba.desktop
%{_datadir}/icons/hicolor/256x256/apps/verba.png

%post
update-desktop-database &> /dev/null || :

%postun
update-desktop-database &> /dev/null || :

%changelog
* $(date "+%a %b %d %Y") Verba Team <hello@verba.app> - 1.0.0-1
- Initial RPM release
- Offline AI meeting assistant with Whisper transcription
- Session management with timestamps
- Markdown export functionality
SPEC_EOF

# Build RPM
echo "Building RPM package..."
rpmbuild -ba "$HOME/rpmbuild/SPECS/verba.spec"

# Copy RPM to current directory
echo "Copying RPM to current directory..."
cp "$HOME/rpmbuild/RPMS/$ARCH/verba-$VERSION-$RELEASE."*".$ARCH.rpm" .

echo ""
echo "✅ RPM package created!"
echo ""
echo "Package: verba-$VERSION-$RELEASE.fc*.x86_64.rpm"
echo ""
echo "To install:"
echo "  sudo dnf install ./verba-$VERSION-$RELEASE.*.rpm"
echo ""
echo "To run after install:"
echo "  verba"
echo ""
