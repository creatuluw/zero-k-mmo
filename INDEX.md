# Zero-K MMO Server - Documentation Index

Complete documentation for deploying and managing Zero-K as a persistent multiplayer MMO server on Railway.app.

## 📚 Quick Navigation

### For Different Users

- **First-Time Users** → Start with [QUICKSTART.md](QUICKSTART.md)
- **Complete Setup Guide** → Read [README.md](README.md)
- **DevOps Engineers** → See [DEPLOYMENT.md](DEPLOYMENT.md)
- **Project Overview** → Read [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)

## 🎯 Documentation Overview

### Getting Started Guides

| Document | Purpose | Read Time |
|----------|---------|-----------|
| [QUICKSTART.md](QUICKSTART.md) | Get running in 5 minutes | 5 min |
| [README.md](README.md) | Complete user guide with all features | 20 min |
| [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) | High-level project overview | 10 min |

### Technical Documentation

| Document | Purpose | Audience |
|----------|---------|----------|
| [DEPLOYMENT.md](DEPLOYMENT.md) | Detailed deployment and configuration | DevOps/Operators |
| [Dockerfile](Dockerfile) | Container build configuration | Developers |
| [gameconfig.txt](gameconfig.txt) | Server and MMO feature settings | Server Admins |
| [railway.json](railway.json) | Railway deployment settings | DevOps |

### Automation & Tools

| Tool/Script | Purpose |
|-------------|---------|
| [Makefile](Makefile) | 50+ commands for building, testing, deploying |
| [start-dedicated.sh](start-dedicated.sh) | Advanced startup with health monitoring |
| [verify-setup.sh](verify-setup.sh) | Pre-deployment setup verification |

## 🚀 Recommended Reading Path

### Path 1: Quick Deploy (5 minutes)
1. [QUICKSTART.md](QUICKSTART.md)
2. Push to GitHub
3. Deploy to Railway

### Path 2: Complete Setup (30 minutes)
1. [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - Understand the project
2. [QUICKSTART.md](QUICKSTART.md) - Get basic deployment working
3. [README.md](README.md) - Learn all features
4. [DEPLOYMENT.md](DEPLOYMENT.md) - Advanced configuration

### Path 3: Deep Dive (1-2 hours)
1. All documentation in order above
2. Review [Dockerfile](Dockerfile) to understand containerization
3. Study [gameconfig.txt](gameconfig.txt) for MMO feature configuration
4. Explore [Makefile](Makefile) for automation capabilities
5. Run [verify-setup.sh](verify-setup.sh) to verify everything

## 📖 Key Concepts

### What is Zero-K?
Zero-K is an open-source real-time strategy game running on the Spring RTS engine. Features include:
- Physical projectiles and smart units
- Large-scale battles (up to 32+ players)
- Powerful UI and modding support
- Persistent MMO-style worlds

### What Does This Project Provide?
A complete, production-ready solution for:
- 24/7 persistent multiplayer server
- Railway.app cloud deployment
- Automated health checks and recovery
- Player statistics and game persistence
- Scalable architecture (horizontal/vertical)

### Technology Stack
```
Spring RTS Engine (Game Engine)
    ↓
Zero-K Mod (Game Rules/Content)
    ↓
Docker Container (Packaging)
    ↓
Railway.app (Cloud Platform)
    ↓
Players (Zero-K Lobby Client)
```

## 🎮 Game Server Features

### MMO Capabilities
- ✅ **Persistent World**: Game state saves across sessions
- ✅ **Player Persistence**: Statistics and progress tracking
- ✅ **Alliance System**: Teams and faction data saved
- ✅ **Territory Control**: MMO-style territory mechanics
- ✅ **Economy Persistence**: Resource systems persist (optional)
- ✅ **Auto-Save**: Game state saves every 5 minutes

### Server Management
- ✅ **24/7 Operation**: Automatic restart on crash
- ✅ **Health Monitoring**: Automated health checks every 30s
- ✅ **Log Aggregation**: Centralized logging in Railway dashboard
- ✅ **Resource Scaling**: Support for 4-32+ players
- ✅ **Persistent Storage**: Game data survives container restarts
- ✅ **Replay System**: All battles automatically recorded

## 📊 System Requirements

### Railway Pricing Tiers
| Tier | Players | Monthly Cost | Features |
|------|---------|--------------|----------|
| Free | 2-4 | $0 | Testing, private games |
| Starter | 4-8 | $5 | Small community |
| Pro | 8-16 | $10 | Standard MMO server |
| Business | 16-32 | $20 | Large community |

### Resource Requirements
- **CPU**: 0.5-1 vCPU (scales with players)
- **Memory**: 512MB-1GB
- **Storage**: 1GB (expands with replays)
- **Network**: Low latency (Railway handles)
- **Ports**: UDP 8200 (game), TCP 8452 (lobby)

## 🔧 Common Tasks

### I Want To...
- **Deploy quickly** → Read [QUICKSTART.md](QUICKSTART.md)
- **Understand the project** → Read [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)
- **Customize server settings** → Edit [gameconfig.txt](gameconfig.txt)
- **Add custom maps** → See [DEPLOYMENT.md#custom-maps](DEPLOYMENT.md#custom-maps)
- **Scale to more players** → See [DEPLOYMENT.md#scaling-strategy](DEPLOYMENT.md#scaling-strategy)
- **Monitor performance** → See [DEPLOYMENT.md#monitoring--maintenance](DEPLOYMENT.md#monitoring--maintenance)
- **Debug issues** → See [DEPLOYMENT.md#troubleshooting](DEPLOYMENT.md#troubleshooting)
- **Use automation tools** → Run `make help`
- **Test locally** → Run `make run` (see [Makefile](Makefile))
- **Verify setup** → Run `./verify-setup.sh`

## 📁 Project Files Reference

### Configuration Files
- **Dockerfile** - Container image definition
- **railway.json** - Railway deployment configuration
- **gameconfig.txt** - Server gameplay settings
- **.dockerignore** - Docker build exclusions
- **.gitignore** - Git version control exclusions

### Scripts & Automation
- **start-dedicated.sh** - Server startup script (354 lines)
  - Directory initialization
  - Dependency checking
  - Persistence setup
  - Health monitoring
  - Auto-restart logic
- **Makefile** - Build automation (480 lines)
  - 50+ commands for development/operations
  - Local testing commands
  - Railway deployment commands
  - Monitoring and maintenance tools
- **verify-setup.sh** - Setup verification (380 lines)
  - Checks all required files
  - Validates configurations
  - Tests Docker capabilities
  - Generates setup report

### Documentation
- **README.md** (323 lines) - Complete user guide
- **DEPLOYMENT.md** (895 lines) - Detailed deployment documentation
- **QUICKSTART.md** (121 lines) - 5-minute quick start
- **PROJECT_SUMMARY.md** (397 lines) - Project overview
- **INDEX.md** (this file) - Documentation navigation hub

## 🎓 Learning Path

### Beginner (First-Time Users)
1. ✅ Read [QUICKSTART.md](QUICKSTART.md)
2. ✅ Deploy your first server
3. ✅ Test with friends
4. ✅ Monitor with Railway dashboard

### Intermediate (Server Operators)
1. ✅ Complete Beginner path
2. ✅ Read [README.md](README.md) thoroughly
3. ✅ Study [gameconfig.txt](gameconfig.txt) options
4. ✅ Use [Makefile](Makefile) for automation
5. ✅ Implement backup strategy

### Advanced (DevOps Engineers)
1. ✅ Complete Intermediate path
2. ✅ Read [DEPLOYMENT.md](DEPLOYMENT.md) fully
3. ✅ Understand [Dockerfile](Dockerfile) internals
4. ✅ Customize [start-dedicated.sh](start-dedicated.sh)
5. ✅ Implement advanced features (SPADS, web panel, etc.)
6. ✅ Design multi-world architecture

## 🔍 Documentation Search

Looking for something specific? Check these sections:

### Configuration
- Server settings → [gameconfig.txt](gameconfig.txt)
- MMO features → [gameconfig.txt#MMO](gameconfig.txt)
- Environment variables → [DEPLOYMENT.md#environment-variables](DEPLOYMENT.md#environment-variables)
- Docker configuration → [Dockerfile](Dockerfile)

### Deployment
- Railway setup → [QUICKSTART.md#step-2-deploy-to-railway](QUICKSTART.md#step-2-deploy-to-railway)
- Persistent volumes → [DEPLOYMENT.md#storage-structure](DEPLOYMENT.md#storage-structure)
- Port configuration → [DEPLOYMENT.md#port-configuration](DEPLOYMENT.md#port-configuration)

### Operations
- Monitoring → [DEPLOYMENT.md#monitoring--maintenance](DEPLOYMENT.md#monitoring--maintenance)
- Troubleshooting → [DEPLOYMENT.md#troubleshooting](DEPLOYMENT.md#troubleshooting)
- Maintenance tasks → [DEPLOYMENT.md#maintenance-tasks](DEPLOYMENT.md#maintenance-tasks)
- Backup and restore → [DEPLOYMENT.md#backup-strategy](DEPLOYMENT.md#backup-strategy)

### Scaling
- Vertical scaling → [DEPLOYMENT.md#vertical-scaling-larger-single-world](DEPLOYMENT.md#vertical-scaling-larger-single-world)
- Horizontal scaling → [DEPLOYMENT.md#horizontal-scaling-multiple-worlds](DEPLOYMENT.md#horizontal-scaling-multiple-worlds)
- Multi-tier deployment → [DEPLOYMENT.md#multi-tier-deployment](DEPLOYMENT.md#multi-tier-deployment)

## 🆘 Getting Help

### Documentation Resources
- **Quick Reference** → [QUICKSTART.md](QUICKSTART.md)
- **Complete Guide** → [README.md](README.md)
- **Technical Details** → [DEPLOYMENT.md](DEPLOYMENT.md)
- **Command Reference** → `make help` (see [Makefile](Makefile))

### Community Resources
- **Zero-K Wiki** → https://zero-k.info/mediawiki
- **Zero-K Discord** → https://discord.gg/zero-k
- **Spring RTS Wiki** → https://springrts.com/wiki
- **Railway Documentation** → https://docs.railway.app
- **Railway Discord** → https://discord.gg/railway

### Diagnostic Tools
- **Setup Verification** → Run `./verify-setup.sh`
- **Local Testing** → Run `make run` (see [Makefile](Makefile))
- **Railway Logs** → Run `railway logs`
- **Status Check** → Run `make status` (see [Makefile](Makefile))

## 📝 Version Information

- **Project Version**: 1.0.0
- **Zero-K Mod**: Latest from GitHub (ZeroK-RTS/Zero-K)
- **Spring Engine**: 104.0.1
- **Last Updated**: January 2025
- **Status**: ✅ Production Ready

## 🎯 Success Checklist

Before going live, ensure you've:

- [ ] Read [QUICKSTART.md](QUICKSTART.md) and deployed
- [ ] Configured persistent volume in Railway
- [ ] Set environment variables (SERVER_NAME, etc.)
- [ ] Tested connectivity with Railway URL
- [ ] Verified players can connect
- [ ] Set up monitoring in Railway dashboard
- [ ] Implemented backup strategy
- [ ] Reviewed [gameconfig.txt](gameconfig.txt) settings
- [ ] Tested local recovery procedures
- [ ] Documented your specific configuration

## 🌟 Next Steps

### Immediate (Today)
1. Read [QUICKSTART.md](QUICKSTART.md)
2. Deploy to Railway
3. Test with 2-4 players
4. Monitor Railway dashboard

### Short Term (This Week)
1. Review [README.md](README.md) completely
2. Customize server settings
3. Set up backup routine
4. Test recovery procedures

### Medium Term (This Month)
1. Study [DEPLOYMENT.md](DEPLOYMENT.md) for advanced features
2. Implement SPADS auto-host (optional)
3. Add Discord integration (optional)
4. Scale as player count grows

### Long Term (Ongoing)
1. Monitor performance and costs
2. Gather player feedback
3. Implement custom Lua mods
4. Expand to multiple worlds if needed

---

**Ready to begin? Start with [QUICKSTART.md](QUICKSTART.md)! 🚀**

**Need more details? Explore the documentation links above.**

**Questions? Join the community on Discord or consult the Zero-K Wiki.**