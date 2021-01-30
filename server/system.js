const baseData = require('../data/base.json');

const MAX_PLANETS_PER_SYSTEM = 5;

class System {
  constructor(chanceInstance) {
    this.planets = [];
    this.star = chanceInstance.weighted(
      baseData.sheets.find(sheet => sheet.name === 'stars').lines.map(star => star.sequence),
      baseData.sheets.find(sheet => sheet.name === 'stars').lines.map(star => star.weight)
    );
    this.position = {
      x: chanceInstance.floating({
        min: -1000,
        max: 1000
      }),
      y: chanceInstance.floating({
        min: -1000,
        max: 1000
      }),
    };

    const numPlanets = chanceInstance.integer({
      min: 0,
      max: MAX_PLANETS_PER_SYSTEM
    });

    for (let i = 0; i < numPlanets; i++) {
      this.planets.push({
        type: 'Terran',
        credits: 1,
        fuel: 2,
        supplies: 3
      });
    }
  }
}

module.exports.System = System;
