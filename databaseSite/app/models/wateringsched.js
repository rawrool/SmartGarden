var mongoose = require('mongoose');
var Schema = mongoose.Schema;

//creating the schema
var wateringSchema = new Schema({
    plantName: {type: String, required: true, unique: true},
    scheduleName: {type: String, required: true, unique: true},
    Time: {type: Number, required: true, unique: false},
    Duration: {type: Number, required: true, unique: false}
});

var wateringSchedule = mongoose.model('wateringSchedule', wateringSchema);

module.exports = wateringSchedule;