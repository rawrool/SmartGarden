module.exports = function (app, passport, express) {

    var User = require('./models/user');
    var Garden = require('./models/garden');
    var Plant = require('./models/plant');

    // get an instance of the router for api routes
    var apiRoutes = express.Router();

    var jwt = require('jsonwebtoken');

    // ========================
    // AUTHENTICATE USER ======
    // ========================
    apiRoutes.post('/authenticate', function (req, res) {
        // find the user
        User.findOne({ 'local.email': req.body.email }, function (err, user) {
            if (err) {
                console.log(err);
            }
            else {
                if (!user) {
                    res.json({
                        success: false,
                        message: 'Authentication failed. User not found. Please signup through the website'
                    });
                }
                else if (user) {

                    // check if the password matches
                    if (!user.validPassword(req.body.password)) {
                        res.json({
                            success: false,
                            message: 'Athentication failed. Wrong password'
                        });
                    }
                    else {

                        // if user is found and password is right
                        // create a token with only our given payload
                        // we don't want to pass in the entire user since that has the password
                        const payload = {
                            email: user.local.email
                        };

                        var token = jwt.sign(payload, app.get('smartSecret'), {
                            expiresIn: 1440 // expires n 24 hours
                        });

                        // return the information including token as JSON
                        res.json({
                            success: true,
                            message: 'Enjoy your Garden!',
                            token: token
                        });
                    }
                }
            }
        });
    });



    // =====================================================
    // MIDDLEWARE FOR OUR TOKEN ============================
    // =====================================================
    // route middleware to verify a token
    apiRoutes.use(function (req, res, next) {

        // check header or url parameters or post parameters for token
        var token = req.body.token || req.query.token || req.headers['x-access-token'];

        // decode token
        if (token) {

            // verifies secret and checks exp
            jwt.verify(token, app.get('smartSecret'), function (err, decoded) {
                if (err) {
                    return res.json({
                        success: false,
                        message: 'Failed to authenticate token.'
                    });
                }
                else {
                    // if everything is good, save to request for use in other routes
                    req.decoded = decoded;
                    next();
                }
            });
        }
        else {

            // if there is no token
            // return an error
            return res.status(403).send({
                success: false,
                message: 'No token provided'
            });
        }
    });

    // ========================
    // BASIC API ROUTE ========
    // ========================


    // ========================
    // USER INFO ==============
    // ========================

    apiRoutes.get('/', function (req, res) {
        res.json({ message: 'Welcome to the smart garden api' });
    });

    // ========================
    // GARDEN INFO ============
    // ========================

    // this will get all the gardens associated with the email
    apiRoutes.route('/gardens')

        .get(function (req, res) {
            var username = req.headers['email'];

            Garden.find({ 'username': username }, function (err, gardens) {
                if (gardens.length > 0) {
                    res.json(gardens);
                }
                else {
                    res.json({ message: 'No Gardens!' });
                }
            });
        })

        .post(function(req, res){
            var garden = new Garden(); // create a new instance of the garden model.

            garden.gardenName = req.body.gardenName;
            garden.username = req.body.email;

            // save the garden and check for errors
            garden.save(function(err){
                if(err){
                    res.send(err);
                }
                else{
                    res.json({message: 'Garden Created'});
                }
            });
        })



    // ========================
    // PLANT INFO =============
    // ========================

    apiRoutes.route('/plants')

        .get(function (req, res) {
            var username = req.headers['email'];

            Plant.find({ 'username': username }, function (err, plants) {
                if (plants.length > 0) {
                    res.json(plants);
                }
                else {
                    res.json({ message: 'No Plants!' });
                }
            })
        })

        .post(function(req, res){
            var plant = new Plant();

            plant.gardenName = req.body.gardenName;
            plant.username = req.body.email;
            plant.plantName = req.body.plantName;

            plant.save(function(err){
                if(err){
                    res.send(err);
                }
                else{
                    res.json({message: 'Plant created successfully'});
                }
            });
        })



    // ========================
    // LOGS INFO ==============
    // ========================


    // for the route apiRoutes, we will be starting the routing with /api/*
    app.use('/api', apiRoutes);

};