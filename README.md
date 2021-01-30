# ggj-2021

An entry for Global Game Jam 2021!

- Mike Gardone: Project Manager, Engineer
- Evan Alley: Game Design, Data Manager
- Anneke Davis: UI Design, Art
- Joyce Shen: Art
- Greyson Richey: Engineer

## Server
In the `server` directory:
```bash
npm install
# or if you have yarn installed, which is preferred
yarn install
# then to start the server
node index.js
# don't forget to restart after making changes to CDB data
```

Runs on `localhost:3000`. Current endpoints are:

`GET /galaxy`
```json
{
  "systems": [
    {
      "star": {
        "sequence": "F",
        "color": 16711630,
        "colorHex": "#feffce",
        "weight": 5,
        "size": 1.3
      },
      "planets": [
        {
          "type": "Ice",
          "credits": 6,
          "fuel": 3,
          "supplies": 1,
          "weight": 10
        },
        ...
      ],
      "position": {
        "x": 388.8755,
        "y": 376.5737
      }
    },
    ...
  ]
}
```
