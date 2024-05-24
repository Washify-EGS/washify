const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(bodyParser.json());

// Database connection configuration
const connectionConfig = {
  host: 'mysql_db',
  port: '3306',
  user: 'root',
  password: 'password',
  database: 'WASHIFY',
};

// Function to connect to the database with retry logic
function connectWithRetry() {
  const connection = mysql.createConnection(connectionConfig);

  connection.connect((err) => {
    if (err) {
      console.error('Error connecting to the database:', err);
      console.log('Retrying connection in 5 seconds...');
      setTimeout(connectWithRetry, 5000); // Wait for 5 seconds before retrying
    } else {
      console.log('Connected to the database!');

      // Set up API endpoints after successful connection
      setupApiEndpoints(connection);
    }
  });

  // Handle connection errors after initial connection
  connection.on('error', (err) => {
    console.error('Database connection error:', err);
    if (err.code === 'PROTOCOL_CONNECTION_LOST') {
      connectWithRetry(); // Reconnect on connection lost
    } else {
      throw err;
    }
  });

  return connection;
}

// Function to set up API endpoints
function setupApiEndpoints(connection) {
  // API endpoint to save user information
  app.post('/adduser', (req, res) => {
    const { username, id } = req.body;

    // Check if the user already exists
    const checkUserSql = 'SELECT * FROM users WHERE id = ?';
    connection.query(checkUserSql, [id], (err, result) => {
      if (err) {
        console.error('Error checking user:', err);
        res.status(500).json({ error: 'Error checking user!' });
        return;
      }

      if (result.length > 0) {
        // User already exists
        console.error('User already exists');
        res.status(400).json({ error: 'User already exists!' });
        return;
      }

      // Insert user information into the database
      const insertUserSql = 'INSERT INTO users (username, id) VALUES (?, ?)';
      connection.query(insertUserSql, [username, id], (err, result) => {
        if (err) {
          console.error('Error adding user:', err);
          res.status(500).json({ error: 'Error adding user!' });
          return;
        }
        console.log('User information added:', result);
        res.status(200).json({ message: 'User information added successfully!' });
      });
    });
  });

  // API endpoint to add a booking
  app.post('/addbooking', (req, res) => {
    const { booking_uuid, booking_type, user_id } = req.body;

    // Insert booking information into the database
    const sql = 'INSERT INTO bookings (booking_uuid, booking_type, user_id) VALUES (?, ?, ?)';
    connection.query(sql, [booking_uuid, booking_type, user_id], (err, result) => {
      if (err) {
        console.error('Error adding booking:', err);
        res.status(500).json({ error: 'Error adding booking!' });
        return;
      }
      console.log('Booking added:', result);
      res.status(200).json({ message: 'Booking added successfully!' });
    });
  });

  // API endpoint to get all bookings for a specific user
  app.get('/bookings/:user_id', (req, res) => {
    const { user_id } = req.params;

    // Query the database to get all bookings for the specified user ID
    const sql = 'SELECT * FROM bookings WHERE user_id = ?';
    connection.query(sql, [user_id], (err, results) => {
      if (err) {
        console.error('Error fetching bookings:', err);
        res.status(500).json({ error: 'Error fetching bookings!' });
        return;
      }
      
      // Return the bookings data
      res.status(200).json(results);
    });
  });

  // API endpoint to update payment status
  app.put('/updatepayment/:booking_uuid', (req, res) => {
    const { booking_uuid } = req.params;
    const { payment_status } = req.body;

    // Update payment status in the database
    const sql = 'UPDATE bookings SET payment_status = ? WHERE booking_uuid = ?';
    connection.query(sql, [payment_status, booking_uuid], (err, result) => {
      if (err) {
        console.error('Error updating payment status:', err);
        res.status(500).json({ error: 'Error updating payment status!' });
        return;
      }
      console.log('Payment status updated:', result);
      res.status(200).json({ message: 'Payment status updated successfully!' });
    });
  });

  // Add payment record
  app.post('/addpayment', (req, res) => {
    const { payment_uuid, booking_uuid } = req.body;

    const sql = 'INSERT INTO payments (payment_uuid, booking_uuid) VALUES (?, ?)';
    connection.query(sql, [payment_uuid, booking_uuid], (err, result) => {
      if (err) {
        console.error('Error adding payment:', err);
        res.status(500).json({ error: 'Error adding payment!' });
        return;
      }
      console.log('Payment added:', result);
      res.status(200).json({ message: 'Payment added successfully!' });
    });
  });

}

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

// Attempt to connect to the database with retry logic
connectWithRetry();
