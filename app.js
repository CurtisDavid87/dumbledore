const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.urlencoded({ extended: true }));

// MongoDB connection string (update with your MongoDB instance details)
const mongoUri = 'mongodb://admin:abc123@mongodb-master:27017/wizapp?authSource=admin';
mongoose.connect(mongoUri, { useNewUrlParser: true, useUnifiedTopology: true });

// Define a simple schema and model for the signup form
const signupSchema = new mongoose.Schema({
    firstName: String,
    lastName: String,
    dob: Date,
    email: String
});
const Signup = mongoose.model('Signup', signupSchema);

// Serve the signup form
app.get('/', (req, res) => {
    res.send(`
        <h1>Sign Up for a $10 Wiz Gift Card</h1>
        <form action="/submit" method="post">
            <label for="firstName">First Name:</label><br>
            <input type="text" id="firstName" name="firstName"><br>
            <label for="lastName">Last Name:</label><br>
            <input type="text" id="lastName" name="lastName"><br>
            <label for="dob">Date of Birth:</label><br>
            <input type="date" id="dob" name="dob"><br>
            <label for="email">Email Address:</label><br>
            <input type="email" id="email" name="email"><br>
            <input type="submit" value="Sign Up">
        </form>
    `);
});

// Handle form submission
app.post('/submit', async (req, res) => {
    try {
        const signupData = new Signup(req.body);
        await signupData.save();
        res.status(201).send('Thank you for signing up!');
    } catch (error) {
        res.status(500).send('Failed to submit your information.');
    }
});

// Start the server
const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});

