module.exports = {
  apps: [{
    name: 'GGJ 2021 Server',
    script: 'index.js',
    watch: '.'
  }],

  deploy: {
    production: {
      user: 'root',
      host: '192.81.135.83',
      ref: 'origin/master',
      repo: 'git@github.com:Bloodyaugust/ggj-2021.git',
      path: '/var/www/ggj-2021',
      key: '~/.ssh/lobby_server_deploy2_rsa.pem',
      'pre-deploy-local': '',
      'post-deploy': 'cd server/ && yarn install && mv .env.prod .env && pm2 startOrReload ecosystem.config.js --env production',
      'pre-setup': ''
    }
  }
}
