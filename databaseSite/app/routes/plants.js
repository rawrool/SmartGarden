const userSchema = require('../models/userSchema');

/* the Joi class is needed for input validation
*/
const Joi = require('joi');

var express = require('express');

// get an instance of the router for api routes
var apiRoutes = express.Router();

var app = require('../server');

// need json web token to authenticate users
var jwt = require('jsonwebtoken');

// will set this username variable when validating the token so that
// we get the correct user from the database that the token was given to.
var user_email;


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

// =========================================================================================
// PLANT INFO ==============================================================================
// =========================================================================================

apiRoutes.route('/plants')

    .get(function (req, res) {


        // retrieve values of the JSON get request
        var gardenID = req.get('gardenid');

        const header_create = {
            gardenid: gardenID
        };

        // validate api requests with JOI
        // create schema of what is required for each method call
        const schema = {
            gardenid: Joi.string().min(4).required()
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
                    return element._id.toString() === gardenID.toString();
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
        let gardenID = req.body.gardenid;
        let plantName = req.body.plantName;

        // validate api requests with JOI

        /*
            retrieving the value of the email and the garden so that
            we can validate the data.
        */
        const header_create = {
            gardenid: gardenID, plantName: plantName
        };

        // create schema of what is required for each method call
        const schema = {
            gardenid: Joi.string().min(4).required(),
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
                    return element._id.toString() === gardenID.toString();
                });

                // checking if the garden exists, if it does then we create the new plant
                if (resG !== undefined) {
                    // adding the new plant that the user wants to create.
                    resG.plants = resG.plants.concat({ name: plantName });

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

module.exports = apiRoutes;