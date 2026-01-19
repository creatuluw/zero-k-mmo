# Evolution RTS Server - Quick Start Guide

Get your persistent Evolution RTS server running in 5 minutes!

## 📋 Prerequisites

- [ ] Railway.app account (free at railway.app)
- [ ] GitHub account
- [ ] Spring lobby client (download from springrts.com)

## 🚀 3-Step Deployment

### Step 1: Push to GitHub

```bash
# Push this project to your GitHub repository
git init
git add .
git commit -m "Evolution RTS Server"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/evolution-rts.git
git push -u origin main
```

### Step 2: Deploy to Railway

**Option A: CLI (Recommended)**
```bash
npm install -g @railway/cli
railway login
railway init
railway up
railway deploy
```

**Option B: Dashboard**
1. Go to railway.app
2. Click "New Project" → "Deploy from GitHub repo"
3. Select your repository
4. Wait for build (takes 2-3 minutes)

### Step 3: Configure in Railway

1. Go to your service in Railway dashboard
2. Click **Volumes** → **New Volume**
   - Name: `persistent-data`
   - Mount Path: `/data/persistent`
3. Get your server URL: `your-project.up.railway.app:8200`

## 🎮 Connect Players

1. **Download Spring Lobby** from https://springrts.com
2. **Connect**: Click "Multiplayer" → "Direct Connect"
3. **Enter**: `your-project.up.railway.app:8200`
4. **Play!** (Maps and mod auto-download)

## ⚙️ Quick Configuration (Optional)

Set environment variables in Railway dashboard:

```env
SERVER_NAME=My Evolution RTS Server
MAX_PLAYERS=16
PORT=8200
```

## 🔍 Verify It's Working

```bash
# Check if server is running
railway logs

# Get your server URL
railway domain
```

## ❓ Common Issues

**Server won't start?**
- Check Railway logs
- Ensure persistent volume is mounted

**Players can't connect?**
- Verify URL format: `domain:8200`
- Check if ports 8200/UDP and 8452/TCP are exposed

**Missing map or mod?**
- Evolution RTS mod and maps auto-download when players connect
- Or upload via Spring lobby client

## 📊 Cost

| Tier | Players | Monthly Cost |
|------|---------|--------------|
| Free | 2-4 | $0 |
| Starter ($5) | 4-8 | $5 |
| Pro ($10) | 8-16 | $10 |

## 🎯 Next Steps

- [ ] Test with a few friends first
- [ ] Monitor Railway dashboard for errors
- [ ] Customize server name in Railway variables
- [ ] Add custom maps if needed
- [ ] Upgrade tier as player count grows

## 💡 Tips

- Server auto-restarts on crash
- All replays saved automatically
- Works 24/7
- Players can join anytime

## 🎨 Game Features

Evolution RTS offers unique gameplay features:
- Modern unit designs with stunning visuals
- Complex strategic depth with multiple factions
- Dynamic terrain effects
- Advanced unit abilities and upgrades
- Realistic physics and projectiles

---

**Need more details?** See [README.md](README.md) for comprehensive guide or [DEPLOYMENT.md](DEPLOYMENT.md) for advanced configuration.

**Questions?** Join the Evolution RTS Discord: https://discord.gg/WUbAs2f

🚀 **Ready to deploy? Start with Step 1 above!**