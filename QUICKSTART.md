# Zero-K MMO Server - Quick Start Guide

Get your persistent Zero-K server running in 5 minutes!

## 📋 Prerequisites

- [ ] Railway.app account (free at railway.app)
- [ ] GitHub account
- [ ] Zero-K lobby client (download from zero-k.info)

## 🚀 3-Step Deployment

### Step 1: Push to GitHub

```bash
# Push this project to your GitHub repository
git init
git add .
git commit -m "Zero-K MMO Server"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/zero-k-mmo.git
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

1. **Download Zero-K Lobby** from https://zero-k.info
2. **Create Account** in the lobby
3. **Connect**: Click "Multiplayer" → "Direct Connect"
4. **Enter**: `your-project.up.railway.app:8200`
5. **Play!** (Map downloads automatically)

## ⚙️ Quick Configuration (Optional)

Set environment variables in Railway dashboard:

```env
SERVER_NAME=My Zero-K World
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

**Missing map?**
- Maps auto-download when players connect
- Or upload via lobby client

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

---

**Need more details?** See [README.md](README.md) for comprehensive guide or [DEPLOYMENT.md](DEPLOYMENT.md) for advanced configuration.

**Questions?** Join the Zero-K Discord: https://discord.gg/zero-k

🚀 **Ready to deploy? Start with Step 1 above!**