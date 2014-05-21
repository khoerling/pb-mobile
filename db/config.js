require('../node_modules/LiveScript')
module.exports = {
  database: {
    client: 'mysql',
    connection: {
      host     : process.env.ICE_DB_HOST     || '127.0.0.1',
      user     : process.env.ICE_DB_USER     || 'root',
      password : process.env.ICE_DB_PASSWORD || 'vagrant',
      database : process.env.ICE_DB_NAME     || 'db'
    }
  },
  directory: './migrations',
  tableName: 'Migration',
  extension: 'ls'
};
