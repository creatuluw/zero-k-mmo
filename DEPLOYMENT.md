# Zero-K MMO Server - Railway.app Deployment Guide

Complete guide for deploying Zero-K as a persistent multiplayer server on Railway.app.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Configuration](#configuration)
- [Player Connection](#player-connection)
- [Monitoring & Maintenance](#monitoring--maintenance)
- [Troubleshooting](#troubleshooting)
- [Advanced Features](#advanced-features)

## Prerequisites

### Required Accounts & Tools

1. **Railway.app Account** (Free tier works for initial testing)
   - Sign up at https://railway.app
   - Add GitHub account for deployment
   - Verify email address

2. **GitHub Account**
   - Create a repository for this project
   - Enable GitHub Actions if using CI/CD

3. **Zero-K Lobby Client**
   - Download from https://zero-k.info
   - Required for players to connect to your server

### Local Development Tools (Optional)

- Git: Version control
- Docker: For local testing before deployment
- SSH client: For Railway terminal access

## Quick Start

### 1. Initialize Project Repository

```bash
# Clone this repository
git clone https://github.com/ZeroK-RTS/Zero-K.git zero-k-mmo
cd zero-k-mmo

# Add Railway configuration files (already included in this project)
# - Dockerfile
# - railway.json
# - gameconfig.txt
# - start-dedicated.sh

# Commit and push to GitHub
git add .
git commit -m "Initial Zero-K MMO server setup"
git branch -M main
git push -u origin main
```

### 2. Deploy to Railway

**Option A: via Railway CLI (Recommended)**

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Initialize new project
railway init

# Add your GitHub repository
railway up

# Deploy
railway deploy
```

**Option B: via Railway Dashboard**

1. Visit https://railway.app
2. Click "New Project" → "Deploy from GitHub repo"
3. Select your Zero-K repository
4. Railway will:
   - Detect the Dockerfile
   - Build the Docker image
   - Deploy the service
   - Generate public URLs

### 3. Configure Persistent Volume

1. Go to your service in Railway dashboard
2. Click "Volumes" tab
3. Click "New Volume"
4. Configure:
   - **Name**: `persistent-data`
   - **Mount Path**: `/data/persistent`
   - **Size**: Start with 1GB, scale as needed

### 4. Set Environment Variables

In Railway dashboard → Variables tab:

```env
SERVER_NAME=Persistent Zero-K MMO World
MAX_PLAYERS=16
PORT=8200
LOBBY_PORT=8452
GAME_MOD=Zero-K
REPLAY_RETENTION_DAYS=30
```

### 5. Verify Deployment

1. Check Railway logs: `railway logs`
2. Monitor service health: Dashboard shows uptime
3. Test connectivity:
   ```bash
   telnet your-project.up.railway.app 8200
   ```

## Detailed Setup

### Docker Configuration

The `Dockerfile` handles:

1. **Base Image**: Ubuntu 22.04 (stable, well-supported)
2. **Dependencies**: Spring RTS libraries and tools
3. **Spring Engine**: Downloaded and installed automatically
4. **Zero-K Mod**: Cloned from GitHub
5. **Default Map**: Comet Catcher Remake included
6. **Configuration**: Auto-generated from templates
7. **Startup**: Automated with health checks

### Railway Configuration (`railway.json`)

Key settings:

```json
{
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "Dockerfile"
  },
  "deploy": {
    "restartPolicyType": "ALWAYS",
    "healthcheckInterval": 30
  },
  "services": {
    "ports": [
      {"port": 8200, "protocol": "UDP"},
      {"port": 8452, "protocol": "TCP"}
    ]
  }
}
```

### Port Configuration

| Port | Protocol | Purpose |
|------|----------|---------|
| 8200 | UDP | Game data - Players connect here |
| 8452 | TCP | Lobby protocol - Server discovery |

**Important**: Ensure these ports are exposed in Railway settings.

### Storage Structure

The persistent volume is mounted at `/data/persistent`:

```
/data/persistent/
├── replays/           # Game replay files (.ssf)
├── logs/              # Server and game logs
├── config/            # Custom configurations
├── economy_data.lua   # Persistent economy data
├── player_data.lua    # Player statistics
└── world_state.lua    # World state for MMO features
```

## Configuration

### Server Settings (`gameconfig.txt`)

Edit before deployment or use Railway environment variables:

```ini
[SERVER]
Name = Persistent Zero-K MMO World        # Server name in lobby
Description = 24/7 Persistent RTS MMO     # Server description
Password =                                # Leave empty for public
MaxPlayers = 16                           # Maximum concurrent players
Port = 8200                               # Game port
Map = Comet Catcher Remake                # Default map
Game = Zero-K                             # Game mod

[MMO]
PersistentWorld = 1                       # Enable MMO features
SaveInterval = 300                        # Auto-save every 5 minutes
PlayerPersistence = 1                     # Save player data
AlliancePersistence = 1                   # Save alliance data
TerritorySystem = 1                       # Enable territory control
```

### Environment Variables Override

Railway env vars take precedence over `gameconfig.txt`:

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVER_NAME` | Persistent Zero-K MMO World | Display name |
| `MAX_PLAYERS` | 16 | Maximum players |
| `PORT` | 8200 | Game UDP port |
| `LOBBY_PORT` | 8452 | Lobby TCP port |
| `GAME_MOD` | Zero-K | Game mod name |
| `REPLAY_RETENTION_DAYS` | 30 | Keep replays for N days |

### Custom Maps

Add custom maps in two ways:

**Method 1: Include in Repository**

```bash
# Create maps directory
mkdir -p maps

# Download map files (.sd7 or .smf)
wget https://example.com/custom-map.sd7 -O maps/custom-map.sd7

# Update gameconfig.txt
# Map = custom-map

# Commit and redeploy
git add maps/
git commit -m "Add custom map"
git push
```

**Method 2: Upload via Lobby**

Players can upload maps directly through the Zero-K lobby client when connecting.

### MMO Feature Configuration

Enable persistent MMO mechanics:

```ini
[MMO]
PersistentWorld = 1                # Enable world persistence
WorldPersistenceFile = /data/persistent/world_state.lua
SaveInterval = 300                 # Save every 5 minutes
AutoSave = 1                       # Save on game events
PlayerPersistence = 1              # Track player stats
AlliancePersistence = 1            # Track alliances
TerritorySystem = 1                # Enable territory control
ResourceNodes = 1                  # Persistent resource nodes
ResourceNodeRespawn = 600          # Respawn nodes every 10 minutes

[PERSISTENCE]
PlayerDataFile = /data/persistent/player_data.lua
AllianceDataFile = /data/persistent/alliance_data.lua
BattleHistoryFile = /data/persistent/battle_history.lua
AutoSaveInterval = 300
SaveOnGameEnd = 1
SaveOnPlayerLeave = 0
```

## Player Connection

### Connection Instructions for Players

1. **Download Zero-K Lobby**
   - Visit https://zero-k.info
   - Download the lobby client
   - Install and run

2. **Create Account**
   - Register free account in lobby
   - Login with credentials

3. **Join Your Server**
   
   **Method A: Direct Connect**
   - Click "Multiplayer" → "Direct Connect"
   - Enter: `your-project.up.railway.app:8200`
   - Click "Connect"

   **Method B: Server Browser**
   - Search for "Persistent Zero-K MMO World"
   - Or filter by your server name
   - Double-click to join

4. **Download Content**
   - Map downloads automatically
   - Zero-K mod downloads automatically
   - First connection may take 5-10 minutes

### Sharing Server Information

Provide players with:

```
Server: your-project.up.railway.app:8200
Password: (none/public)
Map: Comet Catcher Remake
Max Players: 16
Type: Persistent MMO
```

### Player Features Available

- **Public Battles**: Anyone can join
- **Replay System**: All games saved automatically
- **Chat System**: In-game communication
- **Alliances**: Form teams and coordinate
- **Persistent Economy**: Resources carry over (if enabled)
- **Statistics**: Track wins/losses and performance

## Monitoring & Maintenance

### Railway Dashboard Monitoring

Access at https://railway.app/project/your-project

**Metrics to Monitor**:

- **CPU Usage**: Expect 20-50% normal, spikes during battles
- **Memory**: 512MB-1GB recommended for 16 players
- **Network**: Low latency crucial for gameplay
- **Disk Usage**: Replays accumulate over time
- **Uptime**: Should be 99%+ with auto-restart

**View Logs**:

```bash
# Via CLI
railway logs

# Via Dashboard
Click service → Logs tab → Filter by time
```

**Key Log Messages**:

```
[INFO] Starting Zero-K dedicated server...
[SUCCESS] Server starting with PID XXXX
[INFO] Game started: Zero-K on Comet Catcher Remake
[INFO] Player joined: PlayerName
[INFO] Game ended: VictoryCondition met
[INFO] Auto-saving world state...
```

### SSH into Container

For advanced troubleshooting:

```bash
# Open Railway terminal
railway open

# Or via dashboard: Service → Terminal

# Once inside, useful commands:
ls -lah /data/persistent/
tail -f /data/persistent/logs/server.log
df -h  # Check disk usage
ps aux  # Check running processes
netstat -ulpn  # Check open ports
```

### Maintenance Tasks

**Rotate Old Replays**:

```bash
# SSH into container
railway open

# Delete replays older than 30 days
find /data/persistent/replays -name "*.ssf" -mtime +30 -delete
```

**Archive Logs**:

```bash
# Compress old logs
cd /data/persistent/logs
tar -czf old_logs_$(date +%Y%m%d).tar.gz *.log
rm *.log
```

**Check Disk Space**:

```bash
# Monitor usage
df -h /data/persistent

# Clean up if needed
du -sh /data/persistent/*
```

**Update Server Name**:

```bash
# Via Railway dashboard
Variables tab → Update SERVER_NAME → Redeploy
```

### Automated Backups

Railway volumes persist, but for extra safety:

```bash
# Create backup script
cat > backup.sh << 'EOF'
#!/bin/bash
tar -czf /tmp/backup_$(date +%Y%m%d_%H%M%S).tar.gz -C /data/persistent .
curl -X POST https://your-backup-service/upload -F "file=@/tmp/backup_*.tar.gz"
rm /tmp/backup_*.tar.gz
EOF

# Add to Railway cron job or use Railway's scheduled deployments
```

## Troubleshooting

### Common Issues & Solutions

#### Server Won't Start

**Symptoms**: Service shows as "Failed" or "Crashed"

**Diagnosis**:
```bash
# Check logs
railway logs --service zero-k-mmo

# Look for:
# - "Spring dedicated binary not found"
# - "Port already in use"
# - "Missing dependencies"
```

**Solutions**:

1. **Port Conflict**: Ensure 8200/UDP and 8452/TCP are free
2. **Missing Volume**: Check persistent volume is mounted
3. **Build Failure**: Rebuild image
   ```bash
   railway up --force-build
   ```

#### Players Can't Connect

**Symptoms**: Connection timeout or "Server not found"

**Diagnosis**:
```bash
# Test from local machine
telnet your-project.up.railway.app 8200
nc -zuv your-project.up.railway.app 8200

# Check Railway logs for connection attempts
railway logs | grep -i "connect"
```

**Solutions**:

1. **Verify Ports**: Check Railway service settings
2. **Firewall**: Railway handles this, ensure no additional blocking
3. **URL Correct**: Confirm players use correct `domain:port`
4. **Server Running**: Check service status in dashboard

#### Server Crashes Frequently

**Symptoms**: High crash rate, auto-restart loops

**Diagnosis**:
```bash
# Check crash logs
railway logs | grep -i "error\|crash\|exception"

# Monitor resource usage
railway status
```

**Solutions**:

1. **Reduce Players**: Lower `MAX_PLAYERS`
2. **Simplify Map**: Use less complex maps
3. **Upgrade Resources**: Increase memory/CPU allocation
4. **Check Mod**: Ensure Zero-K version is compatible

#### Performance Issues

**Symptoms**: Lag, desync, high latency

**Diagnosis**:
```bash
# Monitor metrics in Railway dashboard
# Look at CPU, memory, network graphs
```

**Solutions**:

1. **Reduce Players**: Lower concurrent player count
2. **Optimize Config**: Adjust game settings in `gameconfig.txt`
3. **Upgrade Plan**: Move to higher Railway tier
4. **Network**: Ensure players have good connections

#### Missing Maps or Mods

**Symptoms**: "Map not found" or "Mod mismatch" errors

**Solutions**:

1. **Default Map**: Included in Dockerfile, should work
2. **Custom Maps**: Upload via lobby or add to repo
3. **Auto-Download**: Zero-K lobby downloads missing content
4. **Version Match**: Ensure players have latest Zero-K version

### Debug Mode

Enable verbose logging:

```bash
# SSH into container
railway open

# Edit start-dedicated.sh
# Add: --log-file=/data/persistent/debug.txt
# Add: --verbose

# Or set environment variable
LOG_LEVEL=debug
```

### Getting Help

**Resources**:

- **Railway Support**: https://docs.railway.app
- **Zero-K Discord**: https://discord.gg/zero-k
- **Spring RTS Wiki**: https://springrts.com/wiki
- **Railway Discord**: https://discord.gg/railway

**Information to Provide**:

```bash
# Collect diagnostic info
railway status
railway logs --lines 100
df -h
ps aux
netstat -ulpn
```

## Advanced Features

### SPADS Auto-Host Integration

For professional-grade auto-matching:

```bash
# Download SPADS
wget https://springfiles.springrts.com/sd7/spads-latest.zip -O spads.zip
unzip spads.zip -d /spring/spads

# Configure SPADS
cat > /spring/spads/spads.conf << 'EOF'
[GENERAL]
lobby=zero-k
host_username=Zero-K-Server
autohost_name=Persistent Zero-K MMO
autohost_password=

[AUTOHOST]
max_players=16
enable_auto_balance=1
map_cycle=Comet Catcher Remake,Small Divisions,Dry River
game_mod=Zero-K
EOF

# Update Dockerfile to include SPADS
# Update startup script to launch SPADS
```

SPADS provides:
- Automatic matchmaking
- Team balancing
- Map rotation
- Custom commands
- Anti-cheat
- Discord/Telegram integration

### Web Interface for Admin

Create a simple Flask/Node.js admin panel:

```python
# admin.py (Flask example)
from flask import Flask, jsonify, request
import os

app = Flask(__name__)

@app.route('/api/status')
def get_status():
    """Get server status"""
    return jsonify({
        'players': get_player_count(),
        'map': get_current_map(),
        'uptime': get_uptime(),
    })

@app.route('/api/config', methods=['POST'])
def update_config():
    """Update server config"""
    config = request.json
    # Apply configuration changes
    return jsonify({'status': 'success'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
```

Add to `Dockerfile`:
```dockerfile
RUN pip3 install flask
COPY admin.py /spring/
EXPOSE 8080
```

### Multi-World Deployment

Deploy multiple instances:

```bash
# Create Railway project for each world
railway init --name zero-k-world-1
railway init --name zero-k-world-2

# Configure each with different maps/settings
# Use Railway load balancer for distribution
```

**Configuration Differences**:

```ini
# World 1: Resource rich
[GAMEPLAY]
ResourceMultiplier = 2.0
VictoryCondition = economic

# World 2: Competitive
[GAMEPLAY]
ResourceMultiplier = 1.0
VictoryCondition = domination
Rank = 1
```

### Custom Lua Mods for MMO Features

Create persistent gameplay mechanics:

```lua
-- LuaRules/persistent_territories.lua
local PersistentTerritories = {}
PersistentTerritories.__index = PersistentTerritories

function PersistentTerritories:Initialize()
    if Spring.GetModOptions().TerritorySystem == "1" then
        self:LoadTerritories()
        Spring.Echo("Persistent territory system enabled")
    end
end

function PersistentTerritories:LoadTerritories()
    local file = io.open("/data/persistent/territories.lua", "r")
    if file then
        local data = file:read("*all")
        file:close()
        self.territories = loadstring(data)()
    else
        self.territories = {}
    end
end

function PersistentTerritories:SaveTerritories()
    local file = io.open("/data/persistent/territories.lua", "w")
    file:write("return " .. table.serialize(self.territories))
    file:close()
end

function PersistentTerritories:GameFrame(frameNum)
    if frameNum % 1800 == 0 then  -- Every minute
        self:UpdateTerritoryControl()
        self:SaveTerritories()
    end
end

return PersistentTerritories
```

### Discord Integration for Server Events

Create a Discord bot for notifications:

```javascript
// discord-bot.js
const { Client, GatewayIntentBits } = require('discord.js');

const client = new Client({
    intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages]
});

client.on('ready', () => {
    console.log(`Logged in as ${client.user.tag}`);
});

function notifyServerEvent(eventType, details) {
    const channel = client.channels.cache.get('YOUR_CHANNEL_ID');
    
    const embed = {
        title: `Server Event: ${eventType}`,
        description: details,
        color: 0x00ff00,
        fields: [
            { name: 'Server', value: 'Persistent Zero-K MMO' },
            { name: 'Players', value: details.playerCount },
        ]
    };
    
    channel.send({ embeds: [embed] });
}

// Export for use by server
module.exports = { notifyServerEvent, client };
```

### External Analytics

Track player statistics:

```lua
-- LuaRules/analytics.lua
local Analytics = {}

function Analytics:ReportGameEnd(winningTeam)
    local data = {
        timestamp = os.time(),
        winner = winningTeam,
        duration = Spring.GetGameFrame() / 30,  -- Convert to seconds
        players = self:GetPlayerStats()
    }
    
    -- Send to external API
    local http = require("socket.http")
    local json = require("dkjson")
    
    local body = json.encode(data)
    local response, status = http.request(
        "https://your-analytics-api.com/game-end",
        body
    )
    
    Spring.Echo("Analytics reported: " .. status)
end

return Analytics
```

### Backup Strategy

Implement automated backups:

```bash
#!/bin/bash
# backup.sh - Run via Railway cron or external scheduler

BACKUP_DIR="/data/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_${TIMESTAMP}.tar.gz"

# Create backup
tar -czf "${BACKUP_DIR}/${BACKUP_FILE}" -C /data/persistent .

# Upload to cloud storage (example: AWS S3)
aws s3 cp "${BACKUP_DIR}/${BACKUP_FILE}" \
    "s3://zero-k-backups/${BACKUP_FILE}"

# Clean up old backups (keep last 30)
find "${BACKUP_DIR}" -name "backup_*.tar.gz" -mtime +30 -delete

# Log backup
echo "Backup completed: ${BACKUP_FILE}" >> /data/persistent/logs/backup.log
```

### Scaling Strategy

**Horizontal Scaling** (Multiple servers):

```yaml
# docker-compose.yml for local testing
services:
  zero-k-world-1:
    build: .
    environment:
      - SERVER_NAME=Zero-K World 1
      - PORT=8200
    ports:
      - "8200:8200/udp"
  
  zero-k-world-2:
    build: .
    environment:
      - SERVER_NAME=Zero-K World 2
      - PORT=8201
    ports:
      - "8201:8201/udp"
```

**Vertical Scaling** (Upgrade resources):

- Monitor Railway metrics
- Upgrade service tier when needed
- Add more CPU/Memory as player count grows

**Load Balancing**:

Use Railway's built-in load balancer:
```json
{
  "services": {
    "load-balancer": {
      "type": "LOAD_BALANCER",
      "targets": ["zero-k-world-1", "zero-k-world-2"]
    }
  }
}
```

## Cost Optimization

### Railway Tier Selection

| Tier | Players | Monthly Cost | Recommended For |
|------|---------|--------------|-----------------|
| Free | 2-4 | $0 | Testing, small private games |
| Starter ($5) | 4-8 | $5 | Small community server |
| Pro ($10) | 8-16 | $10 | Standard MMO server |
| Business ($20) | 16-32 | $20 | Large community |

### Cost-Saving Tips

1. **Idle Shutdown**: Auto-pause during low activity
2. **Resource Limits**: Cap CPU/memory usage
3. **Storage Cleanup**: Regular replay and log cleanup
4. **Caching**: Use CDN for map downloads

## Security Best Practices

1. **Rate Limiting**: Prevent connection spam
2. **Authentication**: Verify player credentials
3. **Anti-Cheat**: Enable validation in `gameconfig.txt`
4. **Regular Updates**: Keep Spring and Zero-K updated
5. **Access Control**: Use admin passwords for sensitive commands

## Conclusion

This deployment provides a robust, persistent Zero-K MMO server on Railway.app. With proper configuration and monitoring, your server can support 24/7 gameplay for up to 16 players on the starter tier, scaling to 32+ players on higher tiers.

### Next Steps

1. ✅ Deploy following this guide
2. ✅ Test with small group of players
3. ✅ Monitor performance for first week
4. ✅ Adjust configuration based on feedback
5. ✅ Implement advanced features as needed

### Support & Community

- **Zero-K Wiki**: https://zero-k.info/mediawiki
- **Railway Docs**: https://docs.railway.app
- **Discord Community**: https://discord.gg/zero-k

---

**Ready to build your persistent RTS empire? Deploy now and start inviting players! 🚀**