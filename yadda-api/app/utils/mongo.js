var mongo = require('mongodb').MongoClient;

var state = {
  db: null,
}

module.exports = {
  connect: function(callback) {
    if (state.db) return callback()

    mongo.connect('mongodb://yaddadb:27017/yaddadb', function(err, db) {
      if (err) return callback(err)
      state.db = db
      callback()
    });
  },
  get: function() {
    return state.db
  },
  close: function(callback) {
    if (state.db) {
      state.db.close(function(err, result) {
        state.db = null
        return callback(err)
      })
    }
    return callback()
  }
}
