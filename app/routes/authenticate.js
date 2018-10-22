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

module.exports = apiRoutes;