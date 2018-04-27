var mongoose = require('mongoose');
var Schema = mongoose.Schema;

// creating the schema
var logSchema = new Schema({
    plantName: {type: String, required: true, unique: false},
    date: {type: Date, required: true, unique: true},
    waterUsed: String,
    moisture: Number,
    humidity: Number,
    temperature: Number
});


/*
    can make methods here
*/


// we need to create a model for the schema so that we can use it
var Logs = mongoose.model('Logs', logSchema);

module.exports = Logs;