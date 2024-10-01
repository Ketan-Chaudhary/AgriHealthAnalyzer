# AgriHealthAnalyzer
# Crop Disease Detection and Prevention

This project is a Node.js and React-based application that detects crop diseases and provides information about their prevention using the Plant.id API. The application allows users to upload images of crops, which are then analyzed to assess their health.

## Features

- Upload images of crops for health assessment.
- Provides detailed information about detected diseases, including treatments and causes.
- User-friendly interface built with React and Tailwind CSS.
- Uses multer for image upload handling.
- Implements Axios for API calls to the Plant.id health assessment service.

## Technologies Used

- **Backend**: Node.js, Express.js
- **Frontend**: React.js, Tailwind CSS
- **Image Upload**: Multer
- **HTTP Requests**: Axios
- **Environment Variables**: dotenv

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/Ketan-Chaudhary/AgriHealthAnalyzer.git
   ```

2. Navigate to the project directory:

   ```bash
   cd AgriHealthAnalyzer
   ```

3. Install the required packages:

   ```bash
   npm install
   ```

4. Create a `.env` file in the root directory and add your Plant.id API key:

   ```plaintext
   PLANT_ID_API_KEY=your_api_key_here
   ```

5. Start the server:

   ```bash
   node server.js
   ```

   The server will run on `http://localhost:5000`.

## Usage

1. Open your frontend application (if it's separate) in your browser.
2. Navigate to the health assessment feature.
3. Upload an image of a crop to receive a health assessment.

## API Documentation

This project utilizes the [Plant.id API](https://web.plant.id/api-docs/) for health assessment. Ensure you are familiar with their documentation to understand the request and response formats.

## Contributing

Contributions are welcome! If you'd like to contribute to this project, please fork the repository and submit a pull request with your changes.


## Acknowledgments

- [Plant.id](https://web.plant.id/) for providing the health assessment API.
- [Express.js](https://expressjs.com/) for the backend framework.
- [React.js](https://reactjs.org/) for building the frontend.
- [Tailwind CSS](https://tailwindcss.com/) for styling.
```

