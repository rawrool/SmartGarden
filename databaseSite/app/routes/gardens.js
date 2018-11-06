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
            retrieving the value of the email and the garden so that
            we can validate the data.
        */
        const header_create = { garden: req.body.garden }

        /*
            schema for the properties that we will need to validate
        */
        const schema = {
            garden: Joi.string().min(4).required()
        };

        // we call the validate function and give it the value of
        // the email/username and the garden
        const result = Joi.validate(header_create, schema);

        if (result.error) {
            // 400 bad request if the information provided does not
            // match the schema
            res.status(400).send(result.error.details[0].message);
        }
        else {
            userSchema.findOne({ 'local.email': user_email }, function (err, uSchema) {

                // get the name of the garden from the headers and trim any extra white space
                var nameG = req.body.garden;

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

module.exports = apiRoutes;