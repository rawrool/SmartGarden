module.exports = function (app, passport, express) {

    const userSchema = require('./models/userSchema');

    /* the Joi class is needed for input validation
    */
    const Joi = require('joi');

    // get an instance of the router for api routes
    var apiRoutes = express.Router();

    // need json web token to authenticate users
    var jwt = require('jsonwebtoken');

    // will set this username variable when validating the token so that
    // we get the correct user from the database that the token was given to.
    var user_email;

    // =========================================================================================
    // AUTHENTICATE USER =======================================================================
    // =========================================================================================
    apiRoutes.post('/authenticate', function (req, res) {
        // find the user
        userSchema.findOne({ 'local.email': req.body.email }, function (err, user) {
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

                        // creating a token for the users one we verified the password
                        var token = jwt.sign(payload, app.get('smartSecret'), {
                            expiresIn: "30 days" // expires n 24 hours
                        });

                        // save the token for the user so that it's the only 
                        // thing being passed in when making requests
                        user.local.token = token;

                        // updating the users token
                        user.save(function (err) {
                            if (err) {
                                console.log(err);
                            }
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



    // ============================================================================================
    // MIDDLEWARE FOR OUR TOKEN ===================================================================
    // ============================================================================================
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

                    // set the user to the token provided
                    userSchema.findOne({ "local.token": token }, function (err, user) {

                        if (err) {
                            console.log(err);
                        }
                        else {
                            // the token must be valid, but it is no longer assigned to the user,
                            // therefore it must be an invalid token and cannot be used.
                            if (user === null) {
                                return res.json({
                                    success: false,
                                    message: 'Token provided is expired!'
                                });
                            }
                            else {

                                // setting the global user variable so that the user won't send
                                // in another username
                                user_email = user.local.email;

                                // after the user_email is set, it will allow the other
                                // routes to execute
                                next();
                            }
                        }
                    });
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

    // ======================================================================================================
    // BASIC API ROUTE ======================================================================================
    // ======================================================================================================


    // =========================================================================================
    // USER INFO ===============================================================================
    // =========================================================================================

    apiRoutes.get('/', function (req, res) {
        res.json({ message: 'Welcome to the smart garden api' });
    });

    // =========================================================================================
    // GARDEN INFO =============================================================================
    // =========================================================================================

    // this will get all the gardens associated with the email
    apiRoutes.route('/gardens')

        .get(function (req, res) {

            // finding the document that belongs to the user.
            userSchema.findOne({ 'local.email': user_email }, function (err, uSchema) {

                // if the results gives an error we print it out.
                if (err) {
                    console.log(err);
                }
                else {
                    if (uSchema.gardens.length > 0) {
                        res.json(uSchema.gardens);
                    }
                    else {
                        // if there are no gardens we send this response to the user
                        res.json({ message: 'No Gardens!' });
                    }
                }
            });
        })

        .post(function (req, res) {

            /*
                retrieving the value of the email and the gardenName so that
                we can validate the data.
            */
            const header_create = { gardenName: req.body.gardenName }

            /*
                schema for the properties that we will need to validate
            */
            const schema = {
                gardenName: Joi.string().min(4).required()
            };

            // we call the validate function and give it the value of
            // the email/username and the gardenName
            const result = Joi.validate(header_create, schema);

            if (result.error) {
                // 400 bad request if the information provided does not
                // match the schema
                res.status(400).send(result.error.details[0].message);
            }
            else {
                userSchema.findOne({ 'local.email': user_email }, function (err, uSchema) {

                    // get the name of the garden from the headers and trim any extra white space
                    var nameG = req.body.gardenName.trim();

                    // concatenating the new garden name into the array of gardens.
                    uSchema.gardens = uSchema.gardens.concat({ name: nameG });

                    // saving the document with the changes that we have made
                    uSchema.save(function (err) {
                        if (err) {
                            console.log(err);
                        }
                        else {
                            res.json({ message: 'Garden Created!', name: nameG });
                        }
                    })
                });
            }
        })



    // =========================================================================================
    // PLANT INFO ==============================================================================
    // =========================================================================================

    apiRoutes.route('/plants')

        .get(function (req, res) {


            // retrieve values of the JSON get request
            var garden = req.headers['gardenName'];

            const header_create = {
                gardenName: garden
            };

            // validate api requests with JOI
            // create schema of what is required for each method call
            const schema = {
                gardenName: Joi.string().min(4).required()
            };

            // validate the headers/ variables
            const result = Joi.validate(header_create, schema);

            // find plants associated with gardens
            if (result.error) {
                // 400 bad request if the information provided does not
                // match the schema
                res.status(400).send(result.error.details[0].message);
            }
            else {
                userSchema.findOne({ 'local.email': user_email }, function (err, uSchema) {

                    // singling out the garden that the user provided from the gardens
                    // that the user owns
                    var resG = uSchema.gardens.find(function (element) {
                        return element.name === garden;
                    });

                    // if the garden exists then we check if there are any plants in the garden
                    if (resG !== undefined) {

                        // if there are no plants, then we notify the user.
                        // else we return the plants in the garden
                        if (resG.plants.length < 1) {
                            res.json("There are no plants in this garden!");
                        }
                        else {
                            res.json(resG.plants);
                        }
                    }
                    else {
                        res.json("No such garden exists!");
                    }

                });

            }
        })

        .post(function (req, res) {

            // retrieve values of the JSON get request
            let gName = req.body.gardenName.trim();
            let pName = req.body.plantName.trim();

            // validate api requests with JOI

            /*
                retrieving the value of the email and the gardenName so that
                we can validate the data.
            */
            const header_create = {
                gardenName: gName, plantName: pName
            };

            // create schema of what is required for each method call
            const schema = {
                gardenName: Joi.string().min(4).required(),
                plantName: Joi.string().min(4).required()
            };

            // validate the headers/ variables
            const result = Joi.validate(header_create, schema);


            // insert the new plant into the plants database
            if (result.error) {
                // 400 bad request if the information provided does not
                // match the schema
                res.status(400).send(result.error.details[0].message);
            }
            else {
                userSchema.findOne({ 'local.email': user_email }, function (err, uSchema) {

                    // singling out the garden with the name that the user provided
                    // from the gardens that the user owns
                    var resG = uSchema.gardens.find(function (element) {
                        return element.name === gName;
                    });

                    // checking if the garden exists, if it does then we create the new plant
                    if (resG !== undefined) {
                        // adding the new plant that the user wants to create.
                        resG.plants = resG.plants.concat({ name: pName });

                        // saving the changes to the database for the users garden.
                        uSchema.save(function (err) {
                            if (err) {
                                console.log(err);
                            }
                            else {
                                res.json({ message: 'Plant Created!' });
                            }
                        });
                    }
                    else {
                        // no gardens exist.
                        res.json("No such garden exists!");
                    }

                });

            }
        })



    // =========================================================================================
    // LOGS INFO ===============================================================================
    // =========================================================================================
    apiRoutes.route('/logs')

        .get(function (req, res) {

        })

        .post(function (req, res) {

        })

    // for the route apiRoutes, we will be starting the routing with /api/*
    app.use('/api', apiRoutes);

};