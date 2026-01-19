# Evolution RTS Persistent Server on Railway.app

Deploy Evolution RTS, an open-source RTS game, as a persistent 24/7 multiplayer server on Railway.app. This deployment provides a dedicated server that players can join anytime using the Spring lobby client.

## 🎮 Features

- **24/7 Persistent Server**: Always available for multiplayer battles
- **Evolution RTS Gameplay**: Modern real-time strategy with unique units and mechanics
- **Automatic Persistence**: Game replays and configurations saved automatically
- **Easy Deployment**: Containerized setup using Docker on Railway.app
- **Scalable**: Horizontal scaling support for multiple battle servers
- **Spring Engine**: Robust game engine supporting large-scale battles
- **Auto-Restart**: Server automatically restarts if it crashes
- **Persistent Storage**: Game state, replays, and logs saved across deployments

## 📋 Prerequisites

1. **Railway.app Account**: Create a free account at railway.app
2. **GitHub Repository**: Push this project to GitHub
3. **Spring Lobby Client**: Download from springrts.com for players to connect
4. **Basic Understanding**: Familiarity with Docker and Railway deployment

## 🚀 Quick Start

### 1. Prepare Your Repository

Clone or download this project structure and push to GitHub:

```bash
git clone https://github.com/EvolutionRTS/Evolution-RTS.git evolution-rts-server
cd evolution-rts-server
git add .
git commit -m "Initial Evolution RTS server setup"
git push origin main
```

### 2. Deploy to Railway

1. Go to [railway.app](https://railway.app)
2. Click "New Project" → "Deploy from GitHub repo"
3. Select your Evolution RTS repository
4. Railway will automatically detect the Dockerfile and build the service

### 3. Configure the Service

In Railway dashboard:

1. **Add Persistent Volume**:
   - Go to your service settings
   - Click "Volumes" → "New Volume"
   - Name: `persistent-data`
   - Mount path: `/data/persistent`

2. **Set Environment Variables** (optional, overrides defaults):
   - `SERVER_NAME`: "Persistent Evolution RTS Server"
   - `MAX_PLAYERS`: "16"
   - `PORT`: "8200"
   - `LOBBY_PORT`: "8452"
   - `GAME_MOD`: "Evolution RTS"

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

1. **Download Spring Lobby**: Get the client from [springrts.com](https://springrts.com)
2. **Join Your Server**:
   - Open Spring Lobby
   - Click "Multiplayer" → "Direct Connect"
   - Enter your Railway domain and port: `your-project.up.railway.app:8200`
   - Or search for "Persistent Evolution RTS Server" in server browser

### Server Features Available

- **Public Battles**: Open for anyone to join
- **Password Protection**: Set via `gameconfig.txt` if needed
- **Auto-Host**: Automatic game hosting when players join
- **Replay System**: All games saved for review
- **Chat & Alliance**: In-game communication and team formation

## ⚙️ Configuration

### Advanced Server Settings

Edit `gameconfig.txt` in your repository before deploying:

```ini
[SERVER]
Name = Persistent Evolution RTS Server
Description = 24/7 Evolution RTS server - Join with your lobby client
Password =                      # Leave empty for public
MaxPlayers = 16
Port = 8200
Map = Comet Catcher Remake      # Change map as desired
Game = Evolution RTS
AutoKick = 1                    # Auto-kick AFK players
IP = 0.0.0.0
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

Or upload maps through the Spring lobby client directly.

## 🌐 Persistence Features

### What Gets Saved

- **Game Replays**: Every battle is recorded and stored
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

## 📊 Scaling Options

### Horizontal Scaling

For multiple concurrent battles:

1. **Deploy Multiple Services**: Create multiple Railway services from the same repo
2. **Load Balancer**: Use Railway's load balancer
3. **Different Maps**: Each service can run different maps
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

### Lua Mods for Custom Features

Evolution RTS supports Lua scripting for custom game rules:

1. Create custom Lua files in the Evolution RTS mod directory
2. Implement custom mechanics like:
   - Custom victory conditions
   - Resource modifications
   - Unit balance tweaks
3. Edit `modinfo.lua` to reference your custom scripts

Example mod modification:
```lua
-- In ModOptions.lua
return {
    {
        key="startmetal",
        name="Starting Metal",
        desc="Amount of metal each player starts with",
        type="number",
        def=1000,
        min=0,
        max=10000,
    },
}
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

- **Custom Mods**: Create EvoRTS-specific game modes
- **Better Auto-Hosting**: Improve auto-host integration
- **Web UI**: Browser-based server management
- **Analytics**: Player statistics and game analysis

## 📝 License

- **Evolution RTS Game**: GPL-2.0 license (see Evolution-RTS repo)
- **Spring Engine**: GPL-2.0 license
- **This Deployment**: MIT license

## 🙏 Acknowledgments

- [Evolution RTS Team](https://www.evolutionrts.info) - For the amazing RTS game
- [Spring RTS Engine](https://springrts.com) - The game engine
- [Railway.app](https://railway.app) - Deployment platform

## 📚 Additional Resources

- **Evolution RTS Website**: https://www.evolutionrts.info
- **Evolution RTS Discord**: https://discord.gg/WUbAs2f
- **Spring RTS Documentation**: https://springrts.com/wiki
- **Railway Documentation**: https://docs.railway.app

## 🎯 Next Steps

1. ✅ Deploy this repository to Railway
2. ✅ Configure persistent volumes and ports
3. ✅ Test server connectivity with Spring lobby
4. ✅ Invite players and monitor first battles
5. ✅ Customize settings based on feedback
6. ✅ Scale up as player base grows

---

**Ready to build your persistent RTS empire? Deploy now and start inviting players to your Evolution RTS server! 🚀**