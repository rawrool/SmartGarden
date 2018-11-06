module.exports = function (io) {

    // custom io for the settings page.
    var sPage = io.of('/settings');

    // mongoose database needed to make changes to the default schedule
    const userSchema = require('../app/models/userSchema');

    // checking for the connection event.
    sPage.on('connection', function (socket) {
        console.log("connection established in settings page!");

        console.log(socket.id);

        // this will listen to the set schedule event and it will
        // change the default schedule for the garden
        socket.on('set schedule', function (args) {
            // getting the values from the arguments
            var args = args.toString();

            // splitting arguments are sent because it is sent id:id:id:id
            args = args.split(":");

            // assigning individual variables
            var scheduleID = args[0];
            var plantID = args[1];
            var gardenID = args[2];
            var userID = args[3];

            // need to find which garden currently holds the 
            // true value for the default schedule.
            userSchema.findOne({ 'local.email': userID }, function (err, uSchema) {

                // retrieving the garden which the schedule belongs to.
                var resG = uSchema.gardens.find(function (element) {
                    return element._id.toString() === gardenID.toString();
                });

                // if there are results we continue with finding the specific plant to change the
                // schedule for.
                if (resG !== undefined) {

                    // checking to see if there are any plants in the garden specified before we continue.
                    if (!(resG.plants.length < 1)) {

                        // retrieving the plant for which the schedule belongs to.
                        var plantR = resG.plants.find(function (element) {
                            return element._id.toString() === plantID.toString();
                        });

                        // if there are results we continue finding the schedule that is already set, and the 
                        // new default schedule.
                        if (plantR !== undefined) {

                            if (!(plantR.waterSchedules.length < 1)) {

                                // we find the current default watering schedule
                                var schedsR = plantR.waterSchedules.find(function (element) {
                                    return element.default === true;
                                });

                                // we find the schedule that is going to be the new default.
                                var dSched = plantR.waterSchedules.find(function (element) {
                                    return element._id.toString() === scheduleID.toString();
                                });

                                // if there are no default watering schedule
                                // then we just set the new default watering schedule.
                                if (schedsR === undefined) {

                                    // set the new default watering schedule.
                                    if (dSched !== undefined) {
                                        dSched.default = true;
                                    }
                                }
                                else {
                                    // if a default watering schedule is already set
                                    // then we set its default value to false.
                                    // set the value to false..
                                    schedsR.default = false;

                                    // set the new default watering schedule.
                                    if (dSched !== undefined) {
                                        dSched.default = true;
                                    }
                                }

                                // saving this to the database.
                                uSchema.save(function (err) {
                                    if (err) {
                                        console.log(err);
                                    }
                                });
                            }
                        }
                    }
                }
            });

            // sending the changes to all other sockets
            socket.broadcast.emit('default_changed', scheduleID);
        });

    });
}