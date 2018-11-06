var express = require('express');

var routes = express.Router();

routes.use('/api', require('./authenticate'));
routes.use('/api', require('./gardens'));
routes.use('/api', require('./plants'));
routes.use('/api', require('./logs'));
routes.use('/api', require('./settings'));
routes.use(require('./routes'));

// =========================================================================================
// USER INFO ===============================================================================
// =========================================================================================

routes.get('/', function (req, res) {
    res.json({ message: 'Welcome to the smart garden api' });
});

module.exports = routes;