#!/bin/bash

REPO1="libretro/ludo"
REPO2="VHSgunzo/sharun"
ARQ1="x11-x86_64"
ARQ2="x86_64"
# Obtém a última versão (com 'v' no prefixo)
VERSION1=$(curl -s "https://api.github.com/repos/$REPO1/releases/latest" | grep '"tag_name":' | cut -d '"' -f 4)

# Remove o 'v' do nome da versão para montar o nome do arquivo
VERSION_CLEAN1=${VERSION1#v}

# Monta os nomes dos arquivos
FILE1="Ludo-Linux-$ARQ1-$VERSION_CLEAN1.tar.gz"
CHECKSUM1="$FILE1.sha256"

# Monta as URLs
BASE_URL1="https://github.com/$REPO1/releases/download/$VERSION1"
URL_BIN1="$BASE_URL1/$FILE1"
URL_SHA1="$BASE_URL1/$CHECKSUM1"

# Baixa os arquivos separadamente
echo "Baixando binário: $URL_BIN1"
wget -c "$URL_BIN1"

echo "Baixando checksum: $URL_SHA1"
wget -c "$URL_SHA1"

# Detecta o nome do diretório extraído
EXTRACTED_DIR=$(tar -tf Ludo*.tar.gz | head -n1 | cut -d/ -f1)

# Renomeia para nome fixo
mv "$EXTRACTED_DIR" Ludo-Linux-x11-x86_64

mv Ludo*.tar.gz bkp.tar.gz
mv Ludo-Linux-x11-x86_64*.sha256 bkp.sha256

VERSION2=$(curl -s "https://api.github.com/repos/$REPO2/releases/latest" | grep '"tag_name":' | cut -d '"' -f 4)

VERSION_CLEAN2=${VERSION2#v}

FILE2="sharun-$ARQ2"

BASE_URL2="https://github.com/$REPO2/releases/download/$VERSION2"
URL_BIN2="$BASE_URL2/$FILE2"

echo "Baixando binário: $URL_BIN2"
wget -c "$URL_BIN2"

mv sharun-x86_64 sharun && chmod +x sharun && mv sharun ./Ludo-Linux-x11-x86_64* && cd Ludo-Linux-x11-x86_64* && xvfb-run -a ./sharun l -p -v -e -k ./ludo && ./sharun -g && ln sharun AppRun
mv assets ./bin && mv cores ./bin && mv database ./bin
find ./bin/assets -iname 'icon.svg' | xargs -i -t -exe cp {} .
rm ludo
cat << EOF > .env
SHARUN_WORKING_DIR=\${SHARUN_DIR}/bin
EOF

cat << EOF > Ludo.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Ludo
Exec=ludo
Icon=icon
Categories=Game;
Terminal=false
StartupNotify=false
EOF

cd ..

wget -c "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage" && mv appimagetool-x86_64.AppImage appimagetool && chmod +x appimagetool
ARCH=x86_64 ./appimagetool --appimage-extract-and-run -n *Ludo-Linux-x11-x86_64*
