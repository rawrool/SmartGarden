var mongoose = require('mongoose');
var Schema = mongoose.Schema;

// creating the schema
var gardenSchema = new Schema({
    gardenName: {type: String, required: true, unique: true},
    username: {type: String, required: true, unique: false}, 
    created_at: Date,
    updated_at: Date
});


/*
    on every save we will be adding the date
    we can use the schema pre method to have operations happen before an
    object is saved.
*/
gardenSchema.pre('save', function(next){
    var currentDate = new Date();

    this.updated_at = currentDate;

    if(!this.created_at){
        this.created_at = currentDate;
    }

    next();
});

// we need to create a model for the schema so that we can use it
var Garden = mongoose.model('Garden', gardenSchema);

// make this available to our users in our node app
module.exports = Garden;