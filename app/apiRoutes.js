module.exports = function (app, passport, express) {

    var Plant = require('./models/plant');

    const userSchema = require('./models/userSchema');

    /* the Joi class is needed for input validation

    */
    const Joi = require('joi');

    // get an instance of the router for api routes
    var apiRoutes = express.Router();

    var jwt = require('jsonwebtoken');

    // ========================
    // AUTHENTICATE USER ======
    // ========================
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

                        var token = jwt.sign(payload, app.get('smartSecret'), {
                            expiresIn: "30 days" // expires n 24 hours
                        });

                        // assign the token to the user schema so that the user
                        // can only access the gardens and logs associated with the users token?

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

            /*
                retrieving the value of email in the header so that we can validate it
            */
            const header_email = { email: req.headers['email'] };

            /*
                schema for the properties that we will need to validate.
            */
            const schema = {
                email: Joi.string().email({ minDomainAtoms: 2 }).required()
            };


            // we call the validate function and give it the value of 
            // the email along with the properties to check
            const result = Joi.validate(header_email, schema);


            // if it results in an error, we let the user know why they go an error.
            if (result.error) {
                //400 bad request
                res.status(400).send(result.error.details[0].message);
            }
            else {
                var username = req.headers['email'];

                // finding the document that belongs to the user.
                userSchema.find({ 'local.email': username }, function (err, uSchema) {

                    var arrclone;

                    // cloning the array of gardens to display on the profile page.
                    uSchema.forEach(element => {
                        arrclone = element.gardens.slice(0);
                    });

                    if (arrclone.length > 0) {
                        res.json(arrclone);
                    }
                    else {
                        // if there are no gardens we send this response to the user
                        res.json({ message: 'No Gardens!' });
                    }
                });
            }
        })

        .post(function (req, res) {

            /*
                retrieving the value of the email and the gardenName so that
                we can validate the data.
            */
            const header_create = { gardenName: req.body.gardenName, username: req.body.email }

            /*
                schema for the properties that we will need to validate
            */
            const schema = {
                gardenName: Joi.string().min(4).required(),
                username: Joi.string().email({ minDomainAtoms: 2 }).required()
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
                userSchema.find({ 'local.email': req.body.email }, function (err, uSchema) {

                    // get the name of the garden from the headers and trim any extra white space
                    var nameG = req.body.gardenName.trim();

                    // concatenating the new garden name into the array of gardens.
                    uSchema[0].gardens = uSchema[0].gardens.concat({ name: nameG });

                    // saving the document with the changes that we have made
                    uSchema[0].save(function (err) {
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



    // ========================
    // PLANT INFO =============
    // ========================

    apiRoutes.route('/plants')

        .get(function (req, res) {
            var email = req.headers['email'];
            var garden = req.headers['garden'];

            const header_create = {
                gardenName: garden, email: email
            };

            const schema = {
                gardenName: Joi.string().min(4).required(),
                email: Joi.string().email({ minDomainAtoms: 2 }).required()
            };

            // retrieve values of the JSON get request


            // validate api requests with JOI

            // create schema of what is required for each method call

            // validate the headers/ variables
            const result = Joi.validate(header_create, schema);
            // find all plants associated with the garden provided


            // find plants associated with gardens
            if (result.error) {
                // 400 bad request if the information provided does not
                // match the schema
                res.status(400).send(result.error.details[0].message);
            }
            else {
                userSchema.findOne({ 'local.email': email }, function (err, uSchema) {

                    var arrclone;

                    // cloning the array of gardens to display on the profile page.

                    arrclone = uSchema.gardens.slice(0);

                    var resG = arrclone.find(function(element){
                        return element.name === garden;
                    });

                    if(resG !== undefined){
                        res.json(resG.plants);
                    }
                    else{
                        res.json("no such garden exists");
                    }


                });

            }
        })

        .post(function (req, res) {

            // retrieve values of the JSON get request
            let gName = req.body.gardenName.trim();
            let email = req.body.email.trim();
            let pName = req.body.plantName.trim();

            // validate api requests with JOI

            /*
                retrieving the value of the email and the gardenName so that
                we can validate the data.
            */
            const header_create = {
                gardenName: gName, username: email, plantName: pName
            };

            // create schema of what is required for each method call
            const schema = {
                gardenName: Joi.string().min(4).required(),
                plantName: Joi.string().min(4).required(),
                username: Joi.string().email({ minDomainAtoms: 2 }).required()
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
                userSchema.findOne({ 'local.email': req.body.email }, function (err, uSchema) {

                    var arrclone;

                    // cloning the array of gardens to display on the profile page.

                    arrclone = uSchema.gardens.slice(0);

                    var resG = arrclone.find(function (element) {
                        return element.name === gName;
                    });

                    resG.plants = resG.plants.concat({ name: pName });

                    uSchema.save(function (err) {
                        if (err) {
                            console.log(err);
                        }
                        else {
                            res.json({ message: 'Plant Created!'});
                        }
                    });

                });

            }
        })



    // ========================
    // LOGS INFO ==============
    // ========================
    apiRoutes.route('/logs')

        .get(function (req, res) {

        })

        .post(function (req, res) {

        })

    // for the route apiRoutes, we will be starting the routing with /api/*
    app.use('/api', apiRoutes);

};