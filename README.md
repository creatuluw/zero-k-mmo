# Zero-K Persistent MMO Server on Railway.app

Deploy Zero-K, an open-source RTS game, as a persistent 24/7 multiplayer world on Railway.app. This deployment provides a dedicated server that players can join anytime using the Zero-K lobby client.

## 🎮 Features

- **24/7 Persistent Server**: Always available for multiplayer battles
- **MMO-Style Gameplay**: Players build economies, command smart units, and wage large-scale battles
- **Automatic Persistence**: Game replays and configurations saved automatically
- **Easy Deployment**: Containerized setup using Docker on Railway.app
- **Scalable**: Horizontal scaling support for multiple battle worlds
- **Zero-K RTS Engine**: Physical projectiles, smart units, and powerful UI
- **Auto-Restart**: Server automatically restarts if it crashes
- **Persistent Storage**: Game state, replays, and logs saved across deployments

## 📋 Prerequisites

1. **Railway.app Account**: Create a free account at railway.app
2. **GitHub Repository**: Push this project to GitHub
3. **Zero-K Lobby Client**: Download from zero-k.info for players to connect
4. **Basic Understanding**: Familiarity with Docker and Railway deployment

## 🚀 Quick Start

### 1. Prepare Your Repository

Clone or download this project structure and push to GitHub:

```bash
git clone https://github.com/ZeroK-RTS/Zero-K.git zero-k-mmo
cd zero-k-mmo
git add .
git commit -m "Initial Zero-K MMO server setup"
git push origin main
```

### 2. Deploy to Railway

1. Go to [railway.app](https://railway.app)
2. Click "New Project" → "Deploy from GitHub repo"
3. Select your Zero-K repository
4. Railway will automatically detect the Dockerfile and build the service

### 3. Configure the Service

In Railway dashboard:

1. **Add Persistent Volume**:
   - Go to your service settings
   - Click "Volumes" → "New Volume"
   - Name: `persistent-data`
   - Mount path: `/data/persistent`

2. **Set Environment Variables** (optional, overrides defaults):
   - `SERVER_NAME`: "Persistent Zero-K MMO World"
   - `MAX_PLAYERS`: "16"
   - `PORT`: "8200"
   - `LOBBY_PORT`: "8452"
   - `GAME_MOD`: "Zero-K"

3. **Expose Ports**:
   - UDP: 8200 (Game port)
   - TCP: 8452 (Lobby port)

### 4. Get Your Server URL

Once deployed, Railway provides:
- **Public URL**: `your-project.up.railway.app`
- **Game Connection**: `your-project.up.railway.app:8200`
- **Lobby Connection**: `your-project.up.railway.app:8452`

## 🎯 Player Connection Guide

### For Players

1. **Download Zero-K Lobby**: Get the client from [zero-k.info](https://zero-k.info)
2. **Create Account**: Register a free account (required for matchmaking)
3. **Join Your Server**:
   - Open Zero-K Lobby
   - Click "Multiplayer" → "Direct Connect"
   - Enter your Railway domain and port: `your-project.up.railway.app:8200`
   - Or search for "Persistent Zero-K MMO World" in server browser

### Server Features Available

- **Public Battles**: Open for anyone to join
- **Password Protection**: Set via `gameconfig.txt` if needed
- **Auto-Matchmaking**: Players automatically paired in battles
- **Replay System**: All games saved for review
- **Chat & Alliance**: In-game communication and team formation

## ⚙️ Configuration

### Advanced Server Settings

Edit `gameconfig.txt` in your repository before deploying:

```ini
[SERVER]
Name = Persistent Zero-K MMO World
Description = 24/7 Zero-K server - Join with your lobby client
Password =                      # Leave empty for public
MaxPlayers = 16
Port = 8200
Map = Comet Catcher Remake      # Change map as desired
Game = Zero-K
AutoKick = 1                    # Auto-kick AFK players
IP = 0.0.0.0

[MODOPTIONS]
persistenteconomy = 1           # Enable economy persistence
persistenceenabled = 1          # Enable game state persistence
```

### Custom Maps

To add custom maps:

1. Download map files (.sd7 or .smf) to the `maps/` directory
2. Rebuild and redeploy:
   ```bash
   git add maps/
   git commit -m "Add custom map"
   git push
   ```

Or upload maps through the Zero-K lobby client directly.

## 🌐 MMO Persistence Features

### What Gets Saved

- **Game Replays**: Every battle is recorded and stored
- **Player Statistics**: Wins, losses, and performance metrics
- **Economy Data**: Resource collection and spending (if enabled)
- **Chat Logs**: Game communications (optional)
- **Configurations**: Server settings persist across restarts

### Accessing Saved Data

All persistent data is stored in the Railway volume at `/data/persistent/`:

```
/data/persistent/
├── replays/          # Game replay files
├── logs/             # Server logs
└── gameconfig.txt    # Current server configuration
```

You can access these files via Railway's file browser or by SSH-ing into the container.

### Auto-Host Scripts

For advanced MMO features, you can integrate **SPADS** (Spring Auto-Hosting Daemon):

1. Download SPADS from [springrts.com](https://springrts.com/wiki/SPADS)
2. Configure it in your Dockerfile
3. SPADS provides:
   - Automatic matchmaking
   - Player authentication
   - Map rotation
   - Custom commands
   - Anti-cheat measures

## 📊 Scaling Options

### Horizontal Scaling

For multiple concurrent battles:

1. **Deploy Multiple Services**: Create multiple Railway services from the same repo
2. **Load Balancer**: Use Railway's load balancer
3. **Different Maps**: Each service can run different maps/mods
4. **Separate Domains**: Each service gets its own Railway URL

### Resource Optimization

Monitor your Railway service metrics:
- **CPU Usage**: Spring RTS is CPU-intensive
- **Memory**: 512MB-1GB recommended per 8-16 players
- **Network**: Low latency crucial for real-time gameplay

Upgrade your Railway plan as player count grows.

## 🐛 Troubleshooting

### Server Won't Start

```bash
# Check Railway logs
railway logs

# Common issues:
# - Port conflicts (ensure 8200/UDP and 8452/TCP are free)
# - Volume not mounted (check Railway volume settings)
# - Spring engine download failed (rebuild image)
```

### Players Can't Connect

1. **Verify Ports**: Ensure 8200/UDP is exposed in Railway settings
2. **Check Firewall**: Railway handles this, but verify no additional blocking
3. **Test URL**: Use telnet to test connectivity
   ```bash
   telnet your-project.up.railway.app 8200
   ```

### Missing Maps

- Default map downloads automatically during build
- If map fails, players can transfer maps via lobby client
- Add maps manually to `maps/` directory and redeploy

### Server Crashes

```bash
# Enable debug mode in start-dedicated.sh
# Add: --log-file=/data/persistent/logs/debug.txt

# Check logs in Railway dashboard or SSH:
ssh railway
tail -f /data/persistent/logs/server.log
```

### Performance Issues

- Reduce `MaxPlayers` in gameconfig.txt
- Use simpler maps
- Upgrade Railway service tier
- Check Railway metrics for bottlenecks

## 🔧 Advanced Customization

### Lua Mods for MMO Features

Zero-K supports Lua scripting for custom game rules:

1. Create custom Lua files in `LuaRules/` directory
2. Implement MMO mechanics like:
   - Persistent territories
   - Resource sharing
   - Alliance systems
   - Tech tree modifications
3. Edit `modinfo.lua` to reference your custom scripts

Example persistent economy mod:
```lua
-- LuaRules/persistent_economy.lua
function PersistentEconomy:Initialize()
    if Spring.GetModOptions().persistenteconomy == "1" then
        self:LoadSavedEconomy()
    end
end
```

### Custom Lobby Integration

For web-based lobby integration:

```bash
# Railway provides HTTP tunneling
# Add to your Dockerfile:
EXPOSE 8080/tcp
```

Then connect your web lobby to `your-project.up.railway.app:8080`

## 📈 Monitoring

### Railway Dashboard

- **Logs**: Real-time server logs
- **Metrics**: CPU, memory, network usage
- **Events**: Deployments and crashes
- **Health Checks**: Automated server uptime monitoring

### External Monitoring

Optional external monitoring:
- **Prometheus**: Export metrics for dashboards
- **Grafana**: Visualize player activity
- **Discord Webhooks**: Send server status updates

## 🤝 Contributing

Contributions welcome! Areas of interest:

- **Custom Mods**: Create MMO-specific game modes
- **Better Auto-Hosting**: Improve SPADS integration
- **Web UI**: Browser-based server management
- **Analytics**: Player statistics and game analysis

## 📝 License

- **Zero-K Game**: GPL-2.0 license (see Zero-K repo)
- **Spring Engine**: GPL-2.0 license
- **This Deployment**: MIT license

## 🙏 Acknowledgments

- [Zero-K Team](https://zero-k.info) - For the amazing RTS game
- [Spring RTS Engine](https://springrts.com) - The game engine
- [Railway.app](https://railway.app) - Deployment platform

## 📚 Additional Resources

- **Zero-K Wiki**: https://zero-k.info/mediawiki
- **Spring RTS Documentation**: https://springrts.com/wiki
- **Railway Documentation**: https://docs.railway.app
- **SPADS Auto-Host**: https://springrts.com/wiki/SPADS

## 🎯 Next Steps

1. ✅ Deploy this repository to Railway
2. ✅ Configure persistent volumes and ports
3. ✅ Test server connectivity with Zero-K lobby
4. ✅ Invite players and monitor first battles
5. ✅ Customize settings based on feedback
6. ✅ Scale up as player base grows

---

**Ready to build your persistent RTS empire? Deploy now and start inviting players to your Zero-K MMO world! 🚀**