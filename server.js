const express = require("express"); // import the application server framework
const { Pool } = require("pg"); // Import the PostgreSQL library

var args = process.argv.slice(2);
const debugOn = args[0] === "--debug";

const app = express();
// get environment variables
const { STAGE: stage, PG_HOST: host, PG_PORT: PG_DOCKER_PORT, APP_PORT: port, DB_USER: user, DB_PASSWORD: password } = process.env;

const pool = new Pool({
  host: process.env.PG_HOST,
  user: process.env.PG_USER,
  password: process.env.PG_PASSWORD,
  port: process.env.PG_DOCKER_PORT,
});

const maximumStartupTime = 120_000; // 2 minutes
const minimumStartupTime = 60_000; // 1 minute
const startupTimeRequired =
  Math.floor(Math.random() * (maximumStartupTime - minimumStartupTime)) + minimumStartupTime;

// Track the application start time
const startTime = Date.now();

app.get("/healthcheck", (req, res) => {
  if(debugOn) {
    console.debug(`Healthcheck called with headers ${JSON.stringify(req.headers)}`);
  }

  // Calculate the time elapsed since the application started (in milliseconds)
  const elapsedTime = Date.now() - startTime;

  if (elapsedTime < startupTimeRequired) {
    // If less than the required startup time has passed, return a 503
    res.status(503).json({
      message: 'Service Unavailable - Application Starting'
    });
  } else {
    // Attempt to access the database
    pool.query("SELECT 1", (error, result) => {
      if (error) {
        // If an error occurs, return a 503
        res.status(503).json({
          message: 'Database Connection Error'
        });
      } else {
        // If the query is successful, return a 200
        res.status(200).json({
          'healthy':true
        });
      }
    });
  }
});

app.listen(port, () => {
  console.log(`Server is running on port ${port} and stage is ${stage}`);
});