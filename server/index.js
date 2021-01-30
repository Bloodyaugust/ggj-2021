const Chance = require('chance');
const express = require('express');
const { System } = require('./system.js');

const SYSTEMS_PER_GALAXY = 1000;

const app = express();
const chanceInstance = new Chance();
const systems = [];

function generateGalaxy() {
  for (let i = 0; i < SYSTEMS_PER_GALAXY; i++) {
    systems.push(new System(chanceInstance));
  }
}

app.get('/galaxy', function (req, res) {
  res.json({
    systems: systems
  })
});

generateGalaxy();
 
app.listen(3000);
