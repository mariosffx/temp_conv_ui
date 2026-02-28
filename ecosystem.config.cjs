/* global process */
require("dotenv").config();

module.exports = {
  apps: [
    {
      name: "temp_conv_ui",
      script: "npm run start"
    }
  ],
  deploy: {
    production: {
      user: "root",
      host: "dns-pi",
      ref: "origin/develop",
      repo: "git@github.com:mariosffx/temp_conv_ui.git",
      path: "/root/projects/temp_conv_ui",
      "post-deploy": "./scripts/deploy/post-deploy.sh"
    }
  }
};
