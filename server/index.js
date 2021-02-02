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
var systems = [];

var winnerID = null;

function generateGalaxy() {
  console.log(`Generating new galaxy at ${new Date()}`);
  systems = [];
  for (let i = 0; i < SYSTEMS_PER_GALAXY; i++) {
    systems.push(new System(chanceInstance));
  }
  // console.log(systems[0]);
}

app.get('/galaxy', function (req, res) {
  res.json({
    systems: systems
  })
});

app.post('/gameover', function(req, res) {
  console.log('checking winner: ', winnerID)
	
	res.json({
		winner: winnerID
	})
});

app.post('/won', function(req, res) {
	const { userID } = req.body;
	winnerID = userID;

  console.log(`Player ${userID} won the game at ${new Date()}, resetting galaxy`);

	res.json({
		winner: winnerID
	})
	
	generateGalaxy();
	
  Object.keys(players).forEach(userID => {
    players[userID] = false;
  });

  setTimeout(() => {
    winnerID = null;
  }, 5000);
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
  console.log(`Player ${userID} explored system: ${systemName}`)

  res.json({
    system: exploringSystem
  });
});

app.post('/owner', (req, res) => {
  const { userID, systemName } = req.body;
  const owningSystem = systems.find(system => system.name === systemName);

  owningSystem.setOwner(userID);

  console.log(`${systemName} now owned by player: ${userID}`);

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
        console.log('Failed to register player')
        res.status(500).end();
        return;
      }
    }

    console.log(`Registered new player with userID: ${userID} in system ${startingSystem.name}`)
    res.json({
      id: userID,
      system: startingSystem
    });
  } else {
    console.log('Failed to register player')
    res.status(500).end()
  }
});

generateGalaxy();
 
app.listen(3000);
