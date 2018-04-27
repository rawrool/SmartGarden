var mongoose = require('mongoose');
var Schema = mongoose.Schema;

// creating the schema
var plantSchema = new Schema({
    gardenName: {type: String, required: true, unique: false},
    plantName: {type: String, required: true, unique: true},
    plantSize: String,
    created_at: Date,
    updated_at: Date
});


/*
    on every save we will be adding the date
    we can use the schema pre method to have operations happen before an
    object is saved.
*/
plantSchema.pre('save', function(next){
    var currentDate = new Date();

    this.updated_at = currentDate;

    if(!this.created_at){
        this.created_at = currentDate;
    }

    next();
});

// we need to create a model for the schema so that we can use it
var plant = mongoose.model('plant', plantSchema);

// make this available to our users in our node app
module.exports = plant;