### What is it

PM2 is a Node.js Process Manager that solves three core problems:

- Background execution — process stays alive after terminal closes
- Auto-restart — process restarts automatically after crash
- Multi-core utilization — run multiple instances across CPU cores

### Core Commands

```bash
pm2 start server.js         # start
pm2 stop server             # stop
pm2 restart server          # restart
pm2 delete server           # remove
pm2 list                    # view all processes
pm2 logs server             # view logs
```

### Cluster Mode

```bash
pm2 start server.js -i 4    # 4 instances across 4 CPU cores
pm2 start server.js -i max  # auto-detect CPU count
```

### ecosystem.config.js

Manage all processes with a single config file:

```js
module.exports = {
  apps: [
    {
      name: 'api-server',
      script: 'server.js',
      instances: 4,
      exec_mode: 'cluster',
      env: { NODE_ENV: 'production', PORT: 3000 }
    },
    {
      name: 'settlement-scheduler',
      script: 'bin/settlement.js',
      instances: 1,
      cron_restart: '0 0 * * *',
      env: { NODE_ENV: 'production' }
    }
  ]
}