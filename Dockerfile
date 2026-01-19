# Zero-K Persistent MMO Server - Railway.app Deployment
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies for Spring RTS engine
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    git \
    lua5.1 \
    libstdc++6 \
    libboost-all-dev \
    libcurl4-openssl-dev \
    libglew-dev \
    libfreetype6-dev \
    libdevil-dev \
    libopenal-dev \
    libvorbis-dev \
    libogg-dev \
    libminiupnpc-dev \
    libicu-dev \
    libjsoncpp-dev \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /spring

# Download and install Spring RTS engine (dedicated server)
# Using the latest stable Linux version
RUN wget https://sourceforge.net/projects/springrts/files/spring/spring%20104.0.1-1803/spring_104.0.1-1803_linux64-minimal-nosdlnotify.tar.gz/download -O spring.tar.gz \
    && tar -xzf spring.tar.gz \
    && rm spring.tar.gz

# Create directory structure for Spring
RUN mkdir -p /spring/games /spring/maps /spring/replays /spring/screenshots /spring/cache

# Clone Zero-K mod from GitHub (using depth 1 for faster download)
WORKDIR /spring/games
RUN git clone --depth 1 https://github.com/ZeroK-RTS/Zero-K.git Zero-K

# Download a popular map for Zero-K (Comet Catcher Remake)
# This is a well-known map that works well for multiplayer
WORKDIR /spring/maps
RUN wget https://files.springrts.com/spring/sd7/Comet%20Catcher%20Remake.v03.sd7 -O "Comet Catcher Remake.v03.sd7" \
    || wget https://springfiles.springrts.com/spring/sd7/Comet%20Catcher%20Remake.v03.sd7 -O "Comet Catcher Remake.v03.sd7" \
    || echo "Map download failed - users will need to upload maps via lobby"

# Create directory for persistent game state
RUN mkdir -p /data/persistent

# Create spring configuration file
RUN cat > /spring/springrc-dedicated.txt << 'EOF'
[Default]
Port = 8200
LobbyPort = 8452
HostIP = 0.0.0.0
LobbyMaxPing = 0
IsHosting = 1
AutoHost = 0
HostPort = 8200
LobbyAddress =
LobbyPort = 8452
LobbyLoginPassword =
LobbyLoginOldPassword =
LobbyUsername = Zero-K-Server
NatTraversal = 0
DirectConnect = 1
EOF

# Create game configuration file
RUN cat > /spring/gameconfig.txt << 'EOF'
[SERVER]
Name = Persistent Zero-K MMO World
Description = 24/7 Zero-K server - Join with your lobby client
Password =
MaxPlayers = 16
Port = 8200
Map = Comet Catcher Remake
Game = Zero-K
AutoKick = 1
IP = 0.0.0.0
Rank = 0
[MODOPTIONS]
persistenteconomy = 1
persistenceenabled = 1
EOF

# Create startup script
RUN cat > /spring/start-dedicated.sh << 'EOF'
#!/bin/bash
set -e

echo "Starting Zero-K Dedicated Server..."
echo "Game Port: 8200/UDP"
echo "Lobby Port: 8452/TCP"
echo "Server Name: Persistent Zero-K MMO World"

# Wait for filesystem to be ready
sleep 2

# Check if a custom config was provided
if [ -f /data/persistent/gameconfig.txt ]; then
    echo "Using persistent game configuration..."
    cp /data/persistent/gameconfig.txt /spring/gameconfig.txt
fi

# Start Spring dedicated server
cd /spring

# Create necessary directories if they don't exist
mkdir -p /data/persistent/replays
mkdir -p /data/persistent/logs

# Link persistent storage
ln -sf /data/persistent/replays /spring/replays
ln -sf /data/persistent/logs /spring/logs

# Execute the dedicated server
# Using headless mode with minimal UI
exec /spring/spring-dedicated \
    --config=/spring/springrc-dedicated.txt \
    --isolated \
    --game="Zero-K" \
    --script="/spring/gameconfig.txt" \
    2>&1 | tee -a /data/persistent/logs/server.log
EOF

RUN chmod +x /spring/start-dedicated.sh

# Expose necessary ports
# 8200 - Game port (UDP)
# 8452 - Lobby port (TCP)
EXPOSE 8200/udp
EXPOSE 8452/tcp

# Set working directory for startup
WORKDIR /spring

# Health check to ensure server is running
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD pgrep spring-dedicated || exit 1

# Start the server
CMD ["/spring/start-dedicated.sh"]
