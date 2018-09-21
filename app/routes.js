// app/routes.js
module.exports = function (app, passport) {

    var Garden = require('./models/garden');

    // =====================================
    // HOME PAGE (with login links) ========
    // =====================================
    // req = request
    // res is the response that we are giving back.
    // res.render() will look in a views folder for the view.

    app.get('/', function (req, res) {
        res.render('index.ejs'); // load the index.ejs file
    });

    // =====================================
    // DEVELOPER GUIDE =====================
    // =====================================
    app.get('/developer', function (req, res) {
        res.render('developer.ejs');
    });

    // =====================================
    // User Manual ++++=====================
    // =====================================
    app.get('/userMan', function (req, res) {
        res.render('userMan.ejs');
    });

    // =====================================
    // LOGIN ===============================
    // =====================================
    // show the login form
    // this will handle the request for a login get
    app.get('/login', function (req, res) {

        // render the page and pass in any flash data if it exists
        res.render('login.ejs', { message: req.flash('loginMessage') });
    });

    // process the login form POST
    // app.post('/login', do all our passport stuff here);
    // process the login form
    app.post('/login', passport.authenticate('local-login', {
        successRedirect: '/profile', // redirect to the secure profile section
        failureRedirect: '/login', // redirect back to the signup page if there is an error
        failureFlash: true // allow flash messages
    }));

    // =====================================
    // SIGNUP ==============================
    // =====================================
    // show the signup form
    app.get('/signup', function (req, res) {

        // render the page and pass in any flash data if it exists
        res.render('signup.ejs', { message: req.flash('signupMessage') });
    });

    // process the signup form POST
    // app.post('/signup', do all our passport stuff here);

    // process the signup form
    app.post('/signup', passport.authenticate('local-signup', {
        successRedirect: '/profile', // redirect to the secure profile section
        failureRedirect: '/signup', // redirect back to the signup page if there is an error
        failureFlash: true // allow flash messages
    }));

    // =====================================
    // PROFILE SECTION =====================
    // =====================================
    // we will want this protected so you have to be logged in to visit
    // we will use route middleware to verify this (the isLoggedIn function)
    app.get('/profile', isLoggedIn, function (req, res) {

        Garden.find({ $or: [{ 'username': req.user.local.email }, { 'username': req.user.google.email }] }, function (err, garden) {
            res.render('profile.ejs', {
                user: req.user,
                gardens: garden,
                message: req.flash('duplicateMessage')
            });
        });
    });


    // fix post for creating a new garden on profile page
    app.post('/profile', isLoggedIn, function (req, res) {

        var garden = new Garden();

        garden.gardenName = req.body.gardenName.trim();

        var google = req.user.google.email;
        var local = req.user.local.email;

        if (typeof local !== 'undefined' && local !== "undefined") {
            garden.username = local;
        }
        else if (typeof google !== 'undefined' && google !== "undefined") {
            garden.username = google;
        }

        garden.save(function (err) {
            if (err) {
                if (err.code === 11000) {
                    req.flash('duplicateMessage', 'That Garden name exists!');
                    res.redirect('/profile');
                }
            }
            else {
                Garden.find({ $or: [{ 'username': req.user.local.email }, { 'username': req.user.google.email }] }, function (err, garden) {
                    res.render('profile.ejs', {
                        user: req.user,
                        gardens: garden,
                        message: req.flash('Nothing')
                    });
                });
            }
        });
    });

    app.get('/profile/:id', isLoggedIn, function (req, res) {

        // get the garden to display
        let gardenO = req.params.id.trim();

        gardenO = gardenO.replace(':', '');

        console.log("***OPENING GARDEN: " + gardenO);

        // make proper call to display the garden


        // render the garden page
        res.redirect('/profile');
    });

    app.post('/profile/:id', isLoggedIn, function (req, res) {


        // get the garden to delete
        let gardenD = req.params.id.trim();

        gardenD = gardenD.replace(':', '');

        console.log("***DELETING GARDEN: " + gardenD);

        // make proper call to delete the garden

        Garden.deleteOne({ gardenName: gardenD }, function (err, garden) {

            if (err) {
                req.flash('duplicateMessage', 'That garden does not exists!');
                res.redirect('/profile');
            }
        });


        // render the account page

        res.redirect('/profile');
    });

    // =====================================
    // ACCOUNT PAGE ========================
    // =====================================
    app.get('/account', isLoggedIn, function (req, res) {
        res.render('account.ejs', {
            user: req.user
        });
    });


    // =====================================
    // GARDEN SECTION ======================
    // =====================================
    app.get('/garden', isLoggedIn, function (req, res) {
        res.render('garden.ejs', {
            user: req.user // get the user out of session and pass to garden.
            /*
                will do the same with gardens once I put it in the database.
                garden: req.garden, or something of the sort.
            */
        });
    });

    /*
        creating a garden
    */
    app.get('/create/garden', isLoggedIn, function (req, res) {
        res.render('gardenCreate.ejs', {
            user: req.user // get the user out of the session and pass to create a garden
            // under this username 
        });
    });

    // =====================================
    // LOGOUT ==============================
    // =====================================
    app.get('/logout', function (req, res) {
        req.logout();
        res.redirect('/');
    });

    // =====================================
    // GOOGLE ROUTES =======================
    // =====================================
    // send to google to do the authentication
    // profile gets us their basic information including their name
    // email gets their emails
    app.get('/auth/google', passport.authenticate('google', { scope: ['profile', 'email'] }));

    // the callback after google has authenticated the user
    app.get('/auth/google/callback',
        passport.authenticate('google', {
            successRedirect: '/account',
            failureRedirect: '/'
        }));

    // =============================================================================
    // AUTHORIZE (ALREADY LOGGED IN / CONNECTING OTHER SOCIAL ACCOUNT) =============
    // =============================================================================

    // locally --------------------------------
    app.get('/connect/local', function (req, res) {
        res.render('connect-local.ejs', { message: req.flash('loginMessage') });
    });
    app.post('/connect/local', passport.authenticate('local-signup', {
        successRedirect: '/account', // redirect to the secure profile section
        failureRedirect: '/connect/local', // redirect back to the signup page if there is an error
        failureFlash: true // allow flash messages
    }));

    // google ---------------------------------

    // send to google to do the authentication
    app.get('/connect/google', passport.authorize('google', { scope: ['profile', 'email'] }));

    // the callback after google has authorized the user
    app.get('/connect/google/callback',
        passport.authorize('google', {
            successRedirect: '/account',
            failureRedirect: '/'
        }));



    // =============================================================================
    // UNLINK ACCOUNTS =============================================================
    // =============================================================================
    // used to unlink accounts. for social accounts, just remove the token
    // for local account, remove email and password
    // user account will stay active in case they want to reconnect in the future

    // local -----------------------------------
    app.get('/unlink/local', function (req, res) {
        var user = req.user;
        user.local.email = undefined;
        user.local.password = undefined;
        user.save(function (err) {
            res.redirect('/account');
        });
    });


    // google ---------------------------------
    app.get('/unlink/google', function (req, res) {
        var user = req.user;
        user.google.token = undefined;
        user.save(function (err) {
            res.redirect('/account');
        });
    });

};

// route middleware to make sure a user is logged in
function isLoggedIn(req, res, next) {

    // if user is authenticated in the session, carry on 
    if (req.isAuthenticated())
        return next();

    // if they aren't redirect them to the home page
    res.redirect('/');
}