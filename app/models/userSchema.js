/*
    My database has been updated so that it performs better when we
    need to query.

    this is the embedded document approach (denormalization)

    we embed a doc inside another doc. 

    with this approach, we need to query a lot and we need the queries to run
    as fast as possible.
*/

let mongoose = require('mongoose');

let bcrypt = require('bcrypt-nodejs');

let Logs = {
    created_at: Date,
    waterUsed: String,
    moisture: Number,
    humidity: Number,
    temperature: Number,
    updated_at: Date
}

let Plants = {
    name: { type: String, required: false, sparse: true },
    plantSize: String,
    created_at: Date,
    updated_at: Date,
    logs: [Logs]
}

let Gardens = {
    name: String,
    created_at: Date,
    updated_at: Date,
    plants: { type: [Plants], required: false, sparse: true }
}

// define the schema for our database
let userSchema = mongoose.Schema({

    local: {
        email: String,
        password: String,
        token: String
    },
    google: {
        id: String,
        token: String,
        email: String,
        name: String
    },
    gardens: [Gardens]
});


//generating a hash
userSchema.methods.generateHash = function (password) {
    return bcrypt.hashSync(password, bcrypt.genSaltSync(8), null);
};

// checking if password is valid
userSchema.methods.validPassword = function (password) {
    return bcrypt.compareSync(password, this.local.password);
}

// create the model for the users gardens with plants and logs.
module.exports = mongoose.model('database', userSchema);