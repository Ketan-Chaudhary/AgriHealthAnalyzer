const express = require("express");
const cors = require("cors");
const multer = require("multer");
const axios = require("axios");
const fs = require("fs");
const FormData = require("form-data");
require("dotenv").config();

const app = express();
const PORT = 5000;

// Middleware
app.use(cors());
app.use(express.json());

const upload = multer({ dest: "uploads/" }); //Used for Temporary storage

// Health assessment route
app.post(
  "/api/v3/health_assessment",
  upload.single("images"),
  async (req, res) => {
    const imagePath = req.file.path;

    try {
      // Prepare form data for Plant.ID health assessment API
      const plantIdFormData = new FormData();
      plantIdFormData.append("images", fs.createReadStream(imagePath));

      // Calling Plant.ID Health Assessment API
      const plantIdResponse = await axios.post(
        "https://plant.id/api/v3/health_assessment?details=local_name,description,url,treatment,classification,common_names,cause",
        plantIdFormData,
        {
          headers: {
            ...plantIdFormData.getHeaders(),
            "Api-Key": process.env.PLANT_ID_API_KEY,
          },
        }
      );

      const combinedResponse = {
        healthAssessment: plantIdResponse.data,
      };

      res.status(200).json(combinedResponse);
    } catch (error) {
      console.error("Error with health assessment:", error);
      if (error.response) {
        res
          .status(400)
          .json({ error: "Bad Request", details: error.response.data });
      } else {
        res.status(500).json({ error: "Internal Server Error" });
      }
    } finally {
      // Clean up the uploaded file
      fs.unlink(imagePath, (err) => {
        if (err) console.error("Error deleting file:", err);
      });
    }
  }
);

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
