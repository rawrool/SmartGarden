
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

// might be more settings in the future, that is why it's getting its'
// own routing file.
// Setting options [get current default watering schedule, & set]

// get current default watering schedule
apiRoutes.route('/settings')
    .get(function (req, res) {

        // get the garden that the user wants to get the plant from
        var gardenID = req.get('gardenid');
        // get the plant that the user wants to view the waterSchedules of
        var plantID = req.get('plantid');

        // create schema for the properties that we will validate
        // these are the values that will be required
        const schema = {
            gardenid: Joi.string().min(4).required(),
            plantid: Joi.string().min(4).required()
        };

        // get values and put it into a schema to be validated
        // these are the values that we are given
        const header_create = {
            gardenid: gardenID,
            plantid: plantID
        };

        // we validate the information provided
        const { error } = Joi.validate(header_create, schema);

        // we get the results
        if (error) {
            // 400 bad request if the information provided does not 
            // match the schema
            res.status(400).send(error.details[0].message);
        }
        else {
            // retrieve information for the current user
            userSchema.findOne({ 'local.email': user_email }, function (err, uSchema) {

                // single out the garden that the user provided
                var resG = uSchema.gardens.find(function (element) {
                    return element._id.toString() === gardenID.toString();
                });

                // if the garden exists then we check if there are any plants in the garden
                if (resG !== undefined) {
                    // if there are no plants, then we notify the user
                    // else we get the plant that the user needs
                    if (resG.plants.length < 1) {
                        res.status(400).json("There are no plants in this garden!");
                    }
                    else {

                        // single out the plant that the user wants the waterSchedules from.
                        var plantR = resG.plants.find(function (element) {
                            return element._id.toString() === plantID.toString();
                        });

                        if (plantR !== undefined) {
                            // check if there are any waterSchedules for the plant
                            if (plantR.waterSchedules.length < 1) {
                                res.status(400).json("No waterSchedules for the current plant yet!");
                            }
                            else {
                                // return all the waterSchedules of the plant provided
                                res.json(plantR.waterSchedules);
                            }
                        }
                        else {
                            res.status(400).json("No such plant exists!");
                        }

                    }
                }
                else {
                    res.status(400).json("No such garden exists!");
                }
            });
        }
    })

    // set current default watering schedule.
    /*
        only one default watering schedule can exist. So this table or schema, is going
        to be used to store a single value.
        if the default settings exist, then erase the only setting, and then
        add the new setting.
    */
    .post(function (req, res) {

    })


module.exports = apiRoutes;