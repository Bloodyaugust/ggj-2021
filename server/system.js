const baseData = require('../data/base.json');

class System {
  constructor(chanceInstance) {
    this.planets = [];
    this.star = chanceInstance.weighted(
      baseData.sheets.find(sheet => sheet.name === 'stars').lines,
      baseData.sheets.find(sheet => sheet.name === 'stars').lines.map(star => star.weight)
    );
    this.owner = null;
    this.position = {
      x: chanceInstance.floating({
        min: 0,
        max: 1920
      }),
      y: chanceInstance.floating({
        min: 0,
        max: 1080
      }),
    };

    const numPlanets = chanceInstance.weighted(
      baseData.sheets.find(sheet => sheet.name === 'numPlanets').lines.map(num => num.num),
      baseData.sheets.find(sheet => sheet.name === 'numPlanets').lines.map(num => num.weight)
    );

    for (let i = 0; i < numPlanets; i++) {
      const planet = chanceInstance.weighted(baseData.sheets.find(sheet => sheet.name === 'planets').lines, baseData.sheets.find(sheet => sheet.name === 'planets').lines.map(planet => planet.weight));

      this.planets.push(planet);
    }
  }

  setOwner(userID) {
    this.owner = userID;
  }
}

module.exports.System = System;