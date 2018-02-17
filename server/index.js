const path = require('path');
const express = require('express');
const api = require('./api');

const port = process.env.PORT || 3001;
const publicFolder = path.join(__dirname, 'public');

const cacheableExtensions = [
  '.gif',
  '.png',
  '.css'
];

const isCacheable = filePath => {
  const ext = path.extname(filePath);
  return cacheableExtensions.includes(ext);
};

const setHeaders = (res, filePath) => {
  console.log(`filePath: ${filePath}`);
  if (isCacheable(filePath)) {
    res.set('Cache-Control', 'public, max-age=31536000');
  }
};

const app = express();
app.use('/', express.static(publicFolder, { setHeaders }));
app.use('/api', api);

app.listen(port, () => console.log(`Listening on port ${port}`));
