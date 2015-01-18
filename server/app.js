/**
 * Main application file
 */

'use strict';

// Set default node environment to development
process.env.NODE_ENV = process.env.NODE_ENV || 'development';

var express = require('express');
var io = require('socket.io');
var config = require('./config/environment');
// Setup server
var app = express();
var server = require('http').createServer(app);
require('./config/express')(app);
require('./routes')(app);

io = io.listen(server);
io.on('connection', function(socket){
  console.log('a user connected');
  socket.on('message', function (from, msg) {
    // console.log('recieved message from', from, 'msg', JSON.stringify(msg));
    // console.log('broadcasting message');
    // console.log('payload is', msg);
    io.sockets.emit('broadcast', {
      payload: msg,
      source: from
    });
    // console.log('broadcast complete');
  });
});

// Start server
server.listen(config.port, config.ip, function () {
  console.log('Express server listening on %d, in %s mode', config.port, app.get('env'));
});

// Expose app
exports = module.exports = app;
