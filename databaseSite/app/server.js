// server.js

// set up ======================================================================
// get all the tools we need
// getting all the required modules

// express is the framework
var express = require('express');
var app = module.exports = express(), passport, io;
var port = 3000;

// used for setting up socket.io
var http = require('http').Server(app);
var io = require('socket.io')(http);


// mongoose is object modeling for our mongoDB database
var mongoose = require('mongoose');

// will help us authenticating with different methods.
// create passport object here.
var passport = require('passport');

// allows for passing session flashdata messages.
var flash = require('connect-flash');

var morgan = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var session = require('express-session');

var configDB = require('../config/database.js');
var auth = require('../config/auth.js');

// used to create, sign, and verify tokens
var jwt = require('jsonwebtoken');

// configuration ===============================================================
mongoose.connect(configDB.url, {useMongoClient: 'true'}); // connect to our database
app.set('smartSecret', auth.secret); // secret variable.

require('../config/passport')(passport); // pass passport for configuration

// set up our express application
app.use(morgan('dev')); // log every request to the console
app.use(cookieParser()); // read cookies (needed for auth)

// use body parser so we can get info from POST and/or URL parameters.
app.use(bodyParser.urlencoded({extended: false}));
app.use(bodyParser.json());

app.set('view engine', 'ejs'); // set up ejs for templating

// required for passport
app.use(session({ secret: 'cecs491smartsecret', resave: 'false', saveUninitialized:'true' })); // session secret
app.use(passport.initialize());
app.use(passport.session()); // persistent login sessions
app.use(flash()); // use connect-flash for flash messages stored in session

app.use(express.static("../public"));
app.set('views', '../views');
app.use(express.static('../bower_components'));


module.exports.passport = passport;
// routes ======================================================================
app.use(require('./routes'));


require('./sockets')(io);

// launch ======================================================================
http.listen(3000, function(){
    console.log('listening on *:3000');
  });
console.log('The magic happens on port ' + port);