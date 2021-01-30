const express = require('express');
const app = express();
 
app.get('/galaxy', function (req, res) {
  res.json({
    systems: [
      {
        star: 'G',
        planets: [
          {
            'type': 'Terran'
          }
        ]
      }
    ]
  })
});
 
app.listen(3000);
