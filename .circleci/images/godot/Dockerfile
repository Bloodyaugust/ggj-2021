FROM ubuntu:xenial

ENV GODOT_VERSION "3.2"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    ssh \
    tar \
    gzip \
    wget \
    unzip \
    zip \
    python \
    python-openssl \
    && rm -rf /var/lib/apt/lists/*

RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash \
    && export NVM_DIR="$HOME/.nvm" \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && nvm install node 15.7.0 \
    && npm install --global yarn

ENV PATH="/root/.nvm/versions/node/v15.7.0/bin/:${PATH}"

RUN wget --quiet https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default -O butler.zip \
    && unzip butler.zip -d /butler \
    && chmod +x /butler/butler

ENV PATH="/butler:${PATH}"

RUN wget --quiet https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip \
    && wget --quiet https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_export_templates.tpz \
    && mkdir ~/.cache \
    && mkdir -p ~/.config/godot \
    && mkdir -p ~/.local/share/godot/templates/${GODOT_VERSION}.stable \
    && unzip Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip \
    && mv Godot_v${GODOT_VERSION}-stable_linux_headless.64 /usr/local/bin/godot \
    && unzip Godot_v${GODOT_VERSION}-stable_export_templates.tpz \
    && mv templates/* ~/.local/share/godot/templates/${GODOT_VERSION}.stable \
    && rm -f Godot_v${GODOT_VERSION}-stable_export_templates.tpz Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip \
    && cat ~/.local/share/godot/templates/${GODOT_VERSION}.stable/version.txt
