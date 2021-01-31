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

var gameOver = false;
var winnerID = null;

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

app.get('/gameover', function(req, res) {
	res.json({
		gameStatus: gameOver,
		winner: winnerID
	})
});

app.post('/won', function(req, res) {
	const { userID } = req.body;
	gameOver = true;
	winnerID = userID;
	
	res.json({
		gameStatus: gameOver,
		winner: winnerID
	})
});

app.post('/rename', (req, res) => {
	const { userID, systemID, systemName } = req.body;
	const renamedSystem = systems.find(system => system.name === systemID);
	
	if (renamedSystem.rename(systemName, userID) == false)
	{
		res.status(500).end();
		return;
	}
	
	res.json({
		system: renamedSystem
	});
});

app.post('/explore', (req, res) => {
  const { userID, systemName } = req.body;
  const exploringSystem = systems.find(system => system.name === systemName);

  exploringSystem.explore(userID);

  res.json({
    system: exploringSystem
  });
});

app.post('/owner', (req, res) => {
  const { userID, systemName } = req.body;
  const owningSystem = systems.find(system => system.name === systemName);

  owningSystem.setOwner(userID);

  res.json({
    system: owningSystem
  });
});

app.post('/register', (req, res) => {
  const { userID } = req.body;

  if (!players[userID]) {
    let startingSystem = false;
    let startingSystemTries = 0;

    players[userID] = true;

    while (!startingSystem) {
      const testingSystem = systems[chanceInstance.integer({ min: 0, max: systems.length - 1 })];
      startingSystemTries++;

      if (!testingSystem.owner && testingSystem.planets.length) {
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
