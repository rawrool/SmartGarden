var mongoose = require('mongoose');
var Schema = mongoose.Schema;

// creating the schema
var defaultWateringSchema = new Schema({
    gardenName: {type: String, required: true, unique: true},
    scheduleName: {type: String, required: true, unique: true},
    Time: {type: Number, required: true, unique: false},
    Duration: {type: Number, required: true, unique: false}
});

var defaultWatering = mongoose.model('defaultWatering', defaultWateringSchema);

module.exports = defaultWatering;