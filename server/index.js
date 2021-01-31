const Chance = require('chance');
const express = require('express');
const { start } = require('pm2');
const { System } = require('./system.js');

const SYSTEMS_PER_GALAXY = 1000;
const MAX_REGISTER_STARTING_SYSTEM_TRIES = SYSTEMS_PER_GALAXY * 2;

const app = express();
app.use(express.json())

const chanceInstance = new Chance();
const players = {};
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

app.post('/register', (req, res) => {
  const { userID } = req.body;
  console.log("New connection request");
  console.log(req.body);
  console.log(userID);

  if (!players[userID]) {
    let startingSystem = false;
    let startingSystemTries = 0;

    players[userID] = true;

    while (!startingSystem) {
      const testingSystem = systems[chanceInstance.integer({ min: 0, max: systems.length - 1 })];
      startingSystemTries++;

      if (!testingSystem.owner) {
        startingSystem = testingSystem;
        testingSystem.setOwner(userID);
      } else if (startingSystemTries >= MAX_REGISTER_STARTING_SYSTEM_TRIES) {
        res.status(500).end();
        return;
      }
    }

    res.json({
      id: userID,
      system: startingSystem
    });
  } else {
    res.status(500).end()
  }
});

generateGalaxy();
 
app.listen(3000);
