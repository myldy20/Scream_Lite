#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
VERSION="$(awk '/^[[:space:]]*VERSION[[:space:]]+[0-9]+\.[0-9]+\.[0-9]+/ { print $2; exit }' "${ROOT_DIR}/CMakeLists.txt")"

PLUGIN_NAME=ScreamLite
DISPLAY_NAME="Scream Lite"
PACKAGE_ID=com.myldy20.screamlite
DIST_DIR="${ROOT_DIR}/dist"
INSTALLER_PATH="${DIST_DIR}/${PLUGIN_NAME}_v${VERSION}.pkg"

if [ -z "${VERSION}" ]; then
    echo "Failed to determine version from CMakeLists.txt"
    exit 1
fi

echo "Building ${DISPLAY_NAME} ${VERSION}"

cd "${ROOT_DIR}"
bash ./shaders.sh

rm -rf "${ROOT_DIR}/build"
mkdir -p "${ROOT_DIR}/build" "${DIST_DIR}"

cmake --no-warn-unused-cli \
      -DCMAKE_BUILD_TYPE:STRING=Release \
      -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE \
      -DSCREAM_LITE_BUILD_STANDALONE=OFF \
      -S"${ROOT_DIR}" \
      -B"${ROOT_DIR}/build" \
      -G Ninja

cmake --build "${ROOT_DIR}/build" --config Release --target all --

if [ -n "${DEVELOPER_ID_APPLICATION:-}" ]; then
    codesign --force -s "${DEVELOPER_ID_APPLICATION}" -v "${ROOT_DIR}/build/Release/${PLUGIN_NAME}.clap" --strict --options=runtime --timestamp
    codesign --force -s "${DEVELOPER_ID_APPLICATION}" -v "${ROOT_DIR}/build/Release/${PLUGIN_NAME}.component" --strict --options=runtime --timestamp
    codesign --force -s "${DEVELOPER_ID_APPLICATION}" -v "${ROOT_DIR}/build/Release/${PLUGIN_NAME}.vst3" --strict --options=runtime --timestamp
else
    echo "No Developer ID Application certificate configured; building unsigned plugins."
fi

chmod +x "${SCRIPT_DIR}/scripts/postinstall"
mkdir -p "${ROOT_DIR}/build/installer_assets"
cp "${ROOT_DIR}/assets/Tomorrow-SemiBold.ttf" "${ROOT_DIR}/build/installer_assets/"
cp "${ROOT_DIR}/assets/OFL.txt" "${ROOT_DIR}/build/installer_assets/"

pkgbuild --root "${ROOT_DIR}/build/installer_assets/" \
         --identifier "${PACKAGE_ID}.pkg.assets" \
         --version "${VERSION}" \
         --install-location "/tmp/${PLUGIN_NAME}-installer/${PLUGIN_NAME}" \
         --scripts "${SCRIPT_DIR}/scripts" \
         "${DIST_DIR}/${PLUGIN_NAME}_assets.pkg"

pkgbuild --root "${ROOT_DIR}/build/Release/${PLUGIN_NAME}.component" \
         --identifier "${PACKAGE_ID}.pkg.au" \
         --version "${VERSION}" \
         --install-location "/Library/Audio/Plug-Ins/Components/${PLUGIN_NAME}.component" \
         "${DIST_DIR}/${PLUGIN_NAME}_au.pkg"

pkgbuild --root "${ROOT_DIR}/build/Release/${PLUGIN_NAME}.clap" \
         --identifier "${PACKAGE_ID}.pkg.clap" \
         --version "${VERSION}" \
         --install-location "/Library/Audio/Plug-Ins/CLAP/${PLUGIN_NAME}.clap" \
         "${DIST_DIR}/${PLUGIN_NAME}_clap.pkg"

pkgbuild --root "${ROOT_DIR}/build/Release/${PLUGIN_NAME}.vst3" \
         --identifier "${PACKAGE_ID}.pkg.vst3" \
         --version "${VERSION}" \
         --install-location "/Library/Audio/Plug-Ins/VST3/${PLUGIN_NAME}.vst3" \
         "${DIST_DIR}/${PLUGIN_NAME}_vst3.pkg"

cp "${ROOT_DIR}/LICENSE" "${SCRIPT_DIR}/LICENSE"

cat > "${DIST_DIR}/distribution.xml" << XMLEND
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="1">
    <title>${DISPLAY_NAME} ${VERSION}</title>
    <license file="LICENSE"/>
    <background file="_macOS_installer_background.png" mime-type="image/png" scaling="proportional" />
    <pkg-ref id="${PACKAGE_ID}.pkg.assets"/>
    <pkg-ref id="${PACKAGE_ID}.pkg.au"/>
    <pkg-ref id="${PACKAGE_ID}.pkg.clap"/>
    <pkg-ref id="${PACKAGE_ID}.pkg.vst3"/>
    <options require-scripts="false" customize="always" />
    <choices-outline>
        <line choice="${PACKAGE_ID}.pkg.assets"/>
        <line choice="${PACKAGE_ID}.pkg.au"/>
        <line choice="${PACKAGE_ID}.pkg.clap"/>
        <line choice="${PACKAGE_ID}.pkg.vst3"/>
    </choices-outline>
    <choice id="${PACKAGE_ID}.pkg.assets" visible="true" start_selected="true" title="Required assets" enabled="false">
        <pkg-ref id="${PACKAGE_ID}.pkg.assets"/>
    </choice>
    <pkg-ref id="${PACKAGE_ID}.pkg.assets" version="${VERSION}">${PLUGIN_NAME}_assets.pkg</pkg-ref>
    <choice id="${PACKAGE_ID}.pkg.au" visible="true" start_selected="true" title="Audio Unit (v2)">
        <pkg-ref id="${PACKAGE_ID}.pkg.au"/>
    </choice>
    <pkg-ref id="${PACKAGE_ID}.pkg.au" version="${VERSION}">${PLUGIN_NAME}_au.pkg</pkg-ref>
    <choice id="${PACKAGE_ID}.pkg.clap" visible="true" start_selected="true" title="CLAP">
        <pkg-ref id="${PACKAGE_ID}.pkg.clap"/>
    </choice>
    <pkg-ref id="${PACKAGE_ID}.pkg.clap" version="${VERSION}">${PLUGIN_NAME}_clap.pkg</pkg-ref>
    <choice id="${PACKAGE_ID}.pkg.vst3" visible="true" start_selected="true" title="VST3">
        <pkg-ref id="${PACKAGE_ID}.pkg.vst3"/>
    </choice>
    <pkg-ref id="${PACKAGE_ID}.pkg.vst3" version="${VERSION}">${PLUGIN_NAME}_vst3.pkg</pkg-ref>
</installer-gui-script>
XMLEND

if [ -n "${DEVELOPER_ID_INSTALLER:-}" ]; then
    productbuild --distribution "${DIST_DIR}/distribution.xml" \
                 --package-path "${DIST_DIR}" \
                 --resources "${SCRIPT_DIR}" \
                 --sign "${DEVELOPER_ID_INSTALLER}" \
                 "${INSTALLER_PATH}"
else
    echo "No Developer ID Installer certificate configured; building unsigned installer."
    productbuild --distribution "${DIST_DIR}/distribution.xml" \
                 --package-path "${DIST_DIR}" \
                 --resources "${SCRIPT_DIR}" \
                 "${INSTALLER_PATH}"
fi

if [ -n "${DEVELOPER_ID_INSTALLER:-}" ]; then
    pkgutil --check-signature "${INSTALLER_PATH}"
fi

if [ -n "${APPLE_ID:-}" ] && [ -n "${TEAM_ID:-}" ]; then
    xcrun notarytool submit "${INSTALLER_PATH}" --apple-id "${APPLE_ID}" --team-id "${TEAM_ID}" --wait
    xcrun stapler staple "${INSTALLER_PATH}"
    spctl --verbose --assess --type install "${INSTALLER_PATH}"
else
    echo "Apple notarization credentials not configured; skipping notarization."
fi

echo "Installer: ${INSTALLER_PATH}"
