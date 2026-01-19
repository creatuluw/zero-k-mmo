# Evolution RTS Setup Guide

## 🎮 What is Evolution RTS?

Evolution RTS is a free, open-source real-time strategy game built on the Spring Engine. It features modern graphics, complex strategic gameplay, and a thriving community of players and developers.

### Key Features

- **Modern Visuals**: Stunning 3D graphics with advanced lighting and effects
- **Strategic Depth**: Complex unit balance with multiple factions
- **Dynamic Gameplay**: Terrain effects, weather systems, and destructible environments
- **Advanced Mechanics**: Unit abilities, upgrades, and commander systems
- **Active Development**: Regular updates and new content
- **Community-Driven**: Built by players for players

## 🆚 Evolution RTS vs Zero-K

| Feature | Evolution RTS | Zero-K |
|---------|--------------|--------|
| Visual Style | Modern, detailed | Classic, clean |
| Complexity | High | Medium |
| Faction Count | Multiple | Single |
| Commander | Yes | No |
| Unit Upgrades | Yes | No |
| Terrain Effects | Yes | Limited |
| Game Pace | Moderate | Fast |
| Community Size | Medium | Large |

## 🚀 Getting Started

### 1. Download the Game

Players need to download the Spring lobby client:

```bash
# Download from official site
https://springrts.com/download
```

### 2. Install Evolution RTS

Once you have the Spring lobby client:

1. Open the Spring Lobby client
2. Go to **Download** → **Games**
3. Search for "Evolution RTS"
4. Click **Install** (approx. 1-2 GB download)

### 3. Connect to Server

Two ways to connect:

#### Option A: Direct Connect
```
Server: your-project.up.railway.app
Port: 8200
```

#### Option B: Server Browser
1. Click **Multiplayer** → **Battle List**
2. Search for your server name
3. Double-click to join

## ⚙️ Configuration

### Basic Server Settings (gameconfig.txt)

```ini
[SERVER]
Name = Persistent Evolution RTS Server
Description = 24/7 Evolution RTS Server
Password =                      # Leave empty for public
MaxPlayers = 16
Port = 8200
Map = Comet Catcher Remake     # Popular Evolution RTS map
Game = Evolution RTS
AutoKick = 1
IP = 0.0.0.0
Rank = 0
```

### Evolution RTS-Specific Options

Evolution RTS has unique configuration options in `ModOptions.lua`:

```lua
return {
    -- Starting Resources
    {
        key="startmetal",
        name="Starting Metal",
        desc="Amount of metal each player starts with",
        type="number",
        def=1000,
        min=0,
        max=10000,
    },
    {
        key="startenergy",
        name="Starting Energy",
        desc="Amount of energy each player starts with",
        type="number",
        def=1000,
        min=0,
        max=10000,
    },
    
    -- Game Settings
    {
        key="game_speed",
        name="Game Speed",
        desc="Speed of the game simulation",
        type="number",
        def=1.0,
        min=0.5,
        max=2.0,
        step=0.1,
    },
    
    -- Commander
    {
        key="commander_start",
        name="Start with Commander",
        desc="Players begin with a commander unit",
        type="bool",
        def=true,
    },
    
    -- Resources
    {
        key="metal_income_mult",
        name="Metal Income Multiplier",
        desc="Multiplier for metal income from mexes",
        type="number",
        def=1.0,
        min=0.5,
        max=3.0,
        step=0.1,
    },
}
```

### Recommended Maps for Evolution RTS

These maps work well with Evolution RTS gameplay:

1. **Comet Catcher Remake** - Classic competitive map
2. **Small Divisions** - Good for 1v1 or 2v2
3. **Dry River** - Features interesting terrain
4. **Islands** - Naval-focused gameplay
5. **Tempest** - Large map for team battles

To add custom maps:

```bash
# Download .sd7 map files
# Place in maps/ directory in the repository
# Or upload via Spring lobby client
```

## 🎯 Gameplay Tips for Evolution RTS

### Commander Strategy

- Your commander is your most valuable unit
- Protect it at all costs - losing it can lose you the game
- Commander has powerful abilities - use them wisely
- Commander can capture and repair - use it early game

### Economy Management

- **Metal**: Extracted from metal spots using metal extractors (mexes)
- **Energy**: Generated using solar/wind/geothermal plants
- Balance is key - too much energy without metal is wasteful
- Overdrive your mexes with excess energy for bonus production

### Unit Types

**T1 Units** (Early Game)
- Fast production, cost-effective
- Raiders for early pressure
- Defenders for holding positions

**T2 Units** (Mid Game)
- More powerful and expensive
- Heavy tanks and assault bots
- Artillery for siege warfare

**T3 Units** (Late Game)
- Experimental units and superweapons
- Game-changing abilities
- Massive resource investment

### Factions

Evolution RTS features multiple playable factions, each with unique strengths:

- **Armada**: Balanced, versatile units
- **Cortex**: Heavy armor, slower units
- **Legion**: Swarm tactics, overwhelming numbers
- **Guardian**: Defensive specialists

## 🔧 Advanced Configuration

### Auto-Host Script (Optional)

For automated hosting, you can use SPADS (Spring Auto-Hosting Daemon):

```bash
# Dockerfile additions
RUN git clone https://github.com/Yaribzar/SPADS.git /opt/spads
```

### Custom Lua Mods

Evolution RTS supports extensive Lua customization:

```lua
-- Example: Custom victory condition
function gadget:GameFrame(frame)
    if frame % 60 == 0 then
        -- Check custom condition every second
        if CheckCustomVictory() then
            Spring.SetGameRulesParam("gameOver", 1)
        end
    end
end
```

### Performance Optimization

For better server performance:

```ini
[OPTIMIZATION]
UsePerformanceMode = 1
DisableParticles = 0
MaxUnitParticles = 1000
RenderDistance = 2000
LODMode = auto
```

## 🐛 Troubleshooting

### Common Issues

#### Server Won't Start

**Problem**: Container fails to start

**Solutions**:
```bash
# Check logs
railway logs

# Common causes:
# 1. Volume not mounted - verify in Railway dashboard
# 2. Port conflict - check 8200/UDP and 8452/TCP
# 3. Mod download failed - rebuild container
```

#### Players Can't Connect

**Problem**: Players timeout when connecting

**Solutions**:
- Verify URL format: `domain.up.railway.app:8200`
- Check port exposure in Railway settings
- Test connectivity: `telnet domain.up.railway.app 8200`
- Ensure UDP port 8200 is accessible

#### Map/Mod Won't Download

**Problem**: Players stuck downloading maps

**Solutions**:
- Check available disk space
- Verify internet connection
- Players can manually download from SpringFiles
- Pre-load maps in Dockerfile

#### Desync Issues

**Problem**: Players get "Desync" errors

**Solutions**:
- Ensure all players have same mod version
- Check if map versions match
- Reduce `MaxPlayers` if server overloaded
- Upgrade Railway resources

#### Performance Lag

**Problem**: Game becomes laggy with many units

**Solutions**:
```ini
# Reduce unit limits in gameconfig.txt
MaxUnits = 1500

# Reduce particle effects
DisableParticles = 1
MaxUnitParticles = 500

# Lower player count
MaxPlayers = 8
```

### Debug Mode

Enable debug logging:

```bash
# In Railway environment variables
LOG_LEVEL=debug

# Check logs for detailed information
railway logs
```

## 📊 Monitoring

### Key Metrics to Monitor

- **CPU Usage**: Should stay under 80% for smooth gameplay
- **Memory Usage**: Typical usage 500MB-1GB for 16 players
- **Network**: Monitor for connection stability
- **Uptime**: Server should be 99%+ with auto-restart

### Railway Dashboard

Monitor these in Railway:
- **Logs**: Look for errors and warnings
- **Metrics**: CPU, memory, network graphs
- **Events**: Track deployments and restarts
- **Volume**: Storage usage for replays

### Makefile Commands

```bash
make health        # Check server health
make stats         # View resource usage
make logs          # View logs
make analyze       # Analyze replay data
```

## 🌐 Community Resources

### Official Resources

- **Website**: https://www.evolutionrts.info
- **Discord**: https://discord.gg/WUbAs2f
- **GitHub**: https://github.com/EvolutionRTS/Evolution-RTS
- **Wiki**: https://springrts.com/wiki/Evolution_RTS

### Community Support

Join the Discord server for:
- Player discussions and strategies
- Mod development help
- Tournament announcements
- Balance discussion
- Bug reporting

### Contributing

Want to help improve Evolution RTS?

1. **Report Bugs**: File issues on GitHub
2. **Contribute Code**: Submit pull requests
3. **Create Content**: Design maps or units
4. **Balance Feedback**: Share gameplay insights
5. **Help Players**: Assist new players in Discord

## 🎓 Learning Resources

### Beginner Guides

1. **Basic Tutorial**: Learn the fundamentals
2. **Unit Guide**: Understanding all unit types
3. **Economy Guide**: Mastering resource management
4. **Map Guide**: Learning terrain advantages
5. **Strategy Guide**: Winning strategies

### Advanced Topics

1. **Micro Management**: Controlling units effectively
2. **Macro Management**: Economy and production
3. **Counter Strategies**: Countering different playstyles
4. **Team Coordination**: Working with allies
5. **Tournament Play**: Competitive tactics

## 🚀 Best Practices

### For Server Operators

1. **Monitor Regularly**: Check logs and metrics daily
2. **Update Frequently**: Keep Evolution RTS updated
3. **Backup Data**: Regular backups of replays and configs
4. **Engage Community**: Listen to player feedback
5. **Balance Teams**: Ensure fair matches

### For Players

1. **Learn the Basics**: Complete tutorial first
2. **Watch Replays**: Learn from experienced players
3. **Communicate**: Use chat to coordinate with allies
4. **Practice**: Play regularly to improve
5. **Be Respectful**: Good sportsmanship matters

## 📝 Changelog

### Latest Updates

Check the official repository for the latest changes:
https://github.com/EvolutionRTS/Evolution-RTS/commits/master

### Version History

- **v17.07** (2022-02-07): Latest stable release
- **v16.x**: Various improvements and fixes
- **v15.x**: Major balance overhaul

## 🎯 Success Metrics

Track these to measure server success:

- **Active Players**: Daily/weekly active player count
- **Session Duration**: Average game length
- **Retention Rate**: Players returning after first game
- **Server Uptime**: Percentage of time server is available
- **Player Satisfaction**: Community feedback

## 🔮 Future Roadmap

Evolution RTS continues to evolve with planned features:

- New units and factions
- Improved graphics engine
- Enhanced multiplayer features
- Better AI opponents
- Campaign mode
- Cross-platform support

---

**Need Help?** Join the Evolution RTS Discord: https://discord.gg/WUbAs2f

**Enjoy the game!** 🎮